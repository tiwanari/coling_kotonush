class CreateReasonSentences < ActiveRecord::Migration
  def change
    create_table :reason_sentences do |t|
      t.references :reason, index: true, foreign_key: true
      t.string :sentence, null: false
    end
  end
end
