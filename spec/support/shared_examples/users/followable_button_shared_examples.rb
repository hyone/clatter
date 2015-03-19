
# a shared context requires conditions below:
# - path: method return path in which we test message, it is passed user and message
#
# arguments:
# - content_navigation: whether or not check following/followers count change in content navigation
shared_examples 'a followable button' do |content_navigation: false|
  let! (:user) { FactoryGirl.create(:user) }
  let! (:other_user) { FactoryGirl.create(:user) }

  subject { page }

  context 'as guest' do
    before {
      signout
      visit path(other_user)
    }
    it 'follow button should be disabled' do
      expect(page).to have_selector("#follow-#{other_user.screen_name}.disabled")
    end
  end

  context 'as user' do
    before {
      signin user
      visit path(other_user)
    }

    context 'about follow button' do
      it 'follow button should be visibule' do
        expect(page).to have_selector('.follow-button', visible: false)
        expect(page).not_to have_selector('.unfollow-button')
      end

      if content_navigation
        context 'in content navigation' do
          it 'should be 0 followers' do
            expect(page).to have_selector('.content-navigation-followers .nav-value', 0)
          end
        end
      end

      context 'when click the follow button' do
        def click_follow_button(u)
          click_on "follow-#{u.screen_name}"
          wait_for_ajax
        end

        it 'should follow other_user' do
          expect {
            click_follow_button(other_user)
          }.to change {
            Follow.find_by(
              follower_id: user.id,
              followed_id: other_user.id
            )
          }.from(nil).to(be_a Follow)
        end

        it "'follow' button should change to 'unfollow' button" do
          click_follow_button(other_user)
          expect(page).to have_selector('.unfollow-button')
          expect(page).not_to have_selector('.follow-button', visible: false)
        end

        if content_navigation
          context 'in content navigation' do
            it 'should be 1 followers' do
              click_follow_button(other_user)
              expect(page).to have_selector('.content-navigation-followers .nav-value', 1)
            end
          end
        end
      end
    end

    context 'about unfollow button' do
      before {
        FactoryGirl.create(:follow, follower: user, followed: other_user)
        visit current_path
      }

      it 'unfollow button should be visibule' do
        expect(page).to have_selector('.unfollow-button')
        expect(page).not_to have_selector('.follow-button', visible: false)
      end

      if content_navigation
        context 'in content navigation' do
          it 'should be 1 followers' do
            expect(page).to have_selector('.content-navigation-followers .nav-value', 1)
          end
        end
      end

      context 'when click the unfollow button' do
        def click_unfollow_button(u)
          click_on "unfollow-#{u.screen_name}"
          wait_for_ajax
        end

        it "'unfollow' button changes to 'follow' button" do
          click_unfollow_button(other_user)
          expect(page).to have_selector('.follow-button', visible: false)
          expect(page).not_to have_selector('.unfollow-button')
        end

        it 'should unfollow other_user' do
          expect {
            click_unfollow_button(other_user)
          }.to change {
            Follow.find_by(
              follower_id: user.id,
              followed_id: other_user.id
            )
          }.to(nil)
        end

        if content_navigation
          context 'in content navigation' do
            it 'should be 0 followers' do
              click_unfollow_button(other_user)
              expect(page).to have_selector('.content-navigation-followers .nav-value', 0)
            end
          end
        end
      end
    end
  end
end

