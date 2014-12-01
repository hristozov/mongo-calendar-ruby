require 'bson'
require 'json'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require_relative 'model/task'

module Calendar
  class Server < Sinatra::Base
    register Sinatra::Namespace

    def tasks
      settings.tasks
    end

    def prepare_before(task)
      task
    end

    def prepare_after(task)
      task = Hash[task.attributes]
      task['date'] = task['date'].strftime('%FT%TZ') if task['date']
      task
    end

    namespace '/tasks' do
      get '/' do
        json Task.all.to_a.map { |task| prepare_after task }
      end

      get '/for_date/:year-:month-:day' do |year, month, day|
        target_date = Time.new(year.to_i, month.to_i, day.to_i)
        end_date = target_date + 3600 * 24
        results = Task.where(:date.gte => target_date,
                             :date.lt => end_date)
        json results.to_a.map { |task| prepare_after task }
      end

      post do
        parameters = prepare_before(JSON.parse(request.body.read))
        task = Task.create(parameters)
        json prepare_after(task)
      end

      put do
        parameters = prepare_before(JSON.parse(request.body.read))
        task = Task.find(parameters['_id'])
        task.update_attributes(parameters)
        json prepare_after(task)
      end

      delete '/:id' do |id|
        task = Task.find(id)
        task.destroy
        json prepare_after(task)
      end
    end
  end
end