# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    Valkyrie::MetadataAdapter.adapters.each_value do |adapter|
      next unless adapter.is_a?(Valkyrie::Persistence::Memory::MetadataAdapter)
      adapter.cache = {}
    end
  end
end
