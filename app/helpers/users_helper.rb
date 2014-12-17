module UsersHelper
  def provider_name(provider)
    s = provider.to_s
    case s
    when 'google_oauth2' then 'google'
    else s
    end
  end

  def text_connect_provider(provider)
    "#{ I18n.t('views.users.form.connect_with') } #{provider_name(provider)}"
  end

  def text_disconnect_provider(provider)
    I18n.t('views.users.form.disconnect_provider', provider: provider_name(provider))
  end

  def t_user(key)
    I18n.t("activerecord.attributes.user.#{key}")
  end
end
