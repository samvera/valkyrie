# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    persister = Valkyrie::Persistence::Redis::MetadataAdapter.new.persister
    persister.wipe!
  end
end
