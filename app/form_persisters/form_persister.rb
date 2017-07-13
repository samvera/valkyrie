# frozen_string_literal: true
class FormPersister
  attr_reader :adapter, :storage_adapter
  def initialize(adapter:, storage_adapter:)
    @adapter = adapter
    @storage_adapter = storage_adapter
  end

  def save(form:)
    instance(form).save
  end

  def delete(form:)
    instance(form).delete
  end

  def save_all(forms:)
    forms.map do |form|
      save(form: form)
    end
  end

  def instance(form)
    Instance.new(form: form, form_persister: self)
  end

  class Instance
    attr_reader :form, :form_persister
    delegate :adapter, :storage_adapter, to: :form_persister
    delegate :persister, :query_service, to: :adapter
    def initialize(form:, form_persister:)
      @form = form
      @form_persister = form_persister
    end

    def save
      before_save
      persister.save(model: form.model).tap do
        after_save
      end
    end

    def delete
      before_delete
      persister.delete(model: form.model)
    end

    private

      def before_save
        create_files
      end

      def after_save
        append if form.append_id
      end

      def append
        return unless form.append_id
        parent_obj = query_service.find_by(id: form.append_id)
        parent_obj.member_ids = parent_obj.member_ids + [form.id]
        persister.save(model: parent_obj)
      end

      def create_files
        appender = FileAppender.new(storage_adapter: storage_adapter, persister: persister, files: files)
        appender.append_to(form.model)
      end

      def files
        form.try(:files) || []
      end

      def before_delete
        parents = query_service.find_parents(model: form.model)
        parents.each do |parent|
          parent.member_ids -= [form.id]
          persister.save(model: parent)
        end
      end
  end
end
