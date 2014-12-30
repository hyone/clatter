FactoryGirl.define do
  factory :message, aliases: [:reply_to] do
    user
    text { Faker::Lorem.sentence(3) }
    created_at { rand(0..240).hours.ago }

    trait :replied do
      reply_to
    end

    factory :message_replied, traits: [:replied]
  end
end
