
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
shared_examples 'a retweetable button' do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:other_user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: other_user) }

  subject { page }

  before { visit path(message) }

  context 'as guest' do
    before { signout }
    it 'retweet button should be disabled' do
      expect(page).to have_selector("#retweet-message-#{message.id}.disabled")
    end
  end

  context 'as user' do
    before {
      signin user
      visit path(message)
    }

    context "in other's user page" do
      context 'when message is not retweeted' do
        it 'retweet button should be displayed' do
          expect(page).to have_selector("#message-#{message.id} .retweet-button")
          expect(find("#message-#{message.id} .unretweet-button", visible: false)).not_to be_visible
        end

        it 'retweet button should be enabled' do
          expect(page).not_to have_selector("#retweet-message-#{message.id}.disabled")
        end

        it 'should not display retweets count' do
          expect(page).not_to have_selector("#message-#{message.id} .retweets-count", visible: false)
        end

        context 'when click retweet button' do
          before { click_on "retweet-message-#{message.id}" }

          it 'should display confirm dialog' do
            expect(page.find('#confirm-dialog')).to be_visible
          end

          context 'when click cancel button' do
            it 'should not retweet the message' do
              expect {
                click_on "cancel-action-button"
              }.not_to change {
                Retweet.find_by(
                  user: user,
                  message: message
                )
              }.from(nil)
            end

            it 'should dismiss confirm dialog' do
              click_on "cancel-action-button"
              expect(page.find('#confirm-dialog', visible: false)).not_to be_visible
            end
          end

          context 'when click ok button' do
            def click_ok_button
              click_on "ok-action-button"
              wait_for_ajax
            end

            it 'should retweet the message' do
              expect {
                click_ok_button
              }.to change {
                Retweet.find_by(
                  user: user,
                  message: message
                )
              }.from(nil).to(be_a Retweet)
            end

            it "'retweet' button changes to 'unretweet' button" do
              click_ok_button
              expect(page).to have_selector("#message-#{message.id} .unretweet-button")
              expect(find("#message-#{message.id} .retweet-button", visible: false)).not_to be_visible
            end

            it 'should disply 1 retweets count' do
              click_ok_button
              expect(page).to have_selector("#message-#{message.id} .retweets-count", text: 1)
            end
          end
        end
      end

      context 'when message is retweeted' do
        before {
          FactoryGirl.create(:retweet, user: user, message: message)
          visit path(message)
        }

        it 'unretweet button should be displayed' do
          expect(page).to have_selector("#message-#{message.id} .unretweet-button")
          expect(find("#message-#{message.id} .retweet-button", visible: false)).not_to be_visible
        end

        it 'unretweet button should be enabled' do
          expect(page).not_to have_selector("#unretweet-message-#{message.id}.disabled")
        end

        it 'should disply 1 retweets count' do
          expect(page).to have_selector("#message-#{message.id} .retweets-count", text: 1)
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
            expect(find("#message-#{message.id} .unretweet-button", visible: false)).not_to be_visible
          end

          it 'should not display retweets count' do
            click_unretweet_button(message)
            expect(page).not_to have_selector("#message-#{message.id} .retweets-count", visible: false)
          end
        end
      end
    end

    context 'in own user page' do
      let! (:message) { FactoryGirl.create(:message, user: user) }
      before { visit path(message) }

      it 'retweet button should be disabled' do
        expect(page).to have_selector("#retweet-message-#{message.id}.disabled")
      end
    end
  end
end
