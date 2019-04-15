# frozen_string_literal: true
class AddDefaultToLockVersion < ActiveRecord::Migration[5.1]
  def change
    change_column_default :orm_resources, :lock_version, from: nil, to: 0
  end
end
