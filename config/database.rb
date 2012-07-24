if Padrino.env = :development
	logger = Logger.new('test.log')
end
MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'licensing_development'
  when :production  then MongoMapper.database = 'licensing_production'
  when :test        then MongoMapper.database = 'licensing_test'
end
