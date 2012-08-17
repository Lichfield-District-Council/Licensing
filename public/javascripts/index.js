$(document).ready(function() {		
	$('#advanced, #alerts').addClass('hidden')
	$('#tabs a').click(function() {
		$('#tabs a').removeClass('active')
		$(this).addClass('active')
		$('#advanced, #alerts, #basic').addClass('hidden')
		$($(this).attr('data-destination')).removeClass('hidden')
		return false
	})
	
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