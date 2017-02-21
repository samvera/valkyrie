# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::Fedora::ResourceFactory do
  it_behaves_like "a Valkyrie::ResourceFactory"
end
