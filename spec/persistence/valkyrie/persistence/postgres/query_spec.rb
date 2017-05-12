# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Postgres do
  let(:adapter) { described_class }
  it_behaves_like "a Valkyrie query provider"
end
