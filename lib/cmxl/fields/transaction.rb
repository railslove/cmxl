module Cmxl
  module Fields
    class Transaction < Field
      self.tag = 61
      self.parser = /^(?<date>\d{6})(?<entry_date>\d{4})?(?<is_storno>R?)(?<funds_code>[CD]{1})(?<currency_letter>[a-zA-Z])?(?<amount>\d{1,12},\d{0,2})(?<swift_code>(?:N|F).{3})(?<reference>NONREF|.{0,16})(?:$|\/\/)(?<bank_reference>.*)/i

      attr_accessor :details

      def add_meta_data(content)
        self.details = Cmxl::Fields::StatementDetails.parse(content) unless content.nil?
      end

      def sha
        Digest::SHA2.new.update(source).to_s
      end

      def credit?
        self.data['funds_code'].to_s.upcase == 'C'
      end

      def debit?
        self.data['funds_code'].to_s.upcase == 'D'
      end

      def storno_credit?
        credit? && is_storno?
      end

      def storno_debit?
        debit? && is_storno?
      end

      def is_storno?
        !storno_flag.empty?
      end

      def funds_code
        [storno_flag, super].join
      end

      def storno_flag
        data['is_storno']
      end

      def sign
        self.credit? ? 1 : -1
      end

      def amount
        to_amount(self.data['amount'])
      end

      def amount_in_cents
        to_amount_in_cents(self.data['amount'])
      end

      def date
        to_date(self.data['date'])
      end

      def entry_date
        if self.data['entry_date'] && self.date
          if date.month == 1 && date.month < to_date(self.data['entry_date'], self.date.year).month
            to_date(self.data['entry_date'], self.date.year - 1)
          else
            to_date(self.data['entry_date'], self.date.year)
          end
        end
      end

      # Fields from details

      def description
        details.description if details
      end
      def information
        details.information if details
      end
      def bic
        details.bic if details
      end
      def name
        details.name if details
      end
      def iban
        details.iban if details
      end
      def sepa
        details.sepa if details
      end
      def sub_fields
        details.sub_fields if details
      end

      def to_h
        {
          'sha' => sha,
          'date' => date,
          'entry_date' => entry_date,
          'amount' => amount,
          'amount_in_cents' => amount_in_cents,
          'sign' => sign,
          'debit' => debit?,
          'credit' => credit?,
          'storno_credit?' => storno_credit?,
          'storno_debit?' => storno_debit?,
          'funds_code' => funds_code,
          'swift_code' => swift_code,
          'reference' => reference,
          'bank_reference' => bank_reference,
          'currency_letter' => currency_letter
        }.merge(details ? details.to_h : {})
      end

      def to_hash
        to_h
      end

      def to_json(*args)
        to_h.to_json(*args)
      end
    end
  end
end
