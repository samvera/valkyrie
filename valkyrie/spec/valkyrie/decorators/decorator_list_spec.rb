# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Decorators::DecoratorList do
  before do
    class OneDecorator < SimpleDelegator
      def test
        "one"
      end
    end
    class TwoDecorator < SimpleDelegator
      def test
        super + " two"
      end
    end
  end
  after do
    Object.send(:remove_const, :OneDecorator)
    Object.send(:remove_const, :TwoDecorator)
  end
  it "allows for multiple decorators to act as one" do
    composite_decorator = described_class.new(OneDecorator, TwoDecorator)
    output = composite_decorator.new(5)

    expect(output.test).to eq "one two"
  end
end
