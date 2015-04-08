
# require:
# - path: method return path on which we test
#
shared_examples 'a user requirable page' do
  before { visit path }

  it 'redirect to signin page' do
    expect(current_path).to eq(new_user_session_path)
  end

  it { expect(page).to have_alert(:notice, I18n.t('alert.please_sign_in')) }
end
