module Cmxl
  module Fields
    class FloorLimitIndicator < Field
      self.tag = 34
      self.parser = /(?<currency>[a-zA-Z]{3})(?<type_indicator>[DC]?)(?<amount>[\d|,|\.]{4,15})/i

      def credit?
        data['type_indicator'].empty? || data['type_indicator'] == 'C'
      end

      def debit?
        data['type_indicator'].empty? || data['type_indicator'] == 'D'
      end

      def amount
        to_amount(data['amount'])
      end
    end
  end
end
