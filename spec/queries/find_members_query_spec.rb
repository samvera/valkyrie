# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FindMembersQuery do
  describe "#run" do
    it "finds all member objects in #member_ids" do
      member = Persister.save(Book.new)
      member2 = Persister.save(Book.new)
      parent = Persister.save(Book.new(member_ids: [member2.id, member.id, member2.id]))

      expect(described_class.new(parent).run.to_a.map(&:id)).to eq [member2.id, member.id, member2.id]
    end

    it "finds different member object types" do
      member = Persister.save(Book.new)
      member2 = Persister.save(Page.new)
      parent = Persister.save(Book.new(member_ids: [member2.id, member.id]))

      expect(described_class.new(parent).run.to_a.map(&:class)).to eq [Page, Book]
    end
  end
end
