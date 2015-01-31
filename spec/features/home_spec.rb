require 'rails_helper'


describe 'Home Page', type: :feature do
  subject { page }

  describe 'GET /' do
    before { visit root_path }

    it { should have_title(page_title) }

    context 'as guest' do
      it { should have_content(I18n.t('views.home.index.welcome_message')) }
      it { should have_link(I18n.t('views.home.index.signup_now'), new_user_registration_path) }
    end

    context 'as user' do
      let (:user) { FactoryGirl.create(:user) }
      before {
        signin user
        visit current_path
      }

      context 'in profile panel' do
        before {
          3.times { FactoryGirl.create(:message, user: user) }
          4.times { FactoryGirl.create(:follow, follower: user) }
          5.times { FactoryGirl.create(:follow, followed: user) }
          visit current_path
        }

        it { should have_link(user.name, href: user_path(user)) }
        it { should have_link(user.screen_name, href: user_path(user)) }

        # messages
        it "should have messages link with its count" do
          expect(page).to have_link(
            I18n.t('views.users.show.navigation.messages'),
            href: user_path(user)
          )
          expect(page).to have_selector '.home-profile-messages-count', user.messages.count
        end

        # following
        it "should have following link with its count" do
          expect(page).to have_link(
            I18n.t('views.users.show.navigation.following'),
            href: following_user_path(user)
          )
          expect(page).to have_selector '.home-profile-following', user.followed_users.count
        end

        # followers
        it "should have followers link with its count" do
          expect(page).to have_link(
            I18n.t('views.users.show.navigation.followers'),
            href: followers_user_path(user)
          )
          expect(page).to have_selector '.home-profile-followers', user.followers.count
        end
      end

      context 'in feed panel' do
        context 'in pagination' do
          before {
            (UsersController::MESSAGE_PAGE_SIZE + 1).times {
              FactoryGirl.create(:message, user: user)
            }
            visit current_path
          }

          it { should have_selector('ul.pagination') }

          it 'should list each feed in page 1', js: true do
            User.page(1).per(UsersController::MESSAGE_PAGE_SIZE).each do |user|
              expect(page).to have_selector('li', text: user.screen_name)
            end
          end
        end
      end

    end
  end


  describe 'GET /home/about' do
    before { visit home_about_path }

    it { should have_title(page_title('About')) }
    it { should have_content('Home#about') }
  end


  describe 'GET /home/mentions' do
    before { visit home_mentions_path }

    context 'as guest' do
      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end

    context 'as user' do
      let (:user) { FactoryGirl.create(:user) }
      before { 
        signin user
        visit home_mentions_path
      }

      its(:status_code) { should == 200 }

      describe 'content' do
        let! (:followed_user) {
          u = FactoryGirl.create(:user)
          FactoryGirl.create(:follow, follower: user, followed: u)
          u
        }
        let! (:reply_from_followed_user) { FactoryGirl.create(
          :message_with_reply,
          user: followed_user,
          users_replied_to: [user]
        ) }
        let! (:reply_from_other) { FactoryGirl.create(
          :message_with_reply,
          users_replied_to: [user]
        ) }

        it { should have_link(I18n.t('views.menu_panel.mentions'), home_mentions_path) }

        context 'when "filter" parameter is none' do
          before { visit current_path }

          it { should have_link(
            I18n.t('views.home.mentions.people_you_follow'),
            home_mentions_path(filter: 'following')
          ) }

          it 'should have all replies', js: true do
            expect(page).to have_selector("#message-#{reply_from_followed_user.id}")
            expect(page).to have_selector("#message-#{reply_from_other.id}")
          end
        end

        context 'when "filter" parameter is "following"' do
          before { visit home_mentions_path(filter: 'following') }

          it { should have_link(I18n.t('views.home.mentions.all'), home_mentions_path) }

          it 'should have replies from followed users', js: true do
            expect(page).to have_selector("#message-#{reply_from_followed_user.id}")
            expect(page).not_to have_selector("#message-#{reply_from_other.id}")
          end
        end
      end
    end
  end
end
