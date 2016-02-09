require "cmxl/version"

require "rchardet19"

require 'cmxl/field'
require 'cmxl/statement'
require 'cmxl/transaction'
Dir[File.join(File.dirname(__FILE__), 'cmxl/fields', '*.rb')].each { |f| require f; }

module Cmxl
  def self.config
    @config
  end
  @config = { :statement_separator => /\n-.?\n/m, :raise_line_format_errors => true }

  # Public: Parse a MT940 string
  #
  # data - The String containing the MT940
  # options - Hash with encoding options. Accepts the same parameters as String#encode!
  #     It is likely that you want to provide the encoding of your MT940 String
  #
  # Examples
  #
  # Cmxl.parse(File.read('mt940.txt'), encoding: 'ISO-8859-1')
  # Cmxl.parse(mt940_string)
  #
  # Returns an array of Statement objects
  def self.parse(data, options={})
    options[:universal_newline] ||= true
    options[:statement_separator] ||= self.config[:statement_separator]
    # if no encoding is provided we try to guess using CharDet
    if options[:encoding].nil? && cd = CharDet.detect(data, silent: true)
      options[:encoding] = cd.encoding
    end

    if options[:encoding]
      data.encode!('UTF-8', options.delete(:encoding), options)
    else
      data.encode!('UTF-8', options) if !options.empty?
    end

    data.split(options[:statement_separator]).reject { |s| s.strip.empty? }.collect {|s| Cmxl::Statement.new(s.strip) }
  end
end
