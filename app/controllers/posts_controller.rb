class PostsController < ApplicationController
  before_action :require_user, only: [:create, :destroy]

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      # flash[:success] = I18n.t('views.posts.success')
      redirect_to root_url
    else
      @user  = current_user
      @feeds = @user.posts.page(params[:page]).per(HomeController::POST_PAGE_SIZE)
      render 'home/index'
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    redirect_to root_url
  end


  private
  def post_params
    params.require(:post).permit(:text)
  end
end
