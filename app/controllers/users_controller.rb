class UsersController < ApplicationController
  PAGE_SIZE = 20

  def index
    @users = User.page(params[:page]).per(PAGE_SIZE)
  end

  def show
    @user = User.find(params[:id])
  end
end
