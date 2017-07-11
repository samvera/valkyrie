# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::DerivativeService' do
  before do
    raise 'valid_model must be set with `let(:valid_model)`' unless
      defined? valid_model
    raise 'derivative_service must be set with `let(:derivative_service)`' unless
      defined? derivative_service
  end

  subject { derivative_service.new(model) }
  let(:model) { valid_model }

  it { is_expected.to respond_to(:create_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:cleanup_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:model) }

  it { is_expected.to respond_to(:mime_type) }

  describe "#valid?" do
    context "when given a model it handles" do
      let(:model) { valid_model }
      it { is_expected.to be_valid }
    end
  end

  it "takes a model as an argument" do
    obj = derivative_service.new(valid_model)
    expect(obj.model).to eq valid_model
  end
end
