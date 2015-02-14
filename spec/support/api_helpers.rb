module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end
end
