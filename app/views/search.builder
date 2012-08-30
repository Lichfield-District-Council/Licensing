xml.instruct!
xml.applications do
	xml.pages do
		xml.totalPages @applications.total_pages
		xml.perPage 10
		xml.currentPage @applications.current_page
	end
	@applications.each do |app|
		xml.application do
			xml.applicationNumber app.refval
			xml.applicantName app.applicantname
			xml.address app.address
			xml.type app.type

			if app.details == "Temporary Event Notice"
				xml.receivedDate app.notices.sort_by(&:recieveddate).reverse[0].receiveddate rescue app.receiveddate
			else
				xml.receivedDate app.receiveddate rescue nil
			end

		end
	end
end