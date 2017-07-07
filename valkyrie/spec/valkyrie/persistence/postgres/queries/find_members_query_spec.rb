# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Persistence::Postgres::Queries::FindMembersQuery do
  before do
    class Resource < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
      attribute :member_ids, Valkyrie::Types::Array
    end
    class Page < Valkyrie::Model
      attribute :id, Valkyrie::Types::ID.optional
      attribute :member_ids, Valkyrie::Types::Array
    end
  end
  after do
    Object.send(:remove_const, :Resource)
    Object.send(:remove_const, :Page)
  end
  describe "#run" do
    it "finds all member objects in #member_ids" do
      member = persister.save(model: Resource.new)
      member2 = persister.save(model: Resource.new)
      parent = persister.save(model: Resource.new(member_ids: [member2.id, member.id, member2.id]))

      expect(described_class.new(parent).run.to_a.map(&:id)).to eq [member2.id, member.id, member2.id]
    end

    it "finds different member object types" do
      member = persister.save(model: Resource.new)
      member2 = persister.save(model: Page.new)
      parent = persister.save(model: Resource.new(member_ids: [member2.id, member.id]))

      expect(described_class.new(parent).run.to_a.map(&:class)).to eq [Page, Resource]
    end

    def persister
      Valkyrie::Persistence::Postgres::Adapter.persister
    end
  end
end
