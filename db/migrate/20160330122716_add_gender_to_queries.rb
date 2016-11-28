class AddGenderToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :gender, :integer
  end
end
