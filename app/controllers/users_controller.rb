class UsersController < ApplicationController
  def index
    render json: User.first(10)
  end
end
