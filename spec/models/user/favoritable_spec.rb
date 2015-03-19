require 'rails_helper'


describe User::Favoritable, type: :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  describe '#favorite_relationships' do
    it { should respond_to(:favorite_relationships) }
    it { should have_many(:favorite_relationships)
                  .class_name('Favorite')
                  .dependent(:destroy) }
  end

  describe '#favorites' do
    it { should respond_to(:favorites) }
    it { should have_many(:favorites)
                  .through(:favorite_relationships)
                  .source(:message) }
  end
end
