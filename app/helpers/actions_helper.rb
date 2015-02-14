module ActionsHelper
  def require_user
    unless user_signed_in?
      respond_to do |format|
        format.html {
          redirect_to new_user_session_path, notice: t('views.generic.please_sign_in')
        }
        format.json {
          head :unauthorized
        }
      end
    end
  end

  def require_message_owner
    message = Message.find_by(id: params[:id])
    unless current_user and
           message and
           message.user == current_user
      respond_to do |format|
        format.html {
          redirect_to new_user_session_path, notice: t('views.generic.not_message_owner')
        }
        format.json {
          head :unauthorized
        }
      end
    end
  end

  def require_favorite_owner
    favorite = Favorite.find_by(id: params[:id])
    unless current_user and
           favorite and
           favorite.user == current_user
      respond_to do |format|
        format.html {
          redirect_to new_user_session_path, notice: t('views.generic.not_favorite_owner')
        }
        format.json {
          head :unauthorized
        }
      end
    end
  end
end
