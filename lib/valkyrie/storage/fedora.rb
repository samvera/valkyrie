# frozen_string_literal: true
module Valkyrie::Storage
  # Implements the DataMapper Pattern to store binary data in fedora
  class Fedora
    attr_reader :connection, :base_path, :fedora_version
    PROTOCOL = 'fedora://'
    SLASH = '/'

    # @param [Ldp::Client] connection
    def initialize(connection:, base_path: "/", fedora_version: Valkyrie::Persistence::Fedora::DEFAULT_FEDORA_VERSION)
      @connection = connection
      @base_path = base_path
      @fedora_version = fedora_version
    end

    # @param id [Valkyrie::ID]
    # @return [Boolean] true if this adapter can handle this type of identifer
    def handles?(id:)
      id.to_s.start_with?(PROTOCOL)
    end

    # @param feature [Symbol] Feature to test for.
    # @return [Boolean] true if the adapter supports the given feature
    def supports?(feature)
      return true if feature == :versions
      # Fedora 6 auto versions and you can't delete versions.
      return true if feature == :version_deletion && fedora_version != 6
      false
    end

    # Return the file associated with the given identifier
    # @param id [Valkyrie::ID]
    # @return [Valkyrie::StorageAdapter::StreamFile]
    # @raise Valkyrie::StorageAdapter::FileNotFound if nothing is found
    def find_by(id:)
      perform_find(id: id)
    end

    # @param file [IO]
    # @param original_filename [String]
    # @param resource [Valkyrie::Resource]
    # @param content_type [String] content type of file (e.g. 'image/tiff') (default='application/octet-stream')
    # @param resource_uri_transformer [Lambda] transforms the resource's id (e.g. 'DDS78RK') into a uri (optional)
    # @param extra_arguments [Hash] additional arguments which may be passed to other adapters
    # @return [Valkyrie::StorageAdapter::StreamFile]
    def upload(file:, original_filename:, resource:, content_type: "application/octet-stream", # rubocop:disable Metrics/ParameterLists
               resource_uri_transformer: default_resource_uri_transformer, **_extra_arguments)
      identifier = resource_uri_transformer.call(resource, base_url) + '/original'
      upload_file(fedora_uri: identifier, io: file, content_type: content_type, original_filename: original_filename)
      # Fedora 6 auto versions, so check to see if there's a version for this
      # initial upload. If not, then mint one (fedora 4/5)
      version_id = current_version_id(id: valkyrie_identifier(uri: identifier)) || mint_version(identifier, latest_version(identifier))
      perform_find(id: Valkyrie::ID.new(identifier.to_s.sub(/^.+\/\//, PROTOCOL)), version_id: version_id)
    end

    # @param id [Valkyrie::ID] ID of the Valkyrie::StorageAdapter::StreamFile to
    #   version.
    # @param file [IO]
    def upload_version(id:, file:)
      uri = fedora_identifier(id: id)
      # Fedora 6 has auto versioning, so have to sleep if it's too soon after last
      # upload.
      if fedora_version == 6 && current_version_id(id: id).to_s.split("/").last == Time.current.utc.strftime("%Y%m%d%H%M%S")
        sleep(0.5)
        return upload_version(id: id, file: file)
      end
      upload_file(fedora_uri: uri, io: file)
      version_id = mint_version(uri, latest_version(uri))
      perform_find(id: Valkyrie::ID.new(uri.to_s.sub(/^.+\/\//, PROTOCOL)), version_id: version_id)
    end

    # @param id [Valkyrie::ID]
    # @return [Array<Valkyrie::StorageAdapter::StreamFile>]
    def find_versions(id:)
      uri = fedora_identifier(id: id)
      version_list = version_list(uri)
      version_list.map do |version|
        id = valkyrie_identifier(uri: version["@id"])
        perform_find(id: id, version_id: id)
      end
    end

    # Delete the file in Fedora associated with the given identifier.
    # @param id [Valkyrie::ID]
    def delete(id:)
      connection.http.delete(fedora_identifier(id: id))
    end

    def version_list(fedora_uri)
      version_list = connection.http.get do |request|
        request.url "#{fedora_uri}/fcr:versions"
        request.headers["Accept"] = "application/ld+json"
      end
      return [] unless version_list.success?
      version_graph = JSON.parse(version_list.body)&.first
      if fedora_version == 4
        version_graph&.fetch("http://fedora.info/definitions/v4/repository#hasVersion", [])
      else
        # Fedora 5/6 use Memento.
        version_graph&.fetch("http://www.w3.org/ns/ldp#contains", [])&.sort_by { |x| x["@id"] }&.reverse
      end
    end

    def upload_file(fedora_uri:, io:, content_type: "application/octet-stream", original_filename: "default")
      sha1 = [5, 6].include?(fedora_version) ? "sha" : "sha1"
      connection.http.put do |request|
        request.url fedora_uri
        request.headers['Content-Type'] = content_type
        request.headers['Content-Length'] = io.length.to_s if io.respond_to?(:length)
        request.headers['Content-Disposition'] = "attachment; filename=\"#{original_filename}\""
        request.headers['digest'] = "#{sha1}=#{Digest::SHA1.file(io)}" if io.respond_to?(:to_str)
        request.headers['link'] = "<http://www.w3.org/ns/ldp#NonRDFSource>; rel=\"type\""
        io = Faraday::UploadIO.new(io, content_type, original_filename)
        request.body = io
      end
    end

    # Returns a new version identifier to mint. Defaults to version1, but will
    # increment to version2 etc if one found. Only for Fedora 4.
    def latest_version(identifier)
      # Only version 4 needs a version ID, 5/6 both mint using timestamps.
      return :not_applicable if fedora_version != 4
      version_list = version_list(identifier)
      return "version1" if version_list.blank?
      last_version = version_list.first["@id"]
      last_version_number = last_version.split("/").last.gsub("version", "").to_i
      "version#{last_version_number + 1}"
    end

    # @param [Valkyrie::ID] id A storage ID that's not a version, to get the
    #   version ID of.
    def current_version_id(id:)
      version_list = version_list(fedora_identifier(id: id))
      return nil if version_list.blank?
      valkyrie_identifier(uri: version_list.first["@id"])
    end

    def perform_find(id:, version_id: nil)
      current_id = Valkyrie::ID.new(id.to_s.split("/fcr:versions").first)
      version_id ||= id if id != current_id
      # No version got passed and we're asking for a current_id, gotta get the
      # version ID
      return perform_find(id: current_id, version_id: (current_version_id(id: id) || :empty)) if version_id.nil?
      Valkyrie::StorageAdapter::StreamFile.new(id: current_id, io: response(id: id), version_id: version_id)
    end

    # @param identifier [String] Fedora URI to mint a version for.
    # @return [Valkyrie::ID] version_id of the minted version.
    # Versions are created AFTER content is uploaded, except for Fedora 6 which
    #   auto versions.
    def mint_version(identifier, version_name = "version1")
      response = connection.http.post do |request|
        request.url "#{identifier}/fcr:versions"
        request.headers['Slug'] = version_name if fedora_version == 4
      end
      # If there's a deletion marker, don't return anything. (Fedora 4)
      return nil if response.status == 410
      # This is awful, but versioning is locked to per-second increments,
      # returns a 409 in Fedora 5 if there's a conflict.
      if response.status == 409
        sleep(0.5)
        return mint_version(identifier, version_name)
      end
      raise "Version unable to be created" unless response.status == 201
      valkyrie_identifier(uri: response.headers["location"].gsub("/fcr:metadata", ""))
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

    def valkyrie_identifier(uri:)
      id = uri.to_s.sub("http://", PROTOCOL)
      Valkyrie::ID.new(id)
    end

    private

    # @return [IOProxy]
    def response(id:)
      response = connection.http.get(fedora_identifier(id: id))
      raise Valkyrie::StorageAdapter::FileNotFound unless response.success?
      IOProxy.new(response.body)
    end

    def default_resource_uri_transformer
      lambda do |resource, base_url|
        id = CGI.escape(resource.id.to_s)
        RDF::URI.new(base_url + id)
      end
    end

    def base_url
      pre_divider = base_path.starts_with?(SLASH) ? '' : SLASH
      post_divider = base_path.ends_with?(SLASH) ? '' : SLASH
      "#{connection.http.url_prefix}#{pre_divider}#{base_path}#{post_divider}"
    end
  end
end
