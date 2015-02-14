Rails.application.config.exceptions_app = ->(env) {
  ErrorsController.action(:error).call(env)
}
