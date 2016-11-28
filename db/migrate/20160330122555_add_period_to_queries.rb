class AddPeriodToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :from, :date
    add_column :queries, :to, :date
  end
end
