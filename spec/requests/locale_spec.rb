require 'rails_helper'

describe 'I18n' do
  let(:user) { FactoryGirl.build(:user, screen_name: 'hoge', email: 'hoge@example.com', lang: 'en') }

  context 'with lang=ja parameter' do
    it 'should use ja locale' do
      get root_path(lang: :ja)
      expect(I18n.locale).to eq(:ja)
    end

    context 'and with current_user.lang=en' do
      before do
        # p user
        signin user
        get root_path(lang: :ja)
      end

      it 'should use ja locale' do
        expect(I18n.locale).to eq(:ja)
      end
    end

    context 'and with HTTP_ACCEPT_LANGUAGE=en' do
      before { get root_path(lang: :ja), nil, HTTP_ACCEPT_LANGUAGE: 'en' }

      it 'should use ja locale' do
        expect(I18n.locale).to eq(:ja)
      end
    end
  end

  context 'with current_user.lang=ja' do
    before do
      user.lang = 'ja'
      signin user
    end

    it 'should use ja locale' do
      get root_path
      expect(I18n.locale).to eq(:ja)
    end

    context 'and with HTTP_ACCEPT_LANGUAGE=en' do
      before { get root_path, nil, HTTP_ACCEPT_LANGUAGE: 'en' }

      it 'should use ja locale' do
        expect(I18n.locale).to eq(:ja)
      end
    end
  end

  context 'with HTTP_ACCEPT_LANGUAGE=ja_JP' do
    before { get root_path, nil, HTTP_ACCEPT_LANGUAGE: 'ja_JP' }

    it 'should use ja locale' do
      expect(I18n.locale).to eq(:ja)
    end
  end

  context 'with default lang (without specifying)' do
    it 'should use en locale' do
      get root_path
      expect(I18n.locale).to eq(:en)
    end
  end
end
