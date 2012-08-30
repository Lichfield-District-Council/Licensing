xml.instruct!
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:georss" => "http://www.georss.org/georss" do
 xml.channel do

   xml.title       "Lichfield District Council - Licensing Applications"
   xml.link        "http://licensing.lichfielddc.gov.uk"

   @applications.each do |app|
     xml.item do
       xml.title       app.occupier + ", " + app.address
       xml.link        "http://licensing.lichfielddc.gov.uk/view/#{app.refval}"
       xml.guid        "http://licensing.lichfielddc.gov.uk/view/#{app.refval}"
       xml.description app.details
       xml.georss :featurename do
       	xml.text! app.address
       end
       xml.georss :point do
       	xml.text! app.latlng[0].to_s + ' ' + app.latlng[1].to_s
       end
       xml.pubDate app.receiveddate.strftime("%a, %d %b %Y %H:%M:%S %z") rescue nil
     end
   end

 end
end