require 'rails_helper'


describe 'Message Panel', type: :feature, js: true do
  let! (:user) { FactoryGirl.create(:user) }
  let! (:message) { FactoryGirl.create(:message, user: user) }

  before { visit status_user_path(user, message) }

  subject { page }

  def path(message)
    status_user_path(message.user, message)
  end

  describe 'message text block' do
    include_examples 'a message textable block'
  end

  describe 'message actions block' do
    describe 'reply button' do
      context 'as guest' do
        before {
          signout
          visit path(message)
        }
        it 'reply button should be disabled' do
          expect(page).to have_selector("#reply-to-message-#{message.id}.disabled")
        end
      end
      context 'as user' do
        let (:prefix) { 'content-main' }
        before {
          signin user
          visit path(message)
        }

        context 'when click reply button' do
          before { click_on "reply-to-message-#{message.id}" }
          include_examples 'form is opened'
        end
      end
    end

    describe 'retweet button' do
      include_examples 'a retweetable button'
    end

    describe 'favorite button' do
      include_examples 'a favoritable button'
    end

    describe 'actions button' do
      include_examples 'a message actionable button'

      # don't work...
      # it 'should redirect to root' do
        # expect(current_path).to eq(root_path)
      # end
    end
  end


  describe 'message stats block' do
    # require:
    # - let(:message)  { ... }
    # - let(:favorite) { ... }
    shared_examples 'a message favorable' do
      it { should have_selector('.favorites-count', text: message.reload.favorited_count) }

      it 'should have avator link' do
        should have_xpath("//a[@href='#{user_path(favorite.user)}']")
        should have_xpath("//img[contains(@src, '#{favorite.user.profile_image.small}')]")
      end
    end

    # require:
    # - let(:message) { ... }
    # - let(:retweet) { ... }
    shared_examples 'a message retweetable' do
      it { should have_selector('.retweets-count', text: message.reload.retweeted_count) }

      it 'should have avator link' do
        should have_xpath("//a[@href='#{user_path(retweet.user)}']")
        should have_xpath("//img[contains(@src, '#{retweet.user.profile_image.small}')]")
      end
    end

    context 'with favorited message' do
      let! (:favorite) { FactoryGirl.create(:favorite, message: message) }
      before { visit status_user_path(message.user, message.id) }
      include_examples 'a message favorable'
    end

    context 'with retweeted message' do
      let! (:retweet) { FactoryGirl.create(:retweet, message: message) }
      before { visit status_user_path(message.user, message.id) }
      include_examples 'a message retweetable'
    end

    context 'with both favorited and retweeted message' do
      let! (:favorite) { FactoryGirl.create(:favorite, message: message) }
      let! (:retweet) { FactoryGirl.create(:retweet, message: message) }
      before { visit status_user_path(message.user, message.id) }
      include_examples 'a message retweetable'
      include_examples 'a message favorable'
    end
  end


  describe 'date block' do
    shared_examples 'a time zonable date' do
      let! (:message) { FactoryGirl.create(:message) }
      let! (:login_user) { FactoryGirl.create(:user, time_zone: time_zone) }
      before {
        signin login_user
        visit status_user_path(message.user, message)
      }

      it { should have_content(
        message.created_at.in_time_zone(login_user.time_zone).strftime('%-l:%M %p - %-d %b %Y')
      ) }
    end

    context 'with UTC' do
      let (:time_zone) { 'UTC' }
      include_examples 'a time zonable date'
    end
    context 'with Tokyo' do
      let (:time_zone) { 'Tokyo' }
      include_examples 'a time zonable date'
    end
  end


  describe 'related messages block' do
    context 'with non reply message' do
      it { should_not have_selector('.message-parents', visible: false) }
      it { should_not have_selector(".message-replies-to", visible: false) }
    end

    context 'with conversation' do
      include_context 'a conversation'
      before { visit status_user_path(conversation30.user, conversation30) }

      it 'should have all parent messages' do
        Message.ancestors_of(conversation30).each do |m|
          expect(page).to have_selector(".message-parents #message-#{m.id}")
        end
      end

      it 'should have all reply messages' do
        Message.descendants_of(conversation30).each do |m|
          expect(page).to have_selector(".message-replies-to #message-#{m.id}")
        end
      end
    end
  end

  describe 'message form' do
    context 'as guest' do
      before { signout }
      it 'should not have message form' do
        should_not have_selector('#content-main-message-form', visible: false)
      end
    end

    context 'as user' do
      before {
        signin user
        visit status_user_path(message.user, message.id)
      }

      it 'should have message form' do
        should have_selector('#content-main-message-form')
      end
    end
  end
end
