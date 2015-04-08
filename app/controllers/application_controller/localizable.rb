class ApplicationController
  module Localizable
    extend ActiveSupport::Concern

    included do
      before_action :set_locale
    end

    private

    def set_locale
      I18n.locale = locale_in_params ||
        locale_in_user ||
        locale_in_accept_language ||
        I18n.default_locale
    end

    def locale_in_params
      if params[:lang].present?
        params[:lang].to_sym.presence_in(I18n.available_locales) || I18n.default_locale
      else
        nil
      end
    end

    def locale_in_user
      current_user && current_user.lang
    end

    def locale_in_accept_language
      request
        .env['HTTP_ACCEPT_LANGUAGE']
        .to_s
        .split(',')
        .map { |ln| ln[0..1].to_sym }
        .select { |ln| I18n.available_locales.include?(ln) }
        .first
    end
  end
end
