module Cmxl
  module Fields
    class EntryDate < Field
      self.tag = 13
      self.parser = DATE

      def date
        to_date(source)
      end
    end
  end
end
