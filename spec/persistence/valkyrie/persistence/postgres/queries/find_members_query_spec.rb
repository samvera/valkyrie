# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::Persistence::Postgres::Queries::FindMembersQuery do
  describe "#run" do
    it "finds all member objects in #member_ids" do
      member = persister.save(Book.new)
      member2 = persister.save(Book.new)
      parent = persister.save(Book.new(member_ids: [member2.id, member.id, member2.id]))

      expect(described_class.new(parent).run.to_a.map(&:id)).to eq [member2.id, member.id, member2.id]
    end

    it "finds different member object types" do
      member = persister.save(Book.new)
      member2 = persister.save(Page.new)
      parent = persister.save(Book.new(member_ids: [member2.id, member.id]))

      expect(described_class.new(parent).run.to_a.map(&:class)).to eq [Page, Book]
    end

    def persister
      ::Persister.new(adapter: Valkyrie::Persistence::Postgres)
    end
  end
end
