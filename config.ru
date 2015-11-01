require File.join(File.dirname(__FILE__), 'lib/server')
require 'mongo'

app = Calendar::Server
client = Mongo::Client.new(['localhost:27017'],
                           :database=> 'calendar')
app.set :tasks, client['tasks']
run app
