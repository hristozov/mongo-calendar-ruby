require 'bson'
require 'json'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'

module Calendar
  class Server < Sinatra::Base
    register Sinatra::Namespace

    def tasks
      settings.tasks
    end

    def prepare_before(task)
      task['_id'] = BSON::ObjectId::from_string(task['id']) if task['id']
      task['date'] = DateTime.parse(task['date']).to_time
      task.delete('id')
      task
    end

    def prepare_after(task)
      task['id'] = task['_id'].to_s
      task['date'] = task['date'].strftime('%FT%TZ') if task['date']
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
        new_id = BSON::ObjectId.new
        task['_id'] = new_id
        tasks.insert_one task
        just_inserted_task = tasks.find({_id: new_id}).limit(1).first
        json prepare_after(just_inserted_task)
      end

      put do
        task = prepare_before(JSON.parse(request.body.read))
        tasks.update_one({_id: task['_id']}, task)
        just_updated_task = tasks.find({_id: task['_id']}).limit(1).first
        json prepare_after(just_updated_task)
      end

      delete '/:id' do |id|
        query = {_id: BSON::ObjectId::from_string(id)}
        task = tasks.find(query).limit(1).first
        tasks.delete_one(query)
        json prepare_after(task)
      end
    end
  end
end