xml.instruct!
xml.application do
	xml.applicationNumber app.refval
	xml.occupier app.occupier
	xml.tradingName app.tradingname
	xml.applicantName app.applicantname
	xml.address app.address
	xml.type app.type
	xml.mainUse app.usetype
	xml.caseType app.casetype
	xml.status app.status
	xml.receivedDate app.recieveddate
	xml.commentsClosingDate app.closingdate
	xml.activities do
		app.activities.each do |activity|
			xml.activity do
				xml.type activity.type
				xml.days activity.cycle
				xml.from activity.open
				xml.to activity.close
			end
		end
	end
	xml.notices do
		app.notices.each do |notice|
			xml.notice do
				xml.startDate notice.startdate
				xml.endDate notice.enddate
				xml.hours notice.hours
				xml.days notice.days
				xml.receivedDate notice.receiveddate
			end
		end
	end
end