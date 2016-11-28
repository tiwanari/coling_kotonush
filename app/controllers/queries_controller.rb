class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]
  before_action :clear_queries, except: [:compare]

  # GET /queries
  # GET /queries.json
  def index
    @queries = Query.all
  end

  # GET /queries/1
  # GET /queries/1.json
  def show
  end

  # GET /queries/new
  def new
    @query = Query.new
  end

  # GET /queries/1/edit
  def edit
  end

  # POST /queries
  # POST /queries.json
  def create
    @query = Query.new(query_params)

    respond_to do |format|
      if @query.save
        format.html { redirect_to @query, notice: 'Query was successfully created.' }
        format.json { render :show, status: :created, location: @query }
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  def compare
    @selected_queries = session[:queries].nil? ? Query.find([]) : Query.find(session[:queries].uniq);
    if params[:delete]
      @selected_queries.delete(Query.find(params[:id]))
    else
      @selected_queries << Query.find(params[:id])
    end

    @selected_queries = @selected_queries.uniq
    session[:queries] = @selected_queries.map {|query| query.id}
    # for reasons
    reasons_hash = {}
    @selected_queries.each do |query|
      query.results.each do |result|
        reasons_hash[result.id] = result.get_reason_hash
      end
    end
    gon.reasons_hash = reasons_hash
    # for scatter plot
    @show_scatter_plot = false
    if @selected_queries.length == 2
      if @selected_queries[0].concepts == @selected_queries[1].concepts
        @show_scatter_plot = true
        figure_params = Query.get_figure_params(@selected_queries)
        gon.title = figure_params['common']
        gon.xLabel = figure_params['only_first']
        gon.yLabel = figure_params['only_second']
        gon.results = figure_params['results']
      end
    end
    gon.show_scatter_plot = @show_scatter_plot
    unless session[:queries].blank?
      query = Query.find(session[:queries].first)
      @queries = Query.where(concepts: query.concepts).where.not(id: session[:queries])
    else
      @queries = Query.all
    end
    render :index
  end

  # PATCH/PUT /queries/1
  # PATCH/PUT /queries/1.json
  def update
    respond_to do |format|
      if @query.update(query_params)
        format.html { redirect_to @query, notice: 'Query was successfully updated.' }
        format.json { render :show, status: :ok, location: @query }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.json
  def destroy
    @query.destroy
    respond_to do |format|
      format.html { redirect_to queries_url, notice: 'Query was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def clear_queries
      session[:queries] = nil
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def query_params
      params.fetch(:query, {})
    end
end
