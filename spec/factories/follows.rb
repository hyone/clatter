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

FactoryGirl.define do
  factory :follow do
    association :follower, factory: :user
    association :followed, factory: :user

    initialize_with {
      Follow.where(
        follower_id: follower.id,
        followed_id: followed.id
      ).first_or_create
    }
  end
end
