# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:each) do
    Valkyrie::Adapter.adapters.values.each do |adapter|
      next unless adapter.is_a?(Valkyrie::Persistence::Memory::Adapter)
      adapter.cache = {}
    end
  end
end
