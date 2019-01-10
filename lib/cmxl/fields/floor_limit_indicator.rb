module Cmxl
  module Fields
    class FloorLimitIndicator < Field
      self.tag = 34
      self.parser = /(?<currency>[a-zA-Z]{3})(?<debit_mark>[DC]?)(?<amount>[\d|,|\.]{4,15})/i

      def credit?
        data['debit_mark'].empty? || data['debit_mark'] == 'C'
      end

      def debit?
        data['debit_mark'].empty? || data['debit_mark'] == 'D'
      end

      def currency
        data['currency']
      end

      def amount
        to_amount(data['amount'])
      end
    end
  end
end
