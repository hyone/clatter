require 'rails_helper'

describe UsersHelper, :type => :helper do
  describe '#provider_name' do
    subject { provider_name(provider) }

    context 'with "github"' do
      let (:provider) { 'github' }
      it { should == 'github' }
    end

    context 'with "google_oauth2"' do
      let (:provider) { 'google_oauth2' }
      it { should == 'google' }
    end

    context 'with "twitter"' do
      let (:provider) { 'twitter' }
      it { should == 'twitter' }
    end
  end
end
