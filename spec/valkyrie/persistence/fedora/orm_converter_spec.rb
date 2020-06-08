# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Fedora::Persister::OrmConverter::GraphToAttributes::Applicator do
  let(:applicator) { described_class.new(:a_property) }
  before do
    allow(applicator).to receive(:warn).and_call_original
  end
  describe '#blacklist?' do
    before do
      allow(applicator).to receive(:deny?)
    end
    it 'is deprecated in favor of #deny?' do
      applicator.blacklist?('something')
      expect(applicator).to have_received(:warn)
      expect(applicator).to have_received(:deny?).with('something')
    end
  end
  describe '#blacklist' do
    before do
      allow(applicator).to receive(:denylist)
    end
    it 'is deprecated in favor of #denylist' do
      applicator.blacklist
      expect(applicator).to have_received(:warn)
      expect(applicator).to have_received(:denylist)
    end
  end
end
