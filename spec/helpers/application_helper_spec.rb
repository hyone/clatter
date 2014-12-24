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

  describe '#active?' do
    let (:request) { instance_double('ActionDispatch::Request') }
    before {
      allow(request).to receive(:path_info) { '/home' }
    }
    subject { active?(url) }

    context 'with "/home"' do
      let (:url) { '/home' }
      it { should be_truthy }
    end

    context 'with "/about"' do
      let (:url) { '/about' }
      it { should be_falsey }
    end

    context 'with nil' do
      let (:url) { nil }
      it { should be_falsey }
    end
  end
end
