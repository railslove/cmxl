module Cmxl
  module Fields
    class StatementDetails < Field
      self.tag = 86
      self.parser = /(?<transaction_code>\w{3})(?<details>(?<seperator>.).*)/

      class << self
        def parse(line)
          # remove line breaks as they are allowed via documentation but not needed for data-parsing
          super line.gsub(/\R?/, '')
        end
      end

      def sub_fields
        @sub_fields ||= if data['details'] =~ /#{Regexp.escape(data['seperator'])}(\d{2})/
                          Hash[data['details'].scan(/#{Regexp.escape(data['seperator'])}(\d{2})([^#{Regexp.escape(data['seperator'])}]*)/)]
                        else
                          {}
          end
      end

      def description
        sub_fields['00'] || data['details']
      end

      def information
        info = (20..29).to_a.collect { |i| sub_fields[i.to_s] }.join('')
        info.empty? ? description : info
      end

      def sepa
        if information =~ /([A-Z]{4})\+/
          Hash[
            *information.split(/([A-Z]{4})\+/)[1..-1].tap { |info| info << '' if info.size.odd? }
          ]
        else
          {}
        end
      end

      def primanota
        sub_fields['10']
      end

      def bic
        sub_fields['30']
      end

      def name
        [sub_fields['32'], sub_fields['33']].compact.join(' ')
      end

      def iban
        sub_fields['38'] || sub_fields['31']
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
          'primanota' => primanota,
          'details' => details
        }
      end
    end
  end
end
