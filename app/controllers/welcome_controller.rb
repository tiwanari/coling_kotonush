class WelcomeController < ApplicationController
  before_action :set_query, only: [:query]
  MAX_CONCEPTS = 8

  def index
    @query = Query.new
  end

  def query
    concepts = request.params['query']['concepts']
    @query.concepts = concepts.sort.join(",") unless concepts.blank?


    if !@query.valid?
      @render_action_name = 'index'
      render :index and return
    end

    prefs = @query.region.blank? ? Query.all_prefectures : Query.prefs_in_region(@query.region)
    prefs = Query.simplify_prefecture_names(prefs)

    uri = URI.parse(ENV['SEARCH_SCRIPT_URL'])
    params = Hash.new
    params.store("adjs", "#{@query.adjective.name},#{@query.adjective.antonym}") unless @query.adjective.blank?
    params.store("nouns", @query.concepts)
    params.store("periods", @query.periods) unless @query.periods.blank?
    params.store("genders", @query[:gender]) unless @query.gender.blank?
    params.store("prefs", prefs.join(",")) unless prefs.blank?
    params.store("nsent", 5)

    # params.store("max", 100)
    uri.query = URI.encode_www_form(params)

    p params

    start_time = Time.now
    post_to_remote_server(uri)
    @duration = Time.now - start_time

    case @response
    when Net::HTTPSuccess
      # save region in Japanese
      if I18n.locale != :ja
        @query.region = Query::Constants::TRANSLATION_EN_TO_JA[@query.region]
      end
      @query.save
      @parsed_response = JSON.parse(@response.body)
      @parsed_response['ranking'].each do |(rank, content)|
        result = Result.create!(query_id: @query.id, rank: rank.to_i,
                        value: content['value'],
                        str_concept: content['concept'])
        # save "reasons" and "reason_sentences"
        reason_types = ['co_occurrences', 'dependencies', 'similia', 'comparatives']
        reason_types.each do |type|
          reason_hash = @parsed_response['reasons'][type][content['concept']]
          type_int = Reason.reason_types[type]
          # save "reasons"
          reason_pos = Reason.create!(result_id: result.id, reason_type: type_int, is_positive: true, count: reason_hash['pos_count'])
          reason_neg = Reason.create!(result_id: result.id, reason_type: type_int, is_positive: false, count: reason_hash['neg_count'])
          # save "reason_sentences"
          reason_hash['pos_sentences'].each do |sentence|
            ReasonSentence.create!(reason_id: reason_pos.id, sentence: sentence)
          end
          reason_hash['neg_sentences'].each do |sentence|
            ReasonSentence.create!(reason_id: reason_neg.id, sentence: sentence)
          end
        end
      end
      # for reasons
      reasons_hash = {}
      @query.results.each do |result|
        reasons_hash[result.id] = result.get_reason_hash
      end
      gon.reasons_hash = reasons_hash

      render :result
    else
      @error = @response.body if @response
      @error ||= "time out"
      render :error
    end
  end

  def list_suffixes
    num_return_words = '30'
    prefix = params[:q] || ''
    pre_concepts = params[:pre_concepts]

    params = Hash.new
    params.store('max', num_return_words)
    params.store('q', pre_concepts)
    params.store('s', prefix)
    uri = URI.parse(ENV['PREFIX_SCRIPT_URL'])

    uri.query = URI.encode_www_form(params)
    p uri

    post_to_remote_server(uri)

    case @response
    when Net::HTTPSuccess
      json = @response.body
      if json && json.length >= 2
        @parsed_response = JSON.parse(json)
      else
        @parsed_response = {}
        @parsed_response["items"] = []
      end
      if prefix.present?
        original = {"id": prefix, "entity": prefix, "count": 0}
        @parsed_response["items"].insert(0, original)
      end
      render :json => @parsed_response
    else
      @error = @response.body if @response
      @error ||= "time out"
      render :error
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.new(query_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.require(:query)
        .permit(:from, :to, :gender, :region, :adjective_id, :concepts)
    end

    def post_to_remote_server(uri)
      @response = nil
      begin
        @response = Net::HTTP.start(uri.host, uri.port) {|http|
          # http.read_timeout = 300 # Default is 60 seconds
          req = Net::HTTP::Get.new(uri.request_uri)
          req.basic_auth ENV['BASIC_AUTH_USERNAME'], ENV['BASIC_AUTH_PASSWORD'] # basic authentication
          http.request(req)
        }
      rescue => e
        p request
        p e.message
      end
    end
end
