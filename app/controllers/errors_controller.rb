class ErrorsController < ActionController::Base
  include ActionsHelper

  layout 'application'

  rescue_from StandardError, with: :internet_server_error

  # bad request
  rescue_from ActionController::ParameterMissing, with: :bad_request

  # unauthorized
  rescue_from CanCan::AccessDenied, with: :unauthorized

  # not found
  rescue_from ActiveRecord::RecordNotFound,   with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found


  def error
    raise env['action_dispatch.exception']
  end


  def bad_request(exception = nil)
    message = exception.try(:message) || t("views.errors.bad_request.title")
    respond_error_to 'bad_request', 400, [message]
  end

  def unauthorized(exception = nil)
    message = exception.try(:message) || t("views.errors.unauthorized.title")
    respond_error_to 'unauthorized', 401, [message]
  end

  def not_found(exception = nil)
    respond_error_to 'not_found', 404, ['404 not found']
  end

  def internet_server_error(exception = nil)
    logger.info "Rendering 500 with exception: #{exception.message}" if exception
    # Airbrake.notify(e) if e

    respond_error_to 'internet_server_error', 500, [exception.message, exception.class.name]
  end


  private

  def respond_error_to(action, status, message)
    respond_to do |format|
      format.json {
        render 'shared/_response',
               locals: { status: :error, messages: [message] },
               status: status
      }
      format.html {
        render "errors/#{action}", locals: { message: message }, status: status
      }
    end
  end
end
