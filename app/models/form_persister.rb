# frozen_string_literal: true
class FormPersister < Persister
  attr_reader :form

  def initialize(form:, mapper:, post_processors: [AppendProcessor], orm_model: ORM::Book)
    @form = form
    @mapper = mapper
    @orm_model = orm_model
    @post_processors = post_processors
  end

  def model
    @model ||= form.model
  end

  class AppendProcessor
    attr_reader :persister
    delegate :model, :form, to: :persister
    delegate :append_id, to: :form
    def initialize(persister:)
      @persister = persister
    end

    def run
      return unless append_id.present?
      parent = FindByIdQuery.new(Book, append_id).run
      parent.member_ids = parent.member_ids + [model.id]
      Persister.save(parent)
    end
  end
end
