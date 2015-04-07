class ApplicationController < ActionController::Base
  include ActionsHelper
  include ApplicationController::Authenticatable
  include ApplicationController::Localizable

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
