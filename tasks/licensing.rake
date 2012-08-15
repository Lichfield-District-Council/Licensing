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
				:refval => row["LICASE_REFVAL"],
				:keyval => row["LICASE_KEYVAL"],
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
				
			app.activities.clear
			app.notices.clear	
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
		if row["LIPERMIT"] != "" && row["LIPERMIT_LIEVENT"] != "TEMP"
			app = Application.find_by_keyval(row["LIPERMIT_PKEYVAL"])
			
			unless app.nil?
			
				row["LIPERMIT_LIPERMIT"] = Codes.where(:category => "LIPERMIT", :code => row["LIPERMIT_LIPERMIT"]).first.description rescue nil
				row["LIPERMIT_LICYCLE"] = Codes.where(:category => "LICYCLE", :code => row["LIPERMIT_LICYCLE"]).first.description rescue nil
				
					app.activities.build(
						:type => row["LIPERMIT_LIPERMIT"],
						:cycle =>  row["LIPERMIT_LICYCLE"],
						:open => row["LIPERMIT_OPENT"],
						:close => row["LIPERMIT_CLOST"]
					)
					
				app.save
			
			end
			
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
		
		app = Application.find_by_keyval(row["LITEMPNOTICES_PKEYVAL"])
		
		unless app.nil?
				
			row["LITEMPNOTICES_DATERECV"] = Date.parse(row["LITEMPNOTICES_DATERECV"]).to_mongo rescue nil
			row["LITEMPNOTICES_STARTDT"] = Date.parse(row["LITEMPNOTICES_STARTDT"]).to_mongo rescue nil
			row["LITEMPNOTICES_ENDDT"] = Date.parse(row["LITEMPNOTICES_ENDDT"]).to_mongo rescue nil
			
			app.notices.build(
				:receiveddate => row["LITEMPNOTICES_DATERECV"],
				:startdate => row["LITEMPNOTICES_STARTDT"],
				:enddate => row["LITEMPNOTICES_ENDDT"],
				:days => row["LITEMPNOTICES_EVENTDAYS"],
				:hours => row["LITEMPNOTICES_EVENTHRS"]
			)
			
			app.save
		
		end
	end	
end