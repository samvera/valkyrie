# frozen_string_literal: true
module Valkyrie
  class DecoratorList
    attr_reader :decorators
    def initialize(*decorators)
      @decorators = decorators
    end

    def new(undecorated_object)
      decorators.inject(undecorated_object) do |obj, decorator|
        decorator.new(obj)
      end
    end
  end
end
