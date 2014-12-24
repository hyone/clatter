class UsersController < ApplicationController
  USER_PAGE_SIZE = 20
  POST_PAGE_SIZE = 50

  def index
    @users = User.page(params[:page]).per(USER_PAGE_SIZE)
  end

  def show
    @user  = User.find(params[:id])
    @posts = @user.posts.latest_order_without_replies
               .page(params[:page]).per(POST_PAGE_SIZE)
  end

  def with_replies
    @user = User.find(params[:id])
    @posts = @user.posts.latest_order.page(params[:page]).per(POST_PAGE_SIZE)
    render 'show'
  end
end
