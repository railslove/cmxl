require 'spec_helper'

describe 'Unknown fields' do
  context 'numerical fields' do
    subject { Cmxl::Field.parse(':42F:C140908EUR000000000136,02') }
    it { expect(subject.tag).to eql('42') }
    it { expect(subject.source).to eql('C140908EUR000000000136,02') }
    it { expect(subject.to_h).to eql(tag: '42', modifier: 'F', source: 'C140908EUR000000000136,02') }
  end

  context 'alphanumerical fields w/ modifier' do
    subject { Cmxl::Field.parse(':NSF:SomethingSomethingDarkSide') }
    it { expect(subject.tag).to eql('NS') }
    it { expect(subject.source).to eql('SomethingSomethingDarkSide') }
    it { expect(subject.to_h).to eql(tag: 'NS', modifier: 'F', source: 'SomethingSomethingDarkSide') }
  end

  context 'alphanumerical fields wo/ modifier' do
    subject { Cmxl::Field.parse(':FO:oBar') }
    it { expect(subject.tag).to eql('FO') }
    it { expect(subject.source).to eql('oBar') }
    it { expect(subject.to_h).to eql(tag: 'FO', modifier: nil, source: 'oBar') }
  end
end
