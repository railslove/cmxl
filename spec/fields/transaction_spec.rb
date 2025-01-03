require 'spec_helper'

describe Cmxl::Fields::Transaction do
  subject(:debit_transaction) { Cmxl::Fields::Transaction.parse(fixture[0]) }
  subject(:storno_credit_transaction) { Cmxl::Fields::Transaction.parse(fixture[1]) }
  subject(:ocmt_transaction) { Cmxl::Fields::Transaction.parse(fixture_line(:statement_ocmt)) }
  subject(:ocmt_cghs_transaction) { Cmxl::Fields::Transaction.parse(fixture_line(:statement_ocmt_chgs)) }
  subject(:supplementary_transaction) { Cmxl::Fields::Transaction.parse(fixture_line(:statement_supplementary_plain)) }
  subject(:complex_supplementary_transaction) { Cmxl::Fields::Transaction.parse(fixture_line(:statement_supplementary_complex)) }
  subject(:valuta_after_entry_date) { Cmxl::Fields::Transaction.parse(fixture[3]) }
  subject(:entry_before_valuta_transaction) { Cmxl::Fields::Transaction.parse(fixture[2]) }
  subject(:transaction_type_swift) { Cmxl::Fields::Transaction.parse(fixture[4]) }

  let(:fixture) { fixture_line(:statement_line).split(/\n/) }

  context 'debit' do
    it { expect(debit_transaction.date).to eql(Date.new(2014, 9, 1)) }
    it { expect(debit_transaction.entry_date).to eql(Date.new(2014, 9, 2)) }
    it { expect(debit_transaction.funds_code).to eql('D') }
    it { expect(debit_transaction.currency_letter).to eql('R') }
    it { expect(debit_transaction.amount).to eql(1.62) }
    it { expect(debit_transaction.amount_in_cents).to eql(162) }
    it { expect(debit_transaction.swift_code).to eql('NTRF') }
    it { expect(debit_transaction.reference).to eql('0000549855700010') }
    it { expect(debit_transaction.bank_reference).to eql('025498557/000001') }
    it { expect(debit_transaction).to_not be_credit }
    it { expect(debit_transaction).to be_debit }
    it { expect(debit_transaction).not_to be_storno }
    it { expect(debit_transaction.sign).to eql(-1) }
  end

  context 'storno credit' do
    it { expect(storno_credit_transaction.date).to eql(Date.new(2014, 9, 1)) }
    it { expect(storno_credit_transaction.entry_date).to eql(Date.new(2014, 9, 2)) }
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
    it { expect(storno_credit_transaction).to be_storno }
    it { expect(storno_credit_transaction.sign).to eql(1) }
  end

  context 'statement with initial amount and currency' do
    it { expect(ocmt_transaction.initial_amount_in_cents).to eql(4711) }
    it { expect(ocmt_transaction.initial_currency).to eql('CAD') }
  end

  context 'statement with initial amount and currency and also charges' do
    it { expect(ocmt_cghs_transaction.initial_amount_in_cents).to eql(4711) }
    it { expect(ocmt_cghs_transaction.initial_currency).to eql('CAD') }

    it { expect(ocmt_cghs_transaction.charges_in_cents).to eql(123) }
    it { expect(ocmt_cghs_transaction.charges_currency).to eql('EUR') }
  end

  context 'statement with plain supplementary' do
    it { expect(supplementary_transaction.initial_amount_in_cents).to eql(nil) }
    it { expect(supplementary_transaction.initial_currency).to eql(nil) }

    it { expect(supplementary_transaction.charges_in_cents).to eql(nil) }
    it { expect(supplementary_transaction.charges_currency).to eql(nil) }

    it { expect(supplementary_transaction.supplementary.source).to eql('Card Transaction') }
  end

  context 'statement with complex supplementary' do
    it 'future reference' do
      result = Cmxl::Fields::Transaction.parse(':61:2412121212ED162,57NDDTNONREF//950\n')
      expect(result.amount).to eql(162.57)
    end

    it { expect(complex_supplementary_transaction.initial_amount_in_cents).to eql(nil) }
    it { expect(complex_supplementary_transaction.initial_currency).to eql(nil) }

    it { expect(complex_supplementary_transaction.charges_in_cents).to eql(nil) }
    it { expect(complex_supplementary_transaction.charges_currency).to eql(nil) }

    it { expect(complex_supplementary_transaction.reference).to eql('FOOBAR/123') }
    it { expect(complex_supplementary_transaction.bank_reference).to eql('HERP-DERP-REF') }
    it { expect(complex_supplementary_transaction.supplementary.source).to eql('random text / and stuff') }
  end

  context 'valuta and entry-date assumptions' do
    it 'entry_date before valuta is recognized correctly when including year-change' do
      expect(entry_before_valuta_transaction.date).to eql(Date.new(2014, 1, 10))
      expect(entry_before_valuta_transaction.entry_date).to eql(Date.new(2013, 12, 24))
    end

    it 'entry_date after valuta is recognized correctly when including year-change' do
      expect(valuta_after_entry_date.date).to eql(Date.new(2014, 12, 24))
      expect(valuta_after_entry_date.entry_date).to eql(Date.new(2015, 1, 2))
    end
  end

  context 'transaction type swift transfer' do
    it { expect(transaction_type_swift.date).to eql(Date.new(2019, 11, 18)) }
    it { expect(transaction_type_swift.entry_date).to eql(Date.new(2019, 11, 18)) }
    it { expect(transaction_type_swift.funds_code).to eql('C') }
    it { expect(transaction_type_swift.currency_letter).to eql('R') }
    it { expect(transaction_type_swift.amount).to eql(653.0) }
    it { expect(transaction_type_swift.amount_in_cents).to eql(65300) }
    it { expect(transaction_type_swift.swift_code).to eql('S445') }
    it { expect(transaction_type_swift.reference).to eql('328556-76501096') }
    it { expect(transaction_type_swift).to be_credit }
    it { expect(transaction_type_swift).not_to be_debit }
    it { expect(transaction_type_swift).not_to be_storno }
    it { expect(transaction_type_swift.sign).to eql(1) }
  end

  describe '#credit_debit_indicator' do
    it 'returns the credit_debit_indicator as debit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902DR000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result.credit_debit_indicator).to eql('D')
    end

    it 'returns the credit_debit_indicator as credit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902CR000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result.credit_debit_indicator).to eql('C')
    end

    it 'returns the credit_debit_indicator as reversal credit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902RC000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result.credit_debit_indicator).to eql('RC')
    end

    it 'returns the credit_debit_indicator as reversal debit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902RD000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result.credit_debit_indicator).to eql('RD')
    end

    it 'returns the credit_debit_indicator as expected credit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902EC000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result.credit_debit_indicator).to eql('EC')
    end
  end

  describe '#expected?' do
    it 'returns true if the transaction is expected' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902EC000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).to be_expected
    end

    it 'returns false if the transaction is not expected' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902RD000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).not_to be_expected
    end
  end

  describe '#expected_credit?' do
    it 'returns true if the transaction is expected and credit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902EC000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).to be_expected_credit
    end

    it 'returns false if the transaction is not expected and credit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902RC000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).not_to be_expected_credit
    end

    it 'returns false if the transaction is expected and debit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902ED000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).not_to be_expected_credit
    end
  end

  describe '#expected_debit?' do
    it 'returns true if the transaction is expected and debit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902ED000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).to be_expected_debit
    end

    it 'returns false if the transaction is not expected and debit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902RD000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).not_to be_expected_debit
    end

    it 'returns false if the transaction is expected and credit' do
      result = Cmxl::Fields::Transaction.parse(':61:1409010902EC000000000001,62NTRF0000549855700010//025498557/000001')
      expect(result).not_to be_expected_debit
    end
  end
end
