xml.instruct! :xml, :version=>"1.0"
xml.kml(:xmlns => 'http://www.opengis.net/kml/2.2') {
	xml.Document {
		for status_update in @status_updates
			xml.Placemark {
				xml.name(status_update.created_at)
				xml.description(status_update.text)
				xml.Point {
					xml.coordinates(status_update.coordinates['coordinates'].join(','))
				}
			}
		end
	}
}
