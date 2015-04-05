class MessagesController < ApplicationController
  before_action :require_user

  load_and_authorize_resource

  respond_to :json

  def create
    @message.save!
    @status = :success
  end

  def destroy
    @message.destroy!
    @status = :success
  end

  private

  def message_params
    params.require(:message).permit(:text, :message_id_replied_to)
  end
end
