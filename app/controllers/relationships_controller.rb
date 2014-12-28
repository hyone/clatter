class RelationshipsController < ApplicationController
  before_action :require_user, only: [:create, :destroy]

  respond_to :html, :json

  def create
    @followed_user = User.find(params[:relationship][:followed_id])
    @follower = current_user

    @follower.follow!(@followed_user)

    @html = render_to_string partial: 'shared/follow_or_unfollow_button',
                             formats: :html,
                             locals: { user: @followed_user }

    respond_with @follower
  end

  def destroy
    @relationship  = Relationship.find(params[:id])
    @follower      = current_user
    @followed_user = @relationship.followed

    @follower.unfollow!(@followed_user)

    @html = render_to_string partial: 'shared/follow_or_unfollow_button',
                             formats: :html,
                             locals: { user: @followed_user }

    respond_with @follower
  end
end
