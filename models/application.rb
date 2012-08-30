class Application
  include MongoMapper::Document
  ensure_index [[:latlng, '2d']]

  key :_id, String
  key :refval, String
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
  
  many :activities, :class_name => 'Activity', :foreign_key => :pkeyval
  many :notices, :class_name => 'Notice', :foreign_key => :pkeyval
end

class Activity
  include MongoMapper::Document

  key :pkeyval, String
  key :keyval, String
  key :type, String  
  key :cycle, String
  key :open, String
  key :close, String
  timestamps!
  
  belongs_to :application, :class_name => 'Application'
end

class Notice
  include MongoMapper::Document

  key :pkeyval, String
  key :keyval, String
  key :recieveddate, Date
  key :startdate, Date
  key :enddate, Date
  key :days, String  
  key :hours, String
  key :activities, Array
  timestamps!

  belongs_to :application, :class_name => 'Application'
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

class Comment
	include MongoMapper::Document
	
	key :refval, String
	key :name, String
	key :email, String
	key :address, String
	key :tel, String
	key :comments, String
	key :website, String

	validates_presence_of :name
	validates_presence_of :address
	validates_presence_of :comments
	validates :website, :length => { :is => 0 }
end