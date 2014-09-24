require 'date'
module Cmxl
  class Field
    class LineFormatError < StandardError; end
    class Unknown < Field;
      @parser= /(?<source>.*)/
      def to_h
        { tag: tag, modifier: modifier, source: source }
      end
    end
    DATE = /(?<year>\d{0,2})(?<month>\d{2})(?<day>\d{2})/
    attr_accessor :source, :modifier, :match, :data, :tag

    @@parsers = {}
    @@parsers.default = Unknown
    def self.parsers; @@parsers; end

    class << self; attr_accessor :parser; end
    self.parser = /(?<source>.*)/ # default parser

    def self.tag=(tag)
      @tag = tag.to_s
      @@parsers[tag.to_s] = self
    end
    def self.tag
      @tag
    end

    def self.parse(line)
      if line.match(/^:(\d{2,2})(\w)?:(.*)$/)
        tag, modifier, content = $1, $2, $3
        Field.parsers[tag.to_s].new(content, modifier, tag)
      else
        raise LineFormatError, "Wrong line format: #{line.dump}"
      end
    end

    def initialize(source, modifier=nil, tag=nil)
      self.tag = tag
      self.modifier = modifier
      self.source = source
      self.data = {}

      if self.match = self.source.match(self.class.parser)
        self.match.names.each do |name|
          self.data[name] = self.match[name]
        end
      end
    end

    def to_h
      self.data
    end
    alias :to_hash :to_h
    def to_json(*args)
      to_h.to_json(*args)
    end

    def to_date(date, year=nil)
      if match = date.to_s.match(DATE)
        year ||= "20#{match['year']}"
        month = match['month']
        day = match['day']
        Date.new(year.to_i, month.to_i, day.to_i)
      else
        date
      end
    rescue ArgumentError # let's simply ignore invalid dates
      date
    end

    def to_amount_in_cents(value)
      value.gsub(/[,|\.](\d*)/) { $1.ljust(2, '0') }.to_i
    end

    def to_amount(value)
      value.gsub(',','.').to_f
    end

    def method_missing(m, *value)
      if m =~ /=\z/
        self.data[m] = value.first
      else
        self.data[m.to_s]
      end
    end
  end
end
