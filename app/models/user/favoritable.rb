class User
  module Favoritable
    extend ActiveSupport::Concern
    include HasManyThrough

    included do
      has_many_through 'favorite', source: :message
    end
  end
end
