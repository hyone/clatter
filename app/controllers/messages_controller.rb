class MessagesController < ApplicationController
  before_action :require_user, only: [:create, :destroy]

  load_and_authorize_resource

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      # flash[:success] = I18n.t('views.messages.success')
      redirect_to root_url
    else
      @user  = current_user
      @feeds = @user.messages.page(params[:page]).per(HomeController::MESSAGE_PAGE_SIZE)
      render 'home/index'
    end
  end

  def destroy
    if @message.destroy
       flash[:success] = I18n.t('views.alert.success_delete_message')
    end
    redirect_to root_url
  end


  private
  def message_params
    params.require(:message).permit(:text)
  end
end
