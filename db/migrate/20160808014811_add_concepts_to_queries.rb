class AddConceptsToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :concepts, :string
  end
end
