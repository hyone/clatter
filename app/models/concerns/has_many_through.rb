module HasManyThrough
  extend ActiveSupport::Concern

  module ClassMethods
    def has_many_through(name, source:, relationship: :"#{name}s")
      has_many :"#{name}_relationships", class_name: name.camelize, dependent: :destroy
      has_many relationship, through: :"#{name}_relationships", source: source
    end
  end
end
