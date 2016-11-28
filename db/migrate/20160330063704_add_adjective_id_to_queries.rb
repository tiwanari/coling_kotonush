class AddAdjectiveIdToQueries < ActiveRecord::Migration
  def change
    add_reference :queries, :adjective, index: true, foreign_key: true
  end
end
