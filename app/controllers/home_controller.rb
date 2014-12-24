class HomeController < ApplicationController
  POST_PAGE_SIZE = 50

  def index
    if user_signed_in?
      @user  = current_user
      @post  = current_user.posts.build
      @feeds = @user.posts.page(params[:page]).per(POST_PAGE_SIZE)
    end
  end

  def about
  end
end
