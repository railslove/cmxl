module Cmxl
  module Fields
    class StatementNumber < Field
      self.tag = 28
      self.parser = /(?<statement_number>\d{1,5})(?:\/(?<sequence_number>\d{1,5}))?/
    end
  end
end
