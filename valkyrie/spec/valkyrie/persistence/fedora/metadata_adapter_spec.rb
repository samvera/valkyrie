# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::MetadataAdapter do
  let(:adapter) { described_class.new(connection: ::Ldp::Client.new("http://localhost:3988/rest"), base_path: "/test_fed") }
  it_behaves_like "a Valkyrie::MetadataAdapter"
end
