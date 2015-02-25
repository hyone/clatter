FactoryGirl.define do
  factory :retweet do
    user
    message

    initialize_with {
      Retweet.where(
        user: user,
        message: message
      ).first_or_create
    }
  end

end
