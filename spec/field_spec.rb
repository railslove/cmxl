require 'spec_helper'

describe Cmxl::Field do
  subject { Cmxl::Field.new('D140829EUR000000000147,64', nil, 42) }

  it { expect(Cmxl::Field.parser).to eql(/(?<details>.*)/) } # default must be set

  it { expect(subject.to_h).to eql('tag' => 42, 'details' => 'D140829EUR000000000147,64') }
  it { expect(subject.to_hash).to eql(subject.to_h) }

  it { expect(subject.to_amount('123.')).to eql(123.00) }
  it { expect(subject.to_amount('123.1')).to eql(123.10) }
  it { expect(subject.to_amount('123.11')).to eql(123.11) }
  it { expect(subject.to_amount('123,1')).to eql(123.10) }
  it { expect(subject.to_amount('123,11')).to eql(123.11) }

  it { expect(subject.to_amount_in_cents('123.')).to eql(12_300) }
  it { expect(subject.to_amount_in_cents('123.1')).to eql(12_310) }
  it { expect(subject.to_amount_in_cents('123.11')).to eql(12_311) }
  it { expect(subject.to_amount_in_cents('123,1')).to eql(12_310) }
  it { expect(subject.to_amount_in_cents('123,11')).to eql(12_311) }

  it { expect(subject.to_date('invalid')).to eql('invalid') }
  it { expect(subject.to_date('140914')).to eql(Date.new(2014, 9, 14)) }
  it { expect(subject.to_date('140914', 2013)).to eql(Date.new(2013, 9, 14)) }
end
