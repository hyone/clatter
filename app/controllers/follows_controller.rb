class FollowsController < ApplicationController
  before_action :require_user

  # load_and_authorize_resource through: :current_user, through_association: :follow_relationships
  load_and_authorize_resource

  respond_to :json

  def create
    @follow.save!
    @status = :success
  end

  def destroy
    @follow.destroy!
    @status = :success
  end

  def follow_params
    params.require(:follow).permit(:followed_id)
  end
end
