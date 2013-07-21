class StatusUpdatesController < ApplicationController
  before_filter :load_data_source
  
  def load_data_source
    @unknown_subject = UnknownSubject.find(params[:unknown_subject_id])
    @data_source = @unknown_subject.data_sources.find(params[:data_source_id])
  end

  def show
    @status_update = @data_source.status_updates.find(params[:id])
  end
end
