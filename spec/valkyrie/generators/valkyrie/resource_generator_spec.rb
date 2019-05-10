# frozen_string_literal: true
require 'spec_helper'
require 'rails/generators'
require 'rails/generators/model_helpers'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::ResourceGenerator do
  before do
    # define RSpec::Rails so test file is generated
    module RSpec::Rails; end

    tempdir = ROOT_PATH.join('tmp', 'resource')
    Rails::Generators.invoke('valkyrie:resource', ['Helm', 'title', 'member_ids:array'], destination_root: tempdir)
    load "#{tempdir}/app/models/helm.rb"
  end

  after do
    tempdir = ROOT_PATH.join('tmp', 'resource')
    Object.send(:remove_const, :Helm)
    RSpec.send(:remove_const, :Rails)
    Rails::Generators.invoke('valkyrie:resource', ['Helm'], behavior: :revoke, destination_root: tempdir)
  end

  let(:subject) { Helm.new }
  let(:helm) { Helm.new }
  let(:resource_klass) { Helm }
  it_behaves_like 'a Valkyrie::Resource'

  it 'generates the model and model test files' do
    expect(ROOT_PATH.join('tmp', 'resource', 'app', 'models', 'helm.rb')).to exist
    expect(ROOT_PATH.join('tmp', 'resource', 'spec', 'models', 'helm_spec.rb')).to exist
  end

  it 'has title and member_ids fields' do
    helm.title = ['Helm']
    helm.member_ids = ['1', '2', '3']
    expect(helm.title).to eq(['Helm'])
    expect(helm.member_ids).to eq(['1', '2', '3'])
  end
end
