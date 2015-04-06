module ActionsHelper
  def require_user
    return if user_signed_in?

    session[:return_to] = request.original_url
    message = t('views.alert.please_sign_in')
    respond_to do |format|
      format.json do
        render 'shared/_response',
               locals: {
                 status: :error,
                 messages: [message]
               },
               status: 401
      end
      format.html do
        redirect_to new_user_session_path, notice: message
      end
    end
  end
end
