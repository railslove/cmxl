module Cmxl
  module Fields
    class AccountIdentification < Field
      self.tag = 25
      self.parser = /(?<bank_code>\w{8,11})\/(?<account_number>\d{0,23})(?<currency>[A-Z]{3})?|(?<country>[a-zA-Z]{2})(?<ban>\d{11,36})/i

      def iban
        "#{country}#{ban}"
      end
    end
  end
end
