require 'rails_helper'


describe Message::Favoritedable, type: :model do
  let (:message) { FactoryGirl.create(:message) }
  subject { message }

  describe '#favorite_relationships' do
    it { should respond_to(:favorite_relationships) }
    it { should have_many(:favorite_relationships)
                  .class_name('Favorite')
                  .dependent(:destroy) }
  end

  describe '#favorite_users' do
    it { should respond_to(:favorite_users) }
    it { should have_many(:favorite_users)
                  .through(:favorite_relationships)
                  .source(:user) }
  end

  describe '#favorited_by' do
    subject { message.favorited_by(user) }

    let (:message) { FactoryGirl.create(:message) }
    let (:user)    { FactoryGirl.create(:user) }

    context 'when favorited by the user' do
      let! (:favorite) { FactoryGirl.create(:favorite, user: user, message: message) }
      it 'should return the Favorite id' do
        should eq(favorite.id)
      end
    end

    context 'when not favorited by the user' do
      let! (:favorite) { FactoryGirl.create(:favorite, message: message) }
      it { should be_nil }
    end
  end
end
