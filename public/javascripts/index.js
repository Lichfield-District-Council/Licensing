$(document).ready(function() {		
	$('#advanced').addClass('hidden');
	$('#showadvanced').removeClass('hidden');
	
	$('#showadvanced').click(function() {
		$('#advanced').removeClass('hidden');
		$('#hideadvanced').removeClass('hidden');
		$('#showadvanced').addClass('hidden');
		return false;
	});
	
	$('#hideadvanced').click(function() {
		$('#advanced').addClass('hidden');
		$('#hideadvanced').addClass('hidden');
		$('#showadvanced').removeClass('hidden');
		return false;
	});
	
	$("#date_from").datepicker({dateFormat: "dd/mm/yy"});
	$("#date_to").datepicker({dateFormat: "dd/mm/yy"});

});