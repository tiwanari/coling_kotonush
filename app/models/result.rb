class Result < ActiveRecord::Base
  belongs_to :query
  has_many :reasons
  validates :rank, numericality: { only_integer: true, greater_than: 0 }

  def get_reason_hash
    reason_hash = {}
    Reason.reason_types.each do |type, type_id|
      reason_hash[type] = {}
    end
    reasons.each do |reason|
      pos_neg = reason.is_positive ? 'pos' : 'neg'
      reason_hash[reason.reason_type][pos_neg] = reason.get_detail
    end
    reason_hash
  end
end
