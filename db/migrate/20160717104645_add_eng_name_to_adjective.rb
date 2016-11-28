class AddEngNameToAdjective < ActiveRecord::Migration
  def change
    add_column :adjectives, :eng_name, :string
  end
end
