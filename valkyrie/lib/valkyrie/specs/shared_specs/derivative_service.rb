# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::DerivativeService' do
  before do
    raise 'valid_change_set must be set with `let(:valid_change_set)`' unless
      defined? valid_change_set
    raise 'derivative_service must be set with `let(:derivative_service)`' unless
      defined? derivative_service
  end

  subject { derivative_service.new(valid_change_set) }

  it { is_expected.to respond_to(:create_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:cleanup_derivatives).with(0).arguments }

  it { is_expected.to respond_to(:change_set) }

  it { is_expected.to respond_to(:mime_type) }

  describe "#valid?" do
    context "when given a model it handles" do
      it { is_expected.to be_valid }
    end
  end

  it "takes a change_set as an argument" do
    obj = derivative_service.new(valid_change_set)
    expect(obj.change_set.model).to eq valid_change_set.model
  end
end
