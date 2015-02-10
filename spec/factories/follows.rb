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
