# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  screen_name            :string           not null
#  name                   :string           not null
#  description            :string(160)
#  url                    :string
#  profile_image          :string
#  messages_count         :integer          default(0), not null
#  following_count        :integer          default(0), not null
#  followers_count        :integer          default(0), not null
#  favorites_count        :integer          default(0), not null
#  time_zone              :string           default("UTC")
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_screen_name           (screen_name) UNIQUE
#

require 'rails_helper'

describe User, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  subject { user }

  it 'original user should be valid' do
    should be_valid
  end

  describe '#screen_name' do
    it { should respond_to(:screen_name) }
    it { should validate_presence_of(:screen_name) }
    it { should validate_length_of(:screen_name).is_at_most(15) }

    context 'when given proper screen_name' do
      let(:screen_names) do
        %w(
          a
          a19
          _hoge
          fuga_hoge
          fuga_hoge_hello
        )
      end
      it 'should be valid' do
        screen_names.each do |screen_name|
          expect(subject).to allow_value(screen_name).for(:screen_name)
        end
      end
    end

    context 'when given wrong format screen_name' do
      let(:screen_names) do
        %w(
          1abc
          _234
          hoge.fuga
          hoge-fuga
          long_long_long_name
        )
      end
      it 'should not be valid' do
        screen_names.each do |screen_name|
          expect(subject).not_to allow_value(screen_name).for(:screen_name)
        end
      end
    end
  end

  describe '#name' do
    it { should respond_to(:name) }
    it { should validate_presence_of(:name) }
  end

  describe '#description' do
    it { should respond_to(:description) }
    it { should validate_length_of(:description).is_at_most(160) }
  end

  describe '#url' do
    it { should respond_to(:url) }
  end

  describe '#email' do
    it { should respond_to(:email) }
  end

  describe '#profile_image' do
    it { should respond_to(:profile_image) }
  end
end
