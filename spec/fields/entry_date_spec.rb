require 'spec_helper'

describe Cmxl::Fields::EntryDate do
  context 'iban' do
    subject { Cmxl::Fields::EntryDate.parse( fixture_line(:entry_date) ) }

    it { expect(subject.date).to eql(Date.parse('2017/12/29')) }
  end
end
