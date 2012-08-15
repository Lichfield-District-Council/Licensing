$(document).ready(function() {
	$('#activities, #progress, #dates, #notices').addClass('hidden')
	$('#tabs a').click(function() {
		$('#tabs a').removeClass('active')
		$(this).addClass('active')
		$('#overview, #activities, #progress, #notices, #dates').addClass('hidden')
		$($(this).attr('data-destination')).removeClass('hidden')
		return false
	})
})