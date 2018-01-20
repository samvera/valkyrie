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
      identifier = resource_identifier(resource: resource)
      af = ActiveFedora::File.new(identifier) do |f|
        f.original_name = original_filename
        f.content = file
        f.save!
        f.metadata.set_value(:type, f.metadata.type + [::RDF::URI('http://pcdm.org/use#OriginalFile')])
        f.metadata.save
      end
      _version_uri = create_version(af)
      find_by(id: to_valkyrie_id(identifier))
    end

    # Delete the file in Fedora associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      ActiveFedora::File.new(active_fedora_identifier(id: id)).ldp_source.delete
    end

    def supports_versions?
      true
    end

    # @param id [Valkyrie::ID]
    def versions(id:)
      # This already is a version, so just return itself.
      return [id] if /fcr:versions/.match?(id.to_s)
      ActiveFedora::File.new(active_fedora_identifier(id: id)).versions.all.map { |v| to_valkyrie_id(v.uri) }
    end

    class IOProxy
      # @param response [Ldp::Resource::BinarySource]
      attr_reader :size
      def initialize(source, size)
        @source = source
        @size = size
      end
      delegate :each, :read, :rewind, to: :io

      # There is no streaming support in faraday (https://github.com/lostisland/faraday/pull/604)
      # @return [StringIO]
      def io
        @io ||= StringIO.new(@source.get.response.body)
      end
    end
    private_constant :IOProxy

    private

      def create_version(af)
        versions_uri = "#{af.uri}/fcr:versions"
        resp = ActiveFedora.fedora.connection.post(versions_uri, nil, slug: version_name(af))
        raise "error creating version" unless resp.success?
        resp.headers['location']
      end

      def version_name(af)
        if af.versions.all.empty?
          'version1'
        else
          'version' + (af.versions.all.count + 1).to_s
        end
      end

      # @return [IOProxy]
      def response(id:)
        af_file = ActiveFedora::File.new(active_fedora_identifier(id: id))
        raise Valkyrie::StorageAdapter::FileNotFound if af_file.ldp_source.new?
        IOProxy.new(af_file.ldp_source, af_file.size)
      end

      # TODO: this is a very naive aproach. Change to PCDM
      def resource_identifier(resource:)
        resource.id.to_uri + '/original'
      end

      # Translate the Valkyrie ID into a URL for the fedora file
      # @param id [Valkyrie::ID]
      # @return [RDF::URI]
      def active_fedora_identifier(id:)
        scheme = URI(ActiveFedora.config.credentials[:url]).scheme
        identifier = id.to_s.sub(PROTOCOL, "#{scheme}://")
        RDF::URI(identifier)
      end

      def to_valkyrie_id(identifier)
        Valkyrie::ID.new(identifier.to_s.sub(/^.+\/\//, PROTOCOL))
      end
  end
end
