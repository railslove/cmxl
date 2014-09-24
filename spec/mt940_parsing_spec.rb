require 'spec_helper'

describe 'parsing a statement' do
  context 'first example' do
    subject { Cmxl.parse(mt940_file(), :encoding => 'ISO-8859-1', :universal_newline => true)[0] }
    it { expect(subject.reference).to eql('131110') }
    it { expect(subject.opening_balance.amount_in_cents).to eql(8434974) }
    it { expect(subject.closing_balance.amount_in_cents).to eql(8443704) }
    it { expect(subject.generation_date).to eql(Date.new(2013, 11, 10)) }
    it { expect(subject.transactions.count).to eql(11) }
  end

  context 'second example' do
    subject { Cmxl.parse(mt940_file(), :encoding => 'ISO-8859-1', :universal_newline => true)[1] }
    it { expect(subject.reference).to eql('1234567') }
    it { expect(subject.opening_balance.amount_in_cents).to eql(218795) }
    it { expect(subject.closing_balance.amount_in_cents).to eql(438795) }
    it { expect(subject.generation_date).to eql('123456') }
    it { expect(subject.reference).to eql("1234567") }
    it { expect(subject.transactions.count).to eql(2) }
    it { expect(subject.transactions.first.description).to eql('DAUERAUFTRAG') }
    it { expect(subject.transactions.first.information).to eql('Miete November') }
    it { expect(subject.transactions.first.name).to eql('MUELLER') }
    it { expect(subject.transactions.first.bic).to eql('10020030') }
    it { expect(subject.transactions.first.iban).to eql('234567') }
  end

    context 'third example' do
      subject { Cmxl.parse(mt940_file(), :encoding => 'ISO-8859-1', :universal_newline => true)[2] }
      it { expect(subject.reference).to eql('TELEWIZORY S.A.') }
      it { expect(subject.opening_balance.amount_in_cents).to eql(4000000) }
      it { expect(subject.closing_balance.amount_in_cents).to eql(5004000) }
      it { expect(subject.reference).to eql("TELEWIZORY S.A.") }
      it { expect(subject.transactions.count).to eql(3) }
      it { expect(subject.transactions.first.description).to eql('Wyplata-(dysp/przel)') }
      it { expect(subject.transactions.first.information).to eql('0810600076000077777777777715617INFO INFO INFO INFO INFO INFO 1 ENDINFO INFO INFO INFO INFOINFO 2 ENDZAPLATA ZA FABRYKATY DO TUB - 200 S ZTUK, TRANZYSTORY-300 SZT GR544 I OPORNIKI-500 SZT GTX847 FAKTURA 333/2003.') }
      it { expect(subject.transactions.first.name).to eql('HUTA SZKLA TOPIC ULPRZEMYSLOWA 67 32-669 WROCLAW') }
      it { expect(subject.transactions.first.bic).to eql('10600076') }
      it { expect(subject.transactions.first.iban).to eql('PL08106000760000777777777777') }
      it { expect(subject.transactions.first.sepa).to eql({}) }
  end


end
