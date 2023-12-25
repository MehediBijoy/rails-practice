class UserSerializer < ActiveModel::Serializer
  include Translatable

  translate_fields :name, :age

  attributes :id, :email
end
