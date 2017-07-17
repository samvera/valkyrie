class AddSecondaryIdentifierToOrmResources < ActiveRecord::Migration[5.1]
  def change
    add_column :orm_resources, :secondary_identifier, :string
    add_index :orm_resources, :secondary_identifier, unique: true
  end
end
