Rails.application.config.exceptions_app = lambda { |env|
  ErrorsController.action(:error).call(env)
}
