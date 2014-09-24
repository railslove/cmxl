require "cmxl/version"

require 'cmxl/field'
require 'cmxl/statement'
require 'cmxl/transaction'
Dir[File.join(File.dirname(__FILE__), 'cmxl/fields', '*.rb')].each { |f| require f; }
module Cmxl

  STATEMENT_SEPARATOR = "\n-"
  def self.parse(data, options={})
    options[:universal_newline] ||= true
    if options[:encoding]
      data.encode!('UTF-8', options.delete(:encoding), options)
    else
      data.encode!('UTF-8', options) if !options.empty?
    end

    data.split(STATEMENT_SEPARATOR).reject { |s| s.strip.empty? }.collect {|s| Cmxl::Statement.new(s.strip) }
  end
end
