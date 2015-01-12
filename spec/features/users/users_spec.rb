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

    context 'in header' do
      before {
        10.times { FactoryGirl.create(:message, user: user) }
        4.times  { FactoryGirl.create(:relationship, follower: user) }
        5.times  { FactoryGirl.create(:relationship, followed: user) }
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

    context 'in messages list panel' do
      context 'in pagination' do
        before {
          (HomeController::MESSAGE_PAGE_SIZE + 1).times {
            FactoryGirl.create(:message, user: user)
          }
          visit current_path
        }

        it { should have_selector('ul.pagination') }

        it 'should list each feed in page 1' do
          user.messages_without_replies.newer.
            page(1).per(UsersController::MESSAGE_PAGE_SIZE).each do |message|
              expect(page).to have_selector("li#message-#{message.id}")
          end
        end
      end
    end
  end
end
