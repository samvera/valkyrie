# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def member_ids
    fetch(:member_ids_ssim, []).map do |id|
      if id.start_with?("id-")
        Valkyrie::ID.new(id.gsub(/^id-/, ''))
      else
        id
      end
    end
  end

  def members
    QueryService.find_members(model: Book.new(id: model_id, member_ids: member_ids))
  end

  def model_id
    Valkyrie::ID.new(id.gsub(/^id-/, ''))
  end

  def resource
    @resource ||= QueryService.find_by(id: model_id)
  end
end
