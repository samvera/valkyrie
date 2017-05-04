# frozen_string_literal: true
module Valkyrie
  class DecoratorWithArguments
    attr_reader :decorator, :args
    def initialize(decorator, *args)
      @decorator = decorator
      @args = args
    end

    def new(item)
      decorator.new(item, *args)
    end
  end
end
