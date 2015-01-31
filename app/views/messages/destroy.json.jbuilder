json.response do
  json.status @status
  json.messages @messages
  json.date DateTime.now
end

json.results do
  json.message do
    json.partial! @message
  end
end
