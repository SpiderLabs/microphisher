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
end
