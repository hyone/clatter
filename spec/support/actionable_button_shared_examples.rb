
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
shared_examples 'a actionable button' do
  let! (:user) { FactoryGirl.create(:user) }

  subject { page }

  describe 'delete message menu' do
    let! (:message) { FactoryGirl.create(:message, user: user) }

    context 'as guest' do
      before {
         signout
         visit path(message)
      }
      it 'should not be included in the dropdown' do
        should_not have_selector("#delete-message-#{message.id}", visible: false)
        # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
      end
    end

    context 'as non owner' do
      let (:other_user) { FactoryGirl.create(:user) }
      before {
        signin other_user
        visit path(message)
      }
      it 'should not be included in the dropdown' do
        should_not have_selector("#delete-message-#{message.id}", visible: false)
        # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
      end
    end

    context 'as owner' do
      before {
        signin user
        visit path(message)
      }

      it 'should be included in the dropdown menu' do
        should have_selector("#delete-message-#{message.id}", visible: false)
      end

      context 'when click the message actions button' do
        before { click_on "message-actions-#{message.id}" }

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
