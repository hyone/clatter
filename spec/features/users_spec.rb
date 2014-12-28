require 'rails_helper'
include Devise::Controllers::UrlHelpers
include UsersHelper


describe 'Users page', type: :feature do
  subject { page }

  describe 'GET /users' do
    before(:all) {
      50.times { FactoryGirl.create(:user) }
    }
    after(:all) {
      User.delete_all
    }

    before {
      visit users_path
    }

    describe 'content' do
      it { should have_title(I18n.t('views.users.index.title')) }

      describe 'pagination' do
        it { should have_selector('ul.pagination') }

        it 'should list each user in page 1' do
          User.page(1).per(UsersController::USER_PAGE_SIZE).each do |user|
            expect(page).to have_selector('li', text: user.screen_name)
          end
        end
      end
    end
  end


  describe 'GET /users/sign_in' do
    before { visit new_user_session_path }

    describe 'content' do
      it { should have_content(I18n.t('views.users.form.signin')) }

      # oauth links
      User.omniauth_providers.each do |provider|
        it {
          should have_link(
            provider_name(provider).titleize,
            href: user_omniauth_authorize_path(provider)
          )
        }
      end

      # sign up link
      it { should have_link(I18n.t('views.users.form.signup_link_text'), href: new_user_registration_path) }
    end

    context 'by email login' do
      context 'with invalid info' do
        before { click_signin_button }

        it 'back to the sign in page' do
          expect(current_path).to eq(new_user_session_path)
        end

        it { should have_message(:alert, I18n.t(
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

          it { should have_message(:notice, I18n.t('devise.sessions.signed_in')) }
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

          it { should have_message(:notice, I18n.t('devise.sessions.signed_in')) }
        end
      end
    end

    context 'by oauth login' do
      let! (:provider) { 'twitter' }
      let! (:omniauth) { setup_omniauth(provider) }

      describe 'content' do
        it { should have_link(provider_name(provider).titleize) }
      end

      context 'when have not had a user yet that has linked to the service' do
        before { click_link 'Twitter' }

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

          context 'after signed up' do
            before { click_signup_button }
            it { should have_message(:notice, 'signed') }
          end
        end
      end

      context 'when have already had a user that has linked to the service' do
        let! (:authentication) {
          FactoryGirl.create(
            :authentication,
            provider:     omniauth['provider'],
            uid:          omniauth['uid'],
            account_name: omniauth['info']['nickname'],
            url:          omniauth['info']['urls']['Twitter'],
          )
        }

        it 'should not create either new user or authentication' do
          expect { click_link 'Twitter' }.not_to change { [User.count, Authentication.count] }
        end

        context 'after signed in' do
          before { click_link 'Twitter' }

          it 'redirect to the root page' do
            expect(current_path).to eq root_path
          end

          it { should have_message(:notice, 'Successfully authenticated from twitter account.') }
        end
      end
    end
  end


  describe 'GET /users/sign_up' do
    before { visit new_user_registration_path }

    describe 'content' do
      it { should have_content(I18n.t('views.users.form.signup')) }
    end

    context 'with invalid info' do
      before { click_signup_button }

      it 'back to the sign up form' do
        expect(current_path).to eq(user_registration_path)
      end

      it { should have_message(:error, 'error') }
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


  describe 'GET /users/:id' do
    let (:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    context 'in header' do
      before {
        10.times { FactoryGirl.create(:post, user: user) }
        4.times  { FactoryGirl.create(:relationship, follower: user) }
        5.times  { FactoryGirl.create(:relationship, followed: user) }
        visit current_path
      }

      # posts
      it "should have posts link with its count" do
        expect(page).to have_link(I18n.t('views.users.show.navigation.posts'), href: user_path(user))
        expect(page).to have_selector '.content-navigation-posts', user.posts.count
      end

      # following
      it "should have following link with its count" do
        expect(page).to have_link(I18n.t('views.users.show.navigation.following'), href: following_user_path(user))
        expect(page).to have_selector '.content-navigation-following', user.followed_users.count
      end

      # followers
      it "should have followers link with its count" do
        expect(page).to have_link(I18n.t('views.users.show.navigation.followers'), href: followers_user_path(user))
        expect(page).to have_selector '.content-navigation-followers', user.followers.count
      end
    end

    context 'in profile panel' do
      it { should have_selector('.user-profile-name', text: user.name) }
      it { should have_selector('.user-profile-screen-name', text: user.screen_name) }
    end

    context 'in posts list panel' do
      context 'in pagination' do
        before {
          (HomeController::POST_PAGE_SIZE + 1).times {
            FactoryGirl.create(:post, user: user)
          }
          visit current_path
        }

        it { should have_selector('ul.pagination') }

        it 'should list each feed in page 1' do
          User.page(1).per(UsersController::POST_PAGE_SIZE).each do |user|
            expect(page).to have_selector('li', text: user.screen_name)
          end
        end
      end
    end
  end


  describe 'GET /users/edit.:id' do
    let (:user) { FactoryGirl.create(:user) }

    context 'as guest' do
      before {
        visit edit_user_registration_path(user)
      }
      its(:status_code) { should == 401 }
    end

    context 'as authenticated user' do
      before {
        signin user
        visit edit_user_registration_path(user)
      }

      its(:status_code) { should == 200 }

      describe 'content' do
        it { should have_title(I18n.t('views.users.edit.title')) }
        it { should have_content(I18n.t('views.users.edit.title')) }
        it { should have_button(I18n.t('views.users.form.update')) }
      end

      # oauth
      describe 'oauth links' do
        let! (:provider) { 'twitter' }
        let! (:text_connect) { text_connect_provider(provider) }
        let! (:text_disconnect) { text_disconnect_provider(provider) }

        context 'when have not linked to twitter' do
          it { should have_link(text_connect, user_omniauth_authorize_path(provider)) }

          context 'after clicking the link to connect twitter' do
            before {
              click_link text_connect_provider(provider)
              # back to setting page
              visit edit_user_registration_path(user)
            }

            # have toggled the button to link
            it { should_not have_link(text_connect, user_omniauth_authorize_path(provider)) }
            it { should have_link(text_disconnect_provider(provider), authentication_path(
              user.authentications.find_by(provider: provider)
            )) }
          end
        end

        context 'when have already linked to twitter' do
          let! (:authentication) {
            FactoryGirl.create(:authentication, provider: provider, user: user)
          }
          before {
            visit current_path
          }

          it { should_not have_link(text_connect, user_omniauth_authorize_path(provider)) }
          it { should have_link(text_disconnect, authentication_path(authentication)) }

          context 'and the user has not set password yet' do
            let! (:user) {
              o = FactoryGirl.build(:user, password: nil, password_confirmation: nil)
              o.save(validation: nil); o
            }
            before {
              # replace the user with one without password
              authentication.user = user
              signin user
              visit edit_user_registration_path(user)
            }

            it 'should have disabled link "Disconnect twitter"' do
              should have_selector('.setting-oauth a.disabled', text: text_disconnect_provider(provider))
            end
          end

          context 'after clicking the link to connect twitter' do
            before {
              click_link text_disconnect
              visit edit_user_registration_path(user)
            }

            it { should have_link(text_connect, user_omniauth_authorize_path(provider)) }
            it { should_not have_link(text_disconnect, authentication_path(authentication)) }
          end
        end
      end

      # delete the account
      it { should have_link(I18n.t('views.users.form.delete_my_account'), registration_path(user)) }
    end
  end
end
