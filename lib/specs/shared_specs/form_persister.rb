# frozen_string_literal: true
RSpec.shared_examples 'a FormPersister' do |*_flags|
  before do
    raise 'adapter must be set with `let(:form_persister)`' unless defined? form_persister
    class CustomResource < Valkyrie::Model
      include Valkyrie::Model::AccessControls
      attribute :id, Valkyrie::Types::ID.optional
      attribute :title
      attribute :member_ids
      attribute :nested_resource
    end
    class CustomForm < Valkyrie::Form
      self.fields = [:title]
    end
  end
  after do
    Object.send(:remove_const, :CustomResource)
    Object.send(:remove_const, :CustomForm)
  end

  subject { form_persister }
  let(:resource_class) { CustomResource }
  let(:resource) { resource_class.new }
  let(:form) { CustomForm.new(resource) }

  it { is_expected.to respond_to(:save).with_keywords(:form) }
  it { is_expected.to respond_to(:save_all).with_keywords(:forms) }
  it { is_expected.to respond_to(:delete).with_keywords(:form) }
  it { is_expected.to respond_to(:adapter) }
  it { is_expected.to respond_to(:storage_adapter) }

  describe "#save" do
    it "saves a resource and returns it" do
      output = subject.save(form: form)

      expect(output).to be_kind_of CustomResource
      expect(output).to be_persisted
    end
  end

  describe "#delete" do
    it "deletes a resource" do
      output = subject.save(form: form)
      subject.delete(form: CustomForm.new(output))

      expect { subject.adapter.query_service.find_by(id: output.id) }.to raise_error Valkyrie::Persistence::ObjectNotFoundError
    end
  end

  describe "#save_all" do
    it "saves multiple forms and returns them" do
      form2 = CustomForm.new(resource_class.new)
      output = subject.save_all(forms: [form, form2])

      expect(output.map(&:id).compact.length).to eq 2
    end
  end
end
