require 'spec_helper'

describe Cmxl::Fields::Reference do

  subject { Cmxl::Fields::Reference.parse(fixture_line(:reference)) }

  it { expect(subject.reference).to eql('D140902049') }
  it { expect(subject.date).to eql(Date.new(2014,9,2)) }
  it { expect(subject.statement_identifier).to eql('D') }
  it { expect(subject.additional_number).to eql('049') }
  it { expect(subject.to_h).to eql({"tag" => '20', "statement_identifier"=>"D", "date"=> Date.new(2014,9,2), "additional_number"=>"049", "reference"=>"D140902049"}) }
  it { expect(subject.to_hash).to eql(subject.to_h) }
end
