require 'rubygems'
require 'weary'
require 'httparty'
require 'json'

class Mapit
	def self.postcode(code)
		(Weary.get "http://mapit.mysociety.org/postcode/#{code.gsub(' ', '')}").perform
	end
	
	def self.partial(code)
		(Weary.get "http://mapit.mysociety.org/postcode/partial/#{code.gsub(' ', '')}").perform
	end
	
	def self.point(x, y, srid)
		JSON.parse HTTParty.get("http://mapit.mysociety.org/point/#{srid}/#{y},#{x}").response.body
	end
	
	def self.pointbox(x, y, srid)
		(Weary.get "http://mapit.mysociety.org/point/#{srid}/#{y},#{x}/box").perform
	end
  
	def self.GetPostcode(postcode)
	
		result = Hash.new
	
		if postcode.blank?
			result["error"] = "No postcode entered"
		else
			begin
				postcode = self.postcode(postcode)
				
				result["council"] = Hash.new
				result["lat"] = postcode["wgs84_lat"]
				result["lng"] = postcode["wgs84_lon"]
				
				postcode["areas"].each do |id, info|
					if info["type"] == 'DIW' # District Ward
						district = postcode["areas"].fetch(info["parent_area"].to_s)
						result["council"]["id"] = district["codes"]["ons"] 
						result["council"]["name"] = district["name"] 
					elsif info["type"] == 'CED' # Electoral District 
						county = postcode["areas"].fetch(info["parent_area"].to_s)
						result["county"] = Hash.new
						result["county"]["id"] = county["codes"]["ons"] 
						result["county"]["name"] = county["name"]
					elsif ['COP','LBW','LGE','MTW','UTE','UTW'].include?(info["type"])
						council = postcode["areas"].fetch(info["parent_area"].to_s)
						result["council"]["id"] = council["codes"]["ons"]
						result["council"]["name"] = council["name"]
					end
				end
			rescue Exception => e
				result["error"] = e.inspect
			end
		end
		
		return result
	end
	
	def self.GetLatlng(lat, lng)
		latlng = self.point(lat, lng, 4326)
		
		result = Hash.new
		result["council"] = Hash.new
		
		latlng.each do |id, info|
			if info["type"] == 'DIW' # District Ward
				district = latlng.fetch(info["parent_area"].to_s)
				result["council"]["id"] = district["codes"]["ons"] 
				result["council"]["name"] = district["name"] 
			elsif info["type"] == 'CED' # Electoral District 
				county = latlng.fetch(info["parent_area"].to_s)
				result["county"] = Hash.new
				result["county"]["id"] = county["codes"]["ons"] 
				result["county"]["name"] = county["name"]
			elsif ['COP','LBW','LGE','MTW','UTE','UTW'].include?(info["type"])
				council = latlng.fetch(info["parent_area"].to_s)
				result["council"]["id"] = council["codes"]["ons"]
				result["council"]["name"] = council["name"]
			end
		end
		
		return result
	end

end