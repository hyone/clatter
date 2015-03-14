require 'rails_helper'


describe 'Message Actions', type: :feature, js: true do
  let (:user) { FactoryGirl.create(:user) }

  subject { page }

  describe 'reply button' do
    context 'as user' do
      before { signin user }

      context 'when click the button' do
        let! (:message) { FactoryGirl.create(:message) }

        before {
          visit user_path(message.user)
          click_on "reply-to-message-#{message.id}"
        }

        # # Unfotunately, don't work below...
        # it 'should display modal dialog' do
        #   expect {
        #     click_on "reply-to-message-#{message.id}"
        #   }.to change {
        #     page.find('#message-dialog', visible: false).visible?
        #   }.from(false).to(true)
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

        describe 'form' do
          it 'hidden field should have original message id' do
            expect(find('#modal-message-form-parent-id', visible: false).value).to eq("#{message.id}")
          end

          it "textarea should have '@screen_name'" do
            expect(find('#modal-message-form-text').value).to match /@#{message.user.screen_name}/
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
  end

  describe 'actions button' do
    describe 'delete message menu' do
      let! (:message) { FactoryGirl.create(:message, user: user) }
      let (:other_user) { FactoryGirl.create(:user) }
      before {
        visit user_path(user)
      }

      context 'as guest' do
        it 'should not be included in the dropdown' do
          should_not have_selector("#delete-message-#{message.id}", visible: false)
          # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
        end
      end

      context 'as non owner' do
        before {
          signin other_user
          visit current_path
        }
        it 'should not be included in the dropdown' do
          should_not have_selector("#delete-message-#{message.id}", visible: false)
          # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
        end
      end

      context 'as owner' do
        before {
          signin user
          visit current_path
        }

        it 'should be included in the dropdown menu' do
          should have_selector("#delete-message-#{message.id}", visible: false)
        end

        context 'when click the message actions button' do
          before {
            click_on "message-actions-#{message.id}"
          }

          it 'should display' do
            should have_selector("#delete-message-#{message.id}")
          end

          context 'and then click the menu' do
            it 'should delete the message' do
              expect {
                click_link "delete-message-#{message.id}"
                wait_for_ajax
              }.to change(Message, :count).by(-1)
            end

            it {
              click_link "delete-message-#{message.id}"
              wait_for_ajax
              expect(page).to have_alert(:success, I18n.t('views.alert.success_delete_message'))
            }
          end
        end
      end
    end
  end
end
