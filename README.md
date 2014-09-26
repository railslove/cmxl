# Cmxl - your friendly ruby MT940 parser

At Railslove we build a lot of banking and payment applications and work on integrating applications with banks and banking functionality. 
Our goal is to making it easy with what sometimes seems complicated. 

Cmxl is a friendly and extendible MT940 bank statement file parser that helps your extracting data from the bank statement files. 

## What is MT940?

MT940 (MT = Message Type) is the SWIFT-Standard for the electronic transfer of bank statement files. 
When integrating with banks you often get MT940 files as interface. 
For more information have a look at the different [SWIFT message types](http://en.wikipedia.org/wiki/SWIFT_message_types)

At some point in the future MT940 file should be exchanged with newer XML documents - but banking institutions are slow so MT940 will stick around for a while.

## Reqirements

Cmxl is a pure ruby parser and has no gem dependencies. 

* Ruby 1.9.3 or newer

## Installation

Add this line to your application's Gemfile:

    gem 'cmxl'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cmxl

## Usage

Simple usage: 

```ruby

# Configuration:
# Cmxl currently allows you to configure the statement divider - though the default should be good in most of the cases
# and you can configure if line parsing errors should be raised

Cmxl.config[:statement_separator] = /\n-.\n/m
Cmxl.config[:raise_line_format_errors] = true

# Statment parsing:

statements = Cmxl.parse(File.read('mt940.txt'), :encoding => 'ISO-8859-1') # parses the file and returns an array of statement objects
statements.each do |s|
  puts s.reference
  puts s.generation_date
  puts s.opening_balance.amount
  puts s.closing_balance.amount
  puts.sha # SHA of the statement source - could be used as an unique identifier
  
  s.transactions.each do |t|
    puts t.information
    puts t.description
    puts t.entry_date
    puts t.funds_code
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

Every object responds to `to_h` and let's you easily convert the data to a hash. 

#### A note about encoding and file wirednesses

You probably will encounter encoding issues (hey, you are building banking applications!). 
We try to handle encoding and format wirednesses as much as possible.  
If you have encoding issues you can pass encoding options to the `Cmxl.parse(<string>, <options hash>)` it accepts the same options as [String#encode](http://ruby-doc.org/core-2.1.3/String.html#method-i-encode)
If that fails try to motify the file before you pass it to the parser - and please create an issue.

### Custom field parsers

Because a lot of banks implement the MT940 format slightly different one of the design goals of this library is to be able to customize the field parsers. 
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

* collect MT940 files from different banks and use them as example for specs


## Contributing

### Specs
We use rspec to test Cmxl. Run `rake` to execute the whole test suite.

1. Fork it ( http://github.com/railslove/cmxl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits and other parsers

Cmxl is inspired and borrows ideas from the `mt940_parser` by the great people at [betterplace](https://www.betterplace.org/).

other parsers:
* [betterplace/mt940_parser](https://github.com/betterplace/mt940_parser)
* [gmitrev/mt940parser](https://github.com/gmitrev/mt940parser)

## Stats

[![Build Status](https://magnum.travis-ci.com/railslove/cmxl.svg?token=e6QUckhTMdWWujkwZNBD&branch=master)](https://magnum.travis-ci.com/railslove/cmxl)

------------

2014 - built with love by [Railslove](http://railslove.com). We have built quite a number of FinTech products. If you need support we are happy to help. Please contact us at team@railslove.com.
