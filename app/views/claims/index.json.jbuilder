json.array!(@claims) do |claim|
  json.extract! claim, :id, :event_id, :user_id
  json.url claim_url(claim, format: :json)
end
