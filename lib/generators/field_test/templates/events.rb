class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :field_test_events do |t|
      t.integer :field_test_membership_id
      t.string :name
      t.timestamp :created_at
    end

    add_foreign_key :field_test_events, :field_test_memberships
    add_index :field_test_events, :field_test_membership_id
  end
end
