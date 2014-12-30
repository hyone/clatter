class UsersController < ApplicationController
  USER_PAGE_SIZE = 20
  MESSAGE_PAGE_SIZE = 50

  def index
    @users = User.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def show
    @user = User.find(params[:id])
    @messages = @user.messages.latest_order_without_replies
               .page(params[:page]).per(MESSAGE_PAGE_SIZE)
  end

  def with_replies
    @user = User.find(params[:id])
    @messages = @user.messages.latest_order.page(params[:page]).per(MESSAGE_PAGE_SIZE)
    render 'show'
  end
end
