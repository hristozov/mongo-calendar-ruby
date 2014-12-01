require 'mongoid'

class Task
  include Mongoid::Document

  field :title, type: String
  field :text, type: String
  field :date, type: Date
  field :priority, type: Integer
end