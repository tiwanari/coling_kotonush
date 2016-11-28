class CreateReasons < ActiveRecord::Migration
  def change
    create_table :reasons do |t|
      t.references :result, index: true, foreign_key: true
      t.integer :reason_type, null: false
      t.boolean :is_positive, null: false
      t.integer :count, null: false
    end
  end
end
