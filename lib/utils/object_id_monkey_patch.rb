require 'bson'

module Calendar
  module ObjectIdMonkeyPatch
    BSON::ObjectId.class_eval do
      def to_json(*args)
        to_s.to_json
      end

      def as_json(*args)
        to_s.as_json
      end
    end
  end
end