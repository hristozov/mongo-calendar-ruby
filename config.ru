require File.join(File.dirname(__FILE__), 'lib/server')
require 'mongo'

app = Calendar::Server
app.set :tasks, Mongo::MongoClient.new['calendar']['tasks']
run app
