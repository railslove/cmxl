module Cmxl
  module Fields
    class AccountBalance < Field
      self.tag = 60
      self.parser = /(?<funds_code>\A[a-zA-Z]{1})(?<date>\d{6})(?<currency>[a-zA-Z]{3})(?<amount>[\d|,|\.]{4,15})/i

      def date
        to_date(self.data['date'])
      end

      def credit?
        self.data['funds_code'].to_s.upcase == 'C'
      end

      def debit?
        !credit?
      end

      def amount
        self.data['amount'].gsub(',','.').to_f * self.sign
      end

      def sign
        self.credit? ? 1 : -1
      end

      def amount_in_cents
        self.data['amount'].gsub(',', '').gsub('.','').to_i * self.sign
      end

      def to_h
        {
          'date' => date,
          'funds_code' => funds_code,
          'credit' => credit?,
          'debit' => debit?,
          'currency' => currency,
          'amount' => amount,
          'amount_in_cents' => amount_in_cents,
          'sign' => sign
        }
      end
    end
  end
end
