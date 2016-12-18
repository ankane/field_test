class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :field_test_memberships do |t|
      t.string :participant
      t.string :experiment
      t.string :variant
      t.timestamp :created_at
      t.boolean :converted, default: false
    end

    add_index :field_test_memberships, [:experiment, :participant], unique: true
    add_index :field_test_memberships, :participant
    add_index :field_test_memberships, [:experiment, :created_at]
  end
end
