require 'cmxl/fields/account_balance'
module Cmxl
  module Fields
    class AvailableBalance < AccountBalance
      self.tag = 64
      self.parser = superclass.parser
    end
  end
end
