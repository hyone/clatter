class HomeController < ApplicationController
  MESSAGE_PAGE_SIZE = 50

  def index
    if user_signed_in?
      @user    = current_user
      @message = current_user.messages.build
      @feeds   = @user.messages.page(params[:page]).per(MESSAGE_PAGE_SIZE)
    end
  end

  def about
  end
end
