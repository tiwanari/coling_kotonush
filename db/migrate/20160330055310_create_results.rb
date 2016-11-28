class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.references :query, index: true, foreign_key: true
      t.integer :rank

      t.timestamps null: false
    end
  end
end
