# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::DerivativeService do
  it_behaves_like "a Valkyrie::DerivativeService"
  let(:valid_file_set) { FileSet.new }
  let(:derivative_service) { described_class }
end
