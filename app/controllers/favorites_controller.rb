class FavoritesController < ApplicationController
  before_action :require_user

  # load_and_authorize_resource through: :current_user, through_association: :favorite_relationships
  load_and_authorize_resource

  respond_to :json

  def create
    @favorite.save!
    @status = :success
  end

  def destroy
    @favorite.destroy!
    @status = :success
  end

  private

  def favorite_params
    params.require(:favorite).permit(:message_id)
  end
end
