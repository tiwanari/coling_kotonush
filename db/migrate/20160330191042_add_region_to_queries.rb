class AddRegionToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :region, :string
  end
end
