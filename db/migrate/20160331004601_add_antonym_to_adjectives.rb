class AddAntonymToAdjectives < ActiveRecord::Migration
  def change
    add_column :adjectives, :antonym, :string
  end
end
