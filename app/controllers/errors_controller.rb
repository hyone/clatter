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
    message = exception.try(:message) || t('views.errors.bad_request.title')
    respond_to do |format|
      format.json {
        render 'shared/_response',
                locals: { status: :error, messages: [message] },
                status: 400
      }
      format.html {
        render 'errors/bad_request', locals: { message: message }, status: 400
      }
    end
  end

  def unauthorized(exception = nil)
    message = exception.try(:message) || t('views.errors.unauthorized.title')
    respond_to do |format|
      format.json {
        render 'shared/_response',
                locals: {
                  status: :error,
                  messages: [message]
                },
                status: 401
      }
      format.html {
        render 'errors/unauthorized', locals: { message: message }, status: 401
      }
    end
  end

  def not_found(exception = nil)
    respond_to do |format|
      format.json {
        render 'shared/_response',
                locals: { status: :error, messages: ['404 not found'] },
                status: 404
      }
      format.html {
        render 'errors/not_found', status: 404
      }
    end
  end

  def internet_server_error(exception = nil)
    logger.info "Rendering 500 with exception: #{exception.message}" if exception
    # Airbrake.notify(e) if e

    respond_to do |format|
      format.json {
        render 'shared/_response',
                locals: { status: :error, messages: [exception.message, exception.class.name] },
                status: 500
      }
      format.html {
        render 'errors/internet_server_error',
               status: 500,
               locals: {
                 description: exception.message
               }
      }
    end
  end
end
