require 'rails_helper'
include Warden::Test::Helpers


describe 'Users page' do
  subject { page }

  describe 'GET /users' do
    before(:all) {
      50.times { FactoryGirl.create(:user) }
    }
    after(:all) {
      User.delete_all
    }

    before {
      # user = FactoryGirl.create(:user)
      # login_as u, scope: :user
      visit users_path
    }

    describe 'content' do
      it { should have_title('All Users') }

      it 'should list all users' do
        User.all do |user|
          expect(page).to have_selector('li', text: user.screen_name)
        end
      end
    end
  end

  describe 'GET /users/sign_in' do
    before { visit new_user_session_path }

    it { should have_content('Sign in') }

    context 'with invalid info' do
      before { click_button 'Sign in' }

      it 'back to the sign in page' do
        expect(current_path).to be == new_user_session_path
      end

      it { should have_message(:alert, 'Invalid') }
    end

    context 'with valid info' do
      let (:user) { FactoryGirl.create(:user) }

      context 'with email' do
        before {
          fill_in 'Login',    with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        }

        it 'redirect to the root page' do
          expect(current_path).to be == root_path
        end

        it { should have_message(:notice, 'Signed in successfully') }
      end

      context 'with screen_name' do
        before {
          fill_in 'Login',    with: user.screen_name
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        }

        it 'redirect to the root page' do
          expect(current_path).to be == root_path
        end

        it { should have_message(:notice, 'Signed in successfully') }
      end
    end
  end


  describe 'GET /users/sign_up' do
    before { visit new_user_registration_path }

    it { should have_content('Sign up') }

    context 'with invalid info' do
      before { click_button 'Sign up' }

      it 'back to the sign up form' do
        expect(current_path).to be == user_registration_path
      end

      it { should have_message(:error, 'error') }
    end

    context 'with valid info' do
      let (:user) { FactoryGirl.build(:user) }

      before {
        fill_in 'Email', with: user.email
        fill_in 'Username', with: user.screen_name
        fill_in 'Password', with: user.password
        fill_in 'Password confirmation', with: user.password
      }

      it 'should create new User' do
        expect { click_button 'Sign up' }.to change(User, :count).by(1)
      end
    end
  end
end
