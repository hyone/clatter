class HomeController < ApplicationController
  before_action :require_user, only: [:mentions]

  MESSAGE_PAGE_SIZE = 30

  def index
    if user_signed_in?
      @user    = current_user
      @message = @user.messages.build
      @page    = params[:page] || 1
      @feeds   = @user
                   .timeline
                   .preload_for_views
                   .page(@page).per(MESSAGE_PAGE_SIZE)
    end
  end

  def about
  end

  def notifications
  end

  def mentions
    @user  = current_user
    @page  = params[:page] || 1
    @feeds = @user
               .mentions(filter: params[:filter])
               .preload_for_views
               .page(@page).per(MESSAGE_PAGE_SIZE)
  end

  def search
    @page = params[:page] || 1

    @feeds = case @search[:mode]
             when 'users'
               @q.result
                 .page(@page)
                 .per(MESSAGE_PAGE_SIZE)
             else
               @q.result
                 .preload_for_views
                 .page(@page)
                 .per(MESSAGE_PAGE_SIZE)
             end
  end


  concerning :Searchable do
    included do
      before_action :init_search, only: [:search]

      def init_search
        p = search_params

        @search = { params: p }
        @search[:text]  = p.fetch(:text, "")
        @search[:mode]  = case p[:mode]
                          when 'users' then p[:mode]
                          else 'messages'
                          end
        @search[:range] = case
                          when current_user && p[:range] == 'followed_users' then p[:range]
                          else 'all'
                          end

        @q = case @search[:mode]
             when 'users' then create_users_search
             else              create_messages_search
             end
      end

      private
      def create_messages_search
        @search[:params][:text_cont_all] = @search[:text].split

        case @search[:range]
        when 'followed_users'
          Message
            .from_self_and_followed_users(current_user)
            .search(@search[:params])
        else
          Message.search(@search[:params])
        end
      end

      def create_users_search
        @search[:params][:screen_name_or_name_or_description_cont_all] = @search[:text].split

        case @search[:range]
        when 'followed_users'
          User
            .self_and_followed_users_of(current_user)
            .search(@search[:params])
        else
          User.search(@search[:params])
        end
      end

      def search_params
        params.require(:q).permit(:text, :mode, :range)
      rescue
        {}
      end
    end
  end
end
