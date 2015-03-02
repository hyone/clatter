require 'rails_helper'

describe 'Retweet buttons', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:other_user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: other_user) }

  subject { page }

  before { visit user_path(other_user) }

  describe 'as guest' do
    it 'retweet button should be disabled' do
      expect(page).to have_selector("#retweet-message-#{message.id}.disabled")
    end
  end

  describe 'as user' do
    before {
      signin user
      visit current_path
    }

    context "in other's user page" do
      context 'when message is not retweeted' do
        it 'retweet button should be displayed' do
          expect(page).to have_selector("#message-#{message.id} .retweet-button")
          expect(page).not_to have_selector("#message-#{message.id} .unretweet-button", visible: false)
        end

        it 'retweet button should be enabled' do
          expect(page).not_to have_selector("#retweet-message-#{message.id}.disabled")
        end

        it 'should not display retweets count' do
          expect(page).not_to have_selector("#message-#{message.id} .retweets-count", visible: false)
        end

        context 'when click retweet button' do
          def click_retweet_button(message)
            click_on "retweet-message-#{message.id}"
            wait_for_ajax
          end

          it 'should retweet the message' do
            expect {
              click_retweet_button(message)
            }.to change {
              Retweet.find_by(
                user: user,
                message: message
              )
            }.from(nil).to(be_a Retweet)
          end

          it "'retweet' button changes to 'unretweet' button" do
            click_retweet_button(message)
            expect(page).to have_selector("#message-#{message.id} .unretweet-button")
            expect(page).not_to have_selector("#message-#{message.id} .retweet-button", visible: false)
          end

          it 'should disply 1 retweets count' do
            click_retweet_button(message)
            expect(page).to have_selector("#message-#{message.id} .retweets-count", 1)
          end
        end
      end

      context 'when message is retweeted' do
        before {
          FactoryGirl.create(:retweet, user: user, message: message)
          visit current_path
        }

        it 'unretweet button should be displayed' do
          expect(page).to have_selector("#message-#{message.id} .unretweet-button")
          expect(page).not_to have_selector("#message-#{message.id} .retweet-button", visible: false)
        end

        it 'unretweet button should be enabled' do
          expect(page).not_to have_selector("#unretweet-message-#{message.id}.disabled")
        end

        it 'should disply 1 retweets count' do
          expect(page).to have_selector("#message-#{message.id} .retweets-count", 1)
        end

        context 'when click unretweet button' do
          def click_unretweet_button(message)
            click_on "unretweet-message-#{message.id}"
            wait_for_ajax
          end

          it 'should unretweet the message' do
            expect {
              click_unretweet_button(message)
            }.to change {
              Retweet.find_by(
                user: user,
                message: message
              )
            }.to(nil)
          end

          it "'unretweet' button change to 'retweet' button" do
            click_unretweet_button(message)
            expect(page).to have_selector("#message-#{message.id} .retweet-button")
            expect(page).not_to have_selector("#message-#{message.id} .unretweet-button", visible: false)
          end

          it 'should not display retweets count' do
            click_unretweet_button(message)
            expect(page).not_to have_selector("#message-#{message.id} .retweets-count", visible: false)
          end
        end
      end
    end

    context 'in own user page' do
      let! (:message_own) { FactoryGirl.create(:message, user: user) }
      before {
        visit user_path(user)
      }

      it 'retweet button should be disabled' do
        expect(page).to have_selector("#retweet-message-#{message_own.id}.disabled")
      end
    end
  end
end
