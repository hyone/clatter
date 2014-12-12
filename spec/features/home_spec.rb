require 'rails_helper'


describe 'Home Page' do
  subject { page }

  describe 'GET /' do
    before { visit root_path }

    it { should have_title('TwitterApp') }
    it { should have_content('Home#index') }
  end

  describe 'GET /home/about' do
    before { visit home_about_path }

    it { should have_title('About | TwitterApp') }
    it { should have_content('Home#about') }
  end
end
