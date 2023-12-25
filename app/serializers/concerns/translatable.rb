module Translatable
  extend ActiveSupport::Concern

  class_methods do
    def translate_fields(*fields)
      puts "\n\ncalled-translate\n\n", fields
    end
  end
end
