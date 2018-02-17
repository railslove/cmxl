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
      self.parse!
    end

    def transactions
      self.fields.select { |field| field.kind_of?(Fields::Transaction) }
    end

    # Internal: Parse a single MT940 statement and extract the line data
    #
    def parse!
      # first we clean uo the source and make concat wraped lines (lines not starting with a ":")
      self.source.split("\n").each do |line|
        if line.start_with?(':') || self.lines.last.nil?
          self.lines << line.strip
        else
          self.lines.last << line.strip
        end
      end

      self.fields = []
      lines.each do |line|
        if line.match(/\A:86:/)
          if field = fields.last
            field.add_meta_data(line)
          end
        else
          field = Field.parse(line)
          self.fields << field unless field.nil?
        end
      end

      # puts "Fixed Fields"
      # puts fields.inspect
      #
      # # Now we check each line for its content ans structure it for further use. If it is part of a transaction we initate or update a transaction else we parse the field and add it to the fields collection
      # self.lines.each do |line|
      #   if line.match(/\A:61:/)
      #     self.transactions << Cmxl::Transaction.new(line)
      #   elsif line.match(/\A:86:/) && !self.transactions.last.nil?
      #     self.transactions.last.details = line
      #   else
      #     field = Field.parse(line)
      #     self.fields << field unless field.nil?
      #   end
      # end
    end

    # Public: SHA2 of the provided source
    # This is an experiment of trying to identify statements. The MT940 itself might not provide a unique identifier
    #
    # Returns the SHA2 of the source
    def sha
      Digest::SHA2.new.update(self.source).to_s
    end

    def reference
      self.field(20).reference
    end

    def generation_date
      self.field(20).date || self.field(13).date
    end

    def account_identification
      self.field(25)
    end

    def opening_balance
      self.field(60, 'F')
    end

    def opening_or_intermediary_balance
      self.field(60)
    end

    def closing_balance
      self.field(62, 'F')
    end

    def closing_or_intermediary_balance
      self.field(62)
    end

    def available_balance
      self.field(64)
    end

    def legal_sequence_number
      self.field(28).source
    end

    def to_h
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
    def field(tag, modifier=nil)
      self.fields.detect {|field| field.tag == tag.to_s && (modifier.nil? || field.modifier == modifier) }
    end
  end
end
