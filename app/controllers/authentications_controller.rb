class AuthenticationsController < ApplicationController
  def index
    @authentications = current_user.try(:authentications) || []
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    if @authentication
      @authentication.destroy
      flash[:notice] = 'Successfully remove authentication'
    end

    redirect_to user_path(current_user)
  end
end
