require 'spec_helper'

describe Cmxl::Fields::Transaction do
  subject(:debit_transaction) { Cmxl::Fields::Transaction.parse(fixture.first) }
  subject(:storno_credit_transaction) { Cmxl::Fields::Transaction.parse(fixture.last) }

  let(:fixture) { fixture_line(:statement_line).split(/\n/) }

  context 'debit' do
    it { expect(debit_transaction.date).to eql(Date.new(2014,9,1)) }
    it { expect(debit_transaction.entry_date).to eql(Date.new(2014,9,2)) }
    it { expect(debit_transaction.funds_code).to eql('D') }
    it { expect(debit_transaction.currency_letter).to eql('R') }
    it { expect(debit_transaction.amount).to eql(1.62) }
    it { expect(debit_transaction.amount_in_cents).to eql(162) }
    it { expect(debit_transaction.swift_code).to eql('NTRF') }
    it { expect(debit_transaction.reference).to eql('0000549855700010') }
    it { expect(debit_transaction.bank_reference).to eql('025498557/000001') }
    it { expect(debit_transaction).to_not be_credit }
    it { expect(debit_transaction).to be_debit }
    it { expect(debit_transaction).not_to be_storno_debit }
    it { expect(debit_transaction).not_to be_storno_credit }
    it { expect(debit_transaction.sign).to eql(-1) }
  end

  context 'storno credit' do
    it { expect(storno_credit_transaction.date).to eql(Date.new(2014,9,1)) }
    it { expect(storno_credit_transaction.entry_date).to eql(Date.new(2014,9,2)) }
    it { expect(storno_credit_transaction.funds_code).to eql('RC') }
    it { expect(storno_credit_transaction.currency_letter).to eql('R') }
    it { expect(storno_credit_transaction.amount).to eql(1.62) }
    it { expect(storno_credit_transaction.amount_in_cents).to eql(162) }
    it { expect(storno_credit_transaction.swift_code).to eql('NTRF') }
    it { expect(storno_credit_transaction.reference).to eql('0000549855700010') }
    it { expect(storno_credit_transaction.bank_reference).to eql('025498557/000001') }
    it { expect(storno_credit_transaction).to be_credit }
    it { expect(storno_credit_transaction).not_to be_debit }
    it { expect(storno_credit_transaction).not_to be_storno_debit }
    it { expect(storno_credit_transaction).to be_storno_credit }
    it { expect(storno_credit_transaction.sign).to eql(1) }
  end
end
