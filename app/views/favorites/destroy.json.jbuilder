json.response do
  json.status @status
  json.messages @response_messages
  json.date DateTime.now
end

if @status == :success
  json.results do
    json.favorite do
      json.extract! @favorite, :id
      json.user do
        json.partial! @user
        json.favorites_count @user.favorites.count
      end
      json.message do
        json.partial! @message
      end
    end
  end
end

