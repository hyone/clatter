require 'rails_helper'


describe 'Home Page' do
  subject { page }

  describe 'GET /' do
    before { visit root_path }

    it { should have_title(page_title) }

    context 'as guest' do
      it { should have_content(I18n.t('views.home.welcome_message')) }
      it { should have_content(I18n.t('views.home.signup_now')) }
    end

    context 'as user' do
      let (:user) { FactoryGirl.create(:user) }
      before {
        signin user
      }

      context 'in profile block' do
        before {
          3.times { FactoryGirl.create(:post, user: user) }
          visit current_path
        }

        it { should have_link(user.name, href: user_path(user)) }
        it { should have_link(user.screen_name, href: user_path(user)) }

        # posts
        it { should have_link(I18n.t('views.users.show.navigation.posts'), href: user_path(user)) }
        it 'should display posts count' do
          expect(page).to have_selector '.user-profile-posts-count', user.posts.count
        end

        # # followers
        # it 'should display followers count' do
          # expect(page).to have_selector '#user-profile-followers', user.followers.count
        # end

        # # following
        # it 'should display following count' do
          # expect(page).to have_selector '#user-profile-following', user.following.count
        # end
      end

      context 'in feed block' do
        context 'in pagination' do
          before {
            (UsersController::POST_PAGE_SIZE + 1).times {
              FactoryGirl.create(:post, user: user)
            }
            visit current_path
          }

          it { should have_selector('ul.pagination') }

          it 'should list each feed in page 1' do
            User.page(1).per(UsersController::POST_PAGE_SIZE).each do |user|
              expect(page).to have_selector('li', text: user.screen_name)
            end
          end
        end

        # context 'in post form' do
        # end
      end


    end
  end

  describe 'GET /home/about' do
    before { visit home_about_path }

    it { should have_title(page_title('About')) }
    it { should have_content('Home#about') }
  end
end
