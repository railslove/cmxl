module Cmxl
  module Fields
    class Transaction < Field
      self.tag = 61
      self.parser = %r{^(?<date>\d{6})(?<entry_date>\d{4})?(?<storno_flag>R?)(?<funds_code>[CD]{1})(?<currency_letter>[a-zA-Z])?(?<amount>\d{1,12},\d{0,2})(?<swift_code>(?:N|F).{3})(?<reference>NONREF|.{0,16})((?:\/\/)(?<bank_reference>[^\n]*))?((?:[\n])?(?<supplementary>.{,34}))$}

      attr_accessor :details

      def add_meta_data(content)
        self.details = Cmxl::Fields::StatementDetails.parse(content) unless content.nil?
      end

      def sha
        Digest::SHA2.new.update(source).to_s
      end

      def credit?
        data['funds_code'].to_s.casecmp('C').zero?
      end

      def debit?
        data['funds_code'].to_s.casecmp('D').zero?
      end

      def storno_credit?
        credit? && storno?
      end

      def storno_debit?
        debit? && storno?
      end

      def storno?
        !storno_flag.empty?
      end

      def funds_code
        data.values_at('storno_flag', 'funds_code').join
      end

      def storno_flag
        data['storno_flag']
      end

      def sign
        credit? ? 1 : -1
      end

      def amount
        to_amount(data['amount'])
      end

      def amount_in_cents
        to_amount_in_cents(data['amount'])
      end

      def date
        to_date(data['date'])
      end

      def entry_date
        if data['entry_date'] && date
          if date.month == 1 && date.month < to_date(data['entry_date'], date.year).month
            to_date(data['entry_date'], date.year - 1)
          else
            to_date(data['entry_date'], date.year)
          end
        end
      end

      def supplementary
        @supplementary ||= Cmxl::Fields::TransactionSupplementary.parse(data['supplementary'])
      end

      # Fields from supplementary

      def initial_amount_in_cents
        supplementary.initial_amount_in_cents
      end
      def initial_currency
        supplementary.initial_currency
      end
      def charges_in_cents
        supplementary.charges_in_cents
      end
      def charges_currency
        supplementary.charges_currency
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
          'storno' => storno?,
          'funds_code' => funds_code,
          'swift_code' => swift_code,
          'reference' => reference,
          'bank_reference' => bank_reference,
          'currency_letter' => currency_letter,
          'initial_amount_in_cents' => initial_amount_in_cents,
          'initial_currency' => initial_currency,
          'charges_in_cents' => charges_in_cents,
          'charges_currency' => charges_currency,
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
