# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Logging do
  let(:logging_delegator) { described_class.new(logger: logger) }
  let(:logger) { instance_double("Logger") }
  describe '#warn' do
    let(:logger) { instance_double("Logger", warn: true) }
    describe 'with suppressed logging' do
      it 'will not log a suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.warn('Hello', logging_context: :salutations)
        end
        expect(logger).not_to have_received(:warn).with('Hello')
      end
      it 'will log a non-suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.warn('Hello', logging_context: :something_elses)
        end
        expect(logger).to have_received(:warn).with('Hello')
      end
    end
    it 'preserves the interface of the underlying logger' do
      logging_delegator.warn('You have one interface!')
      expect(logger).to have_received(:warn).with('You have one interface!')
    end
  end
  describe '#info' do
    let(:logger) { instance_double("Logger", info: true) }
    describe 'with suppressed logging' do
      it 'will not log a suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.info('Hello', logging_context: :salutations)
        end
        expect(logger).not_to have_received(:info).with('Hello')
      end
      it 'will log a non-suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.info('Hello', logging_context: :something_elses)
        end
        expect(logger).to have_received(:info).with('Hello')
      end
    end
    it 'preserves the interface of the underlying logger' do
      logging_delegator.info('You have one interface!')
      expect(logger).to have_received(:info).with('You have one interface!')
    end
  end
  describe '#error' do
    let(:logger) { instance_double("Logger", error: true) }
    describe 'with suppressed logging' do
      it 'will not log a suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.error('Hello', logging_context: :salutations)
        end
        expect(logger).not_to have_received(:error).with('Hello')
      end
      it 'will log a non-suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.error('Hello', logging_context: :something_elses)
        end
        expect(logger).to have_received(:error).with('Hello')
      end
    end
    it 'preserves the interface of the underlying logger' do
      logging_delegator.error('You have one interface!')
      expect(logger).to have_received(:error).with('You have one interface!')
    end
  end
  describe '#fatal' do
    let(:logger) { instance_double("Logger", fatal: true) }
    describe 'with suppressed logging' do
      it 'will not log a suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.fatal('Hello', logging_context: :salutations)
        end
        expect(logger).not_to have_received(:fatal).with('Hello')
      end
      it 'will log a non-suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.fatal('Hello', logging_context: :something_elses)
        end
        expect(logger).to have_received(:fatal).with('Hello')
      end
    end
    it 'preserves the interface of the underlying logger' do
      logging_delegator.fatal('You have one interface!')
      expect(logger).to have_received(:fatal).with('You have one interface!')
    end
  end
  describe '#debug' do
    let(:logger) { instance_double("Logger", debug: true) }
    describe 'with suppressed logging' do
      it 'will not log a suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.debug('Hello', logging_context: :salutations)
        end
        expect(logger).not_to have_received(:debug).with('Hello')
      end
      it 'will log a non-suppressed logging_context' do
        logging_delegator.suppress_logging_for_contexts!(:salutations) do
          logging_delegator.debug('Hello', logging_context: :something_elses)
        end
        expect(logger).to have_received(:debug).with('Hello')
      end
    end
    it 'preserves the interface of the underlying logger' do
      logging_delegator.debug('You have one interface!')
      expect(logger).to have_received(:debug).with('You have one interface!')
    end
  end

  it 'is a SimpleDelegator wrapper for the given logger' do
    expect(logging_delegator).to be_a(SimpleDelegator)
  end
end
