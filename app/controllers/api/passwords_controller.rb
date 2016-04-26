class API::PasswordsController < Devise::PasswordsController
  respond_to :json, only: :create
  def create
    super
  end   
end
