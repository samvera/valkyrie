# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

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
  let(:resource_klass) { Resource }
  it_behaves_like "a Valkyrie::Resource"

  describe '.attributes' do
    let(:schema) { { attr1: Valkyrie::Types::String, attr2: Valkyrie::Types::Set } }

    it 'defines new attributes' do
      expect { Resource.attributes(schema) }
        .to change { Resource.fields }
        .to include(:attr1, :attr2)
    end

    it 'defines setters for attributes' do
      Resource.attributes(schema)

      expect { resource.attr1 = 'moomin' }
        .to change { resource.attr1 }
        .to eq 'moomin'
    end
  end

  describe "#fields" do
    it "returns all configured fields as an array of symbols" do
      expect(Resource.fields).to contain_exactly :id, :internal_resource, :created_at, :updated_at, :title
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
      it "doesn't change the type" do
        old_type = MyResource.schema.key(:id).type
        expect { MyResource.attribute(:id, Valkyrie::Types::Set) }.to raise_error Valkyrie::Resource::ReservedAttributeError
        expect(MyResource.schema.key(:id).type).to eq old_type
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
      describe ".clear_optimistic_lock_token!" do
        it "sets the #{Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK} attribute to an empty Array" do
          lock_token = Valkyrie::Persistence::OptimisticLockToken.deserialize("lock_token:adapter_id:a_tok:en")
          resource = MyLockingResource.new(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => lock_token)
          expect do
            resource.clear_optimistic_lock_token!
          end.to change { resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK) }.from([lock_token]).to([])
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

      describe ".clear_optimistic_lock_token!" do
        it "makes no attempt to set the #{Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK} attribute" do
          resource = MyNonlockingResource.new
          resource.clear_optimistic_lock_token!
          expect { resource.send(Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK) }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
