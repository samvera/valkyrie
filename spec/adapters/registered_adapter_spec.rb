# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Adapter do
  described_class.adapters.each do |key, adapter|
    let(:adapter) { adapter }
    it_behaves_like "a Valkyrie::Adapter", adapter
  end
end
