FactoryGirl.define do
  factory :favorite do
    user
    message

    initialize_with {
      Favorite.where(
        user: user,
        message: message
      ).first_or_create
    }
  end
end
