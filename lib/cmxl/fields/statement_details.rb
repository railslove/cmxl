module Cmxl
  module Fields
    class StatementDetails < Field
      self.tag = 86
      self.parser = /(?<transaction_code>\w{3})(?<details>(?<seperator>.).*)/

      def sub_fields
        @sub_fields ||= if self.data['details'] =~ /#{Regexp.escape(self.data['seperator'])}(\d{2})/
            Hash[self.data['details'].scan(/#{Regexp.escape(self.data['seperator'])}(\d{2})([^#{Regexp.escape(self.data['seperator'])}]*)/)]
          else
            {}
          end
      end

      def description
        self.sub_fields['00'] || self.data['details']
      end

      def information
        info = (20..29).to_a.collect {|i| self.sub_fields[i.to_s] }.join('')
        info.empty? ? self.description : info
      end

      def sepa
        if self.information =~ /([A-Z]{4})\+/
          Hash[*self.information.split(/([A-Z]{4})\+/).reject(&:empty?)]
        else
          {}
        end
      end

      def bic
        self.sub_fields['30']
      end

      def name
        [self.sub_fields['32'], self.sub_fields['33']].compact.join(" ")
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
