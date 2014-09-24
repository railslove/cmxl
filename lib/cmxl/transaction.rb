module Cmxl
  class Transaction
    attr_accessor :statement_line, :details

    def initialize(statement_line, details = nil)
      self.statement_line = statement_line
      self.details = details
    end

    def statement_line=(line)
      @statement_line = Cmxl::Fields::StatementLine.parse(line) unless line.nil?
    end

    def details=(line)
      @details = Cmxl::Fields::StatementDetails.parse(line) unless line.nil?
    end

    def debit?
      self.statement_line.debit?
    end
    def credit?
      self.statement_line.credit?
    end
    def amount
      self.statement_line.amount
    end
    def sign
      self.statement_line.sign
    end
    def funds_code
      self.statement_line.funds_code
    end
    def amount_in_cents
      self.statement_line.amount_in_cents
    end
    def date
      self.statement_line.date
    end
    def entry_date
      self.statement_line.entry_date
    end
    def funds_code
      self.statement_line.funds_code
    end
    def currency_letter
      self.statement_line.currency_letter
    end
    def swift_code
      self.statement_line.swift_code
    end
    def reference
      self.statement_line.reference
    end
    def bank_reference
      self.statement_line.bank_reference
    end
    def description
      self.details.description if self.details
    end
    def information
      self.details.information if self.details
    end
    def bic
      self.details.bic if self.details
    end
    def name
      self.details.name if self.details
    end
    def iban
      self.details.iban if self.details
    end
    def sepa
      self.details.sepa if self.details
    end
    def sub_fields
      self.details.sub_fields if self.details
    end

    def to_h
      {}.tap do |h|
        h.merge!(self.statement_line.to_h)
        h.merge!(self.details.to_h) if self.details
      end
    end
    alias :to_hash :to_h
    def to_json(*args)
      to_h.to_json(*args)
    end
  end

end
