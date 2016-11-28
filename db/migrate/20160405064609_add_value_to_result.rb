class AddValueToResult < ActiveRecord::Migration
  def change
    add_column :results, :value, :float
  end
end
