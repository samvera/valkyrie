# frozen_string_literal: true
module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data in fedora
  class Fedora
    attr_reader :connection, :base_path
    PROTOCOL = 'fedora://'

    # @param [Ldp::Client] connection
    def initialize(connection:, base_path: "/")
      @connection = connection
      @base_path = base_path
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      Valkyrie::StorageAdapter::StreamFile.new(id: id, io: response(id: id))
    rescue ::Ldp::Gone
      raise Valkyrie::StorageAdapter::FileNotFound
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource:)
      identifier = id_to_uri(resource.id) + '/original'
      connection.http.put do |request|
        request.url identifier
        request.headers['Content-Type'] = file.content_type
        request.headers['Content-Disposition'] = "attachment; filename=\"#{original_filename}\""
        request.headers['digest'] = "sha1=#{Digest::SHA1.file(file)}"
        request.body = file.tempfile.read
      end
      find_by(id: Valkyrie::ID.new(identifier.to_s.sub(/^.+\/\//, PROTOCOL)))
    end

    # Delete the file in Fedora associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      connection.http.delete(fedora_identifier(id: id))
    end

    class IOProxy
      # @param response [Ldp::Resource::BinarySource]
      attr_reader :size
      def initialize(source)
        @source = source
        @size = source.size
      end
      delegate :each, :read, :rewind, to: :io

      # There is no streaming support in faraday (https://github.com/lostisland/faraday/pull/604)
      # @return [StringIO]
      def io
        @io ||= StringIO.new(@source)
      end
    end
    private_constant :IOProxy

    private

      # @return [IOProxy]
      def response(id:)
        response = connection.http.get(fedora_identifier(id: id))
        raise Valkyrie::StorageAdapter::FileNotFound unless response.success?
        IOProxy.new(response.body)
      end

      # Translate the Valkrie ID into a URL for the fedora file
      # @return [RDF::URI]
      def fedora_identifier(id:)
        identifier = id.to_s.sub(PROTOCOL, "#{connection.http.scheme}://")
        RDF::URI(identifier)
      end

      def id_to_uri(id)
        RDF::URI("#{connection_prefix}/#{CGI.escape(id.to_s)}")
      end

      def connection_prefix
        "#{connection.http.url_prefix}/#{base_path}"
      end
  end
end
