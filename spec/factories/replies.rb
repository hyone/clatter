FactoryGirl.define do
  factory :reply do
    message
    association :to_message, factory: :message
    association :to_user, factory: :user
  end
end
