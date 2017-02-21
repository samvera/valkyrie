# frozen_string_literal: true
require 'active_fedora/cleaner'

RSpec.configure do |config|
  config.before :each do
    ActiveFedora::Cleaner.clean! if ActiveFedora::Base.count > 0
  end
end
