# == Schema Information
#
# Table name: authentications
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  provider     :string           not null
#  uid          :string           not null
#  account_name :string           not null
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_authentications_on_user_id  (user_id)
#

require 'rails_helper'

describe Authentication, type: :model do
  let (:authentication) { FactoryGirl.create(:authentication) }

  subject { authentication }

  it 'original authentication should be valid' do
    should be_valid
  end

  describe '#user' do
    it { should respond_to(:user) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  describe '#provider' do
    it { should respond_to(:provider) }
    it { should validate_presence_of(:provider) }
  end

  describe '#account_name' do
    it { should respond_to(:account_name) }
    it { should validate_presence_of(:account_name) }
  end

  describe '#url' do
    it { should respond_to(:url) }
  end


  describe '#deletable' do
    subject { authentication.deletable? }

    context 'when the user has already set password' do
      before { authentication.user.encrypted_password = 'hogefuga' }
      it { should be_truthy }
    end

    context 'when the user has not set password yes' do
      before { authentication.user.encrypted_password = nil }

      context 'and has only this authentication' do
        it { should be_falsey }
      end

      context 'and has more than one authentication' do
        before { FactoryGirl.create(
          :authentication,
          user: authentication.user,
          provider: 'github'
        ) }
        it { should be_truthy }
      end
    end
  end
end
