module ActionsHelper
  def require_user
    unless user_signed_in?
      session[:return_to] = request.original_url
      message = t('views.alert.please_sign_in')
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
          redirect_to new_user_session_path, notice: message
        }
      end
    end
  end
end
