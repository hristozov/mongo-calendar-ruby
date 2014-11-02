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

    def prepare_before(task)
      task['_id'] = task['id']
      task.delete('id')
      task
    end

    def prepare_after(task)
      task['id'] = task['_id']
      task.delete('_id')
      task
    end

    namespace '/tasks' do
      get '/' do
        json tasks.find.to_a.map { |task| prepare_after task }
      end

      get '/for_date/:year-:month-:day' do |year, month, day|
        target_date = Time.new(year.to_i, month.to_i, day.to_i)
        end_date = target_date + 3600 * 24
        results = tasks.find({date: {:$gte => target_date,
                                     :$lt => end_date}})
        json results.to_a.map { |task| prepare_after task }
      end

      post do
        task = prepare_before(JSON.parse(request.body.read))
        task['date'] = DateTime.parse(task['date']).to_time
        new_id = BSON::ObjectId.new
        task['_id'] = new_id
        tasks.insert task
        json prepare_after(tasks.find_one(_id: new_id))
      end

      put do
        task = prepare_before(JSON.parse(request.body.read))
        task['date'] = DateTime.parse(task[:date]).to_time
        new_id = BSON::ObjectId.new(task[:_id])
        tasks.update({_id: new_id}, task, {multi: true})
        json prepare_after(tasks.find_one(_id: new_id))
      end

      delete '/:id' do |id|
        query = {_id: BSON::ObjectId::from_string(id)}
        task = tasks.find_one(query)
        tasks.remove(query)
        json prepare_after(task)
      end
    end
  end
end