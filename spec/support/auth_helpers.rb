include Warden::Test::Helpers

module AuthHelpers
  def signin(user)
    login_as user, scope: :user
  end

  def signout
    logout(:user)
  end
end
