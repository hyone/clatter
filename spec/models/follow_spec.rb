# == Schema Information
#
# Table name: follows
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_follows_on_followed_id                  (followed_id)
#  index_follows_on_follower_id                  (follower_id)
#  index_follows_on_follower_id_and_followed_id  (follower_id,followed_id) UNIQUE
#

require 'rails_helper'


describe Follow, type: :model do
  let (:follower) { FactoryGirl.create(:user) }
  let (:followed) { FactoryGirl.create(:user) }
  let (:follow) { follower.follow_relationships.build(followed_id: followed.id) }

  subject { follow }

  it { should be_valid }

  describe '#follower' do
    it { should respond_to(:follower) }

    it { should validate_presence_of(:follower) }
    it { should belong_to(:follower).class_name(:User) }

    it 'should return follower' do
      expect(follow.follower).to eq(follower)
    end
  end

  describe '#followed' do
    it { should respond_to(:followed) }

    it { should validate_presence_of(:followed) }
    it { should belong_to(:followed).class_name(:User) }

    it 'should return followed' do
      expect(follow.followed).to eq(followed)
    end
  end
end
