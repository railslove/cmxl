require "cmxl/version"

require 'cmxl/field'
Dir[File.join(File.dirname(__FILE__), 'cmxl/fields', '*.rb')].each { |f| require f; }
module Cmxl
  module Fields
    autoload :AccountBalance, 'cmxl/fields/account_balance'
    autoload :AccountIdentification, 'cmxl/fields/account_identification'
    autoload :AvailableBalance, 'cmxl/fields/available_balance'
    autoload :ClosingBalance, 'cmxl/fields/closing_balance'
    autoload :Reference, 'cmxl/fields/reference'
    autoload :StatementDetails, 'cmxl/fields/statement_details'
    autoload :StatementLine, 'cmxl/fields/statement_line'
    autoload :StatementNumber, 'cmxl/fields/statement_number'
  end
  autoload :Field, 'cmxl/field'
  autoload :Statement, 'cmxl/statement'
  autoload :Transaction, 'cmxl/transaction'

  def self.parse(data, options={})
    options[:universal_newline] ||= true
    if options[:encoding]
      data.encode!('UTF-8', options.delete(:encoding), options)
    else
      data.encode!('UTF-8', options) if !options.empty?
    end

    data.split("\n-").reject { |s| s.strip.empty? }.collect {|s| Cmxl::Statement.new(s.strip) }
  end
end
