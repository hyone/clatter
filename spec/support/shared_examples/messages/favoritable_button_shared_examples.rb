
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
# arguments:
# - content_navigation: whether or not check favorites count change in content navigation
shared_examples 'a favoritable button' do |content_navigation: false|
  let!(:user) { FactoryGirl.create(:user) }
  let!(:message) { FactoryGirl.create(:message, user: user) }

  subject { page }

  before { visit path(message) }

  context 'as guest', js: true do
    before { signout }
    it 'favorite button should be disabled' do
      expect(page).to have_selector("#favorite-message-#{message.id}.disabled")
    end
  end

  context 'as user', js: true do
    before do
      signin user
      visit path(message)
    end

    context 'when message is not favorited' do
      it 'favorite button should be displayed' do
        expect(page).to have_selector("#message-#{message.id} .favorite-button")
        expect(find("#message-#{message.id} .unfavorite-button", visible: false)).not_to be_visible
      end

      it 'favorite button should be enabled' do
        expect(page).not_to have_selector("#favorite-message-#{message.id}.disabled")
      end

      it 'should not display favorites count' do
        expect(page).not_to have_selector("#message-#{message.id} .favorites-count", visible: false)
      end

      if content_navigation
        context 'in content navigation' do
          it 'should have 0 favorites' do
            expect(page).to have_selector('.content-navigation-favorites .nav-value', text: 0)
          end
        end
      end

      context 'when click favorite button' do
        def click_favorite_button(message)
          click_on "favorite-message-#{message.id}"
          wait_for_ajax
        end

        it 'should mark the message as favorite' do
          expect do
            click_favorite_button(message)
          end.to change {
            Favorite.find_by(
              user: user,
              message: message
            )
          }.from(nil).to(be_a Favorite)
        end

        it "'favorite' button changes to 'unfavorite' button" do
          click_favorite_button(message)
          expect(page).to have_selector("#message-#{message.id} .unfavorite-button")
          expect(find("#message-#{message.id} .favorite-button", visible: false)).not_to be_visible
        end

        it 'should display 1 favorites count' do
          click_favorite_button(message)
          expect(page).to have_selector("#message-#{message.id} .favorites-count", text: 1)
        end

        if content_navigation
          context 'in content navigation' do
            it 'should have 1 favorites' do
              click_favorite_button(message)
              expect(page).to have_selector('.content-navigation-favorites .nav-value', text: 1)
            end
          end
        end
      end
    end

    context 'when message is favorited' do
      before do
        FactoryGirl.create(:favorite, user: user, message: message)
        visit path(message)
      end

      it 'unfavorite button should be displayed' do
        expect(page).to have_selector("#message-#{message.id} .unfavorite-button")
        expect(find("#message-#{message.id} .favorite-button", visible: false)).not_to be_visible
      end

      it 'unfavorite button should be enabled' do
        expect(page).not_to have_selector("#unfavorite-message-#{message.id}.disabled")
      end

      it 'should display 1 favorites count' do
        expect(page).to have_selector("#message-#{message.id} .favorites-count", 1)
      end

      if content_navigation
        context 'in content navigation' do
          it 'should have 1 favorites' do
            expect(page).to have_selector('.content-navigation-favorites .nav-value', 1)
          end
        end
      end

      context 'when click unfavorite button' do
        def click_unfavorite_button(message)
          click_on "unfavorite-message-#{message.id}"
          wait_for_ajax
        end

        it 'should unmark the message as favorite' do
          expect do
            click_unfavorite_button(message)
          end.to change {
            Favorite.find_by(
              user: user,
              message: message
            )
          }.to(nil)
        end

        it "'unfavorite' button changes to 'favorite' button" do
          click_unfavorite_button(message)
          expect(page).to have_selector("#message-#{message.id} .favorite-button")
          expect(find("#message-#{message.id} .unfavorite-button", visible: false)).not_to be_visible
        end

        it 'should not display favorites count' do
          click_unfavorite_button(message)
          expect(page).not_to have_selector("#message-#{message.id} .favorites-count", visible: false)
        end

        if content_navigation
          context 'in content navigation' do
            it 'should have 0 favorites' do
              click_unfavorite_button(message)
              expect(page).to have_selector('.content-navigation-favorites .nav-value', 0)
            end
          end
        end
      end
    end
  end
end
