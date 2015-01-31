class MessagesController < ApplicationController
  before_action :require_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  load_and_authorize_resource

  respond_to :json

  def create
    @message = current_user.messages.build(message_params)
    if @message.save
      @status = :success
    else
      @status = :error
      @response_messages = @message.error.full_messages
    end
  end

  def destroy
    if @message.destroy
      @status = :success
      @response_message = [I18n.t('views.alert.success_delete_message')]
    else
      @status = :error
      @response_message = I18n.t('views.alert.failed_delete_message')
      @response_details = @message.errors.full_messages
    end
  end


  private
  def message_params
    params.require(:message).permit(:text)
  end
end
