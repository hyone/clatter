module DeviseHelper
  def devise_error_messages!(resource)
    return '' if resource.errors.empty?
    render 'shared/error_messages', object: resource
  end

  def devise_error_messages?(resource)
    resource.errors.empty? ? false : true
  end
end
