# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::Persister do
  let(:resource_class) { Book }
  it_behaves_like "a Valkyrie::Persister"
end
