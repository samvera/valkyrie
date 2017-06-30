# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::AdapterContainer do
  it "wraps up a persister and a query service" do
    persister = instance_double(Valkyrie::Persistence::Memory::Persister)
    query_service = instance_double(Valkyrie::Persistence::Memory::QueryService)

    container = described_class.new(persister: persister, query_service: query_service)
    expect(container.persister).to eq persister
    expect(container.query_service).to eq query_service
  end
end
