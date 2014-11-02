require 'bson'
require 'json'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require_relative 'utils/object_id_monkey_patch'

module Calendar
  class Server < Sinatra::Base
    include Calendar::ObjectIdMonkeyPatch
    register Sinatra::Namespace

    def tasks
      settings.tasks
    end

    namespace '/tasks' do
      get '/' do
        json tasks.find.to_a
      end

      get '/for_date/:year-:month-:day' do |year, month, day|
        target_date = Time.new(year.to_i, month.to_i, day.to_i)
        end_date = target_date + 3600 * 24
        json (tasks.find date: {:$gte => target_date,
                                :$lt => end_date}).to_a
      end

      post do
        task = JSON.parse(request.body.read)
        p task
        task["date"] = DateTime.parse(task["date"]).to_time
        new_id = BSON::ObjectId.new
        task[:_id] = new_id
        tasks.insert task
        json tasks.find_one(_id: new_id)
      end

      put do
        task = JSON.parse(request.body.read)
        task[:date] = DateTime.parse(task[:date]).to_time
        new_id = BSON::ObjectId.new(task[:_id])
        tasks.update({_id: new_id}, task, {multi: true})
        json tasks.find_one(_id: new_id)
      end

      delete '/:id' do |id|
        json tasks.find_and_remove(_id: BSON::ObjectId.new(id))
      end
    end
  end
end