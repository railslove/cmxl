require 'spec_helper'

describe Cmxl::Fields::TransactionSupplementary do
  let(:fixture) { 'Card Transaction/OCMT/CAD47,11/CHGS/EUR123,45' }

  it { expect(described_class.parse(fixture).initial_amount_in_cents).to eql(4711) }
  it { expect(described_class.parse(fixture).initial_currency).to eql('CAD') }

  it { expect(described_class.parse(fixture).charges_in_cents).to eql(12345) }
  it { expect(described_class.parse(fixture).charges_currency).to eql('EUR') }
end
