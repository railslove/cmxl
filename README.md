[![CI](https://github.com/railslove/cmxl/actions/workflows/ci.yml/badge.svg)](https://github.com/railslove/cmxl/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/cmxl.svg)](https://rubygems.org/gems/cmxl)

# Cmxl - your friendly ruby MT940 parser

At [Railslove](http://railslove.com) we build a lot of financial applications and work on integrating applications with banks and banking functionality.
Our goal is to make simple solutions for what often looks complicated.

Cmxl is a friendly and extensible MT940 bank statement file parser that helps you extract data from bank statement files.

## What is MT940 & MT942?

MT940 (MT = Message Type) is the SWIFT-Standard for the electronic transfer of bank statement files.
When integrating with banks you often get MT940 or MT942 files as interface.
For more information have a look at the different [SWIFT message types](http://en.wikipedia.org/wiki/SWIFT_message_types)

At some point in the future MT940 file should be exchanged with newer XML documents - but banking institutions are slow, so MT940 will stick around for a while.

## Requirements

Cmxl is a pure ruby parser and has no dependency on native extensions.

- Ruby (current officially supported distributions)

## Installation

Add this line to your application's Gemfile:

    gem 'cmxl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cmxl

## Usage

### Simple usage:

```ruby
statements = Cmxl.parse(File.read('mt940.txt'))

statements.each do |s|
  puts s.reference
  puts s.generation_date
  puts s.opening_balance.amount
  puts s.closing_balance.amount
  puts s.sha # SHA of the statement source - could be used as an identifier (see: https://github.com/railslove/cmxl/blob/main/lib/cmxl/statement.rb#L49-L55)

  s.transactions.each do |t|
    puts t.information
    puts t.description
    puts t.entry_date
    puts t.credit_debit_indicator
    puts t.credit?
    puts t.debit?
    puts t.sign # -1 if it's a debit; 1 if it's a credit
    puts t.name
    puts t.iban
    puts t.sepa
    puts t.sub_fields
    puts t.reference
    puts t.bank_reference
    # ...
  end
end
```

Every object responds to `to_h` and let's you easily convert the data to a hash. Also every object responds to `to_json` which lets you easily represent the statements as JSON with your favorite JSON library.

### File encoding options

You probably will encounter encoding issues (hey, you are building banking applications!).
We try to handle encoding and format weirdnesses as much as possible. If no encoding is passed we try to guess the encoding of the data and convert it to UTF8.
In the likely case that you encounter encoding issues you can pass encoding options to `Cmxl.parse(<string>, <options hash>)`. It accepts the same options as [String#encode](http://ruby-doc.org/core-2.1.3/String.html#method-i-encode)
If that fails, try to modify the file before you pass it to the parser - and please create an issue.

```ruby
Cmxl.parse(File.read('mt940.txt'), :encoding => 'ISO-8859-1')
```

## Global configurations:
The gem offers option to adjust behavior for the gem

### `statement_separator`
statement divider regex to split the individual statements in one file

|type|default|
|----|-------|
|regex|[`/\R+-[^\n\r]*\R*/m`](https://github.com/railslove/cmxl/blob/main/lib/cmxl.rb#L18)|

```ruby
Cmxl.config[:statement_separator] = ...
Cmxl.parse(...)
```

### `raise_line_format_errors`
do you want an error to be raised when a line can not be parsed? 

|type|default|
|----|-------|
|boolean|[`true`](https://github.com/railslove/cmxl/blob/main/lib/cmxl.rb#L19)|

```ruby
Cmxl.config[:raise_line_format_errors] = ...
Cmxl.parse(...)
```

### `strip_headers`
Cmxl currently does not support parsing of the SWIFT headers (like {1:F01AXISINBBA ....)
If your file comes with these headers try the `strip_headers` configuration option to strip data except the actual MT940 fields.

|type|default|
|----|-------|
|boolean|[`false`](https://github.com/railslove/cmxl/blob/main/lib/cmxl.rb#L20)|

```ruby
Cmxl.config[:strip_headers] = ...
Cmxl.parse(...)
```

### MT942 data

CMXL is now also capable of parsing MT942 data. Just pass the data and the parser will identify the type automatically.

```ruby
first_statement = Cmxl.parse(File.read('mt940.txt'), :encoding => 'ISO-8859-1').first
puts first_statement.mt942?
#=> false

first_statement = Cmxl.parse(File.read('mt942.txt'), :encoding => 'ISO-8859-1').first
puts first_statement.mt942?
#=> true

p first_statement.vmk_credit_summary.to_h
#=> { type: 'credit', entries: 1, amount: 9792.0, currency: 'EUR' }

p first_statement.vmk_dedit_summary.to_h
#=> { type: 'debit', entries: 0, amount: 0.0, currency: 'EUR' }

first_statement.transactions # same as for MT940
```

### Custom field parsers

Because a lot of banks implement the MT940 format slightly different one of the design goals of this library is to be able to customize the individual field parsers.
Every line get parsed with a special parser. Here is how to write your own parser:

```ruby

# simply create a new parser class inheriting from Cmxl::Field
class MyFieldParser < Cmxl::Field
  self.tag = 42 # define which MT940 tag your parser can handle. This will automatically register your parser and overwriting existing parsers
  self.parser = /(?<world>.*)/ # the regex to parse the line. Use named regexp to access your match.

  def upcased
    self.data['world'].upcase
  end
end

my_field_parser = MyFieldParser.parse(":42:hello from mt940")
my_field_parser.world #=> hello from MT940
my_field_parser.upcased #=> HELLO FROM MT940
my_field_parser.data #=> {'world' => 'hello from mt940'} - data is the accessor to the regexp matches

```

## Parsing issues? - please create an issue with your file

The Mt940 format often looks different for the different banks and the different countries. Especially the not strict defined fields are often used for custom bank data.
If you have a file that can not be parsed please open an issue. We hope to build a parser that handles most of the files.

## ToDo

- collect MT940 files from different banks and use them as example for specs
- better header data handling

## Looking for other Banking and EBICS tools?

Maybe these are also interesting for you.

- [EPICS: Open Source SEPA EBICS client](https://railslove.github.io/epics/) full implementation to manage all the banking activities like direct debits, credits, etc. (SEPA Lastschrift, Überweisungen, etc.)
- [EBICS::Box: out of the box solution to automate banking activities](http://www.railslove.com/ebics-box) - The missing API for your bank

## Contributing

Automated tests: We use rspec to test Cmxl. Simply run `rake` to execute the whole test suite.

1. Fork it ( http://github.com/railslove/cmxl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits and other parsers

Cmxl is inspired and borrows ideas from the `mt940_parser` by the great people at [betterplace](https://www.betterplace.org/).

other parsers:

- [betterplace/mt940_parser](https://github.com/betterplace/mt940_parser)
- [gmitrev/mt940parser](https://github.com/gmitrev/mt940parser)

---
built with love by [Railslove](http://railslove.com) and some [amazing people](https://github.com/railslove/cmxl/graphs/contributors).  
Released under the MIT-License. 

Railslove builds FinTech products, if you need support for your project we are happy to help. Please contact us at team@railslove.com.
