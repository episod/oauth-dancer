class ServiceProvidersController < ApplicationController
  # GET /service_providers
  # GET /service_providers.xml
  def index
    @service_providers = ServiceProvider.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_providers }
    end
  end

  # GET /service_providers/1
  # GET /service_providers/1.xml
  def show
    @service_provider = ServiceProvider.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service_provider }
    end
  end

  # GET /service_providers/new
  # GET /service_providers/new.xml
  def new
    @service_provider = ServiceProvider.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_provider }
    end
  end

  # GET /service_providers/1/edit
  def edit
    @service_provider = ServiceProvider.find(params[:id])
  end

  # POST /service_providers
  # POST /service_providers.xml
  def create
    @service_provider = ServiceProvider.new(params[:service_provider])

    respond_to do |format|
      if @service_provider.save
        flash[:notice] = 'ServiceProvider was successfully created.'
        format.html { redirect_to(@service_provider) }
        format.xml  { render :xml => @service_provider, :status => :created, :location => @service_provider }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_providers/1
  # PUT /service_providers/1.xml
  def update
    @service_provider = ServiceProvider.find(params[:id])

    respond_to do |format|
      if @service_provider.update_attributes(params[:service_provider])
        flash[:notice] = 'ServiceProvider was successfully updated.'
        format.html { redirect_to(@service_provider) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_provider.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /service_providers/1
  # DELETE /service_providers/1.xml
  def destroy
    @service_provider = ServiceProvider.find(params[:id])
    @service_provider.destroy

    respond_to do |format|
      format.html { redirect_to(service_providers_url) }
      format.xml  { head :ok }
    end
  end
end
