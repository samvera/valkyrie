# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie locking persister' do
  before do
    class MyLockingResource < Valkyrie::Resource
      enable_optimistic_locking
      attribute :title
    end
  end

  after do
    ActiveSupport::Dependencies.remove_constant("MyLockingResource")
  end

  describe "#save" do
    context "when creating a resource" do
      it "returns the value of the system-generated optimistic locking attribute on the resource" do
        resource = MyLockingResource.new(title: ["My Locked Resource"])
        saved_resource = persister.save(resource: resource)
        expect(saved_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)).not_to be_empty
      end
    end

    context "when updating a resource with a correct lock token" do
      it "successfully saves the resource and returns the updated value of the optimistic locking attribute" do
        resource = MyLockingResource.new(title: ["My Locked Resource"])
        initial_resource = persister.save(resource: resource)
        updated_resource = persister.save(resource: initial_resource)
        expect(initial_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK))
          .not_to eq updated_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
      end
    end

    context "when updating a resource with an incorrect lock token" do
      it "raises a Valkyrie::Persistence::StaleObjectError" do
        resource = MyLockingResource.new(title: ["My Locked Resource"])
        resource = persister.save(resource: resource)
        # update the resource in the datastore to make its token stale
        persister.save(resource: resource)

        expect { persister.save(resource: resource) }.to raise_error(Valkyrie::Persistence::StaleObjectError, resource.id.to_s)
      end
    end

    context "when lock token is nil" do
      it "successfully saves the resource and returns the updated value of the optimistic locking attribute" do
        resource = MyLockingResource.new(title: ["My Locked Resource"])
        initial_resource = persister.save(resource: resource)
        initial_token = initial_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
        initial_resource.send("#{Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK}=", [])
        updated_resource = persister.save(resource: initial_resource)
        expect(initial_token).not_to eq updated_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
        expect(updated_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)).not_to be_empty
      end
    end
  end

  describe "#save_all" do
    context "when creating multiple resources" do
      it "returns an array of resources with their system-generated optimistic locking attributes" do
        resource1 = MyLockingResource.new(title: ["My Locked Resource 1"])
        resource2 = MyLockingResource.new(title: ["My Locked Resource 2"])
        resource3 = MyLockingResource.new(title: ["My Locked Resource 3"])
        saved_resources = persister.save_all(resources: [resource1, resource2, resource3])
        saved_resources.each do |saved_resource|
          expect(saved_resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)).not_to be_empty
        end
      end
    end

    context "when updating multiple resources that all have a correct lock token" do
      it "saves the resources and returns them with updated values of the optimistic locking attribute" do
        resource1 = MyLockingResource.new(title: ["My Locked Resource 1"])
        resource2 = MyLockingResource.new(title: ["My Locked Resource 2"])
        resource3 = MyLockingResource.new(title: ["My Locked Resource 3"])
        saved_resources = persister.save_all(resources: [resource1, resource2, resource3])
        initial_lock_tokens = saved_resources.map do |r|
          r.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
        end
        updated_resources = persister.save_all(resources: saved_resources)
        updated_lock_tokens = updated_resources.map do |r|
          r.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
        end
        expect(initial_lock_tokens & updated_lock_tokens).to be_empty
      end
    end

    context "when one of the resources has an incorrect lock token" do
      it "raises a Valkyrie::Persistence::StaleObjectError" do
        resource1 = MyLockingResource.new(title: ["My Locked Resource 1"])
        resource2 = MyLockingResource.new(title: ["My Locked Resource 2"])
        resource3 = MyLockingResource.new(title: ["My Locked Resource 3"])
        resource1, resource2, resource3 = persister.save_all(resources: [resource1, resource2, resource3])
        # update a resource in the datastore to make its token stale
        persister.save(resource: resource2)

        expect { persister.save_all(resources: [resource1, resource2, resource3]) }
          .to raise_error(Valkyrie::Persistence::StaleObjectError, [resource1, resource2, resource3].map(&:id).join(", "))
      end
    end
  end
end
