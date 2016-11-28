class Reason < ActiveRecord::Base
  belongs_to :result
  has_many :reason_sentences
  enum reason_type: {co_occurrences: 0, dependencies: 1, similia: 2, comparatives: 3}

  def get_detail
    sentences = ''
    reason_sentences.each do |reason_sentence|
      sentences << reason_sentence.sentence << "<br>"
    end
    detail_hash = { count: count, sentences: sentences}
  end
end
