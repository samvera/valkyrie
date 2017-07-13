# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::DerivativeService' do
  before do
    raise 'valid_form must be set with `let(:valid_form)`' unless
      defined? valid_form
    raise 'derivative_service must be set with `let(:derivative_service)`' unless
      defined? derivative_service
  end

  subject { derivative_service.new(valid_form) }

  it { is_expected.to respond_to(:create_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:cleanup_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:form) }

  it { is_expected.to respond_to(:mime_type) }

  describe "#valid?" do
    context "when given a model it handles" do
      it { is_expected.to be_valid }
    end
  end

  it "takes a form as an argument" do
    obj = derivative_service.new(valid_form)
    expect(obj.form.model).to eq valid_form.model
  end
end
