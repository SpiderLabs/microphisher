#
# microphisher - a spear phishing support tool
#
# Created by Ulisses Albuquerque & Joaquim Espinhara
# Copyright (C) 2013 Trustwave Holdings, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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
    @data_source.delay.fetch_status_updates!
    redirect_to [ @unknown_subject, @data_source ]
  end

  def destroy
    @data_source = @unknown_subject.data_sources.find(params[:id])
    @data_source.destroy
    redirect_to @unknown_subject
  end
end
