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
        self_fields = column_names.map { extract_params(_1) }
        excluded_fields = excluded_fields.flat_map { extract_params(_1, excluded: true) }
        (self_fields - excluded_fields) + (excluded_fields - self_fields)
      else
        included_fields.flat_map { extract_params(_1) }
      end
    end

    def extract_params(field, excluded: false)
      if field.is_a?(Hash)
        associated_name, associated_fields = field.first
        associated_table = associated_reflections(associated_name.to_s)
        associated_fields = associated_table.column_names.map(&:to_sym) - associated_fields if excluded
        associated_fields.map { build_field(associated_table, _1) }
      else
        build_field(self, field)
      end
    end

    def build_field(klass, field)
      if klass.column_names.include?(field.to_s)
        "#{klass.name.underscore.pluralize}.#{field}"
      else
        raise ArgumentError, "#{klass.name} model does not have '#{field}' field"
      end
    end

    def associated_reflections(reference_name)
      associated_klass = reflections[reference_name.singularize] || reflections[reference_name.pluralize]
      if associated_klass.present?
        OpenStruct.new({
          name: associated_klass.klass.name,
          column_names: associated_klass.klass.column_names,
        })
      else
        raise ArgumentError, "'#{reference_name}' reference model not associated with '#{name}' model"
      end
    end

    def build_search_conditions(fields)
      fields.map { "#{_1} LIKE :query" }.join(' OR ')
    end
  end
end
