require 'rails_helper'


describe 'Favorite buttons', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user) }

  subject { page }

  before { visit user_path(user) }

  def click_favorite_button(message)
    click_on "favorite-message-#{message.id}"
  end

  def click_unfavorite_button(message)
    click_on "unfavorite-message-#{message.id}"
  end

  describe 'as guest' do
    it 'favorite button should be disabled' do
      expect(page).to have_selector("#favorite-message-#{message.id}.disabled")
    end
  end

  describe 'as user' do
    before {
      signin user
      visit current_path
    }

    context 'when message is not favorited' do
      it 'favorite button should be displayed' do
        expect(page).to have_selector("#message-#{message.id} .favorite-button")
        expect(page).not_to have_selector("#message-#{message.id} .unfavorite-button", visible: false)
      end

      it 'favorite button should be enabled' do
        expect(page).not_to have_selector("#favorite-message-#{message.id}.disabled")
      end

      context 'in content navigation' do
        it 'should have 0 favorites' do
          expect(page).to have_selector('.content-navigation-favorites .nav-value', 0)
        end
      end

      context 'when click favorite button' do
        it 'should mark the message as favorite' do
          expect {
            click_favorite_button(message)
            wait_for_ajax
          }.to change {
            Favorite.find_by(
              user: user,
              message: message
            )
          }.from(nil)
        end

        it "'favorite' button changes to 'unfavorite' button" do
          click_favorite_button(message)
          wait_for_ajax

          expect(page).to have_selector("#message-#{message.id} .unfavorite-button")
          expect(page).not_to have_selector("#message-#{message.id} .favorite-button", visible: false)
        end

        context 'in content navigation' do
          it 'should have 1 favorites' do
            click_favorite_button(message)
            wait_for_ajax

            expect(page).to have_selector('.content-navigation-favorites .nav-value', 1)
          end
        end
      end
    end

    context 'when message is favorited' do
      before {
        FactoryGirl.create(:favorite, user: user, message: message)
        visit current_path
      }

      it 'unfavorite button should be displayed' do
        expect(page).to have_selector("#message-#{message.id} .unfavorite-button")
        expect(page).not_to have_selector("#message-#{message.id} .favorite-button", visible: false)
      end

      it 'unfavorite button should be enabled' do
        expect(page).not_to have_selector("#unfavorite-message-#{message.id}.disabled")
      end

      context 'in content navigation' do
        it 'should have 1 favorites' do
          expect(page).to have_selector('.content-navigation-favorites .nav-value', 1)
        end
      end

      context 'when click unfavorite button' do
        it 'should unmark the message as favorite' do
          expect {
            click_unfavorite_button(message)
            wait_for_ajax
          }.to change {
            Favorite.find_by(
              user: user,
              message: message
            )
          }.to(nil)
        end

        it "'unfavorite' button changes to 'favorite' button" do
          click_unfavorite_button(message)
          wait_for_ajax

          expect(page).to have_selector("#message-#{message.id} .favorite-button")
          expect(page).not_to have_selector("#message-#{message.id} .unfavorite-button", visible: false)
        end

        context 'in content navigation' do
          it 'should have 0 favorites' do
            click_unfavorite_button(message)
            wait_for_ajax

            expect(page).to have_selector('.content-navigation-favorites .nav-value', 0)
          end
        end
      end
    end
  end
end
