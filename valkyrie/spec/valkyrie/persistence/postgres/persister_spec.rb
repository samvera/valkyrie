# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::Persister do
  let(:query_service) { Valkyrie::Persistence::Postgres::QueryService }

  let(:persister) { described_class }
  it_behaves_like "a Valkyrie::Persister"
end
