# frozen_string_literal: true
require 'rails_helper'
require 'penguin/specs/shared_specs'

RSpec.describe Penguin::Persistence::Fedora do
  let(:adapter) { described_class }
  let(:resource_class) { Book }
  it_behaves_like "a Penguin query provider"
end
