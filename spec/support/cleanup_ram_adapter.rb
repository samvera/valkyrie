# frozen_string_literal: true
RSpec.configure do |config|
  config.before(:each) do
    Valkyrie::Adapter.find(:XXTREME).cache = {}
  end
end
