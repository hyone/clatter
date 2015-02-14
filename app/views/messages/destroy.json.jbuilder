json.partial! 'shared/response', status: @status, messages: @response_messages

json.results do
  json.message do
    json.partial! @message
  end
end
