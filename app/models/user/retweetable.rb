class User
  module Retweetable
    extend ActiveSupport::Concern
    include HasManyThrough

    included do
      has_many_through 'retweet', source: :message
    end
  end
end
