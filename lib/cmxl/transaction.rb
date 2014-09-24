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
      self.details.try(:description)
    end
    def information
      self.details.try(:information)
    end
    def bic
      self.details.try(:bic)
    end
    def name
      self.details.try(:name)
    end
    def iban
      self.details.try(:iban)
    end
    def sepa
      self.details.try(:sepa)
    end
    def sub_fields
      self.details.try(:sub_fields)
    end

    def to_h
      {}.tap do |h|
        h.merge!(self.statement_line.to_h)
        h.merge!(self.details.to_h) if self.details
      end
    end
  end

end
