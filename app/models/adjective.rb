class Adjective < ActiveRecord::Base
  has_one :query
  validates :name, presence: true

  def localized_name
    I18n.locale != :ja ? eng_name : name
  end
end
