class AddPrefectureToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :prefecture_code, :integer
  end
end
