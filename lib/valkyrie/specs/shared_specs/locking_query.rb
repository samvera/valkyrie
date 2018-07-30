# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie locking query provider' do
  before do
    raise 'adapter must be set with `let(:adapter)`' unless
      defined? adapter
    class CustomLockingQueryResource < Valkyrie::Resource
      enable_optimistic_locking
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title
    end
  end
  after do
    Object.send(:remove_const, :CustomLockingQueryResource)
  end

  let(:query_service) { adapter.query_service } unless defined? query_service
  let(:persister) { adapter.persister }
  subject { adapter.query_service }

  it "retrieves the lock token and casts it to optimistic_lock_token attribute" do
    resource = CustomLockingQueryResource.new(title: "My Title")
    resource = persister.save(resource: resource)
    resource = query_service.find_by(id: resource.id)
    # we can't know the value in the general case
    expect(resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)).not_to be_empty
  end
end
