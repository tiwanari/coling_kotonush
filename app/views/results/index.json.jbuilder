json.array!(@results) do |result|
  json.extract! result, :id, :query_id, :rank, :str_concept
  json.url result_url(result, format: :json)
end
