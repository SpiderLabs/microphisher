class DataSourcesController < ApplicationController
  before_filter :load_unknown_subject
  
  def load_unknown_subject
    @unknown_subject = UnknownSubject.find(params[:unknown_subject_id])
  end
  
  def show
    @data_source = @unknown_subject.data_sources.find(params[:id])
    @page = params['page'] || 1
    @status_updates = @data_source.status_updates.desc(:created_at).page(@page).per(15)
  end

  def new
    @data_source = @unknown_subject.data_sources.new
  end
  
  def create
    @data_source = @unknown_subject.data_sources.new(params[:data_source])
    @data_source.save!
    redirect_to [ @unknown_subject, @data_source ]
  end

  def destroy
    @data_source = @unknown_subject.data_sources.find(params[:id])
    @data_source.destroy
    redirect_to @unknown_subject
  end
end
