module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(q, included_fields: nil, excluded_fields: nil)

      if included_fields.present? && excluded_fields.present?
        raise ArgumentError, "Can't set both 'excluded_fields' and 'included_fields' in search."
      end

      unless included_fields.present? || excluded_fields.present?
        raise ArgumentError, "Must provide either 'excluded_fields' or 'included_fields' in search."
      end

      params = build_query_params(included_fields, excluded_fields)
      query = "%#{sanitize_sql_like(q)}%"

      return all if params.empty?
      where(build_search_conditions(params), {query:})
    end

    private

    def build_query_params(included_fields, excluded_fields)
      if excluded_fields.present?
        column_names - Array(excluded_fields).map(&:to_s)
      else
        included_fields.flat_map { |field| extract_params(field) }
      end
    end

    def extract_params(field)
      if field.is_a?(Hash)
        associated_name, associated_fields = field.first
        associated_table = associated_reflections(associated_name.to_s)

        associated_fields.map do |associated_field|
          if associated_table.column_names.include?(associated_field.to_s)
            "#{associated_table.name}.#{associated_field}"
          else
            raise ArgumentError, "'#{associated_table.klass}' model does not have '#{associated_field}' field"
          end
        end
      else
        if column_names.include?(field.to_s)
          "#{name.downcase.pluralize}.#{field.to_s}"
        else
          raise ArgumentError, "#{name} model does not have '#{field}' field"
        end
      end
    end

    def associated_reflections(reference_name)
      associated_klass = reflections[reference_name.singularize] || reflections[reference_name.pluralize]
      if associated_klass.present?
        OpenStruct.new({
          name: associated_klass.plural_name,
          klass: associated_klass.klass,
          column_names: associated_klass.klass.column_names,
        })
      else
        raise ArgumentError, "'#{reference_name}' reference model not associated with '#{name}' model"
      end
    end

    def build_search_conditions(fields)
      fields.map { |item| "#{item} LIKE :query" }.join(' OR ')
    end
  end
end