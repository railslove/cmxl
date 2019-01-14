require 'spec_helper'

describe Cmxl::Fields::FloorLimitIndicator do
  context 'credit' do
    subject { Cmxl::Fields::FloorLimitIndicator.parse(fixture_line(:floor_limit_indicator_credit)) }

    it { expect(subject.amount).to eql(47.11) }
    it { expect(subject.currency).to eql('EUR') }
    it { expect(subject.credit?).to be_truthy }
    it { expect(subject.debit?).to be_falsey }
  end

  context 'debit' do
    subject { Cmxl::Fields::FloorLimitIndicator.parse(fixture_line(:floor_limit_indicator_debit)) }

    it { expect(subject.amount).to eql(13.37) }
    it { expect(subject.currency).to eql('EUR') }
    it { expect(subject.credit?).to be_falsey }
    it { expect(subject.debit?).to be_truthy }
  end

  context 'both' do
    subject { Cmxl::Fields::FloorLimitIndicator.parse(fixture_line(:floor_limit_indicator_both)) }

    it { expect(subject.amount).to eql(13.37) }
    it { expect(subject.currency).to eql('EUR') }
    it { expect(subject.credit?).to be_truthy }
    it { expect(subject.debit?).to be_truthy }
  end
end
