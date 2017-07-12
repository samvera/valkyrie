# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::ActiveFedora::Persister do
  let(:persister) { described_class }
  let(:query_service) { Valkyrie::Persistence::ActiveFedora::QueryService }
  it_behaves_like "a Valkyrie::Persister", :no_deep_nesting, :no_mixed_nesting
end
