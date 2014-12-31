class UsersController < ApplicationController
  layout 'user', only: [:followers, :following, :show]

  USER_PAGE_SIZE = 20
  MESSAGE_PAGE_SIZE = 30

  def index
    @users = User.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def show
    @user = User.find(params[:id])
    @messages = @user.messages
                  .without_replies.newer
                  .page(params[:page]).per(MESSAGE_PAGE_SIZE)
  end

  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def following
    @user = User.find(params[:id])
    @followed_users = @user.followed_users.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def with_replies
    @user = User.find(params[:id])
    @messages = @user.messages.latest_order.page(params[:page]).per(MESSAGE_PAGE_SIZE)
    render 'show'
  end
end
