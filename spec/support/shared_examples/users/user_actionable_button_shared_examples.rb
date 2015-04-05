
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
shared_examples 'a user actionable button' do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:button_id) { "user-actions-#{user.screen_name}" }

  context 'as guest', js: true do
    before do
      signout
      visit path(user)
    end

    it 'should not be shown' do
      expect(page).not_to have_selector("\##{button_id}", visible: false)
    end
  end

  context 'as user', js: true do
    before do
      signin other_user
      visit path(user)
    end

    it 'should be shown' do
      expect(page).to have_selector("\##{button_id}")
    end

    context 'when open user actions menu' do
      before { click_button button_id }

      context 'and then click "message to @screen_name" button' do
        before { click_link "reply-to-#{user.screen_name}" }

        it 'should display modal window' do
          expect(page.find('#message-dialog')).to be_visible
        end

        describe 'textarea' do
          it "should match '@screen_name'" do
            expect(find('#modal-message-form-text').value).to match(
              /#{ Regexp.escape "@#{user.screen_name}" }/
            )
          end
        end
      end
    end
  end
end
