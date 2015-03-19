
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
shared_examples 'a replyable button' do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user) }

  subject { page }

  before { visit path(message) }

  def click_reply_button(message)
    click_on "reply-to-message-#{message.id}"
  end

  context 'as guest', js: true do
    before { signout }
    it 'reply button should be disabled' do
      expect(page).to have_selector("#reply-to-message-#{message.id}.disabled")
    end
  end

  context 'as user', js: true do
    before {
      signin user
      visit path(message)
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

      it "title should match 'Reply to @screen_name'" do
        should have_selector('#message-dialog .modal-title', /Reply to @#{message.user.screen_name}/)
      end

      it "should include parent tweet" do
        expect(page).to have_selector("#message-dialog #parent-message-#{message.id}")
      end

      describe 'form' do
        it 'hidden field should have original message id' do
          expect(find('#modal-message-form-parent-id', visible: false).value).to eq("#{message.id}")
        end

        it "should match '@screen_name'" do
          expect(find('#modal-message-form-text').value).to match /@#{message.user.screen_name}/
        end
      end

      context 'when submit' do
        let (:text) { "@#{message.user.screen_name} Hello World!" }

        it 'should create a reply to the message' do
          expect {
            fill_in "modal-message-form-text", with: text
            click_button "modal-message-form-submit"
            wait_for_ajax
          }.to change {
            Message.find_by(text: text, user: user)
          }.from(nil)
          .and change( Reply.where(
            to_message_id: message.id,
            to_user_id: message.user
          ), :count )
          .by(1)
        end
      end
    end
  end
end
