# frozen_string_literal: true
require 'rails_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe ::ResourceFactory do
  it_behaves_like "a Valkyrie::ResourceFactory"
end
