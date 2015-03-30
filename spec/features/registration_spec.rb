require 'rails_helper'
include Devise::Controllers::UrlHelpers
include ApplicationHelper


describe 'Registration pages', type: :feature do

  subject { page }


  describe 'GET /login' do
    before { visit new_user_session_path }

    describe 'content' do
      it { should have_content(I18n.t('views.users.form.signin')) }

      # oauth links
      User.omniauth_providers.each do |provider|
        it {
          should have_link(
            provider_name(provider).titleize,
            href: user_omniauth_authorize_path(provider, origin: current_url)
          )
        }
      end

      # sign up link
      it { should have_link(I18n.t('views.users.form.signup_link_text'), href: new_user_registration_path) }
    end

    context 'by email login', js: true do
      context 'with invalid info' do
        before { click_signin_button }

        it 'back to the sign in page' do
          expect(current_path).to eq(new_user_session_path)
        end

        it { should have_alert(:alert, I18n.t(
          'devise.failure.invalid',
          { authentication_keys: User.authentication_keys.join(', ') }
        )) }
      end

      context 'with valid info' do
        let (:user) { FactoryGirl.create(:user) }

        context 'with email' do
          before {
            fill_in t_user('login'),    with: user.email
            fill_in t_user('password'), with: user.password
            click_signin_button
          }

          it 'redirect to the root page' do
            expect(current_path).to eq(root_path)
          end

          it { should have_alert(:notice, I18n.t('devise.sessions.signed_in')) }
        end

        context 'with screen_name' do
          before {
            fill_in t_user('login'),    with: user.email
            fill_in t_user('password'), with: user.password
            click_signin_button
          }

          it 'redirect to the root page' do
            expect(current_path).to eq(root_path)
          end

          it { should have_alert(:notice, I18n.t('devise.sessions.signed_in')) }
        end
      end
    end

    context 'by oauth login' do
      let! (:provider) { 'developer' }
      let! (:provider_text) { provider_name(provider).titleize }
      let! (:omniauth) { setup_omniauth(provider) }

      describe 'content' do
        it { should have_link(provider_name(provider).titleize) }
      end

      context 'when have not had a user yet that has linked to the service' do
        before { click_link provider_text }

        it 'redirect to the sign up page' do
          expect(current_path).to eq new_user_registration_path
        end

        it { should have_field(t_user('name'), with: omniauth['info']['name']) }

        context 'after authenticated by an oauth service' do
          before {
            account = omniauth['info']['_account_name']
            fill_in t_user('email'), with: "#{account}-twitter@example.com"
            fill_in t_user('screen_name'), with: account
          }

          it 'should create both new user and its authentication' do
            expect { click_signup_button }.to change {
              [User.count, Authentication.count]
            }.from([0, 0]).to([1, 1])
          end

          context 'after signed up', js: true do
            before { click_signup_button }
            it { should have_alert(:notice, 'signed') }
          end
        end
      end

      context 'when have already had a user that has linked to the service' do
        let! (:authentication) {
          FactoryGirl.create(
            :authentication,
            provider:     omniauth['provider'],
            uid:          omniauth['uid'],
            account_name: omniauth['info']['nickname'] || omniauth['info']['name'] ,
          )
        }

        it 'should not create either new user or authentication' do
          expect { click_link provider_text }.not_to change { [User.count, Authentication.count] }
        end

        context 'after signed in', js: true do
          before { click_link provider_text }

          it 'redirect to the root page' do
            expect(current_path).to eq root_path
          end


          it { should have_alert(:notice, I18n.t('devise.omniauth_callbacks.success', kind: provider)) }
        end
      end
    end
  end


  describe 'GET /signup' do
    before { visit new_user_registration_path }

    describe 'content' do
      it { should have_content(I18n.t('views.users.form.signup')) }
    end

    context 'with invalid info' do
      before { click_signup_button }

      it 'back to the sign up form' do
        expect(current_path).to eq(user_registration_path)
      end

      it { should have_alert(:error, 'error') }
    end

    context 'with valid info' do
      let (:user) { FactoryGirl.build(:user) }

      before {
        fill_in t_user('email'), with: user.email
        fill_in t_user('screen_name'), with: user.screen_name
        fill_in t_user('name'), with: user.name
        fill_in t_user('password'), with: user.password
        fill_in t_user('password_confirmation'), with: user.password
      }

      it 'should create new User' do
        expect { click_signup_button }.to change(User, :count).by(1)
      end
    end
  end
end
