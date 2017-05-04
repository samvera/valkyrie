# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Valkyrie::FileRepository do
  let(:repository) { instance_double(Valkyrie::FileRepository::Memory) }
  before do
    described_class.register(repository, :example)
  end
  after do
    described_class.unregister(:example)
  end
  describe ".register" do
    it "can register a repository by a short name for easier access" do
      expect(described_class.find(:example)).to eq repository
    end
  end

  describe ".find_by" do
    it "delegates down to its repositories to find one which handles the given identifier" do
      file = instance_double(Valkyrie::FileRepository::File, id: "yo")
      allow(repository).to receive(:handles?).and_return(true)
      allow(repository).to receive(:find_by).and_return(file)
      described_class.register(repository, :find_test)

      expect(described_class.find_by(id: file.id)).to eq file
      expect(repository).to have_received(:find_by).with(id: "yo")
    end
  end
end
