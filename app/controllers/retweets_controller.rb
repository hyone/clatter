class RetweetsController < ApplicationController
  before_action :require_user

  load_and_authorize_resource

  respond_to :json

  def create
    @retweet.save!
    @status = :success
  end

  def destroy
    @retweet.destroy!
    @status = :success
  end


  private
  def retweet_params
    params.require(:retweet).permit(:message_id)
  end
end
