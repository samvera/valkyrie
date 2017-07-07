# frozen_string_literal: true
class ChangeModelTypeToInternalModel < ActiveRecord::Migration[5.1]
  def change
    rename_column :orm_resources, :model_type, :internal_model
  end
end
