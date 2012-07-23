$(document).ready(function() {
	$('#activities, #progress, #dates').addClass('hidden')
	$('#tabs a').click(function() {
		$('#tabs a').removeClass('active')
		$(this).addClass('active')
		$('#overview, #activities, #progress, #dates').addClass('hidden')
		$($(this).attr('data-destination')).removeClass('hidden')
		return false
	})
})