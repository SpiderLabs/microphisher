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

class UnknownSubjectsController < ApplicationController
  def index
    @unknown_subjects = current_user.unknown_subjects.asc(:name)
  end
  
  def show
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    
		# Obtain a listing of sources with geotagged status updates for the
		# geolocation profile analysis
	  geo_sources = @unknown_subject.status_updates.ne(coordinates: nil)
    @geo_enabled_sources = sources_hash(geo_sources)
    
    # Charts
    @source_chart = sources_chart(@unknown_subject.status_updates)
    @geo_chart = geolocation_chart(@unknown_subject.status_updates)
    @retweet_chart = retweet_chart(@unknown_subject.status_updates)
  end
  
  def new
    @unknown_subject = current_user.unknown_subjects.new
  end
  
  def create
    @unknown_subject = current_user.unknown_subjects.new(params[:unknown_subject])
    @unknown_subject.save!
    redirect_to @unknown_subject
  end

  def edit
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
  end

  def update
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    @unknown_subject.update_attributes(params[:unknown_subject])
    @unknown_subject.save!
    redirect_to @unknown_subject
  end  

  def destroy
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    @unknown_subject.destroy
    redirect_to unknown_subjects_path
  end
  
  def export_profile
  	@unknown_subject = current_user.unknown_subjects.find(params[:id])
		geo_updates = @unknown_subject.status_updates.ne(coordinates: nil)
		@status_updates = geo_updates.where(source: Regexp.new(params[:source]))
  	
  	respond_to do |format|
  		format.kml
  	end
  end
  
  protected
  # Return a listing of unique data sources along with their corresponding
  # counts
  def sources_hash(criteria)
  	# Count sources using map/reduce
  	# TODO: db.aggregate() would probably be easier/simpler, but apparently
  	# Mongoid does not support that, so we use map/reduce for now
		map_func = %Q{ function() { emit(this.source, 1); } }
		reduce_func = %Q{ function(key, values) { return Array.sum(values); } }
		Hash[criteria.map_reduce(map_func, reduce_func).out(inline: true).map do |entry|
			[ entry['_id'].gsub(/^<.+>(.+)<.+>$/, '\1'), entry['value'].to_i ]
		end]
  end
  
  def sources_chart(criteria)
  	# Fetch sources count and group low-ranking sources into 'Other'
		sorted_data = sources_hash(criteria).sort { |a, b| b[1] <=> a[1] }
		other_value = [ [ 'Other', sorted_data[9..-1].inject(0) { |a,b| a + b[1] } ] ]
		data = sorted_data[0..8] + other_value
		
		# Produce the actual chart
		LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({ :defaultSeriesType => 'pie' })
      f.series({
      	:type => 'pie',
				:name => 'Status Update Source',
				:data => data
      })
      f.options[:title][:text] = 'Status Update Source'
			f.plot_options(:pie=> { :allowPointSelect=>true })
		end
	end
	
  def geolocation_chart(criteria)
  	# Geolocation information is simple, so we do not resort to
  	# MongoDB-based aggregation and/or map/reduce
  	data = [
  		[ 'Present', criteria.ne(coordinates: nil).count ],
  		[ 'Absent', criteria.where(coordinates: nil).count ]
  	]
		
		# Produce the actual chart
		LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({ :defaultSeriesType => 'pie' })
      f.series({
      	:type => 'pie',
				:name => 'Geolocation Information',
				:data => data
      })
      f.options[:title][:text] = 'Geolocation Information'
			f.plot_options(:pie=> { :allowPointSelect=>true })
		end
	end

  def retweet_chart(criteria)
  	# Geolocation information is simple, so we do not resort to
  	# MongoDB-based aggregation and/or map/reduce
  	data = [
  		[ 'Yes', criteria.where(retweeted: true).count ],
  		[ 'No', criteria.where(retweeted: false).count ]
  	]
		
		# Produce the actual chart
		LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({ :defaultSeriesType => 'pie' })
      f.series({
      	:type => 'pie',
				:name => 'Retweeted Content',
				:data => data
      })
      f.options[:title][:text] = 'Retweeted Content'
			f.plot_options(:pie=> { :allowPointSelect=>true })
		end
	end
end
