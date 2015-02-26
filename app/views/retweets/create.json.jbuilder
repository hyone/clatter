json.partial! 'shared/response', status: @status, messages: @response_messages

if @status == :success
  json.results do
    json.retweet do
      json.extract! @retweet, :id
      json.user do
        json.partial! @retweet.user
      end
      json.message do
        json.partial! @retweet.message
      end
    end
  end
end

