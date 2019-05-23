# frozen_string_literal: true
module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data in fedora
  class Fedora
    attr_reader :connection, :base_path, :fedora_version
    PROTOCOL = 'fedora://'
    SLASH = '/'

    # @param [Ldp::Client] connection
    def initialize(connection:, base_path: "/", fedora_version: 4)
      @connection = connection
      @base_path = base_path
      @fedora_version = fedora_version

      warn "[DEPRECATION] `fedora_version` will default to 5 in the next major release." unless fedora_version
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
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param extra_arguments [Hash] additional arguments which may be passed to other adapters
    # @option id_transformer [Lambda] transforms a simple id (e.g. 'DDS78RK') into a uri
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource:, content_type: "application/octet-stream", **extra_arguments)
      identifier = id_to_uri(resource.id, id_transformer: id_transformer(extra_arguments)) + '/original'
      sha1 = fedora_version == 5 ? "sha" : "sha1"
      connection.http.put do |request|
        request.url identifier
        request.headers['Content-Type'] = content_type
        request.headers['Content-Length'] = file.length.to_s
        request.headers['Content-Disposition'] = "attachment; filename=\"#{original_filename}\""
        request.headers['digest'] = "#{sha1}=#{Digest::SHA1.file(file)}"
        request.headers['link'] = "<http://www.w3.org/ns/ldp#NonRDFSource>; rel=\"type\""
        io = Faraday::UploadIO.new(file, content_type, original_filename)
        request.body = io
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

    # Translate the Valkrie ID into a URL for the fedora file
    # @return [RDF::URI]
    def fedora_identifier(id:)
      identifier = id.to_s.sub(PROTOCOL, "#{connection.http.scheme}://")
      RDF::URI(identifier)
    end

    # Convert the simple id into a URI
    # @param [String] simple id (e.g. 'AN1D4UHA')
    # @param id_transformer [lambda] procedure for performing the transformation
    # @return [RDF::URI] the transformed URI (e.g. <RDF::URI 'http://localhost:8998/rest/dev/AN1D4UHA'>)
    def id_to_uri(id, id_transformer: default_id_transformer)
      id = CGI.escape(id.to_s)
      RDF::URI.new(id_transformer.call(id))
    end

    private

      # @return [IOProxy]
      def response(id:)
        response = connection.http.get(fedora_identifier(id: id))
        raise Valkyrie::StorageAdapter::FileNotFound unless response.success?
        IOProxy.new(response.body)
      end

      def id_transformer(extra_arguments)
        extra_arguments[:id_transformer] || default_id_transformer
      end

      def default_id_transformer
        lambda do |id|
          pre_divider = base_path.starts_with?(SLASH) ? '' : SLASH
          post_divider = base_path.ends_with?(SLASH) ? '' : SLASH
          "#{connection.http.url_prefix}#{pre_divider}#{base_path}#{post_divider}#{id}"
        end
      end
  end
end
