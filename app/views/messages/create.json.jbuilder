json.response do
  json.status @status
  json.message @response_message
  json.details @response_details
  json.date DateTime.now
end

if @status == :success
  json.results do
    json.message do
      json.partial! @message
    end
  end
end
