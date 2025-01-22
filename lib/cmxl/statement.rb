require 'digest/sha2'
module Cmxl
  class Statement
    attr_accessor :source, :collection, :fields, :lines

    # Public: Initiate a new Statement and parse a provided single statement string
    # It directly parses the source and initiates file and transaction objects.
    #
    # Example:
    #
    # Cmxl::Statement.new(single_statement_string)
    def initialize(source)
      self.source = source
      self.fields = []
      self.lines = []
      strip_headers! if Cmxl.config[:strip_headers]
      parse!
    end

    def transactions
      fields.select { |field| field.is_a?(Fields::Transaction) }
    end

    # Internal: Parse a single MT940 statement and extract the line data
    #
    def parse!
      self.fields = []

      lines = source.split(/(^:[0-9A-Z]{2,3}:)/m).reject(&:empty?).each_slice(2).map(&:join)

      lines.map do |line|
        if line =~ /\A:86:/
          if field = fields.last
            field.add_meta_data(line)
          end
        else
          field = Field.parse(line)
          fields << field unless field.nil?
        end
      end
    end

    def strip_headers!
      source.gsub!(/\A.*?(?=^:)/m, '') # beginning: strip every line in the beginning that does not start with a :
      source.gsub!(/^[^:]*\z/, '') # end: strip every line in the end that does not start with a :
      source.strip!
    end

    # Public: SHA2 of the provided source
    # This is an experiment of trying to identify statements. The MT940 itself might not provide a unique identifier
    #
    # Returns the SHA2 of the source
    def sha
      Digest::SHA2.new.update(source).to_s
    end

    def reference
      field(20).reference
    end

    #Get generation date from field 20. If generation date is not provided in field 20, method will fall back to field 13 if present.
    def generation_date
      field(20).date || (field(13).nil? ? nil : field(13).date)
    end

    def account_identification
      field(25)
    end

    def opening_balance
      field(60, 'F')
    end

    def opening_or_intermediary_balance
      field(60)
    end

    def closing_balance
      field(62, 'F')
    end

    def closing_or_intermediary_balance
      field(62)
    end

    def available_balance
      field(64)
    end

    def legal_sequence_number
      field(28).source
    end

    def vmk_credit_summary
      field(90, 'C')
    end

    def vmk_debit_summary
      field(90, 'D')
    end

    def mt942?
      fields.any? { |field| field.is_a? Fields::FloorLimitIndicator }
    end

    def to_h
      mt942? ? mt942_hash : mt940_hash
    end

    def mt940_hash
      {
        'reference' => reference,
        'sha' => sha,
        'generation_date' => generation_date,
        'account_identification' => account_identification.to_h,
        'opening_balance' => opening_balance.to_h,
        'closing_balance' => closing_balance.to_h,
        'available_balance' => available_balance.to_h,
        'transactions' => transactions.map(&:to_h),
        'fields' => fields.map(&:to_h)
      }
    end

    def mt942_hash
      {
        'reference' => reference,
        'sha' => sha,
        'generation_date' => generation_date,
        'account_identification' => account_identification.to_h,
        'debit_summary' => vmk_debit_summary.to_h,
        'credit_summary' => vmk_credit_summary.to_h,
        'transactions' => transactions.map(&:to_h),
        'fields' => fields.map(&:to_h)
      }
    end

    def to_hash
      to_h
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    # Internal: Field accessor
    # returns a field object by a given tag
    #
    # Example:
    # field(20)
    # field(61,'F')
    def field(tag, modifier = nil)
      fields.detect { |field| field.tag == tag.to_s && (modifier.nil? || field.modifier == modifier) }
    end
  end
end
