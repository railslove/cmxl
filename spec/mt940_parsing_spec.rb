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

  context 'no generation date' do
    subject { Cmxl.parse(mt940_file('mt940'))[3] }

    it { expect(subject.reference).to eql('01ANWZTPJTYEGJWA') }
    it { expect(subject.generation_date).to eql(nil) }
  end

  context 'statement separator as used by most banks' do
    subject { Cmxl.parse(mt940_file('mt940')) }

    it 'detects all statements by default' do
      expect(subject.size).to eq(4)
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

  describe "MT940 abnamro" do
    it "splits the file into on statement with the headers included" do
      expected_data = <<~MT940.chomp
        ABNANL2A
        940
        ABNANL2A
        :20:ABN AMRO BANK NV
        :25:517852257
        :28:19321/1
        :60F:C110522EUR3236,28
        :61:1105240524D9,N192NONREF
        :86:GIRO   428428 KPN - DIGITENNE    BETALINGSKENM.  000000042188659
        5314606715                       BETREFT FACTUUR D.D. 20-05-2011
        INCL. 1,44 BTW
        :61:1105210523D11,59N426NONREF
        :86:BEA   NR:XXX1234   21.05.11/12.54 DIRCKIII FIL2500 KATWIJK,PAS999
        :61:1105230523D11,63N426NONREF
        :86:BEA   NR:XXX1234   23.05.11/09.08 DIGROS FIL1015 KATWIJK Z,PAS999
        :61:1105220523D11,8N426NONREF
        :86:BEA   NR:XXX1234   22.05.11/14.25 MC DONALDS A44 LEIDEN,PAS999
        :61:1105210523D13,45N426NONREF
        :86:BEA   NR:XXX1234   21.05.11/12.09 PRINCE FIL. 55 KATWIJK Z,PAS999
        :61:1105210523D15,49N426NONREF
        :86:BEA   NR:XXX1234   21.05.11/12.55 DIRX FIL6017 KATWIJK ZH ,PAS999

        :61:1105210523D107,N426NONREF
        :86:BEA   NR:XXX1234   21.05.11/12.04 HANS ANDERS OPT./056 KAT,PAS999
        :61:1105220523D141,48N426NONREF
        :86:BEA   NR:XXX1234   22.05.11/13.45 MYCOM DEN HAAG  S-GRAVEN,PAS999
        :62F:C110523EUR876,84
      MT940
      stub = instance_double(Cmxl::Statement)
      allow(Cmxl::Statement).to receive(:new).and_return(stub)

      Cmxl.parse(mt940_file('mt940-abnamro'))

      expect(Cmxl::Statement).to have_received(:new).with(expected_data)
    end

    it 'splits the file into two statements' do
      allow(Cmxl::Statement).to receive(:new)

      Cmxl.parse(mt940_file('mt940-abnamro'))

      expect(Cmxl::Statement).to have_received(:new).twice
    end
  end

  describe 'MT940 handelsbank' do
    it 'splits the file with the special characters correctly' do
      expected_data = <<~MT940.chomp
        채4:
        :20:5566778899100112
        :25:10020030/1234567
        :28C:188/1
        :60F:C130928SEK0,
        :62F:C130930SEK0,
        :64:C130930SEK0,
      MT940
      stub = instance_double(Cmxl::Statement)
      allow(Cmxl::Statement).to receive(:new).and_return(stub)

      Cmxl.parse(mt940_file('mt940-handelsbank'))

      expect(Cmxl::Statement).to have_received(:new).with(expected_data)
    end

    it 'splits the file into two statements' do
      allow(Cmxl::Statement).to receive(:new)

      Cmxl.parse(mt940_file('mt940-handelsbank'))

      expect(Cmxl::Statement).to have_received(:new).twice
    end
  end

  describe "MT940 windows line breaks" do
    it 'splits the file with the special characters correctly' do
      expected_data =
        "{1:D02AASDISLNETAXXXXXXXXXXXXX}\r\n"\
        "{2:E623XXXXXXXXAXXXN}\r\n"\
        "{4:\r\n"\
        ":20:1234567\r\n"\
        ":21:9876543210\r\n"\
        ":25:10020030/1234567\r\n"\
        ":28C:5/1\r\n"\
        ":60F:C160314EUR2187,95\r\n"\
        ":61:0211011102DR800,NSTONONREF//55555\r\n"\
        ":86:008?00DAUERAUFTRAG?100599?20Miete November?3010020030?31234567?32MUELLER?34339\r\n"\
        ":61:0211021102CR3000,NTRFNONREF//55555\r\n"\
        ":86:051?00UEBERWEISUNG?100599?20Gehalt Oktober?21Firma\r\n"\
        "Mustermann GmbH?3050060400?310847564700?32MUELLER?34339\r\n"\
        ":62F:C160315EUR4387,95\r\n"\
        ":86:Some random data"
      stub = instance_double(Cmxl::Statement)
      allow(Cmxl::Statement).to receive(:new).and_return(stub)

      Cmxl.parse(mt940_file('mt940-windows-line-breaks'))

      expect(Cmxl::Statement).to have_received(:new).with(expected_data)
    end

    it 'splits the file into two statements' do
      allow(Cmxl::Statement).to receive(:new)

      Cmxl.parse(mt940_file('mt940-windows-line-breaks'))

      expect(Cmxl::Statement).to have_received(:new).once
    end
  end
end
