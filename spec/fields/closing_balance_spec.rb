require 'spec_helper'

describe Cmxl::Fields::ClosingBalance do
  subject { Cmxl::Fields::ClosingBalance.parse(fixture_line(:closing_balance)) }

  it { expect(subject.date).to eql(Date.new(2014, 9, 1)) }
  it { expect(subject).to be_credit }
  it { expect(subject).to_not be_debit }

  it { expect(subject.amount).to eql(137.0) }
  it { expect(subject.amount_in_cents).to eql(13_700) }
  it { expect(subject.sign).to eql(1) }
end
