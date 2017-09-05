# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::StorageAdapter::File do
  let(:io) { instance_double(IO) }
  let(:file) { described_class.new(id: "test_file", io: io) }
  it_behaves_like "a Valkyrie::StorageAdapter::File"
end
