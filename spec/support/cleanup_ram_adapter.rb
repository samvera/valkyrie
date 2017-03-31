# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:each) do
    Valkyrie::Adapter.adapters.values.select do |adapter|
      adapter.is_a?(Valkyrie::Persistence::Memory::Adapter)
    end.each do |adapter|
      adapter.cache = {}
    end
  end
end
