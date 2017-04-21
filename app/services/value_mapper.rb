# frozen_string_literal: true
class ValueMapper
  def self.register(value_caster)
    self.value_casters += [value_caster]
  end

  def self.value_casters
    @value_casters ||= []
  end

  class << self
    attr_writer :value_casters
  end

  def self.for(value)
    (value_casters + [self]).find do |value_caster|
      value_caster.handles?(value)
    end.new(value, self)
  end

  def self.handles?(_value)
    true
  end

  attr_reader :value, :calling_mapper
  def initialize(value, calling_mapper)
    @value = value
    @calling_mapper = calling_mapper
  end

  def result
    value
  end
end
