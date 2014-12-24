FactoryGirl.define do
  factory :post, aliases: [:reply_to] do
    user
    text { Faker::Lorem.sentence(3) }
    created_at { rand(0..240).hours.ago }

    trait :replied do
      reply_to
    end

    factory :post_replied, traits: [:replied]
  end
end
