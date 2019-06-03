require 'spec_helper'

describe Cmxl::Fields::StatementDetails do
  context 'sepa' do
    subject { Cmxl::Fields::StatementDetails.parse(fixture_line(:statement_details)) }

    it { expect(subject.transaction_code).to eql('171') }
    it { expect(subject.seperator).to eql('?') }
    it { expect(subject.description).to eql('SEPA LASTSCHRIFT KUNDE') }
    it { expect(subject.information).to eql('KREF+EREF+TRX-0A4A47C3-F846-4729-8A1B-5DF620FMREF+CAC97D2144174318AC18D9BF815BD4FBCRED+DE98ZZZ09999999999SVWZ+FOO TRX-0A4A47C3-F846-4729-8A1B-5DF620F') }
    it { expect(subject.bic).to eql('HYVEDEMMXXX') }
    it { expect(subject.name).to eql('Peter Pan') }
    it { expect(subject.iban).to eql('HUkkbbbsssskcccccccccccccccx') }
    it {
      expect(subject.sub_fields).to eql(
        '00' => 'SEPA LASTSCHRIFT KUNDE',
        '10' => '281',
        '20' => 'KREF+EREF+TRX-0A4A47C3-F846-4729',
        '21' => '-8A1B-5DF620F',
        '22' => 'MREF+CAC97D2144174318AC18D9',
        '23' => 'BF815BD4FB',
        '24' => 'CRED+DE98ZZZ09999999999',
        '25' => 'SVWZ+FOO TRX-0A4A47C3-F84',
        '26' => '6-4729-8A1B-5DF620F',
        '30' => 'HYVEDEMMXXX',
        '31' => 'HUkkbbbsssskcccccccccccccccx',
        '32' => 'Peter Pan',
        '99' => '',
        '34' => '171'
      )
    }
    it {
      expect(subject.sepa).to eql(
        'KREF' => '',
        'CRED' => 'DE98ZZZ09999999999',
        'EREF' => 'TRX-0A4A47C3-F846-4729-8A1B-5DF620F',
        'MREF' => 'CAC97D2144174318AC18D9BF815BD4FB',
        'SVWZ' => 'FOO TRX-0A4A47C3-F846-4729-8A1B-5DF620F'
      )
    }

    it {
      expect(subject.to_h).to eql(
        'bic' => 'HYVEDEMMXXX',
        'iban' => 'HUkkbbbsssskcccccccccccccccx',
        'name' => 'Peter Pan',
        'sepa' => {
          'KREF' => '',
          'EREF' => 'TRX-0A4A47C3-F846-4729-8A1B-5DF620F',
          'MREF' => 'CAC97D2144174318AC18D9BF815BD4FB',
          'CRED' => 'DE98ZZZ09999999999',
          'SVWZ' => 'FOO TRX-0A4A47C3-F846-4729-8A1B-5DF620F'
        },
        'information' => 'KREF+EREF+TRX-0A4A47C3-F846-4729-8A1B-5DF620FMREF+CAC97D2144174318AC18D9BF815BD4FBCRED+DE98ZZZ09999999999SVWZ+FOO TRX-0A4A47C3-F846-4729-8A1B-5DF620F',
        'description' => 'SEPA LASTSCHRIFT KUNDE',
        'sub_fields' => {
          '00' => 'SEPA LASTSCHRIFT KUNDE',
          '10' => '281',
          '20' => 'KREF+EREF+TRX-0A4A47C3-F846-4729',
          '21' => '-8A1B-5DF620F',
          '22' => 'MREF+CAC97D2144174318AC18D9',
          '23' => 'BF815BD4FB',
          '24' => 'CRED+DE98ZZZ09999999999',
          '25' => 'SVWZ+FOO TRX-0A4A47C3-F84',
          '26' => '6-4729-8A1B-5DF620F',
          '30' => 'HYVEDEMMXXX',
          '31' => 'HUkkbbbsssskcccccccccccccccx',
          '32' => 'Peter Pan',
          '34' => '171',
          '99' => ''
        },
        'transaction_code' => '171',
        'details' => '?00SEPA LASTSCHRIFT KUNDE?10281?20KREF+EREF+TRX-0A4A47C3-F846-4729?21-8A1B-5DF620F?22MREF+CAC97D2144174318AC18D9?23BF815BD4FB?24CRED+DE98ZZZ09999999999?25SVWZ+FOO TRX-0A4A47C3-F84?266-4729-8A1B-5DF620F?30HYVEDEMMXXX?31HUkkbbbsssskcccccccccccccccx?32Peter Pan?99?34171'
      )
    }
    it { expect(subject.to_hash).to eql(subject.to_h) }
  end

  describe 'information parsing with empty fields on the end' do
    subject { Cmxl::Fields::StatementDetails.parse(fixture_line(:statement_details_empty_fields)) }

    it {
      expect(subject.sepa).to eql(
        'EREF' => 'S1001675',
        'SVWZ' => ''
      )
    }
  end
end
