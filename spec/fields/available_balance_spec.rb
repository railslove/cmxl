require 'spec_helper'

describe Cmxl::Fields::AvailableBalance do

  subject { Cmxl::Fields::AvailableBalance.parse(fixture_line(:available_balance)) }

  it { expect(subject.date).to eql(Date.new(2014,9,1)) }
  it { expect(subject).to_not be_credit }
  it { expect(subject).to be_debit }
  it { expect(subject.currency).to eql('EUR') }

  it { expect(subject.amount).to eql(3.66) }
  it { expect(subject.amount_in_cents).to eql(366) }
  it { expect(subject.sign).to eql(-1) }

end
