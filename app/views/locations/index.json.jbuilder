json.array!(@locations) do |location|
  json.extract! location, :id
  json.extract! location, :address
  json.extract! location, :longitude
  json.extract! location, :latitude
  json.url location_url(location, format: :json)
end
