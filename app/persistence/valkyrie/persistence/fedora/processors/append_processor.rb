# frozen_string_literal: true
module Valkyrie::Persistence::Fedora::Processors
  class AppendProcessor
    class Factory
      attr_reader :form
      def initialize(form:)
        @form = form
      end

      def new(hsh_args)
        ::Valkyrie::Persistence::Postgres::Processors::AppendProcessor.new(hsh_args.merge(form: form, adapter: ::Valkyrie::Persistence::Fedora))
      end
    end
  end
end
