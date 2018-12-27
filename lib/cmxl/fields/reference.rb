module Cmxl
  module Fields
    class Reference < Field
      self.tag = 20
      self.parser = /(?<statement_identifier>[a-zA-Z]{0,2})(?<date>\d{6})(?<additional_number>.*)/i

      def reference
        source
      end

      def date
        to_date(data['date'])
      end

      def to_h
        super.merge('date' => date, 'reference' => source)
      end
    end
  end
end
