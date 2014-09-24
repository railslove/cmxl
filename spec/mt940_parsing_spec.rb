require 'spec_helper'

describe 'parsing a statement' do
  context 'first example' do
    subject { Cmxl.parse(mt940_file(), :encoding => 'ISO-8859-1', :universal_newline => true) }
    it { expect(subject.length).to eql(2) }
    it { expect(subject.first.reference).to eql('131110') }
    it { expect(subject.first.opening_balance.amount_in_cents).to eql(8434974) }
    it { expect(subject.first.closing_balance.amount_in_cents).to eql(8443704) }
    it { expect(subject.first.generation_date).to eql(Date.new(2013, 11, 10)) }
    it { expect(subject.first.transactions.count).to eql(11) }
  end

  context 'second example' do
    subject { Cmxl.parse(mt940_file(), :encoding => 'ISO-8859-1', :universal_newline => true) }
    it { expect(subject[1].reference).to eql('1234567') }
    it { expect(subject[1].opening_balance.amount_in_cents).to eql(218795) }
    it { expect(subject[1].closing_balance.amount_in_cents).to eql(438795) }
    it { expect(subject[1].generation_date).to eql('123456') }
    it { expect(subject[1].reference).to eql("1234567") }
    it { expect(subject[1].transactions.count).to eql(2) }
    it { expect(subject[1].transactions.first.description).to eql('DAUERAUFTRAG') }
    it { expect(subject[1].transactions.first.information).to eql('Miete November') }
    it { expect(subject[1].transactions.first.name).to eql('MUELLER') }
    it { expect(subject[1].transactions.first.bic).to eql('10020030') }
    it { expect(subject[1].transactions.first.iban).to eql('234567') }
  end


end
