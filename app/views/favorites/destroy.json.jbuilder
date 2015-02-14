json.partial! 'shared/response', status: @status, messages: @response_messages

if @status == :success
  json.results do
    json.favorite do
      json.extract! @favorite, :id
      json.user do
        json.partial! @favorite.user
        json.favorites_count @favorite.user.favorites.count
      end
      json.message do
        json.partial! @favorite.message
      end
    end
  end
end

