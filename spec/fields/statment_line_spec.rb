require 'spec_helper'

describe Cmxl::Fields::StatementLine do

  subject { Cmxl::Fields::StatementLine.parse(fixture_line(:statement_line)) }

  it { expect(subject.date).to eql(Date.new(2014,9,1)) }
  it { expect(subject.entry_date).to eql(Date.new(2014,9,2)) }
  it { expect(subject.funds_code).to eql('D') }
  it { expect(subject.currency_letter).to eql('R') }
  it { expect(subject.amount).to eql(1.62) }
  it { expect(subject.amount_in_cents).to eql(162) }
  it { expect(subject.swift_code).to eql('NTRF') }
  it { expect(subject.reference).to eql('0000549855700010') }
  it { expect(subject.bank_reference).to eql('025498557/000001') }
  it { expect(subject).to_not be_credit }
  it { expect(subject).to be_debit }
  it { expect(subject.sign).to eql(-1) }
end
