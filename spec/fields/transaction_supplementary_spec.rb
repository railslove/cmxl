require 'spec_helper'

describe Cmxl::Fields::TransactionSupplementary do
  let(:fixture) { 'Card Transaction/OCMT/CAD47,11/CHGS/EUR123,45' }
  subject(:supplementary) { described_class.parse(fixture) }

  it { expect(supplementary.initial_amount_in_cents).to eql(4711) }
  it { expect(supplementary.initial_currency).to eql('CAD') }

  it { expect(supplementary.charges_in_cents).to eql(12_345) }
  it { expect(supplementary.charges_currency).to eql('EUR') }

  describe '.to_h' do
    it 'returns expected hash' do
      expect(supplementary.to_h).to eql(
        source: 'Card Transaction/OCMT/CAD47,11/CHGS/EUR123,45',
        initial_amount_in_cents: 4711,
        initial_currency: 'CAD',
        charges_in_cents: 12_345,
        charges_currency: 'EUR'
      )
    end
  end
end
