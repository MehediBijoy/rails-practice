class Author < ApplicationRecord
  has_many :books
  has_one :city

  def set_city
    if send("city").nil?
      send("create_city!")
    else
      send("city").update(updated_at: Time.now)
    end
  end
end
