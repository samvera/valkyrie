# frozen_string_literal: true
require 'rails_helper'
require 'penguin/specs/shared_specs'

RSpec.describe Penguin::Persistence::Fedora::Persister do
  let(:persister) { described_class }
  it_behaves_like "a Penguin::Persister"
end
