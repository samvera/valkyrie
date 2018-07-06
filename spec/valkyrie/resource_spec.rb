# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Resource do
  before do
    class Resource < Valkyrie::Resource
      attribute :title, Valkyrie::Types::Set
    end
  end
  after do
    Object.send(:remove_const, :Resource)
  end
  subject(:resource) { Resource.new }
  describe "#fields" do
    it "returns all configured fields as an array of symbols" do
      expect(Resource.fields).to eq [:id, :internal_resource, :created_at, :updated_at, :title]
    end
  end

  describe ".constructor_type" do
    it "throws a deprecation warning" do
      allow(Resource).to receive(:warn)

      Resource.constructor_type :schema
      expect(Resource).to have_received(:warn)
    end
  end

  describe "initialization with a string hash" do
    it "works, but throws a deprecation warning" do
      expect { Resource.new(title: "test") }.not_to output.to_stderr
      expect { Resource.new("title" => "test") }.to output.to_stderr
      resource = Resource.new("title" => "test")
      expect(resource.title).to eq ["test"]
    end
  end

  describe "#attributes" do
    it "returns all keys even if they're uninitialized" do
      expect(Resource.new.attributes).to eq(
        id: nil,
        internal_resource: "Resource",
        title: [],
        created_at: nil,
        updated_at: nil,
        new_record: true
      )
    end
    it "can not mutate attributes" do
      resource = Resource.new
      expect do
        resource.attributes[:title] = "bla"
      end.to raise_error "can't modify frozen Hash"
    end
  end

  describe "[]" do
    it "works as an accessor for properties" do
      expect(resource[:title]).to eq []
    end
    it "throws a deprecation warning if accessed via a string" do
      # rubocop:disable RSpec/SubjectStub
      allow(resource).to receive(:warn)
      # rubocop:enable RSpec/SubjectStub
      expect(resource["title"]).to eq []

      expect(resource).to have_received(:warn)
    end
  end

  describe "#has_attribute?" do
    it "returns true for fields that exist" do
      expect(resource.has_attribute?(:title)).to eq true
      expect(resource.has_attribute?(:not)).to eq false
    end
  end

  describe "#column_for_attribute" do
    it "returns the column" do
      expect(resource.column_for_attribute(:title)).to eq :title
    end
  end

  describe "#persisted?" do
    context 'when nothing is passed to the constructor' do
      it { is_expected.not_to be_persisted }
    end

    context 'when new_record: false is passed to the constructor' do
      subject(:resource) { Resource.new(new_record: false) }

      it { is_expected.to be_persisted }
    end
  end

  describe "#to_key" do
    it "returns the record's id in an array" do
      resource.id = "test"
      expect(resource.to_key).to eq [resource.id]
    end
  end

  describe "#to_param" do
    it "returns the record's id as a string" do
      resource.id = "test"
      expect(resource.to_param).to eq 'test'
    end
  end

  describe "#to_model" do
    it "returns itself" do
      expect(resource.to_model).to eq resource
    end
  end

  describe "#model_name" do
    it "returns a model name" do
      expect(resource.model_name).to be_kind_of(ActiveModel::Name)
    end
    it "returns a model name at the class level" do
      expect(resource.class.model_name).to be_kind_of(ActiveModel::Name)
    end
  end

  describe "#to_s" do
    it "returns a good serialization" do
      resource.id = "test"
      expect(resource.to_s).to eq "Resource: test"
    end
  end

  describe '.human_readable_type=' do
    it 'sets the human readable type' do
      described_class.human_readable_type = 'Bogus Type'
      expect(described_class.human_readable_type).to eq('Bogus Type')
    end
  end

  context "extended class" do
    before do
      class MyResource < Resource
      end
    end
    after do
      Object.send(:remove_const, :MyResource)
    end
    subject(:resource) { MyResource.new }
    describe "#fields" do
      it "returns all configured parent fields as an array of symbols" do
        expect(MyResource.fields).to eq [:id, :internal_resource, :created_at, :updated_at, :title]
      end
    end
    describe "#internal_resource" do
      it "returns a stringified version of itself" do
        expect(MyResource.new.internal_resource).to eq "MyResource"
      end
    end
    describe "defining an internal attribute" do
      it "warns you and changes the type" do
        expect { MyResource.attribute(:id) }.to output(/is a reserved attribute/).to_stderr
        expect(MyResource.schema[:id]).to eq Valkyrie::Types::Set.optional
      end
    end
  end

  describe "::enable_optimistic_locking" do
    context "when it is enabled" do
      before do
        class MyLockingResource < Valkyrie::Resource
          enable_optimistic_locking
          attribute :title, Valkyrie::Types::Set
        end
      end

      after do
        Object.send(:remove_const, :MyLockingResource)
      end

      it "has an optimistic_lock_token attribute" do
        resource = MyLockingResource.new(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => "lock_token:adapter_id:a_tok:en")

        expect(resource).to respond_to(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK)
        expect(resource.optimistic_locking_enabled?).to be true
        expect(resource.class.optimistic_locking_enabled?).to be true
      end

      describe ".#{Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK}" do
        it "returns an empty array by default" do
          expect(MyLockingResource.new[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK]).to eq []
        end

        it "casts serialized tokens to OptimisticLockTokens" do
          resource = MyLockingResource.new(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => "lock_token:adapter_id:a_tok:en")

          expect(resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK][0]).to be_a Valkyrie::Persistence::OptimisticLockToken
        end

        it "returns a token if given a token" do
          resource = MyLockingResource.new(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => Valkyrie::Persistence::OptimisticLockToken.deserialize("lock_token:adapter_id:a_tok:en"))

          expect(resource[Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK][0]).to be_a Valkyrie::Persistence::OptimisticLockToken
        end
      end
    end

    context "when it is not enabled" do
      before do
        class MyNonlockingResource < Valkyrie::Resource
          attribute :title, Valkyrie::Types::Set
        end
      end

      after do
        Object.send(:remove_const, :MyNonlockingResource)
      end

      it "does not have an optimistic_lock_token attribute" do
        expect(MyNonlockingResource.new).not_to respond_to(:optimistic_lock_token)
        expect(MyNonlockingResource.new.optimistic_locking_enabled?).to be false
        expect(MyNonlockingResource.optimistic_locking_enabled?).to be false
      end
    end
  end
end
