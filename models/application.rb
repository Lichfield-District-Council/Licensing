class Application
  include MongoMapper::Document
  ensure_index [[:latlng, '2d']]

  key :refval, String
  key :keyval, String
  key :applicantname, String
  key :latlng, Array
  key :address, String
  key :occupier, String
  key :type, String
  key :casetype, String
  key :tradingname, String
  key :closingdate, Date
  key :recieveddate, Date
  key :details, String
  key :usetype, String
  key :status, String
  key :validfrom, Date
  timestamps!
  
  many :activities  
  many :notices  
end

class Activity
  include MongoMapper::EmbeddedDocument

  key :type, String  
  key :cycle, String
  key :open, String
  key :close, String
  
  belongs_to :application
end

class Notice
  include MongoMapper::EmbeddedDocument

  key :keyval, String
  key :recieveddate, Date
  key :startdate, Date
  key :enddate, Date
  key :days, String  
  key :hours, String
  key :activities, Array

  belongs_to :application
end

class Codes
  include MongoMapper::Document
  
  key :category, String
  key :code, String
  key :description, String
end

class Alert
  include MongoMapper::Document
  ensure_index [[:latlng, '2d']]
  
  key :email, String
  key :postcode, String
  key :latlng, Array
  key :radius, String
  key :lastsent, Date
  key :hash, String
  key :confirmed, Boolean
  
  validates_presence_of :email
  validates_presence_of :postcode
  validates_presence_of :radius
  validates_uniqueness_of :email
end