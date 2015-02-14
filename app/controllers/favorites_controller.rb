class FavoritesController < ApplicationController
  before_action :require_user,           only: [:create, :destroy]
  before_action :require_favorite_owner, only: [:destroy]

  respond_to :json

  def create
    @user     = current_user
    @favorite = @user.favorite_relationships.build(favorites_params)
    if @favorite.save
      @status  = :success
      @message = @favorite.message
    else
      @status = :error
      @response_messages = @favorite.errors.full_messages
    end
  end

  def destroy
    @user     = current_user
    @favorite = Favorite.find(params[:id])
    if @favorite.destroy
      @status = :success
      @message = @favorite.message
    else
      @status = :error
      @response_messages = @message.error.full_messages
    end
  end


  private
  def favorites_params
    params.require(:favorite).permit(:message_id)
  end
end
