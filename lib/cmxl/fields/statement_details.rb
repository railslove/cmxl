module Cmxl
  module Fields
    class StatementDetails < Field
      self.tag = 86
      self.parser = /(?<transaction_code>\w{3})(?<details>(?<seperator>.).*)/

      def sub_fields
        @sub_fields ||= self.data['details'].split(/#{Regexp.escape(self.data['seperator'])}(\d{2})/).reject(&:empty?).each_slice(2).to_h
      end

      def description
        self.sub_fields['00']
      end

      def information
        (20..29).to_a.collect {|i| self.sub_fields[i.to_s] }.join('')
      end

      def sepa
        self.information.split(/([A-Z]{4})\+/).reject(&:empty?).each_slice(2).to_h
      end

      def bic
        self.sub_fields['30']
      end

      def name
        "#{self.sub_fields['32']}#{self.sub_fields['33']}"
      end

      def iban
        self.sub_fields['38'] || self.sub_fields['31']
      end

      def to_h
        {
          'bic' => bic,
          'iban' => iban,
          'name' => name,
          'sepa' => sepa,
          'information' => information,
          'description' => description,
          'sub_fields' => sub_fields,
          'transaction_code' => transaction_code,
          'details' => details
        }
      end
    end
  end
end
