class HomeController < ApplicationController
  before_action :require_user, only: [:mentions]

  MESSAGE_PAGE_SIZE = 30

  def index
    if user_signed_in?
      @user    = current_user
      @message = @user.messages.build
      @feeds   = @user.timeline.page(params[:page]).per(MESSAGE_PAGE_SIZE)
    end
  end

  def about
  end

  def notifications
  end

  def mentions
    @user  = current_user
    @feeds = @user.mentions(filter: params[:filter]).page(params[:page]).per(MESSAGE_PAGE_SIZE)
  end
end
