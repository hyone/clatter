class FollowsController < ApplicationController
  before_action :require_user, only: [:create, :destroy]

  respond_to :html, :json

  def create
    @followed = User.find(params[:follow][:followed_id])
    @follower = current_user

    @follow = @follower.follow!(@followed)

    respond_with @follower
  end

  def destroy
    @follow   = Follow.find(params[:id])
    @follower = current_user
    @followed = @follow.followed

    @follower.unfollow!(@followed)

    respond_with @follower
  end
end
