require 'rails_helper'


describe 'Home Page' do
  subject { page }

  describe 'GET /' do
    before { visit root_path }

    it { should have_title(page_title) }

    context 'as guest' do
      it { should have_content(I18n.t('views.home.welcome_message')) }
      it { should have_link(I18n.t('views.home.signup_now'), new_user_registration_path) }
    end

    context 'as user' do
      let (:user) { FactoryGirl.create(:user) }
      before {
        signin user
        visit current_path
      }

      context 'in profile panel' do
        before {
          3.times { FactoryGirl.create(:post, user: user) }
          visit current_path
        }

        it { should have_link(user.name, href: user_path(user)) }
        it { should have_link(user.screen_name, href: user_path(user)) }

        # posts
        it { should have_link(I18n.t('views.users.show.navigation.posts'), href: user_path(user)) }
        it 'should display posts count' do
          expect(page).to have_selector '.user-profile-posts-count', user.posts.count
        end

        # # followers
        # it 'should display followers count' do
          # expect(page).to have_selector '#user-profile-followers', user.followers.count
        # end

        # # following
        # it 'should display following count' do
          # expect(page).to have_selector '#user-profile-following', user.following.count
        # end
      end

      context 'in feed panel' do
        context 'in post form', js: true do
          it { should have_selector('textarea#content-main-post-form-text') }

          it 'submit button should be initially hidden' do
            expect(page.find('#content-main-post-form-submit', visible: false)).not_to be_visible
          end

          context 'when focus on textarea' do
            before {
              page.find('#content-main-post-form-text').trigger('focus')
            }

            it 'submit button should be visible' do
              expect(page.find('#content-main-post-form-submit')).to be_visible
            end

            context 'with empty text' do
              it 'should be disabled post button' do
                expect(page).to have_selector('#content-main-post-form-submit:disabled')
              end

              context 'and then when blur the textarea' do
                before {
                  page.find('#content-main-post-form-text').trigger('blur')
                }
                it 'submit button should be hidden' do
                  expect(page.find('#content-main-post-form-submit', visible: false)).not_to be_visible
                end
              end
            end

            context 'with some text' do
              before { fill_in 'content-main-post-form-text', with: 'Hello World' }

              it 'should be enabled post button' do
                expect(page).to have_selector('#content-main-post-form-submit')
                expect(page).not_to have_selector('#content-main-post-form-submit:disabled')
              end

              it 'should display textarea count in normal color' do
                expect(page).not_to have_selector('.posts-head .post-form .text-danger')
              end

              context 'and then when blur the textarea' do
                before {
                  page.find('#content-main-post-form-text').trigger('blur')
                }
                it 'submit button should be visible' do
                  expect(page.find('#content-main-post-form-submit')).to be_visible
                end
              end

              context 'after submit' do
                it 'should create a new post' do
                  expect { click_button 'content-main-post-form-submit' }.to change(Post, :count).by(1)
                end
              end
            end

            context "with text that's length is near limit" do
              before { fill_in 'content-main-post-form-text', with: 'a' * 131 }

              it 'should display textarea count in danger color' do
                expect(page).to have_selector('.posts-head .post-form .text-danger')
              end
            end

            context 'with too long text' do
              before { fill_in 'content-main-post-form-text', with: 'a' * 141 }
              it 'should be disabled post button' do
                expect(page).to have_selector('#content-main-post-form-submit:disabled')
              end

              it 'should display textarea count in danger color' do
                expect(page).to have_selector('.posts-head .post-form .text-danger')
              end
            end
          end

        end

        context 'in pagination' do
          before {
            (UsersController::POST_PAGE_SIZE + 1).times {
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

        # context 'in post form' do
        # end
      end


    end
  end

  describe 'GET /home/about' do
    before { visit home_about_path }

    it { should have_title(page_title('About')) }
    it { should have_content('Home#about') }
  end
end
