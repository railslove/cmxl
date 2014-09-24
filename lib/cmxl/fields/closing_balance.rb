require 'cmxl/fields/account_balance'
module Cmxl
  module Fields
    class ClosingBalance < AccountBalance
      self.tag = 62
      self.parser = superclass.parser
    end
  end
end
