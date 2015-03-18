require 'rails_helper'


describe 'Users pages', type: :feature do
  subject { page }

  describe 'GET /u' do
    before(:all) {
      50.times { FactoryGirl.create(:user) }
    }
    after(:all) {
      User.delete_all
    }

    before {
      visit users_path
    }

    describe 'content' do
      it { should have_title(I18n.t('views.users.index.title')) }

      context 'in pagination' do
        it { should have_selector('ul.pagination') }

        it 'should list each user in page 1', js: true do
          User.newer.page(1).per(UsersController::USER_PAGE_SIZE).each do |user|
            expect(page).to have_selector('li', text: "@#{user.screen_name}")
          end
        end
      end
    end
  end


  describe 'GET /u/:screen_name' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    describe 'url' do
      before { visit current_path }
      it "should have screen_name in user's page url" do
        expect(user_path(user)).to include(user.screen_name)
      end
    end

    describe 'content' do
      context 'in header', js: true do
        before {
          FactoryGirl.create_list(:message, 10, user: user) 
          FactoryGirl.create_list(:follow, 4, follower: user)
          FactoryGirl.create_list(:follow, 5, followed: user)
          visit current_path
        }

        # messages
        it "should have messages link with its count" do
          expect(page).to have_link(I18n.t('views.users.show.navigation.messages'), href: user_path(user))
          expect(page).to have_selector '.content-navigation-messages', user.messages.count
        end

        # following
        it "should have following link with its count" do
          expect(page).to have_link(I18n.t('views.users.show.navigation.following'), href: following_user_path(user))
          expect(page).to have_selector '.content-navigation-following', user.followed_users.count
        end

        # followers
        it "should have followers link with its count" do
          expect(page).to have_link(I18n.t('views.users.show.navigation.followers'), href: followers_user_path(user))
          expect(page).to have_selector '.content-navigation-followers', user.followers.count
        end
      end

      context 'in profile panel' do
        it { should have_selector('.user-profile-name', text: user.name) }
        it { should have_selector('.user-profile-screen-name', text: user.screen_name) }
      end

      context 'in messages panel' do
        context 'in header' do
          it { should have_link(
            I18n.t('views.users.show.messages_and_replies'),
            with_replies_user_path(user)
          ) }
        end

        context 'in pagination' do
          before {
            FactoryGirl.create_list(:message, HomeController::MESSAGE_PAGE_SIZE+1, user: user)
            visit current_path
          }

          it { should have_selector('ul.pagination') }

          it 'should list each feed in page 1', js: true do
            user.messages_without_replies.newer.
              page(1).per(UsersController::MESSAGE_PAGE_SIZE).each do |m|
              expect(page).to have_message(m)
            end
          end
        end

        context 'in messages list', js: true do
          let! (:messages) { FactoryGirl.create_list(:message, 10, user: user) }
          let! (:reply) { FactoryGirl.create(:message_with_reply, user: user) }

          before {
            stub_const('UsersController::MESSAGE_PAGE_SIZE', 20)
            visit current_path
          }

          it 'should not display reply' do
            should_not have_message(reply)
          end

          it 'should display messages' do
            messages.each { |m| expect(page).to have_message(m) }
          end
        end
      end
    end
  end


  describe 'GET /u/:screen_name/with_replies' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit with_replies_user_path(user) }

    describe 'content' do
      context 'in messages panel' do
        context 'in header' do
          it { should have_link(I18n.t('views.users.show.messages'), user_path(user)) }
        end

        context 'in messages list', js: true do
          let! (:messages) { FactoryGirl.create_list(:message, 10, user: user) }
          let! (:replies) { FactoryGirl.create_list(:message_with_reply, 10, user: user) }
          before {
            stub_const('UsersController::MESSAGE_PAGE_SIZE', 20)
            visit current_path
          }

          it 'should display both messages and replies' do
            messages.each { |m| expect(page).to have_message(m) }
            replies.each  { |m| expect(page).to have_message(m) }
          end
        end
      end
    end
  end


  describe 'GET /u/:screen_name/favorites', js: true do
    let (:user) { FactoryGirl.create(:user) }
    let (:login_user) { FactoryGirl.create(:user) }

    context 'as guest' do
      before { visit favorites_user_path(user) }
      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end

    context 'as user' do
      before {
        signin login_user
        visit favorites_user_path(user)
      }

      describe 'content' do
        it { should have_title(I18n.t('views.users.favorites.title', user: username_formatted(user))) }

        context 'in messages panel' do
          context 'in header' do
            it { should have_content(I18n.t('views.users.favorites.header_title')) }
          end

          context 'in message list' do
            let! (:favorites) { FactoryGirl.create_list(:favorite, 3, user: user) }
            let! (:other_favorites) { FactoryGirl.create_list(:favorite, 7) }
            before {
              stub_const('UsersController::MESSAGE_PAGE_SIZE', 10)
              visit current_path    # reload page
            }

            it "should display own favorite's messages" do
              favorites.each { |f| expect(page).to have_message(f.message) }
            end

            it "should not display other user favorite's messages" do
              other_favorites.each { |f| expect(page).not_to have_message(f.message) }
            end
          end
        end
      end
    end
  end


  describe 'GET /u/:screen_name/following', js: true do
    let (:user) { FactoryGirl.create(:user) }
    let (:login_user) { FactoryGirl.create(:user) }

    context 'as guest' do
      before { visit following_user_path(user) }
      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end

    context 'as user' do
      before {
        signin login_user
        visit following_user_path(user)
      }

      describe 'content' do
        context 'in users panel' do
          let! (:followed_users) { FactoryGirl.create_list(:user, 10) }
          let! (:other_user) { FactoryGirl.create(:user) }
          before {
            followed_users.each do |u|
              FactoryGirl.create(:follow, follower: user, followed: u)
            end
            stub_const('UsersController::MESSAGE_PAGE_SIZE', 10)
            visit current_path
          }

          it 'should display people the user follow' do
            followed_users.each do |u|
              expect(page).to have_user(u)
            end
          end

          it "should not display a user that the user don't follow" do
            expect(page).not_to have_user(other_user)
          end
        end
      end
    end
  end


  describe 'GET /u/:screen_name/followers', js: true do
    let (:user) { FactoryGirl.create(:user) }
    let (:login_user) { FactoryGirl.create(:user) }

    context 'as guest' do
      before { visit followers_user_path(user) }
      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end

    context 'as user' do
      before {
        signin login_user
        visit followers_user_path(user)
      }

      describe 'content' do
        context 'in users panel' do
          let! (:followers) { FactoryGirl.create_list(:user, 10) }
          let! (:other_user) { FactoryGirl.create(:user) }
          before {
            followers.each do |u|
              FactoryGirl.create(:follow, follower: u, followed: user)
            end
            stub_const('UsersController::MESSAGE_PAGE_SIZE', 10)
            visit current_path
          }

          it 'should display people follow the user' do
            followers.each do |u|
              expect(page).to have_user(u)
            end
          end

          it "should not display a user that don't follow the user" do
            expect(page).not_to have_user(other_user)
          end
        end
      end
    end
  end


  describe 'GET /u/:screen_name/status/:status_id', js: true do
    let (:user) { FactoryGirl.create(:user) }
    let (:message) { FactoryGirl.create(:message, user: user) }

    before { visit status_user_path(user, message.id) }

    describe 'content' do
      it {
        p current_path
      }
    end
  end
end
