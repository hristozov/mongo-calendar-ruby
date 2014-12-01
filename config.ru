require File.join(File.dirname(__FILE__), 'lib/server')
require 'mongoid'

Mongoid.load!('mongoid.yml')

app = Calendar::Server
run app
