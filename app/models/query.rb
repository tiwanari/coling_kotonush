class Query < ActiveRecord::Base
  GENDER_NOT_SPECIFIED_VALUE = "M,F"

  include JpPrefecture

  belongs_to :adjective
  has_many :results, :dependent => :destroy

  accepts_nested_attributes_for :results

  validate :concepts_must_have_at_least_two_nouns

  enum gender: {not_specified: GENDER_NOT_SPECIFIED_VALUE, male: "M", female: "F"}

  module Constants
    TRANSLATION_JA_TO_EN = {
      "北海道" => "Hokkaido",
      "東北"   => "Tohoku",
      "関東"   => "Kanto",
      "中部"   => "Chubu",
      "関西"   => "Kansai",
      "中国"   => "Chugoku",
      "四国"   => "Shikoku",
      "九州"   => "Kyushu",
    }
    TRANSLATION_EN_TO_JA = {
      "Hokkaido" => "北海道",
      "Tohoku"   => "東北",
      "Kanto"    => "関東",
      "Chubu"    => "中部",
      "Kansai"   => "関西",
      "Chugoku"  => "中国",
      "Shikoku"  => "四国",
      "Kyushu"   => "九州",
    }
  end

  def self.localed_genders
    genders.keys.map {|k| [I18n.t("query.gender.#{k}"), k]}
  end

  def self.simplify_prefecture_names(prefs)
    prefs.map {|p| p.name == "北海道" ? p.name : p.name.chop}
  end

  def self.all_prefectures
    JpPrefecture::Prefecture.all
  end

  def self.region_choices
    JpPrefecture::Prefecture
      .all
      .map {|p|
        if I18n.locale != :ja
          Constants::TRANSLATION_JA_TO_EN[p.area]
        else
          p.area
        end
      }
      .uniq
  end

  def self.prefs_in_region(region)
    if I18n.locale != :ja
      JpPrefecture::Prefecture.all.select {|pref|
        pref.area == Constants::TRANSLATION_EN_TO_JA[region]
      }
    else
      JpPrefecture::Prefecture.all.select {|pref| pref.area == region}
    end
  end

  def concept_ordering_number(result)
    concepts.split(",").index(result.str_concept)
  end

  def localized_gender
    I18n.t("query.gender.#{gender}")
  end

  def localized_region
    if region.blank?
      I18n.t("query.region.not_specified")
    else
      I18n.locale != :ja ? Constants::TRANSLATION_JA_TO_EN[region] : region
    end
  end

  def from_month
    from.strftime("%Y/%m")
  end

  def to_month
    to.strftime("%Y/%m")
  end

  def periods
    (from..to).map{|p| p.strftime("%Y/%m")}.uniq.join(",")
  end

  def self.get_figure_params(queries)
    figure_params = {}
    if queries.length != 2
      return figure_params
    end

    common, only_first, only_second = get_compared_params_of_two_queries(queries)
    figure_params['common'] = common
    figure_params['only_first'] = only_first.present? ? only_first : 'q1'
    figure_params['only_second'] = only_second.present? ? only_second : 'q2'
    figure_params['results'] = get_result_params_of_two_queries(queries)

    return figure_params
  end

  private

  def concepts_must_have_at_least_two_nouns
    if concepts.blank?
      errors.add(:concepts, "can't be blank")
    elsif concepts.split(",").length < 2
      errors.add(:concepts, "must have at least 2 nouns")
    end
  end


  # for figure_params

  def self.get_compared_params_of_two_queries(queries)
    common, only_first, only_second = '', '', ''
    methods = ['adjective.localized_name', 'from_month', 'to_month', 'localized_gender', 'localized_region']
    labels = ['Adjective', 'From', 'To', 'Gender', 'Region']
    methods.each_with_index do |method, index|
      tmp_common, tmp_only_first, tmp_only_second = get_compared_param_of_two_queries(queries, method, labels[index])
      common += tmp_common
      only_first += tmp_only_first
      only_second += tmp_only_second
    end
    return common, only_first, only_second
  end

  #
  # called from self.get_compared_params_of_two_queries
  # @param method: method (chain) of Query (e.g. "from_month", "adjective.eng_name")
  # @param label: label name of the method (e.g. "From", "Adjective")
  #
  def self.get_compared_param_of_two_queries(queries, method, label)
    common, only_first, only_second = '', '', ''

    # set value
    first_value = queries[0].instance_eval{eval method}
    second_value = queries[1].instance_eval{eval method}
    # nil to string
    first_value = first_value || ''
    second_value = second_value || ''

    # update "common", "only_first", and "only_second"
    if first_value == second_value
      common += label + ': ' + first_value + ' '
    else
      only_first += label + ': ' + first_value + ' '
      only_second += label + ': ' + second_value + ' '
    end

    return common, only_first, only_second
  end

  def self.get_result_params_of_two_queries(queries)
    result_params = []
    tmp_result_params = {} # default dict
    queries.each.with_index(1) do |query, index|
      key_base = 'q' + index.to_s + '_'
      key_rank = key_base + 'rank'
      key_value = key_base + 'value'
      query.results.each do |result|
        concept = result.str_concept
        if !tmp_result_params.has_key?(concept)
          tmp_result_params[concept] = {}
          tmp_result_params[concept]['concept'] = concept
          tmp_result_params[concept][key_rank] = result.rank
          tmp_result_params[concept][key_value] = result.value
        else
          tmp_result_params[concept][key_rank] = result.rank
          tmp_result_params[concept][key_value] = result.value
        end
      end
    end
    tmp_result_params.each do |key, hash|
      result_params.push(hash)
    end
    return result_params
  end
end
