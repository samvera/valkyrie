# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::ValueMapper do
  before do
    class SubMapper < Valkyrie::ValueMapper
    end
    class TestMapper < Valkyrie::ValueMapper
      SubMapper.register(self)
      def self.handles?(value)
        value == 1
      end

      def result
        "yo"
      end
    end
  end
  after do
    Object.send(:remove_const, :SubMapper)
    Object.send(:remove_const, :TestMapper)
  end
  it "doesn't share value casters with parent" do
    expect(described_class.value_casters).to eq []
    expect(SubMapper.value_casters).to eq [TestMapper]
  end

  describe "#result" do
    context "when not handled by a registered handler" do
      it "returns the given value back" do
        expect(SubMapper.for(2).result).to eq 2
      end
    end
    context "when handled by a registered handler" do
      it "returns that handler's result" do
        expect(SubMapper.for(1).result).to eq "yo"
      end
    end
  end
end
