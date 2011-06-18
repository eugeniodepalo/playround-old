class ArenasController < ApplicationController
  load_and_authorize_resource :except => [:autocomplete_address, :autocomplete_arena_name]
  before_filter :authorize_autocomplete, :only => [:autocomplete_address, :autocomplete_arena_name]
  
  autocomplete :arena, :name
  
  # GET /arenas
  # GET /arenas.xml
  def index
    if located?
      @arenas = Arena.where(:town_woeid => current_location.woeid)
    else
      @arenas = []
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @arenas }
    end
  end

  # GET /arenas/1
  # GET /arenas/1.xml
  def show
    @arena = Arena.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @arena }
    end
  end

  # GET /arenas/new
  # GET /arenas/new.xml
  def new
    @arena = Arena.new
    
    if located?
      @arena.latitude = @location.latitude
      @arena.longitude = @location.longitude
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @arena }
    end
  end

  # GET /arenas/1/edit
  def edit
    @arena = Arena.find(params[:id])
  end

  # POST /arenas
  # POST /arenas.xml
  def create
    @arena = current_user.arenas.build(params[:arena])

    respond_to do |format|
      if @arena.save
        format.html { redirect_to(@arena, :notice => 'Arena was successfully created.') }
        format.xml  { render :xml => @arena, :status => :created, :location => @arena }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @arena.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /arenas/1
  # PUT /arenas/1.xml
  def update
    @arena = Arena.find(params[:id])

    respond_to do |format|
      if @arena.update_attributes(params[:arena])
        format.html { redirect_to(@arena, :notice => 'Arena was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @arena.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /arenas/1
  # DELETE /arenas/1.xml
  def destroy
    @arena = Arena.find(params[:id])
    @arena.destroy

    respond_to do |format|
      format.html { redirect_to(arenas_url) }
      format.xml  { head :ok }
    end
  end
  
  def autocomplete_address
    @locations = Geocoder.search(params[:term]).collect {|l| {:label => l.address, :value => l.address, :latitude => l.latitude, :longitude => l.longitude}}
    
    render :json => @locations
  end
  
  private
    
  def authorize_autocomplete
    authorize! :create, Arena
  end
end
