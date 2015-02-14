require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#title' do
    subject { page_title(text) }

    context 'with "home"' do
      let (:text) { 'home' }
      it { should == 'home | TwitterApp' }
    end

    context 'with ""' do
      let (:text) { '' }
      it { should == 'TwitterApp' }
    end

    context 'with nil' do
      let (:text) { nil }
      it { should == 'TwitterApp' }
    end

    context 'with arguments' do
      it { expect(page_title).to be == 'TwitterApp' }
    end
  end


  describe '#username_formatted' do
    subject { username_formatted(user) }

    context 'with user' do
      let (:user) { FactoryGirl.create(:user) }
      it { should eq("#{user.name} (@#{user.screen_name})") }
    end

    context 'with nil' do
      it { expect { username_formatted(nil) }.to raise_error(Exception) }
    end
  end


  describe '#bindable_path' do
    subject { bindable_path(:user, arg) }

    context 'with binding text' do
      let (:arg) { '{{user.id}}' }
      it { should eq('/users/{{user.id}}') }
    end

    context 'with no binding text' do
      let (:arg) { 3 }
      it { should eq(user_path(arg)) }
    end
  end
end
