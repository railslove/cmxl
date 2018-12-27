require 'spec_helper'

describe Cmxl::Fields::StatementNumber do
  subject { Cmxl::Fields::StatementNumber.parse(fixture_line(:statement_number)) }

  it { expect(subject.statement_number).to eql('00035') }
  it { expect(subject.sequence_number).to eql('001') }
end
