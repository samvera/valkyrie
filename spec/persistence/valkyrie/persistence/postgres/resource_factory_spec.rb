# frozen_string_literal: true
require 'rails_helper'
require 'penguin/specs/shared_specs'

RSpec.describe Penguin::Persistence::Postgres::ResourceFactory do
  it_behaves_like "a Penguin::ResourceFactory"
end
