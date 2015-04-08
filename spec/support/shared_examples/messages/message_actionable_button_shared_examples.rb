
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
shared_examples 'a message actionable button' do
  let!(:user) { FactoryGirl.create(:user) }

  subject { page }

  describe 'delete message menu' do
    let!(:message) { FactoryGirl.create(:message, user: user) }

    context 'as guest' do
      before do
        signout
        visit path(message)
      end
      it 'should not be included in the dropdown' do
        should_not have_selector("#delete-message-#{message.id}", visible: false)
        # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
      end
    end

    context 'as non owner' do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        signin other_user
        visit path(message)
      end
      it 'should not be included in the dropdown' do
        should_not have_selector("#delete-message-#{message.id}", visible: false)
        # expect(find("#delete-message-#{message.id}", visible: false)).not_to be_visible
      end
    end

    context 'as owner' do
      before do
        signin user
        visit path(message)
      end

      it 'should be included in the dropdown menu' do
        should have_selector("#delete-message-#{message.id}", visible: false)
      end

      context 'when click the message actions button' do
        before { click_on "message-actions-#{message.id}" }

        it 'should display' do
          should have_selector("#delete-message-#{message.id}")
        end

        context 'and then click the menu' do
          before { click_on "delete-message-#{message.id}" }

          it 'should display confirm dialog' do
            expect(page.find('#confirm-dialog')).to be_visible
          end

          context 'when click cancel button' do
            it 'should not delete the message' do
              expect do
                click_on 'cancel-action-button'
              end.not_to change {
                Message.exists?(message.id)
              }.from(true)
            end

            it 'should dismiss confirm dialog' do
              click_on 'cancel-action-button'
              expect(page.find('#confirm-dialog', visible: false)).not_to be_visible
            end
          end

          context 'when click ok button' do
            it 'should delete the message' do
              expect do
                click_on 'ok-action-button'
                wait_for_ajax
              end.to change {
                Message.exists?(message.id)
              }.from(true).to(false)
            end

            it do
              click_on 'ok-action-button'
              wait_for_ajax
              expect(page).to have_alert(:success, I18n.t('alert.success_delete_message'))
            end

            it 'should dismiss confirm dialog' do
              click_on 'ok-action-button'
              wait_for_ajax
              expect(page.find('#confirm-dialog', visible: false)).not_to be_visible
            end
          end
        end
      end
    end
  end
end
