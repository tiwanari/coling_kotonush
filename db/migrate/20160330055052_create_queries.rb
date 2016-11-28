class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|

      t.timestamps null: false
    end
  end
end
