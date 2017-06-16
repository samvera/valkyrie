# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::Persistence::Postgres::Queries::FindMembersQuery do
  describe "#run" do
    it "finds all member objects in #member_ids" do
      member = persister.save(model: Book.new(title: "Title"))
      member2 = persister.save(model: Book.new)
      parent = persister.save(model: Book.new(member_ids: [member2.id, member.id, member2.id]))

      result = described_class.new(parent).run.to_a
      expect(result.map(&:id)).to eq [member2.id, member.id, member2.id]
      expect(result[1].title).to eq member.title
    end

    it "finds different member object types" do
      member = persister.save(model: Book.new)
      member2 = persister.save(model: Page.new)
      parent = persister.save(model: Book.new(member_ids: [member2.id, member.id]))

      expect(described_class.new(parent).run.to_a.map(&:class)).to eq [Page, Book]
    end

    def persister
      ::Persister.new(adapter: Valkyrie::Persistence::Postgres::Adapter)
    end
  end
end
