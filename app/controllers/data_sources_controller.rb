class DataSourcesController < ApplicationController
  def show
    @unknown_subject = UnknownSubject.find(params[:unknown_subject_id])
    @data_source = DataSource.find(params[:id])
  end
end
