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
	
	$('[placeholder]').focus(function() {
	  var input = $(this);
	  if (input.val() == input.attr('placeholder')) {
	    input.val('');
	    input.removeClass('placeholder');
	  }
	}).blur(function() {
	  var input = $(this);
	  if (input.val() == '' || input.val() == input.attr('placeholder')) {
	    input.addClass('placeholder');
	    input.val(input.attr('placeholder'));
	  }
	}).blur();
	
	$('[placeholder]').parents('form').submit(function() {
	  $(this).find('[placeholder]').each(function() {
	    var input = $(this);
	    if (input.val() == input.attr('placeholder')) {
	      input.val('');
	    }
	  })
	});

});