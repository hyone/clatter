require 'rails_helper'


describe User, type: :model do
  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  it 'original user should be valid' do
    should be_valid
  end

  describe '#screen_name' do
    it { should respond_to(:screen_name) }
    it { should validate_presence_of(:screen_name) }
    it { should validate_length_of(:screen_name).is_at_most(15) }

    context 'when given proper screen_name' do
      let (:screen_names) { %w[
        a
        a19
        _hoge
        fuga_hoge
        fuga_hoge_hello
      ] }
      it 'should be valid' do
        screen_names.each do |screen_name|
          expect(subject).to allow_value(screen_name).for(:screen_name)
        end
      end
    end

    context 'when given wrong format screen_name' do
      let (:screen_names) { %w[
        1abc
        _234
        hoge.fuga
        hoge-fuga
        long_long_long_name
      ] }
      it 'should not be valid' do
        screen_names.each do |screen_name|
          expect(subject).not_to allow_value(screen_name).for(:screen_name)
        end
      end
    end
  end

  describe '#name' do
    it { should respond_to(:name) }
    it { should validate_presence_of(:name) }
  end

  describe '#description' do
    it { should respond_to(:description) }
    it { should validate_length_of(:description).is_at_most(160) }
  end

  describe '#url' do
    it { should respond_to(:url) }
  end

  describe '#email' do
    it { should respond_to(:email) }
  end

  describe '#profile_image' do
    it { should respond_to(:profile_image) }
  end
end
