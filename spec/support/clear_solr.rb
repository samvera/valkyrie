# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    Blacklight.default_index.connection.delete_by_query("*:*")
    Blacklight.default_index.connection.commit
  end
end
