class UsersController < ApplicationController
  layout 'user', except: [:index]

  before_action :set_user, except: [:index]

  USER_PAGE_SIZE = 20
  MESSAGE_PAGE_SIZE = 30

  def index
    @users = User.newer.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def show
    @page = params[:page] || 1
    @messages = @user.messages_without_replies
                  .newer
                  .page(@page)
                  .per(MESSAGE_PAGE_SIZE)
  end

  def favorites
    @page = params[:page] || 1
    @messages = @user.favorites
                  .newer
                  .page(@page)
                  .per(MESSAGE_PAGE_SIZE)
  end

  def followers
    @followers = @user.followers.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def following
    @followed_users = @user.followed_users.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def with_replies
    @messages = @user.messages.newer.page(params[:page]).per(MESSAGE_PAGE_SIZE)
    render 'show'
  end

  private
  def set_user
    @user = User.friendly.find(params[:id])
  end
end
