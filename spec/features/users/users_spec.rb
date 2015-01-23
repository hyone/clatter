require 'rails_helper'


describe 'Users pages', type: :feature do
  subject { page }

  describe 'GET /users' do
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

      describe 'pagination' do
        it { should have_selector('ul.pagination') }

        it 'should list each user in page 1' do
          User.newer.page(1).per(UsersController::USER_PAGE_SIZE).each do |user|
            expect(page).to have_selector('li', text: "@#{user.screen_name}")
          end
        end
      end
    end
  end


  describe 'GET /users/:id' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    describe 'content' do
      context 'in header' do
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

          it 'should list each feed in page 1' do
            user.messages_without_replies.newer.
              page(1).per(UsersController::MESSAGE_PAGE_SIZE).each do |m|
              expect(page).to have_message(m)
            end
          end
        end

        context 'in messages list' do
          let! (:messages) { FactoryGirl.create_list(:message, 10, user: user) }
          let! (:reply) { FactoryGirl.create(:message_with_reply, user: user) }
          before { visit current_path }

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


  describe 'GET /users/:id/with_replies' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit with_replies_user_path(user) }

    describe 'content' do
      context 'in messages panel' do
        context 'in header' do
          it { should have_link(I18n.t('views.users.show.messages'), user_path(user)) }
        end

        context 'in messages list' do
          let! (:messages) { FactoryGirl.create_list(:message, 10, user: user) }
          let! (:replies) { FactoryGirl.create_list(:message_with_reply, 10, user: user) }
          before { visit current_path }

          it 'should display both messages and replies' do
            messages.each { |m| expect(page).to have_message(m) }
            replies.each  { |m| expect(page).to have_message(m) }
          end
        end
      end
    end
  end


  describe 'GET /users/:id/following' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit following_user_path(user) }

    describe 'content' do
      context 'in users panel' do
        let! (:followed_users) { FactoryGirl.create_list(:user, 10) }
        let! (:other_user) { FactoryGirl.create(:user) }
        before { 
          followed_users.each do |u|
            FactoryGirl.create(:follow, follower: user, followed: u)
          end 
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


  describe 'GET /users/:id/followers' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit followers_user_path(user) }

    describe 'content' do
      context 'in users panel' do
        let! (:followers) { FactoryGirl.create_list(:user, 10) }
        let! (:other_user) { FactoryGirl.create(:user) }
        before { 
          followers.each do |u|
            FactoryGirl.create(:follow, follower: u, followed: user)
          end 
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
