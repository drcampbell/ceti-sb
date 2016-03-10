jQuery ->
	if $('#infinite-scrolling').size() > 0
		$(window).on 'scroll', ->
			notifications_url = $('.pagination .next_page a').attr('href=notifications')
			if notifications_url && $(window).scrollTop() > $(document).height() - $(window).height() - 60
					$('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
					$.getScript notifications_url
			return
		return
