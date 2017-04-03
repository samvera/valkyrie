# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::LDP::QueryService do
  let(:adapter) { Valkyrie::Persistence::LDP::Adapter.new(url: "http://localhost:4567") }
  let(:resource_class) { Book }
  it_behaves_like "a Valkyrie query provider"
end
