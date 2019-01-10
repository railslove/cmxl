require 'spec_helper'

describe Cmxl::Fields::AccountIdentification do
  context 'legacy data' do
    subject { Cmxl::Fields::AccountBalance.parse(fixture_line(:account_identification_legacy)) }

    it { expect(subject.bank_code).to eql('70011110') }
    it { expect(subject.account_number).to eql('4005287001') }
    it { expect(subject.currency).to eql('EUR') }
    it { expect(subject.country).to be_nil }
  end

  context 'iban' do
    subject { Cmxl::Fields::AccountBalance.parse(fixture_line(:account_identification_iban)) }
    it { expect(subject.country).to eql('PL') }
    it { expect(subject.ban).to eql('25106000760000888888888888') }
    it { expect(subject.iban).to eql('PL25106000760000888888888888') }
    it { expect(subject.bank_code).to be_nil }
  end
end
