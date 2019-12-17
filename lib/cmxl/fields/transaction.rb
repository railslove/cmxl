module Cmxl
  module Fields
    class Transaction < Field
      self.tag = 61
      self.parser = %r{^(?<date>\d{6})(?<entry_date>\d{4})?(?<storno_flag>R?)(?<funds_code>[CD]{1})(?<currency_letter>[a-zA-Z])?(?<amount>\d{1,12},\d{0,2})(?<swift_code>(?:N|F).{3})(?<reference>NONREF|(.(?!\/\/)){,16}([^\/]){,1})((?:\/\/)(?<bank_reference>[^\n]{,16}))?((?:\n)(?<supplementary>.{,34}))?$}

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
        return if !date || !data['entry_date']

        e_date = to_date(data['entry_date'], date.year)
        # we assume that valuta (date) and entry_date have a close connection. so valuta and entry_date should not be
        # further apart than one month. this leads to some edge cases

        # valuta is in january while entry_date is in december => entry_date was done the year before
        e_date = to_date(data['entry_date'], date.year - 1) if date.month == 1 && e_date.month == 12

        # valuta is in december but entry_date is in january => entry_date is actually in the year after valuta
        e_date = to_date(data['entry_date'], date.year + 1) if date.month == 12 && e_date.month == 1

        e_date
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

      def transaction_id
        details.transaction_id if details
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
          'currency_letter' => currency_letter
        }.tap do |h|
          h.merge!(details.to_h) if details
          h.merge!(supplementary.to_h) if supplementary.source
        end
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
