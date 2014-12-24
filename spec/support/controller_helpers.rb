module ControllerHelpers
  def signin(user = instance_double('User'))
    if user.nil?
      # to disable warnings
      allow_message_expectations_on_nil
      allow(request.env['warden']).to receive(:authenticate!).and_throw(:warden, scope: :user)
      allow(controller).to receive(:current_user).and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
    end
  end
end
