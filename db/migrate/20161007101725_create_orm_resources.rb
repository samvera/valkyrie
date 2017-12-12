# frozen_string_literal: true
class CreateOrmResources < ActiveRecord::Migration[5.0]
  def change
    if ENV["VALKYRIE_ID_TYPE"] == "string"
      create_table :orm_resources, { id: :text, default: -> { '(uuid_generate_v4())::text' } } do |t|
        t.jsonb :metadata, null: false, default: {}
        t.timestamps
      end
    else
      create_table :orm_resources, id: :uuid do |t|
        t.jsonb :metadata, null: false, default: {}
        t.timestamps
      end
    end
    add_index :orm_resources, :metadata, using: :gin
  end
end
