require 'spec_helper'
require 'date'
describe Cmxl::Fields::AccountBalance do

  context 'Credit' do
    subject { Cmxl::Fields::AccountBalance.parse( fixture_line(:account_balance_credit) ) }

    it { expect(subject.date).to eql(Date.new(2014,8,29)) }
    it { expect(subject).to be_credit }
    it { expect(subject).to_not be_debit }
    it { expect(subject.currency).to eql('EUR') }

    it { expect(subject.amount).to eql(147.64) }
    it { expect(subject.amount_in_cents).to eql(14764) }
    it { expect(subject.sign).to eql(1) }
    it { expect(subject.to_h).to eql({
        'date' =>Date.new(2014,8,29),
        'funds_code' =>"C",
        'credit' =>true,
        'debit' =>false,
        'currency' =>"EUR",
        'amount' =>147.64,
        'amount_in_cents' =>14764,
        'sign' =>1,
        'tag' => '60'
    }) }
  end

  context 'Debit' do
    subject { Cmxl::Fields::AccountBalance.parse( fixture_line(:account_balance_debit) ) }

    it { expect(subject.date).to eql(Date.new(2014,8,29)) }
    it { expect(subject).to_not be_credit }
    it { expect(subject).to be_debit }
    it { expect(subject.currency).to eql('EUR') }

    it { expect(subject.amount).to eql(147.64) }
    it { expect(subject.amount_in_cents).to eql(14764) }
    it { expect(subject.sign).to eql(-1) }
  end

end
