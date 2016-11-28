class ChangeGenderTypeToQueries < ActiveRecord::Migration
  def up
    change_column :queries, :gender, :string, null: true
  end

  def down
    change_column :queries, :gender, :integer
  end
end
