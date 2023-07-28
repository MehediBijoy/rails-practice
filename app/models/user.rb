class User < ApplicationRecord
  include Searchable

  has_one :user_detail

  accepts_nested_attributes_for :user_detail, update_only: true
end
