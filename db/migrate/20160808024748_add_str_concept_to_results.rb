class AddStrConceptToResults < ActiveRecord::Migration
  def change
    add_column :results, :str_concept, :string
  end
end
