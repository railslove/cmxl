require 'date'
module Cmxl
  class Field
    class LineFormatError < StandardError; end
    class Unknown < Field
      @parser = /(?<source>.*)/
      def to_h
        { tag: tag, modifier: modifier, source: source }
      end
    end
    DATE = /(?<year>\d{0,2})(?<month>\d{2})(?<day>\d{2})/.freeze
    attr_accessor :source, :modifier, :match, :data, :tag

    # The parser class variable is the registry of all available parser.
    # It is a hash with the tag (MT940 field number/tag) as key and the class as value
    # When parsing a statment line we look for a matching entry or use the Unknown class as default
    @@parsers = {}
    @@parsers.default = Unknown
    def self.parsers
      @@parsers
    end

    # Class accessor for the parser
    # Every sub class should have its own parser (regex to parse a MT940 field/line)
    # The default parser matches the whole line
    class << self; attr_accessor :parser; end
    self.parser = /(?<details>.*)/ # default parser

    # Class accessor for the tag every defines a MT940 tag it can parse
    # This also adds the class to the parser registry.
    def self.tag=(tag)
      @tag = tag.to_s
      @@parsers[tag.to_s] = self
    end

    class << self
      attr_reader :tag
    end

    # Public: Parses a statement line and initiates a matching Field class
    #
    # Returns an instance of the special field class for the matched line.
    #     Raises and LineFormatError if the line is not well formatted
    #
    # Example:
    #
    # Cmxl::Field.parse(':60F:C031002PLN40000,00') #=> returns an AccountBalance instance
    #
    def self.parse(line)
      if line =~ /\A:(\d{2,2})(\w)?:(.*)\z/m
        tag = Regexp.last_match(1)
        modifier = Regexp.last_match(2)
        content = Regexp.last_match(3).delete("\r").gsub(/\n\z/, '') # remove trailing line break to prevent empty field parsing
        Field.parsers[tag.to_s].new(content, modifier, tag)
      else
        raise LineFormatError, "Wrong line format: #{line.dump}" if Cmxl.config[:raise_line_format_errors]
      end
    end

    def initialize(source, modifier = nil, tag = nil)
      self.tag = tag
      self.modifier = modifier
      self.source = source
      self.data = {}

      if self.match = self.source.match(self.class.parser)
        match.names.each do |name|
          data[name] = match[name]
        end
      end
    end

    def add_meta_data(content)
      # Override if the field supports it
    end

    def to_h
      data.merge('tag' => tag)
    end

    def to_hash
      to_h
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    # Internal: Converts a provided string into a date object
    #     In MT940 documents the date is provided as a 6 char string (YYMMDD) or as a 4 char string (MMDD)
    #     If a 4 char string is provided a second parameter with the year should be provided. If no year is present the current year is assumed.
    #
    # Example:
    #
    # to_date('140909')
    # to_date('0909', 2014)
    #
    # Retuns a date object or the provided date value if it is not parseable.
    def to_date(date, year = nil)
      if match = date.to_s.match(DATE)
        year ||= "20#{match['year'] || Date.today.strftime('%y')}"
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
      value.gsub(/[,|\.](\d*)/) { Regexp.last_match(1).ljust(2, '0') }.to_i
    end

    def to_amount(value)
      value.tr(',', '.').to_f
    end

    def method_missing(m, *value)
      if m =~ /=\z/
        data[m] = value.first
      else
        data[m.to_s]
      end
    end
  end
end
