require 'rails_helper'


describe 'Follow/Unfollow button', type: :feature do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:other_user) { FactoryGirl.create(:user) }

  subject { page }

  before { visit user_path(other_user) }

  context 'as guest' do
    context 'when click follow button' do
      before { click_on I18n.t('views.navigation.follow') }

      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  context 'as user' do
    before {
      signin user
      visit current_path
    }

    context 'about follow button', js: true do
      before {
        # wait until Vue.js compilation and DOM setup have finished
        # wait_for_ready
      }
      # before {
        # page.evaluate_script('Vue.config.async = false')
      # }

      def click_follow_button(u)
        click_on "follow-#{u.screen_name}"
      end

      it 'follow button should be visibule' do
        expect(page.find('.follow-button')).to be_visible
        expect(page.find('.unfollow-button', visible: false)).not_to be_visible
      end

      it 'should be 0 followers' do
        expect(page).to have_selector('.content-navigation-followers .nav-value', 0)
      end

      context 'when click the button' do
        it 'should follow other_user' do
          expect {
            click_follow_button(other_user)
            wait_for_ajax
          }.to change {
            Follow.find_by(
              follower_id: user.id,
              followed_id: other_user.id
            )
          }.from(nil)
        end

        it "'follow' button should change to 'unfollow' button" do
          click_follow_button(other_user)
          wait_for_ajax

          expect(page.find('.follow-button', visible: false)).not_to be_visible
          expect(page.find('.unfollow-button')).to be_visible
        end

        it 'should be 1 followers' do
          click_follow_button(other_user)
          wait_for_ajax

          expect(page).to have_selector('.content-navigation-followers .nav-value', 1)
        end
      end
    end

    context 'about unfollow button', js: true do
      def click_unfollow_button(u)
        click_on "unfollow-#{u.screen_name}"
      end

      before {
        unless user.following?(other_user)
          FactoryGirl.create(:follow, follower: user, followed: other_user)
        end
        visit current_path
      }

      it 'unfollow button should be visibule' do
        expect(page.find('.follow-button', visible: false)).not_to be_visible
        expect(page.find('.unfollow-button')).to be_visible
      end

      it 'should be 1 followers' do
       expect(page).to have_selector('.content-navigation-followers .nav-value', 1)
      end

      context 'when click the button' do

        it "'unfollow' button changes to 'follow' button" do
          click_unfollow_button(other_user)
          wait_for_ajax

          expect(page.find('.follow-button')).to be_visible
          expect(page.find('.unfollow-button', visible: false)).not_to be_visible
        end

        it 'should unfollow other_user' do
          expect {
            click_unfollow_button(other_user)
            wait_for_ajax
          }.to change {
            Follow.find_by(
              follower_id: user.id,
              followed_id: other_user.id
            )
          }.to(nil)
        end

        it 'should be 0 followers' do
          click_unfollow_button(other_user)
          wait_for_ajax

          expect(page).to have_selector('.content-navigation-followers .nav-value', 0)
        end
      end
    end
  end
end
