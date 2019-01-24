require 'spec_helper'

describe 'parsing a statement' do
  context 'ISO 8859-1' do
    subject { Cmxl.parse(mt940_file('mt940-iso8859-1'))[0] }

    it { expect(subject.reference).to eql('1234567') }
    it { expect(subject.opening_balance.amount_in_cents).to eql(218_795) }
    it { expect(subject.closing_balance.amount_in_cents).to eql(438_795) }
    it { expect(subject.transactions.last.description).to eql('ÜBERWEISUNG') }
    it { expect(subject.transactions.last.information).to eql('Gehalt OktoberFirmaMüstermannGmbH') }
    it { expect(subject.transactions.last.name).to eql('MÜLLER') }
    it { expect(subject.transactions.last.bic).to eql('50060400') }
  end

  context 'first example' do
    subject { Cmxl.parse(mt940_file, encoding: 'ISO-8859-1', universal_newline: true)[0] }

    it { expect(subject.reference).to eql('131110') }
    it { expect(subject.opening_balance.amount_in_cents).to eql(8_434_974) }
    it { expect(subject.closing_balance.amount_in_cents).to eql(8_443_704) }
    it { expect(subject.generation_date).to eql(Date.new(2013, 11, 10)) }
    it { expect(subject.transactions.count).to eql(11) }
    it { expect(subject.transactions.first.description).to eql('PN5477SCHECK-NR. 0000016703074') }
    it { expect(subject.transactions.first.information).to eql('PN5477SCHECK-NR. 0000016703074') }
    it { expect(subject.transactions.first.sepa).to eql({}) }
    it { expect(subject.transactions.first.bic).to eql(nil) }
  end

  context 'second example' do
    subject { Cmxl.parse(mt940_file, encoding: 'ISO-8859-1', universal_newline: true)[1] }

    it { expect(subject.reference).to eql('1234567') }
    it { expect(subject.opening_balance.amount_in_cents).to eql(218_795) }
    it { expect(subject.closing_balance.amount_in_cents).to eql(438_795) }
    it { expect(subject.generation_date).to eql('123456') }
    it { expect(subject.reference).to eql('1234567') }
    it { expect(subject.transactions.count).to eql(2) }
    it { expect(subject.transactions.first.description).to eql('DAUERAUFTRAG') }
    it { expect(subject.transactions.first.information).to eql('Miete November') }
    it { expect(subject.transactions.first.name).to eql('MUELLER') }
    it { expect(subject.transactions.first.bic).to eql('10020030') }
    it { expect(subject.transactions.first.iban).to eql('234567') }
  end

  context 'third example' do
    subject { Cmxl.parse(mt940_file, encoding: 'ISO-8859-1', universal_newline: true)[2] }

    it { expect(subject.reference).to eql('TELEWIZORY S.A.') }
    it { expect(subject.opening_balance.amount_in_cents).to eql(4_000_000) }
    it { expect(subject.closing_balance.amount_in_cents).to eql(5_004_000) }
    it { expect(subject.reference).to eql('TELEWIZORY S.A.') }
    it { expect(subject.transactions.count).to eql(3) }
    it { expect(subject.transactions.first.description).to eql('Wyplata-(dysp/przel)') }
    it { expect(subject.transactions.first.information).to eql('0810600076000077777777777715617INFO INFO INFO INFO INFO INFO 1 ENDINFO INFO INFO INFO INFOINFO 2 ENDZAPLATA ZA FABRYKATY DO TUB - 200 S ZTUK, TRANZYSTORY-300 SZT GR544 I OPORNIKI-500 SZT GTX847 FAKTURA 333/2003.') }
    it { expect(subject.transactions.first.name).to eql('HUTA SZKLA TOPIC ULPRZEMY SLOWA 67 32-669 WROCLAW') }
    it { expect(subject.transactions.first.bic).to eql('10600076') }
    it { expect(subject.transactions.first.iban).to eql('PL08106000760000777777777777') }
    it { expect(subject.transactions.first.sepa).to eql({}) }

    it { expect(subject.field('NS').to_h).to eql({tag: 'NS', modifier: 'F', source: 'HelloWorld'}) }
  end

  context 'statement separator as used by most banks' do
    subject { Cmxl.parse(mt940_file('mt940')) }

    it 'detects all statements by default' do
      expect(subject.size).to eq(3)
    end
  end

  context 'statement separator as used by Deutsche Bank' do
    subject { Cmxl.parse(mt940_file('mt940-deutsche_bank')) }

    it 'detects all statements by default' do
      expect(subject.size).to eq(3)
    end
  end

  describe 'MT940 with headers' do
    before { Cmxl.config[:strip_headers] = true }
    after { Cmxl.config[:strip_headers] = false }
    subject { Cmxl.parse(mt940_file('mt940-headers')) }

    it { expect(subject.count).to eql(1) }

    it 'parses the statement without problems' do
      expect(subject[0].transactions.count).to eql(1)
    end
  end
end
