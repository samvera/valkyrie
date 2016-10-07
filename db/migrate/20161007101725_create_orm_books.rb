class CreateOrmBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :orm_books do |t|
      t.jsonb :metadata, null: false, default: '{}'
      t.timestamps
    end
    add_index  :orm_books, :metadata, using: :gin
  end
end
