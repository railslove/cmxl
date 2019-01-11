module Cmxl
  module Fields
    class VmkSummary < Field
      self.tag = 90
      self.parser = /(?<entries>\d{,53})(?<currency>\w{3})(?<amount>[\d|,|\.]{1,15})/i

      def credit?
        modifier == 'C'
      end

      def debit?
        modifier == 'D'
      end

      def entries
        data['entries'].to_i
      end

      def amount
        to_amount(data['amount'])
      end

      def to_h
        {
          type: debit? ? 'debit' : 'credit',
          entries: entries,
          amount: amount,
          currency: currency
        }
      end
    end
  end
end
