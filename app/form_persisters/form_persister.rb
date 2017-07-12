# frozen_string_literal: true
class FormPersister
  attr_reader :adapter, :storage_adapter
  delegate :persister, :query_service, to: :adapter
  def initialize(adapter:, storage_adapter:)
    @adapter = adapter
    @storage_adapter = storage_adapter
  end

  def save(form:)
    before_save(form: form)
    persister.save(model: form.model).tap do |_output|
      after_save(form: form)
    end
  end

  def delete(form:)
    before_delete(form: form)
    persister.delete(model: form.model)
  end

  def save_all(forms:)
    forms.map do |form|
      save(form: form)
    end
  end

  private

    def before_save(form:)
      create_files(form: form)
    end

    def after_save(form:)
      append(form: form) if form.append_id
    end

    def append(form:)
      return unless form.append_id
      parent_obj = query_service.find_by(id: form.append_id)
      parent_obj.member_ids = parent_obj.member_ids + [form.id]
      persister.save(model: parent_obj)
    end

    def create_files(form:)
      appender = FileAppender.new(storage_adapter: storage_adapter, persister: persister, files: files(form: form))
      appender.append_to(form.model)
    end

    def files(form:)
      form.try(:files) || []
    end

    def before_delete(form:)
      parents = query_service.find_parents(model: form.model)
      parents.each do |parent|
        parent.member_ids -= [form.id]
        persister.save(model: parent)
      end
    end
end
