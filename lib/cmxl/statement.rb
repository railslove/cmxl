require 'digest/sha2'
module Cmxl
  class Statement
    attr_accessor :source, :collection, :transactions, :fields, :lines

    def initialize(source)
      self.source = source
      self.fields = []
      self.lines = []
      self.transactions = []
      self.parse!
    end

    def parse!
      # first we clean uo the source and make concat wraped lines
      self.source.split("\n").each do |line|
        if line.start_with?(':') || self.lines.last.nil?
          self.lines << line.strip
        else
          self.lines.last << line.strip
        end
      end
      # now we check each line. if it is part of a transaction we initate or update a transaction else we parse the field and add it to the fields collection
      self.lines.each do |line|
        if line.match(/\A:61:/)
          self.transactions << Cmxl::Transaction.new(line)
        elsif line.match(/\A:86:/) && !self.transactions.last.nil?
          self.transactions.last.details = line
        else
          self.fields << Field.parse(line)
        end
      end
    end

    def sha
     Digest::SHA2.new.update(self.source).to_s
    end

    def reference
      self.field(20).reference
    end

    def generation_date
      self.field(20).date
    end

    def account_identification
      self.field(25)
    end

    def opening_balance
      self.field(60, 'F')
    end

    def closing_balance
      self.field(62, 'F')
    end

    def available_balance
      self.field(64)
    end


    def field(tag, modifier=nil)
      self.fields.detect {|field| field.tag == tag.to_s && (modifier.nil? || field.modifier == modifier) }
    end
  end
end
