module Cmxl
  module Fields
    class StatementLine < Field
      self.tag = 61
      self.parser = /\A(?<date>\d{6})(?<entry_date>\d{4})?(?<funds_code>[a-zA-Z])(?<currency_letter>[a-zA-Z])?(?<amount>\d{1,12},\d{0,2})(?<swift_code>(?:N|F).{3})(?<reference>NONREF|.{0,16})(?:$|\/\/)(?<bank_reference>.*)/i

      def credit?
        self.data['funds_code'].to_s.upcase == 'C'
      end

      def debit?
        !credit?
      end

      def sign
        self.credit? ? 1 : -1
      end

      def amount
        self.data['amount'].gsub(',','.').to_f * sign
      end

      def amount_in_cents
        self.data['amount'].gsub(',', '').gsub('.','').to_i * sign
      end

      def date
        to_date(self.data['date'])
      end
      def entry_date
        to_date(self.data['entry_date'], self.date.year)
      end

      def to_h
        super.merge({
          'date' => date,
          'entry_date' => entry_date,
          'amount' => amount,
          'amount_in_cents' => amount_in_cents,
          'sign' => sign,
          'debit' => debit?,
          'credit' => credit?
        })
      end
    end
  end
end
