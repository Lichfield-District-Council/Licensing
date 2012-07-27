task :import => :environment do
	require 'httparty'
	require 'nokogiri'
	require 'easting_northing'
		
	doc = Nokogiri::XML HTTParty.get("http://www.lichfielddc.gov.uk/site/custom_scripts/test.php").response.body
	
	rows = []
	count = 0
	
	doc.search('ROW').each do |i|
		rows << i.children.inject({}){|hsh,el| hsh[el.name] = el.inner_text;hsh}
	end
	
	rows.each do |row|
		app = Application.first_or_create(:refval => row["REFVAL"])
		
		closingdate = Date.parse(row["REPRESPDT"]) rescue nil
		recieveddate = Date.parse(row["RECPTD"]) rescue nil
		
		latlng = EastingNorthing.eastingNorthingToLatLong(row["MAPEAST"].to_i, row["MAPNORTH"].to_i)
		
		row["LICNTYPE"] = Codes.where(:category => "LICNTYPE", :code => row["LICNTYPE"]).first.description rescue nil
		row["LIUSE"] = Codes.where(:category => "LIUSE", :code => row["LIUSE"]).first.description rescue nil
		row["LISTAT"] = Codes.where(:category => "LISTAT", :code => row["LISTAT"]).first.description rescue nil
		
		case row["LICASETYPE"]
		when "NEW"
			row["LICASETYPE"] = "New"
		when "VAR"
			row["LICASETYPE"] = "Variation"
		when "REN"
			row["LICASETYPE"] = "Renewal"
		when "REV"
			row["LICASETYPE"] = "Review"
		when "TRN"
			row["LICASETYPE"] = "Transfer"
		else
			row["LICASETYPE"] = nil
		end
			
		
		app.update_attributes(
			:refval => row["REFVAL"],
			:applicantname => row["FULLNAME"],
			:applicantaddress => row["LIADDRESS"],
			:latlng => [latlng["lat"], latlng["long"]],
			:address => row["ADDRESS"],
			:occupier => row["CPOCCUP"],
			:permit => row["LIPERMIT"],
			:type => row["LICNTYPE"],
			:casetype => row["LICASETYPE"],
		    :tradingname => row["CPTRADEAS"],
		    :closingdate => closingdate,
		    :recieveddate => recieveddate,
		    :details => row["LICDETAILS"],
		    :usetype => row["LIUSE"],
		    :status => row["LISTAT"],
		)
			
		app.activities.clear	
		app.save
	end
	
	rows.each do |row|
	
		if row["LIPERMIT"] != ""
			app = Application.find_by_refval(row["REFVAL"])
			
			row["LIPERMIT"] = Codes.where(:category => "LIPERMIT", :code => row["LIPERMIT"]).first.description rescue nil
			row["LICYCLE"] = Codes.where(:category => "LICYCLE", :code => row["LICYCLE"]).first.description rescue nil
				
				app.activities.build(
					:type => row["LIPERMIT"],
					:cycle =>  row["LICYCLE"],
					:open => row["OPENT"],
					:close => row["CLOST"]
				)
				
			app.save
		end
	end
	
end