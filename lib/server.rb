require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'bson'
require_relative 'utils/object_id_monkey_patch'

module Calendar
  class Server < Sinatra::Base
    include Calendar::ObjectIdMonkeyPatch

    def tasks
      settings.tasks
    end

    get '/tasks' do
      json tasks.find.to_a
    end
  end
end