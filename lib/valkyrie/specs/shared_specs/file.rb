# frozen_string_literal: true
RSpec.shared_examples 'a Valkyrie::StorageAdapter::File' do
  before do
    raise 'adapter must be set with `let(:file)`' unless defined? file
  end

  subject { file }

  it { is_expected.to respond_to(:read) }
  it { is_expected.to respond_to(:rewind) }
  it { is_expected.to respond_to(:id) }
end
