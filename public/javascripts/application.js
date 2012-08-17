$(document).ready(function() {
	$('#activities, #progress, #dates, #notices, #comment').addClass('hidden')
	$('#tabs a').click(function() {
		$('#tabs a').removeClass('active')
		$(this).addClass('active')
		$('#overview, #activities, #progress, #notices, #dates, #comment').addClass('hidden')
		$($(this).attr('data-destination')).removeClass('hidden')
		return false
	})
})