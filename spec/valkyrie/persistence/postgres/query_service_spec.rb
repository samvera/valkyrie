# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres::QueryService do
  let(:adapter) { Valkyrie::Persistence::Postgres::Adapter }
  it_behaves_like "a Valkyrie query provider"
end
