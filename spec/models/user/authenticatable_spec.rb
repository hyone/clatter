require 'rails_helper'

describe User::Authenticatable, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  subject { user }

  describe '#login' do
    it { should respond_to(:login) }
  end
end
