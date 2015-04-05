class User
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def ransackable_attributes(_auth_object = nil)
        %w( screen_name name description )
      end
    end
  end
end
