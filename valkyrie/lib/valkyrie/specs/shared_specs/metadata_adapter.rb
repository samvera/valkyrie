# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::MetadataAdapter' do |passed_adapter|
  before do
    raise 'adapter must be set with `let(:adapter)`' unless
      defined? adapter
  end
  subject { passed_adapter || adapter }
  it { is_expected.to respond_to(:persister).with(0).arguments }
  it { is_expected.to respond_to(:query_service).with(0).arguments }
  it "caches query_service so it can register custom queries" do
    expect(subject.query_service.custom_queries.query_handlers.object_id).to eq subject.query_service.custom_queries.query_handlers.object_id
  end
end
