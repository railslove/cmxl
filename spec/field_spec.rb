require 'spec_helper'

describe Cmxl::Field do
  subject { Cmxl::Field.new('D140829EUR000000000147,64') }

  it { expect(Cmxl::Field.parser).to eql(/(?<details>.*)/) } # default must be set

  it { expect(subject.to_amount('123.')).to eql(123.00) }
  it { expect(subject.to_amount('123.1')).to eql(123.10) }
  it { expect(subject.to_amount('123.11')).to eql(123.11) }
  it { expect(subject.to_amount('123,1')).to eql(123.10) }
  it { expect(subject.to_amount('123,11')).to eql(123.11) }

  it { expect(subject.to_amount_in_cents('123.')).to eql(12300) }
  it { expect(subject.to_amount_in_cents('123.1')).to eql(12310) }
  it { expect(subject.to_amount_in_cents('123.11')).to eql(12311) }
  it { expect(subject.to_amount_in_cents('123,1')).to eql(12310) }
  it { expect(subject.to_amount_in_cents('123,11')).to eql(12311) }

  it { expect(subject.to_date('invalid')).to eql('invalid') }
  it { expect(subject.to_date('140914')).to eql(Date.new(2014,9,14)) }
  it { expect(subject.to_date('140914', 2013)).to eql(Date.new(2013,9,14)) }

end
