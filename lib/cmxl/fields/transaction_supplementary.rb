module Cmxl
  module Fields
    class TransactionSupplementary < Field

      attr_accessor :source, :initial, :charges

      class << self
        def parse(line)
          initial = $1 if line.match(initial_parser)
          charges = $1 if line.match(charges_parser)
          new(line, initial, charges)
        end

        def initial_parser; %r{((?:\/OCMT\/)(?<initial>[a-zA-Z]{3}[\d,]{1,15}))} end
        def charges_parser; %r{((?:\/CHGS\/)(?<charges>[a-zA-Z]{3}[\d,]{1,15}))} end
      end


      def initialize(line, initial, charges)
        self.source = line
        self.initial = initial
        self.charges = charges
      end

      def initial_amount_in_cents
        to_amount_in_cents(initial[3..-1]) if initial
      end

      def initial_currency
        initial[0..2] if initial
      end

      def charges_in_cents
        to_amount_in_cents(charges[3..-1]) if charges
      end

      def charges_currency
        charges[0..2] if charges
      end
    end
  end
end
