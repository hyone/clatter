require 'rails_helper'


describe 'Reply buttons', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user) }

  subject { page }

  before { visit user_path(user) }

  def click_reply_button(message)
    click_on "reply-to-message-#{message.id}"
  end

  describe 'as guest' do
    it 'reply button should be disabled' do
      expect(page).to have_selector("#reply-to-message-#{message.id}.disabled")
    end
  end

  describe 'as user' do
    before {
      signin user
      visit current_path
    }

    it 'reply button should be enabled' do
      expect(page).to have_selector("#reply-to-message-#{message.id}")
      expect(page).not_to have_selector("#reply-to-message-#{message.id}.disabled")
    end

    context 'when click reply button' do
      before { click_reply_button(message) }

      it 'should display modal window' do
        expect(page.find('#message-dialog')).to be_visible
      end

      context 'in modal window' do
        it "should include parent tweet" do
          expect(page).to have_selector("#message-dialog #parent-message-#{message.id}")
        end

        it "should match '@screen_name'" do
          expect(find('#modal-message-form-text').value).to match /@#{message.user.screen_name}/
        end
      end
    end
  end
end
