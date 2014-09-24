require 'spec_helper'

describe 'parsing a statement' do
  subject { Cmxl.parse(mt940_file(), :encoding => 'ISO-8859-1', :universal_newline => true) }
  it { expect(subject.length).to eql(1) }
  it { expect(subject.first.reference).to eql('131110') }
  it { expect(subject.first.opening_balance.amount_in_cents).to eql(8434974) }
  it { expect(subject.first.closing_balance.amount_in_cents).to eql(8443704) }
  it { expect(subject.first.generation_date).to eql(Date.new(2013, 11, 10)) }
  it { expect(subject.first.transactions.count).to eql(11) }
end
