require 'rails_helper'


describe 'Home pages', type: :feature, js: true do
  subject { page }

  describe 'GET /' do
    before { visit root_path }

    it { should have_title(page_title) }

    context 'as guest' do
      it { should have_content(
        I18n.t('views.home.index.welcome_message', appname: I18n.t('views.generic.appname'))
      ) }
      it { should have_link(I18n.t('views.home.index.signup_now'), new_user_registration_path) }
    end

    context 'as user' do
      let (:user) { FactoryGirl.create(:user) }
      before {
        signin user
        visit current_path
      }

      context 'in profile panel' do
        before {
          FactoryGirl.create_list(:message, 3, user: user)
          FactoryGirl.create_list(:follow, 4, follower: user)
          FactoryGirl.create_list(:follow, 5, followed: user)
          visit current_path
        }

        it { should have_link(user.name, href: user_path(user)) }
        it { should have_link(user.screen_name, href: user_path(user)) }

        # messages
        it "should have messages link with its count" do
          expect(page).to have_link(
            I18n.t('views.home.index.profile.messages'),
            href: user_path(user)
          )
          expect(page).to have_selector(
            '.home-profile-messages-count',
            text: user.messages.count
          )
        end

        # following
        it "should have following link with its count" do
          expect(page).to have_link(
            I18n.t('views.home.index.profile.following'),
            href: following_user_path(user)
          )
          expect(page).to have_selector(
            '.home-profile-following',
            text: user.followed_users.count
          )
        end

        # followers
        it "should have followers link with its count" do
          expect(page).to have_link(
            I18n.t('views.home.index.profile.followers'),
            href: followers_user_path(user)
          )
          expect(page).to have_selector(
            '.home-profile-followers',
            text: user.followers.count
          )
        end
      end

      context 'in timeline panel' do
        context 'when has some messages' do
          before {
            (UsersController::MESSAGE_PAGE_SIZE + 1).times {
              FactoryGirl.create(:message, user: user)
            }
            visit current_path
          }

          it 'should not have greeting text' do
            should_not have_selector('.empty-description', text: I18n.t('views.home.index.empty_description'))
          end

          context 'in pagination' do
            it { should have_selector('ul.pagination') }

            it 'should list each feed in page 1' do
              User.page(1).per(UsersController::MESSAGE_PAGE_SIZE).each do |user|
                expect(page).to have_selector('li', text: user.screen_name)
              end
            end
          end
        end

        context 'when has not any messages' do
          it 'should have greeting text' do
            should have_selector('.empty-description', text: I18n.t('views.home.index.empty_description'))
          end
        end
      end

    end
  end


  describe 'GET /about' do
    before { visit about_path }

    it { should have_title(page_title('About')) }
    it { should have_content('Home#about') }
  end


  describe 'GET /mentions' do
    before { visit mentions_path }

    context 'as guest' do
      it 'redirect to the sign in page' do
        expect(current_path).to eq(new_user_session_path)
      end
    end

    context 'as user' do
      let (:user) { FactoryGirl.create(:user) }
      before { 
        signin user
        visit mentions_path
      }

      its(:status_code) { should eq(200) }

      describe 'content' do
        it { should have_link(I18n.t('views.menu_panel.mentions'), mentions_path) }

        context 'when has not any messages' do
          context 'when "filter" parameter is none' do
            it 'should have greeting text' do
              should have_selector(
                '.empty-description',
                text: I18n.t('views.home.mentions.empty_description_all')
              )
            end
          end

          context 'when "filter" parameter is "following"' do
            before { visit mentions_path(filter: 'following') }

            it 'should have greeting text' do
              should have_selector(
                '.empty-description',
                text: I18n.t('views.home.mentions.empty_description_people_you_follow')
              )
            end
          end
        end

        context 'when has some messages' do
          let! (:followed_user) {
            u = FactoryGirl.create(:user)
            FactoryGirl.create(:follow, follower: user, followed: u)
            u
          }
          let! (:reply_from_followed_user) { FactoryGirl.create(
            :message_with_reply,
            user: followed_user,
            users_replied_to: [user]
          ) }
          let! (:reply_from_other) { FactoryGirl.create(
            :message_with_reply,
            users_replied_to: [user]
          ) }

          context 'when "filter" parameter is none' do
            before { visit current_path }

            it { should have_link(
              I18n.t('views.home.mentions.people_you_follow'),
              mentions_path(filter: 'following')
            ) }

            it 'should have all replies' do
              expect(page).to have_selector("#message-#{reply_from_followed_user.id}")
              expect(page).to have_selector("#message-#{reply_from_other.id}")
            end
          end

          context 'when "filter" parameter is "following"' do
            before { visit mentions_path(filter: 'following') }

            it { should have_link(I18n.t('views.home.mentions.all'), mentions_path) }

            it 'should have replies from followed users' do
              expect(page).to have_selector("#message-#{reply_from_followed_user.id}")
              expect(page).not_to have_selector("#message-#{reply_from_other.id}")
            end
          end
        end
      end
    end
  end


  describe 'GET /search' do
    before { visit search_path }

    def search(keyword)
      visit current_path
      fill_in  'navigation-search-input', with: keyword
      click_on 'navigation-search-submit'
    end

    shared_examples 'no results' do
      let (:keyword) { 'no-match-keywords' }
      before {
        search keyword
        click_on 'search-menu-mode-users' if mode == 'users'
      }

      it 'should display no result message' do
        expect(page).to have_selector(
          '.empty-description',
          I18n.t('views.home.search.empty_description_html', mode: mode, word: keyword)
        )
      end
    end

    # type = :normal
    #   modal message form
    # type = :foldable
    #   foldable message form
    shared_examples 'searchable' do |type = :guest|
      if type == :user
        let (:user) { FactoryGirl.create(:user) }
        before { signin user }
      end

      before { visit search_path }

      context 'in menu' do
        it { should have_selector('#search-menu-mode-messages') }
        it { should have_selector('#search-menu-mode-users') }

        case type
        when :guest
          it { should_not have_selector('#search-menu-range-all', visible: false) }
          it { should_not have_selector('#search-menu-range-followed-users', visible: false) }
        when :user
          it { should have_selector('#search-menu-range-all') }
          it { should have_selector('#search-menu-range-followed-users') }
        end
      end

      context 'in messages search' do
        context 'with matched results' do
          let! (:message_match1)  { FactoryGirl.create(:message, text: 'keyword 1') }
          let! (:message_match2)  { FactoryGirl.create(:message, text: 'some keyword 2') }
          let! (:message_nomatch) { FactoryGirl.create(:message, text: 'other text') }

          before { search 'keyword' }

          it 'should display only matched messages' do
            expect(page).to have_selector("#message-#{message_match1.id}").and \
                            have_selector("#message-#{message_match2.id}")
            expect(page).not_to have_selector("#message-#{message_nomatch.id}", visible: false)
          end

          if type == :user
            context "when click 'People You follow' menu" do
              let! (:message_followed_match) {
                FactoryGirl.create(
                  :message,
                  text: 'hoge keyword',
                  user: FactoryGirl.create(:follow, follower: user).followed
                )
              }
              let! (:message_followed_nomatch) {
                FactoryGirl.create(
                  :message,
                  text: 'other text',
                  user: FactoryGirl.create(:follow, follower: user).followed
                )
              }

              before { click_on 'search-menu-range-followed-users' }

              it 'should display only matched messages from followed users' do
                expect(page).to have_selector("#message-#{message_followed_match.id}")
                expect(page).not_to have_selector("#message-#{message_match1.id}", visible: false)
                expect(page).not_to have_selector("#message-#{message_followed_nomatch.id}", visible: false)
              end
            end
          end
        end

        context 'with no result' do
          include_examples 'no results' do
            let (:mode) { 'messages' }
          end
        end
      end

      context 'in users search' do
        context 'with matched results' do
          let! (:user_match1)  { FactoryGirl.create(:user, screen_name: 'a_keyword_user') }
          let! (:user_match2)  { FactoryGirl.create(:user, name: 'keyword2 user') }
          let! (:user_match3)  { FactoryGirl.create(:user, description: 'hoge fuga keyword-description') }
          let! (:user_nomatch) { FactoryGirl.create(:user, screen_name: 'no_match_user') }

          before {
            search 'keyword'
            click_on 'search-menu-mode-users'
          }

          it 'should display only matched users' do
            expect(page).to have_selector("#user-#{user_match1.id}").and \
                            have_selector("#user-#{user_match2.id}").and \
                            have_selector("#user-#{user_match3.id}")
            expect(page).not_to have_selector("#user-#{user_nomatch.id}", visible: false)
          end

          if type == :user
            context "when click 'People You follow' menu" do
              let! (:user_followed_match) {
                u = FactoryGirl.create(:user, screen_name: 'a_keyword3_user')
                FactoryGirl.create(:follow, follower: user, followed: u).followed
              }
              let! (:user_followed_nomatch) {
                u = FactoryGirl.create(:user, screen_name: 'no_match_user2')
                FactoryGirl.create(:follow, follower: user, followed: u).followed
              }

              before { click_on 'search-menu-range-followed-users' }

              it 'should display only matched users in followed users' do
                expect(page).to have_selector("#user-#{user_followed_match.id}")
                expect(page).not_to have_selector("#user-#{user_match1.id}", visible: false)
                expect(page).not_to have_selector("#user-#{user_match2.id}", visible: false)
                expect(page).not_to have_selector("#user-#{user_match3.id}", visible: false)
                expect(page).not_to have_selector("#user-#{user_followed_nomatch.id}", visible: false)
              end
            end
          end
        end

        context 'with no result' do
          include_examples 'no results' do
            let (:mode) { 'users' }
          end
        end
      end
    end


    context 'as guest' do
      include_examples 'searchable', :guest
    end

    context 'as user' do
      include_examples 'searchable', :user
    end
  end
end
