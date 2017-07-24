# frozen_string_literal: true
module Valkyrie::Storage
  class Fedora
    attr_reader :connection
    PROTOCOL = 'fedora://'
    def initialize(connection:)
      @connection = connection
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::File]
    def find_by(id:)
      Valkyrie::StorageAdapter::File.new(id: id, io: response(id: id))
    end

    # @param file [IO]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::File]
    def upload(file:, resource:)
      # TODO: this is a very naive aproach. Change to PCDM
      identifier = resource.id.to_uri + '/original'
      ActiveFedora::File.new(identifier) do |af|
        af.content = file
        af.save!
        af.metadata.set_value(:type, af.metadata.type + [::RDF::URI('http://pcdm.org/use#OriginalFile')])
        af.metadata.save
      end
      find_by(id: Valkyrie::ID.new(identifier.to_s.sub(/^.+\/\//, PROTOCOL)))
    end

    class IOProxy
      # @param response [Ldp::Resource::BinarySource]
      def initialize(source)
        @source = source
      end
      delegate :read, to: :io

      # There is no streaming support in faraday (https://github.com/lostisland/faraday/pull/604)
      # @return [StringIO]
      def io
        @io ||= StringIO.new(@source.get.response.body)
      end
    end
    private_constant :IOProxy

    private

      # @return [IOProxy]
      def response(id:)
        af_file = ActiveFedora::File.new(active_fedora_identifier(id: id))
        IOProxy.new(af_file.ldp_source)
      end

      # Translate the Valkrie ID into a URL for the fedora file
      # @return [RDF::URI]
      def active_fedora_identifier(id:)
        scheme = URI(ActiveFedora.config.credentials[:url]).scheme
        identifier = id.to_s.sub(PROTOCOL, "#{scheme}://")
        RDF::URI(identifier)
      end
  end
end
