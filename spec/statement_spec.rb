require 'spec_helper'

describe Cmxl do
  context 'mt940' do
    context 'with details' do
      subject { Cmxl.parse(mt940_file('statement-details-mt940')).first.transactions.first }

      it { expect(subject.mt942?).to be_falsey }
      it { expect(subject).to be_debit }
      it { expect(subject).to_not be_credit }
      it { expect(subject.funds_code).to eql('D') }
      it { expect(subject.date).to eql(Date.new(2014, 9, 1)) }
      it { expect(subject.entry_date).to eql(Date.new(2014, 9, 2)) }
      it { expect(subject.amount).to eql(1.62) }
      it { expect(subject.amount_in_cents).to eql(162) }
      it { expect(subject.primanota).to eql('281') }
      it {
        expect(subject.to_h).to eql(
          'date' => Date.new(2014, 9, 1),
          'sha' => '3c5e65aa3d3878b06b58b6f1ae2f3693004dfb04e3ab7119a1c1244e612293da',
          'entry_date' => Date.new(2014, 9, 2),
          'funds_code' => 'D',
          'currency_letter' => 'R',
          'amount' => 1.62,
          'swift_code' => 'NTRF',
          'reference' => '0000549855700010',
          'bank_reference' => '025498557/000001',
          'amount_in_cents' => 162,
          'sign' => -1,
          'credit_debit_indicator' => 'D',
          'debit' => true,
          'credit' => false,
          'storno' => false,
          'reversal' => false,
          'expected' => false,
          'bic' => 'HYVEDEMMXXX',
          'iban' => 'HUkkbbbsssskcccccccccccccccx',
          'name' => 'Peter Pan',
          'sepa' => {
            'KREF' => '',
            'EREF' => 'TRX-0A4A47C3-F846-4729-8A1B-5DF620F:FOO:',
            'MREF' => 'CAC97D2144174318ABF815BD4FB',
            'CRED' => 'DE98ZZZ09999999999',
            'SVWZ' => 'FOO TRX-0A4A47C3-F846-4729-8A1B-5DF620F'
          },
          'information' => 'KREF+EREF+TRX-0A4A47C3-F846-4729-8A1B-5DF620F:FOO:MREF+CAC97D2144174318ABF815BD4FBCRED+DE98ZZZ09999999999SVWZ+FOO TRX-0A4A47C3-F846-4729-8A1B-5DF620F',
          'description' => 'SEPA LASTSCHRIFT KUNDE',
          'sub_fields' => {
            '00' => 'SEPA LASTSCHRIFT KUNDE',
            '10' => '281',
            '20' => 'KREF+EREF+TRX-0A4A47C3-F846-4729',
            '21' => '-8A1B-5DF620F',
            '22' => ':FOO:MREF+CAC97D2144174318A',
            '23' => 'BF815BD4FB',
            '24' => 'CRED+DE98ZZZ09999999999',
            '25' => 'SVWZ+FOO TRX-0A4A47C3-F84',
            '26' => '6-4729-8A1B-5DF620F',
            '30' => 'HYVEDEMMXXX',
            '31' => 'HUkkbbbsssskcccccccccccccccx',
            '32' => 'Peter Pan',
            '99' => '',
            '34' => '171'
          },
          'transaction_code' => '171',
          'primanota' => '281',
          'details' => '?00SEPA LASTSCHRIFT KUNDE?10281?20KREF+EREF+TRX-0A4A47C3-F846-4729?21-8A1B-5DF620F?22:FOO:MREF+CAC97D2144174318A?23BF815BD4FB?24CRED+DE98ZZZ09999999999?25SVWZ+FOO TRX-0A4A47C3-F84?266-4729-8A1B-5DF620F?30HYVEDEMMXXX?31HUkkbbbsssskcccccccccccccccx?32Peter Pan?99?34171'
        )
      }
    end

    context 'without details' do
      subject { Cmxl.parse(mt940_file('statement-mt940')).first.transactions.first }

      it { expect(subject.mt942?).to be_falsey }
      it { expect(subject).to be_debit }
      it { expect(subject).to_not be_credit }
      it { expect(subject.date).to eql(Date.new(2014, 9, 1)) }
      it { expect(subject.entry_date).to eql(Date.new(2014, 9, 2)) }
      it { expect(subject.amount).to eql(1.62) }
      it { expect(subject.amount_in_cents).to eql(162) }
      it 'does not include any details in its hash representation' do
        expect(subject.to_h).to eql(
          'date' => Date.new(2014, 9, 1),
          'sha' => '3c5e65aa3d3878b06b58b6f1ae2f3693004dfb04e3ab7119a1c1244e612293da',
          'entry_date' => Date.new(2014, 9, 2),
          'funds_code' => 'D',
          'credit_debit_indicator' => 'D',
          'currency_letter' => 'R',
          'amount' => 1.62,
          'swift_code' => 'NTRF',
          'reference' => '0000549855700010',
          'bank_reference' => '025498557/000001',
          'amount_in_cents' => 162,
          'sign' => -1,
          'debit' => true,
          'credit' => false,
          'storno' => false,
          'reversal' => false,
          'expected' => false,
        )
      end
    end

    describe 'statement issued over a years boundary' do
      subject { Cmxl.parse(mt940_file('statement-mt940')).first.transactions.last }

      it { expect(subject.mt942?).to be_falsey }

      it 'includes correct entry date' do
        expect(subject.entry_date).to eq(Date.new(2013, 12, 29))
      end

      it 'includes correct date' do
        expect(subject.date).to eq(Date.new(2014, 0o1, 0o4))
      end
    end

    describe 'statement with detailed end balance' do
      subject { Cmxl.parse(mt940_file('mt940-with-detailed-end-balance')).first.transactions.first }

      it { expect(subject.mt942?).to be_falsey }

      it 'includes correct iban' do
        expect(subject.iban).to eq('234567')
      end

      it 'includes correct bic' do
        expect(subject.bic).to eq('10020030')
      end
    end

    describe 'statement with colon right after linebreak' do
      subject { Cmxl.parse(mt940_file('mt940-with-colon-after-line-break')).first.transactions.first }

      it 'has the right details' do
        expect(subject.to_h['details']).to eq('?109075/658?20EREF+000000000193592204?21MREF+CN3R3U?22CRED+DE7600200000132558?23SVWZ+STARTER//8449273399/US?24 22-04-2019T03:46:08 Karten?25nr. 5355999999999975  Origi?26nal 49,00 USD 1 EUR/1,12385?27 USD  Entgelt 0,44 EUR?30DEUTDEDBFRA?31DE19500700240004020480?32DEUTSCHE BANK')
      end
    end
  end

  context 'mt942' do
    subject(:statement) { Cmxl.parse(mt940_file('mt942')).first }

    it { expect(statement.mt942?).to be_truthy }
    it { expect(statement.vmk_credit_summary.amount).to eql(9792.00) }
    it { expect(statement.vmk_credit_summary.currency).to eql('EUR') }
    it { expect(statement.vmk_debit_summary.amount).to eql(0.00) }
    it { expect(statement.vmk_debit_summary.currency).to eql('EUR') }

    it 'includes correct iban' do
      expect(subject.transactions.first.iban).to eq('234567')
    end
  end

  context 'mt942 generation date from field 20' do
    subject(:statement) { Cmxl.parse(mt940_file('mt942')).first }

    it { expect(statement.mt942?).to be_truthy }
    it { expect(statement.generation_date).to eql(Date.new(2013, 11, 10)) }

  end

  context 'mt942 generation date from field 13' do
    subject(:statement) { Cmxl.parse(mt940_file('mt942'))[1] }

    it { expect(statement.mt942?).to be_truthy }
    it { expect(statement.generation_date).to eql(Date.new(2019, 1, 9)) }
  end

  describe "header parsing" do
    context "when strip_headers is enabled" do
      around do |example|
        existing_value = Cmxl.config[:strip_headers]
        Cmxl.config[:strip_headers] = true
        example.run
        Cmxl.config[:strip_headers] = existing_value
      end

      it "removes any headers" do
        data = <<~MT940.chomp
          {1:D02AASDISLNETAXXXXXXXXXXXXX}
          {2:E623XXXXXXXXAXXXN}
          {4:
          :20:MT940/78374
          :25:xxxxxxxxxxxxxx
          :28C:3/1
          :60F:C160201INR0,00
          :61:3622687806CR1368378,92NMSC37935531
          :86:-TX TRN-REF NO.1156ADS5601187 EUR 13456/TSV
          :62F:C141387INR11 27421,94
          -}
        MT940

        result = Cmxl::Statement.new(data)

        expect(result.fields.count).to eq(6)
      end

      it "does nothing if there are no headers" do
        data = <<~MT940.chomp
          :20:MT940/78374
          :25:xxxxxxxxxxxxxx
          :28C:3/1
          :60F:C160201INR0,00
          :61:3622687806CR1368378,92NMSC37935531
          :86:-TX TRN-REF NO.1156ADS5601187 EUR 13456/TSV
          :62F:C141387INR11 27421,94
        MT940

        result = Cmxl::Statement.new(data)

        expect(result.fields.count).to eq(6)
      end
    end

    context "when strip_headers is disabled" do
      around do |example|
        existing_value = Cmxl.config[:strip_headers]
        Cmxl.config[:strip_headers] = false
        example.run
        Cmxl.config[:strip_headers] = existing_value
      end

      it "raise an parsing error exception if headers are present" do
        data = <<~MT940.chomp
          {1:D02AASDISLNETAXXXXXXXXXXXXX}
          {2:E623XXXXXXXXAXXXN}
          {4:
          :20:MT940/78374
          :25:xxxxxxxxxxxxxx
          :28C:3/1
          :60F:C160201INR0,00
          :61:3622687806CR1368378,92NMSC37935531
          :86:-TX TRN-REF NO.1156ADS5601187 EUR 13456/TSV
          :62F:C141387INR11 27421,94
          -}
        MT940

        expect{
          Cmxl::Statement.new(data)
        }.to raise_error(Cmxl::Field::LineFormatError)
      end

      it "extracts the field" do
        data = <<~MT940.chomp
          :20:MT940/78374
          :25:xxxxxxxxxxxxxx
          :28C:3/1
          :60F:C160201INR0,00
          :61:3622687806CR1368378,92NMSC37935531
          :86:-TX TRN-REF NO.1156ADS5601187 EUR 13456/TSV
          :62F:C141387INR11 27421,94
        MT940

        result = Cmxl::Statement.new(data)

        expect(result.fields.count).to eq(6)
      end
    end
  end
end
