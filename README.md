# Cmxl - your friendly ruby MT940 bank statement parser

At Railslove we build a lot of banking and payment applications and work on integrating applications with banks and banking functionality. 
Our goal is to making it easy with what sometimes seems complicated. 

Cmxl is a friendly and extendible MT940 file parser that helps your extracting data from the bank statement files. 

## What is MT940

MT940 (MT = Message Type) is the SWIFT-Standard for the electronic transfer of bank statement files. 
When integrating with banks you often get MT940 files as interface. 
For more information have a look at the different [SWIFT message types](http://en.wikipedia.org/wiki/SWIFT_message_types)

At some point in the future MT940 file should be exchanged with newer XML documents - but banking institutions are slow so MT940 will stick around for a while.

## Reqirements

Cmxl is§ a pure ruby parser and has no gem dependencies. 

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

statements = Cmxl.parse(File.read('mt940.txt')) # parses the file and returns an array of statement objects
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

Every object responds to `to_h` and let's you easily convert the data to a hash. 

```

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

## Contributing

1. Fork it ( http://github.com/railslove/cmxl/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
