# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::QueryService do
  let(:adapter) { Valkyrie::Persistence::Fedora::MetadataAdapter.new(fedora_adapter_config(base_path: "test_fed")) }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  it_behaves_like "a Valkyrie query provider"
end
