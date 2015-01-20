require 'rails_helper'


describe 'Message Actions', type: :feature, js: true do
  subject { page }

  context 'as user' do
    let (:user) { FactoryGirl.create(:user) }
    before { signin user }

    context 'when click reply button in the message panel' do
      let (:message) { FactoryGirl.create(:message) }
      before {
        visit user_path(message.user)
        click_link "reply-to-message-#{message.id}"
      }

      # # Unfotunately, don't work below...
      # it 'should display modal dialog' do
        # expect {
          # click_link "reply-to-message-#{message.id}"
        # }.to change {
          # page.find('#message-dialog').visible?
        # }.from(false).to(true)
      # end

      it 'should display modal dialog' do
        expect(page.find('#message-dialog')).to be_visible
      end

      describe 'title' do
        it "should match 'Reply to @screen_name'" do
          should have_selector('#message-dialog .modal-title', /Reply to @#{message.user.screen_name}/)
        end
      end

      describe 'body' do
        it "should display the parent message" do
          should have_selector('#message-dialog .modal-body', /#{message.text}/)
        end
      end

      describe 'textarea' do
        it "should match '@screen_name'" do
          expect(find('#modal-message-form-text').value).to match /@#{message.user.screen_name}/
        end
      end
    end
  end
end
