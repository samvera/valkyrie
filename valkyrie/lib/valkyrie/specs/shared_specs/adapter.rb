# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::Adapter' do |passed_adapter|
  before do
    raise 'adapter must be set with `let(:adapter)`' unless
      defined? adapter
  end
  subject { passed_adapter || adapter }
  it { is_expected.to respond_to(:persister).with(0).arguments }
  it { is_expected.to respond_to(:query_service).with(0).arguments }
end
