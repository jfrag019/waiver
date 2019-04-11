require 'sinatra'
require 'rest-client'

get '/waivers' do

today = Date.today
twoDaysBefore = Date.today-1

today_s = today.strftime("%F")
twoDaysBefore_s = twoDaysBefore.strftime("%F")

url = 'https://services1.arcgis.com/CvuPhqcTQpZPT9qY/arcgis/rest/services/Waivers_and_Warrants/FeatureServer/0/query?where=1%3D1+AND+%28Address+IS+NOT+NULL%29++AND+%28ApplicationType+LIKE+%27Waiver%27%29+AND+%28IssuanceDate+%3E+%27'+twoDaysBefore_s+'%27+AND+IssuanceDate+%3C+%27'+today_s+'%27%29&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&returnGeodetic=false&outFields=*&returnGeometry=true&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=pgeojson&token='

response = RestClient.get url

collection = JSON.parse(response.body)

puts collection.inspect

features = collection['features'].map do |record|

	id = "#{record['properties']['ID']}"

	title ="There is waiver activity at #{record['properties']['Address']} for process number #{record['properties']['ApplicationNumber']}. The current status is #{record['properties']['ApplicationStatus']}."

{
    'id' => id,
    'type' => 'Feature',
    'properties' => record['properties'].merge('title' => title),
    'geometry' => {
        'type' => 'Point',
        'coordinates' => [
          record['properties']['Longitude'].to_f,
          record['properties']['Latitude'].to_f
        ]
      }
  }	

end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
