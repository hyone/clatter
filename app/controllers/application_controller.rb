
# Hack to get the current template name from the layout file (controller)
# see: http://stackoverflow.com/questions/4973699/rails-3-find-current-view-while-in-the-layout

class ActionController::Base
  attr_accessor :active_template

  def active_template_virtual_path
    self.active_template.virtual_path if self.active_template
  end
end

class ActionView::TemplateRenderer
  alias_method :_render_template_original, :render_template

  def render_template(template, layout_name = nil, locals = {})
    if @view.controller && @view.controller.respond_to?('active_template=')
      @view.controller.active_template = template 
    end
    result = _render_template_original( template, layout_name, locals)
    if @view.controller && @view.controller.respond_to?('active_template=')
      @view.controller.active_template = nil
    end
    return result

  end
end


class ApplicationController < ActionController::Base
  include ActionsHelper

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(
        :screen_name, :email, :name, :description, :url,
        :password, :password_confirmation, :remeber_me,
        :profile_image, :profile_image_cache, :remove_profile_image
      )
    }
    devise_parameter_sanitizer.for(:sign_in) { |u|
      u.permit(:login, :screen_name, :email, :password, :remeber_me)
    }
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(
        :screen_name, :email, :name, :description, :url,
        :password, :password_confirmation, :current_password,
        :profile_image, :profile_image_cache, :remove_profile_image
      )
    }
  end
end
