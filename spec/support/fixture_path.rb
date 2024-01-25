# frozen_string_literal: true
module FixturePath
  def fixture_path
    RSpec.configuration.fixture_path
  end

  def file_fixture_path
    RSpec.configuration.fixture_path
  end

  def file_fixture(path)
    Pathname.new(file_fixture_path).join(path)
  end
end
RSpec.configure do |config|
  config.add_setting :fixture_path
  config.extend FixturePath
  config.include FixturePath
  config.fixture_path = "#{Valkyrie::Engine.root}/spec/fixtures"
end
