json.partial! 'shared/response', status: @status, messages: @response_messages

if @status == :success
  json.results do
    json.message do
      json.partial! @message
    end
  end
end
