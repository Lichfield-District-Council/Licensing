MongoMapper.connection = Mongo::Connection.new('localhost', nil)

case Padrino.env
  when :development then MongoMapper.database = 'licensing_development'
  when :production  then MongoMapper.database = 'licensing_production'
  when :test        then MongoMapper.database = 'licensing_test'
end
