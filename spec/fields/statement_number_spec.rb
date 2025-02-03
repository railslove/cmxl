require 'spec_helper'

describe Cmxl::Fields::StatementNumber do
  subject { Cmxl::Fields::StatementNumber.parse(fixture_line(:statement_number)) }

  it { expect(subject.statement_number).to eql('00035') }
  it { expect(subject.sequence_number).to eql('001') }

  context "without leading zeros" do
    subject { Cmxl::Fields::StatementNumber.parse(fixture_line(:statement_number_short)) }

    it { expect(subject.statement_number).to eql('35') }
    it { expect(subject.sequence_number).to eql('1') }
  end

  context "without sequence number" do
    subject { Cmxl::Fields::StatementNumber.parse(fixture_line(:statement_number_without_sequence)) }

    it { expect(subject.statement_number).to eql('00035') }
    it { expect(subject.sequence_number).to be(nil) }
  end
end
