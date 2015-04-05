require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#page_title' do
    subject { page_title(text) }

    context 'with "home"' do
      let(:text) { 'home' }
      it { should eq("home | #{ I18n.t('views.generic.base_title') }") }
    end

    context 'with ""' do
      let(:text) { '' }
      it { should eq(I18n.t('views.generic.base_title')) }
    end

    context 'with nil' do
      let(:text) { nil }
      it { should eq(I18n.t('views.generic.base_title')) }
    end

    context 'with arguments' do
      it { expect(page_title).to eq(I18n.t('views.generic.base_title')) }
    end
  end

  describe '#username_formatted' do
    subject { username_formatted(user) }

    context 'with user' do
      let(:user) { FactoryGirl.create(:user) }
      it { should eq("#{user.name} (@#{user.screen_name})") }
    end

    context 'with nil' do
      it { expect { username_formatted(nil) }.to raise_error(Exception) }
    end
  end

  describe '#provider_name' do
    subject { provider_name(provider) }

    context 'with "github"' do
      let(:provider) { 'github' }
      it { should == 'github' }
    end

    context 'with "google_oauth2"' do
      let(:provider) { 'google_oauth2' }
      it { should == 'google' }
    end

    context 'with "twitter"' do
      let(:provider) { 'twitter' }
      it { should == 'twitter' }
    end
  end

  describe '#bindable_path' do
    subject { bindable_path(:user, arg) }

    context 'with binding text' do
      let(:arg) { '{{user.id}}' }
      it { should eq('/u/{{user.id}}') }
    end

    context 'with no binding text' do
      let(:arg) { 3 }
      it { should eq(user_path(arg)) }
    end
  end
end
