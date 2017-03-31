# frozen_string_literal: true
require 'rails_helper'
require 'penguin/specs/shared_specs'

RSpec.describe AppendingPersister do
  let(:persister) { described_class.new(Persister.new(adapter: Penguin::Persistence::Postgres)) }
  it_behaves_like "a Penguin::Persister"

  it "appends when given a form with an append_id" do
    parent = persister.save(Book.new)
    form = BookForm.new(Book.new)
    form.append_id = parent.id

    output = persister.save(form)
    reloaded = persister.adapter.query_service.find_by_id(parent.id)

    expect(reloaded.member_ids).to eq [output.id]
  end
end
