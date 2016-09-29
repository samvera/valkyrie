RSpec.configure do |config|
  config.before(:all) do
    NoBrainer.sync_schema
  end
  config.before(:each) do
    NoBrainer.purge!
  end
end
