require 'spec_helper'

describe 'Unknwn fields' do

  subject { Cmxl::Field.parse(':42F:C140908EUR000000000136,02') }
  it { expect(subject.tag).to eql('42') }
  it { expect(subject.source).to eql('C140908EUR000000000136,02') }
  it { expect(subject.to_h).to eql({tag: '42', modifier: 'F', source: 'C140908EUR000000000136,02'}) }
end
