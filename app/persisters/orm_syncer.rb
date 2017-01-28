class ORMSyncer
  attr_reader :model, :orm_model
  def initialize(model:, orm_model:)
    @model = model
    @orm_model = orm_model
  end

  def sync!
    orm_object.metadata.merge!(clean_attributes)
  end

  def save
    sync! && apply_model! && orm_object.save! && rebuild_model
  end

  private

  def orm_object
    @orm_object ||= orm_model.find_or_initialize_by(id: model.id)
  end

  def apply_model!
    orm_object.model_type = model.class.to_s
  end

  def rebuild_model
    @model = model.class.new(orm_attributes)
  end

  def orm_attributes
    orm_object.attributes.merge(orm_object.metadata)
  end

  def clean_attributes
    model.attributes.except(:id)
  end
end
