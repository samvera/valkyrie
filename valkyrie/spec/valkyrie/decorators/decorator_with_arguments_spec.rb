# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Decorators::DecoratorWithArguments do
  before do
    class Decorator < SimpleDelegator
      def initialize(obj, test)
        super(obj)
        @test = test
      end

      attr_reader :test
    end
  end
  after do
    Object.send(:remove_const, :Decorator)
  end
  it "can delay adding arguments to a decorator" do
    decorator_with_arguments = described_class.new(Decorator, "testing")
    output = decorator_with_arguments.new(1)
    expect(output.test).to eq "testing"
  end
end
