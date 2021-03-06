class UsersController < ApplicationController
  include MessagesHelper

  layout 'user', except: [:index, :status]

  before_action :set_user, except: [:index]
  before_action :require_user, only: [:followers, :following, :favorites]

  USER_PAGE_SIZE    = 24
  MESSAGE_PAGE_SIZE = 30

  def index
    @users = User.newer.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def show
    @page = params[:page] || 1
    @messages = Message.with_retweets_without_replies_of(@user)
                .includes(*preload_fields)
                .page(@page)
                .per(MESSAGE_PAGE_SIZE)
  end

  def favorites
    @page = params[:page] || 1
    @messages = @user
                .favorites
                .includes(*preload_fields)
                .newer
                .page(@page)
                .per(MESSAGE_PAGE_SIZE)
  end

  def followers
    @followers = @user.followers_newer
                 .page(params[:page])
                 .per(USER_PAGE_SIZE)
  end

  def following
    @followed_users = @user.followed_users_newer
                      .page(params[:page])
                      .per(USER_PAGE_SIZE)
  end

  def with_replies
    @messages = Message
                .with_retweets_of(@user)
                .includes(*preload_fields)
                .page(@page)
                .per(MESSAGE_PAGE_SIZE)
    render 'show'
  end

  def status
    @message = @user.messages.find(params[:message_id])
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end
end
