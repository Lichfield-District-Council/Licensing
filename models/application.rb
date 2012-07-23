class Application
  include MongoMapper::Document
  ensure_index [[:latlng, '2d']]

  key :refval, String
  key :applicantname, String
  key :latlng, Array
  key :address, String
  key :occupier, String
  key :type, String
  key :permit, String
  key :casetype, String
  key :tradingname, String
  key :closingdate, Date
  key :recieveddate, Date
  key :details, String
  key :usetype, String
  key :status, String
  timestamps!
  
  many :activities  
end

class Activity
  include MongoMapper::EmbeddedDocument

  key :type, String  
  key :cycle, String
  key :open, String
  key :close, String
end

class Codes
  include MongoMapper::Document
  
  key :category, String
  key :code, String
  key :description, String
end