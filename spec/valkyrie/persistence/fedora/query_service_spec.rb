# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::QueryService, :wipe_fedora do
  [4, 5, 6].each do |fedora_version|
    context "fedora #{fedora_version}" do
      let(:version) { fedora_version }
      let(:adapter) { Valkyrie::Persistence::Fedora::MetadataAdapter.new(fedora_adapter_config(base_path: "test_fed", fedora_version: version)) }
      let(:persister) { adapter.persister }
      let(:query_service) { adapter.query_service }
      it_behaves_like "a Valkyrie query provider"
    end
  end
end
