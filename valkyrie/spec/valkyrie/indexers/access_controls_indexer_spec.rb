# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Indexers::AccessControlsIndexer do
  describe ".to_solr" do
    before do
      class Resource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
      end
    end
    after do
      Object.send(:remove_const, :Resource)
    end
    it "indexes for Hydra::AccessControls" do
      resource = Resource.new(read_users: ["read_user"], edit_users: ["edit_user"], read_groups: ["read_group"], edit_groups: ["edit_group"])
      output = described_class.new(resource: resource).to_solr

      expect(output["read_access_person_ssim"]).to eq ["read_user"]
      expect(output["edit_access_person_ssim"]).to eq ["edit_user"]
      expect(output["read_access_group_ssim"]).to eq ["read_group"]
      expect(output["edit_access_group_ssim"]).to eq ["edit_group"]
    end
  end
end
