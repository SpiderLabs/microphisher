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

class HomeController < ApplicationController
  skip_filter :require_login, only: [ :index ]
  
  def index
  	# We can only provide indexing metrics if the user is currently
  	# logged in
  	if logged_in?
  		# Unknown subject count
  		@unknown_subject_count = current_user.unknown_subjects.count
  		
  		# Data source count
  		unknown_subject_ids = current_user.unknown_subjects.map { |us| us.id }
  		data_sources = DataSource.in(unknown_subject_id: unknown_subject_ids)
  		@data_source_count = data_sources.count || 0
  		
  		# Status update count
  		data_source_ids = data_sources.map { |ds| ds.id }
  		@status_update_count = StatusUpdate.in(data_source_id: data_source_ids).count || 0
  	end
  end
end
