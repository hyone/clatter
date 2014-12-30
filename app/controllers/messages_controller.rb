class MessagesController < ApplicationController
  before_action :require_user, only: [:create, :destroy]

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
    @message = Message.find(params[:id])
    @message.destroy

    redirect_to root_url
  end


  private
  def message_params
    params.require(:message).permit(:text)
  end
end
