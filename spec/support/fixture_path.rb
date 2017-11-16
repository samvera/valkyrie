# frozen_string_literal: true
module FixturePath
  def fixture_path
    RSpec.configuration.fixture_path
  end
end
RSpec.configure do |config|
  config.add_setting :fixture_path
  config.extend FixturePath
  config.fixture_path = "#{ROOT_PATH}/spec/fixtures"
end
