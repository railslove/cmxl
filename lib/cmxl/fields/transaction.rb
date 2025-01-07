module Cmxl
  module Fields
    class Transaction < Field
      self.tag = 61
      self.parser = %r{^(?<date>\d{6})(?<entry_date>\d{4})?(?<credit_debit_indicator>D|C|RD|RC|ED|EC)(?<currency_letter>[a-zA-Z])?(?<amount>\d{1,12},\d{0,2})(?<swift_code>(?:N|F|S).{3})(?<reference>NONREF|(.(?!\/\/)){,16}([^\/]){,1})((?:\/\/)(?<bank_reference>[^\n]{,16}))?((?:\n)(?<supplementary>.{,34}))?$}

      attr_accessor :details

      def add_meta_data(content)
        self.details = Cmxl::Fields::StatementDetails.parse(content) unless content.nil?
      end

      def sha
        Digest::SHA2.new.update(source).to_s
      end

      def credit?
        credit_debit_indicator.include?('C')
      end

      def debit?
        credit_debit_indicator.include?('D')
      end

      def storno_credit?
        warn "[DEPRECATION] `storno_credit?` is deprecated.  Please use `reversal_credit?` instead. It will be removed in version 3.0."
        reversal_credit?
      end

      def reversal_credit?
        credit? && storno?
      end

      def storno_debit?
        warn "[DEPRECATION] `storno_debit?` is deprecated.  Please use `reversal_debit?` instead. It will be removed in version 3.0."
        reversal_debit?
      end

      def reversal_debit?
        debit? && storno?
      end

      def storno?
        warn "[DEPRECATION] `storno?` is deprecated.  Please use `reversal?` instead. It will be removed in version 3.0."
        reversal?
      end

      def reversal?
        credit_debit_indicator.include?('R')
      end

      def expected_credit?
        credit? && expected?
      end

      def expected_debit?
        debit? && expected?
      end

      def expected?
        credit_debit_indicator.include?('E')
      end

      def credit_debit_indicator
        data['credit_debit_indicator'].to_s
      end

      def funds_code
        warn "[DEPRECATION] `funds_code` is deprecated.  Please use `credit_debit_indicator` instead. It will be removed in version 3.0."
        data['credit_debit_indicator'].to_s
      end

      def storno_flag
        reversal? ? 'R' : ''
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

      def primanota
        details.primanota if details
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
          'storno' => reversal?,
          'reversal' => reversal?,
          'expected' => expected?,
          'funds_code' => credit_debit_indicator,
          'credit_debit_indicator' => credit_debit_indicator,
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
