require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#title' do
    subject { title(text) }

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
      it { expect(title).to be == 'TwitterApp' }
    end
  end
end
