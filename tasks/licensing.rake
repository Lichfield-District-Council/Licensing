task :alert => :environment do
	
	alerts = Alert.where(:confirmed => true)
	
	alerts.each do |alert|
		
		EARTH_RADIUS_M = 3959		
		applications = Application.where(:latlng => {'$nearSphere' => [alert.latlng[0], alert.latlng[1]], '$maxDistance' => Float(alert.radius.to_i) / EARTH_RADIUS_M }, '$or' => [{:receiveddate => {:$gte => alert.lastsent.to_mongo, :$lte => Date.to_mongo(Date.today)}}, {'notices.receiveddate' => {:$gte => alert.lastsent.to_mongo, :$lte => Date.to_mongo(Date.today)}}])
		
		puts "#{alert.email} - #{applications.count} applications found!" 
		
		if applications.count > 0
			applications.each do |application|
				puts application.address
				Licensing.deliver(:alerts, :send_alert, alert.email, alert.radius, alert.postcode, alert.hash, application)
			end
		end
		
		alert.update_attributes(:lastsent => Date.to_mongo(Date.today))
		alert.save
	
	end

end

task :import => :environment do
	require 'httparty'
	require 'nokogiri'
	require 'easting_northing'
	
	# Get basic details
	
	puts "Importing basic details..."
		
	doc = Nokogiri::XML HTTParty.get("http://lichfielddc.gov.uk/site/custom_scripts/licensing/licase.php").response.body
	
	rows = []
	count = 0
	
	doc.search('ROW').each do |i|
		rows << i.children.inject({}){|hsh,el| hsh[el.name] = el.inner_text;hsh}
	end
	
	rows.each do |row|
	
		unless row["LICASE_LICNTYPE"] == "LAPERN"
	
			app = Application.first_or_create(:refval => row["REFVAL"])
			
			closingdate = Date.parse(row["LICASE_REPRESPDT"]).to_mongo rescue nil
			receiveddate = Date.parse(row["LICASE_RECPTD"]).to_mongo rescue nil
			validfrom = Date.parse(row["LICASE_ACTCOMND"]).to_mongo rescue nil
			
			if row["LICASE_MAPEAST"] == "000000" && row["LICASE_MAPNORTH"] == "000000"
				latlng = {}
				latlng["lat"] = 0
				latlng["lng"] = 0
			else
				latlng = EastingNorthing.eastingNorthingToLatLong(row["LICASE_MAPEAST"].to_i, row["LICASE_MAPNORTH"].to_i)
			end
			
			row["LICASE_LICNTYPE"] = Codes.where(:category => "LICNTYPE", :code => row["LICASE_LICNTYPE"]).first.description rescue nil
			row["LICASE_LIUSE"] = Codes.where(:category => "LIUSE", :code => row["LICASE_LIUSE"]).first.description rescue nil
			row["LICASE_LISTAT"] = Codes.where(:category => "LISTAT", :code => row["LICASE_LISTAT"]).first.description rescue nil
			
			case row["LICASE_LICASETYPE"]
			when "NEW"
				row["LICASE_LICASETYPE"] = "New"
			when "VAR"
				row["LICASE_LICASETYPE"] = "Variation"
			when "REN"
				row["LICASE_LICASETYPE"] = "Renewal"
			when "REV"
				row["LICASE_LICASETYPE"] = "Review"
			when "TRN"
				row["LICASE_LICASETYPE"] = "Transfer"
			else
				row["LICASE_LICASETYPE"] = nil
			end
				
			
			app.update_attributes(
				:_id => row["LICASE_KEYVAL"],
				:refval => row["LICASE_REFVAL"],
				:applicantname => row["LIPARTY_FULLNAME"],
				:applicantaddress => row["LIPARTY_ADDRESS"],
				:latlng => [latlng["lat"], latlng["long"]],
				:address => row["LICASE_ADDRESS"],
				:occupier => row["LICASE_CPOCCUP"],
				:type => row["LICASE_LICNTYPE"],
				:casetype => row["LICASE_LICASETYPE"],
			    :tradingname => row["LICASE_CPTRADEAS"],
			    :closingdate => closingdate,
			    :receiveddate => receiveddate,
			    :details => row["LICASE_LICDETAILS"],
			    :usetype => row["LICASE_LIUSE"],
			    :status => row["LICASE_LISTAT"],
			    :validfrom => validfrom
			)

			app.save
		end
	end
	
	# Get permitted activities
	
	puts "Importing permitted activities..."
	
	doc = Nokogiri::XML HTTParty.get("http://lichfielddc.gov.uk/site/custom_scripts/licensing/lipermit.php").response.body
	
	rows = []
	count = 0
	
	doc.search('ROW').each do |i|
		rows << i.children.inject({}){|hsh,el| hsh[el.name] = el.inner_text;hsh}
	end
	
	rows.each do |row|
		if row["LIPERMIT_LIPERMIT"] != "" && row["LIPERMIT_LIEVENT"] != "TEMP"
			
			activity = Activity.first_or_create(:keyval => row["LIPERMIT_KEYVAL"])
			
			row["LIPERMIT_LIPERMIT"] = Codes.where(:category => "LIPERMIT", :code => row["LIPERMIT_LIPERMIT"]).first.description rescue nil
			row["LIPERMIT_LICYCLE"] = Codes.where(:category => "LICYCLE", :code => row["LIPERMIT_LICYCLE"]).first.description rescue nil
				
			activity.update_attributes(
				:pkeyval => row["LIPERMIT_PKEYVAL"],
				:type => row["LIPERMIT_LIPERMIT"],
				:cycle =>  row["LIPERMIT_LICYCLE"],
				:open => row["LIPERMIT_OPENT"],
				:close => row["LIPERMIT_CLOST"]
			)
				
			activity.save
			
		end
	end
	
	# Get temporary notices
	
	puts "Importing temporary notices..."
	
	doc = Nokogiri::XML HTTParty.get("http://lichfielddc.gov.uk/site/custom_scripts/licensing/litempnotices.php").response.body
	
	rows = []
	count = 0
	
	doc.search('ROW').each do |i|
		rows << i.children.inject({}){|hsh,el| hsh[el.name] = el.inner_text;hsh}
	end
	
	rows.each do |row|
				
		notice = Notice.first_or_create(:keyval => row["LITEMPNOTICES_KEYVAL"])
						
		row["LITEMPNOTICES_DATERECV"] = Date.parse(row["LITEMPNOTICES_DATERECV"]).to_mongo rescue nil
		row["LITEMPNOTICES_STARTDT"] = Date.parse(row["LITEMPNOTICES_STARTDT"]).to_mongo rescue nil
		row["LITEMPNOTICES_ENDDT"] = Date.parse(row["LITEMPNOTICES_ENDDT"]).to_mongo rescue nil
		
		notice.update_attributes(
			:pkeyval => row["LITEMPNOTICES_PKEYVAL"],
			:receiveddate => row["LITEMPNOTICES_DATERECV"],
			:startdate => row["LITEMPNOTICES_STARTDT"],
			:enddate => row["LITEMPNOTICES_ENDDT"],
			:days => row["LITEMPNOTICES_EVENTDAYS"],
			:hours => row["LITEMPNOTICES_EVENTHRS"]
		)
		
		notice.save
		
	end	
end