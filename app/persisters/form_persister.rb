# frozen_string_literal: true
class FormPersister < Persister
  attr_reader :form

  def initialize(form:, mapper:, post_processors: [Processors::AppendProcessor], orm_model: ORM::Book)
    @form = form
    @mapper = mapper
    @orm_model = orm_model
    @post_processors = post_processors
  end

  def model
    @model ||= form.model
  end
end
