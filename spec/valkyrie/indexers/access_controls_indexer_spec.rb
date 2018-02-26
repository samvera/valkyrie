# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Indexers::AccessControlsIndexer do
  describe ".to_solr" do
    before do
      class Resource < Valkyrie::Resource
        include Valkyrie::Resource::AccessControls
      end
      class SimpleResource < Valkyrie::Resource
      end
    end
    after do
      Object.send(:remove_const, :Resource)
      Object.send(:remove_const, :SimpleResource)
    end
    context "without Hydra::AccessControls" do
      it "indexes without Hydra::AccessControls" do
        resource = Resource.new(read_users: ["read_user"], edit_users: ["edit_user"], read_groups: ["read_group"], edit_groups: ["edit_group"])
        output = described_class.new(resource: resource).to_solr

        expect(output["read_access_person_ssim"]).to eq ["read_user"]
        expect(output["edit_access_person_ssim"]).to eq ["edit_user"]
        expect(output["read_access_group_ssim"]).to eq ["read_group"]
        expect(output["edit_access_group_ssim"]).to eq ["edit_group"]
      end
      context "when it's passed a resource which has no read_users" do
        it "does nothing" do
          resource = SimpleResource.new(read_users: ["read_user"], edit_users: ["edit_user"], read_groups: ["read_group"], edit_groups: ["edit_group"])
          output = described_class.new(resource: resource).to_solr

          expect(output).to eq({})
        end
      end
    end

    context "with Hydra::AccessControls" do
      before do
        class EditPermission
          def group
            'test_edit_access_group'
          end

          def individual
            'test_edit_access_person'
          end
        end
        class ReadPermission
          def group
            'test_read_access_group'
          end

          def individual
            'test_read_access_person'
          end
        end

        module Hydra
          class << self
            def configure(_ = nil)
              { permissions: { read: ReadPermission.new, edit: EditPermission.new } }
            end
            alias config configure
          end
        end
      end
      after do
        Hydra.remove_possible_method(:configure)
      end

      it "indexes with Hydra::AccessControls" do
        resource = Resource.new(read_users: ["read_user"], edit_users: ["edit_user"], read_groups: ["read_group"], edit_groups: ["edit_group"])
        output = described_class.new(resource: resource).to_solr

        expect(output["test_read_access_person"]).to eq ["read_user"]
        expect(output["test_edit_access_person"]).to eq ["edit_user"]
        expect(output["test_read_access_group"]).to eq ["read_group"]
        expect(output["test_edit_access_group"]).to eq ["edit_group"]
      end
    end
  end
end
