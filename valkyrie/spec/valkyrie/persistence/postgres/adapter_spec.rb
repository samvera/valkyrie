# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::Adapter do
  let(:adapter) { described_class }
  it_behaves_like "a Valkyrie::Adapter"
end
