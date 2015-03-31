# == Schema Information
#
# Table name: favorites
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  message_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_favorites_on_message_id              (message_id)
#  index_favorites_on_user_id                 (user_id)
#  index_favorites_on_user_id_and_message_id  (user_id,message_id) UNIQUE
#

require 'rails_helper'


describe Favorite, type: :model do
  let (:favorite) { FactoryGirl.create(:favorite) }

  subject { favorite }

  it { should be_valid }

  describe '#user' do
    it { should respond_to(:user) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  describe '#message' do
    it { should respond_to(:message) }
    it { should validate_presence_of(:message) }
    it { should belong_to(:message) }
  end
end
