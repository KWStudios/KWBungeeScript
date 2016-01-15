# encoding: utf-8
db_file = open(File.expand_path('json/db.json',
                                File.dirname(__FILE__)))
db_json = db_file.read
db = JSON.parse(db_json)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://#{db['username']}:"\
"#{db['password']}@"\
"#{db['hostname']}/"\
"#{db['database']}")

# The Servers representing database class
class MinecraftServer
  include DataMapper::Resource
  # property :id,           Serial
  property :name,       String, required: true, length: 255, key: true
  property :server,     String, required: true, length: 255
  property :number,     Integer, required: true
  property :is_used,    Boolean, required: true
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize
