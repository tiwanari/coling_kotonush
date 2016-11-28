class RemovePrefectureCodeFromQueries < ActiveRecord::Migration
  def change
    remove_column :queries, :prefecture_code, :integer
  end
end
