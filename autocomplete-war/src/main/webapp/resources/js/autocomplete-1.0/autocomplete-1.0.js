/**
 * jQuery Autocomplete Plugin 1.0.
 *
 * Aaron Loucks
 * 2013-02-23 
 * 
 * $("#myinput).autocomplete({url:"autocomplete.json"});
 * 
 */
(function($){
	
	var defaultOptions = {
		// The URL to query.
		'url'				: null,
		// Max desired results. This is passed to the dataCallback.
		'max'				: 10,
		// The name of the property on the 'data' object that contains our results. 
		// If null, the 'data' object itself will be iterated over.
		'resultsProperty'	: "results",
		// The value to set in the input box when a dropdown element is selected.
		// @param result - An element in the results array.
		'valueCallback' 	: function(result) { return result['value']; },
		// The text to display in a dropdown line.
		// @param result - An element in the results array.
		'textCallback'		: function(result) { return result['value'] + " - " + result['description']; },
		// The GET data sent to the URL.
		// @param value - The current value of the input box.
		// @param max - The max value specified in options.
		'dataCallback'		: function(value, max) { return { "query" : value, "max" : max }; }
	};
	
	// The dropdown margins have to be handled different in IE 7 and below.
	// Note: not tested in IE 5 or 6.
	var isLTIE8 = navigator.userAgent.indexOf("MSIE 7.") > 0 || navigator.userAgent.indexOf("MSIE 6.") > 0 || navigator.userAgent.indexOf("MSIE 5.") > 0; 
	
	// Handler for selecting dropdown elements.
	var clickHandler = function() {
		var input = $(this).parent('ul').data('ref-input');
		var dropdown = input.data('ref-dropdown');
		input.val($(this).attr('autocomplete-value'));
		setTimeout(function(){
			dropdown.hide();
		}, 150);
	};
		
	var $document = $(document);
	
	// jQuery 1.7+
	if ( $document.on ) {
		$document.on('click', ".autocomplete-dropdown ul li", clickHandler);
	}
	// jQuery 1.4.3+
	else if ( $document.delegate ) {
		$document.delegate(".autocomplete-dropdown ul li", 'click', clickHandler);
	}
	// jQuery 1.3+ 
	else if ( $document.live ) {
		$(".autocomplete-dropdown ul li").live('click', clickHandler);
		// first() and last() weren't introduced until 1.4
		if ( ! $.fn.first ) {
			$.fn.first = function() {
				return $($(this)[0]);
			};
		}
		if ( ! $.fn.last ) {
			$.fn.last = function() {
				var $this = $(this);
				return $($this[$this.length - 1]);
			};
		}
	} 
	else {
		if ( console ) {
			console.log("Autocomplete: unsupported jQuery version: " + $().jquery);
		}
	}
	
	var pxToInt = function(str) {
		var intValue = parseInt(str.substring(0, str.indexOf("px")));
		if ( isNaN(intValue) ) {
			intValue = 0;
		}
		return intValue;
	};
	
	// Plugin method
	$.fn.autocomplete = function(options) {
		var settings = $.extend($.extend({}, defaultOptions), options);
		var input = $(this);
		var jqXHR = null;
		var timer = null;
		var dropdown = $('<div class="autocomplete-dropdown"></div>');
		
		dropdown.css('min-width', (input.outerWidth() - (dropdown.outerWidth() - dropdown.width()) ) + "px");
		
		if ( isLTIE8 ) {
			dropdown.css('margin-left', "-" + input.outerWidth() + "px");
			dropdown.css('margin-top', "+" + input.outerHeight() + "px");
		}
		else {
			dropdown.css('margin-top', pxToInt(dropdown.css('margin-top')) - pxToInt(input.css('margin-bottom')) + "px");
		}
		
		input.data('ref-dropdown', dropdown); // Reference to the dropdown
		
		// Attach the dropdown after the input
		input.after(dropdown);
		
		// Hide the dropdown when the input loses focus
		input.blur(function(){
			setTimeout(function(){
				dropdown.hide();
			}, 150);
		});
		
		// Perform the autocomplete search
		$(input).keyup(function(event){
			// Ignore arrow keys and enter
			if ( event.keyCode == 13 || (event.keyCode >= 37 && event.keyCode <= 40) ) {
				return;
			}
			var value = $(this).val();
			clearTimeout(timer);
			if ( jqXHR ) {
				jqXHR.abort();
			}
			timer = setTimeout(function(){
				if ( value ) {
					jqXHR = $.getJSON(settings.url, settings.dataCallback(value, settings.max), function(data){
						dropdown.html('');
						var results = data[settings.resultsProperty] ? data[settings.resultsProperty] : data;
						if ( results && results.length > 0 ) {
							var ul = $('<ul></ul>');
							ul.data('ref-input', input); // Reference to the input
							dropdown.append(ul);
							for ( var i in results ) {
								var result = data.results[i];
								var li = $('<li autocomplete-value="'+settings.valueCallback(result)+'">'+settings.textCallback(result)+"</li>");
								li.hover(
									// mouseIn
									function(){
										// remove active from all, including set by up/down keys
										$(this).parent('ul').find('li.active').removeClass('active');
										// set this li as active
										$(this).addClass('active');
									},
									// mouseOut
									function(){
										// remove active from all, including set by up/down keys
										$(this).parent('ul').find('li.active').removeClass('active');
									}
								);
								ul.append(li);
							}
							dropdown.show();
							dropdown.scrollTop(0);
						}
						else {
							dropdown.hide();
						}
					});
				}
				else {
					jqXHR = null;
					setTimeout(function(){
						if ( ! jqXHR ) {
							dropdown.hide();
						}
					}, 250);
				}
			}, 250);
			
		}); // keyup
		
		// Move the active selection
		$(input).keydown(function(event){
			var ul = dropdown.find("ul");
			
			// Enter key
			if ( event.keyCode == 13 ) {
				var activeLi = ul.find("li.active");
				if ( activeLi.length > 0 ) {
					activeLi.click();
					activeLi.removeClass("active");
					event.preventDefault();
				}
			}

			// Down key
			else if ( event.keyCode == 40 ) {
				var activeLi = ul.find("li.active");
				if ( activeLi.length > 0 ) {
					activeLi.removeClass("active");
					var nextLi = activeLi.next("li");
					if ( nextLi.length == 0 ) {
						nextLi = ul.find("li").first();
					}
					nextLi.addClass("active");
				}
				else {
					ul.find("li").first().addClass("active");
				}
				event.preventDefault();
			}
			
			// Up key
			else if ( event.keyCode == 38 ) {
				var activeLi = ul.find("li.active");
				if ( activeLi.length > 0 ) {
					activeLi.removeClass("active");
					var prevLi = activeLi.prev("li");
					if ( prevLi.length == 0 ) {
						prevLi = ul.find("li").last();
					}
					prevLi.addClass("active");
				}
				else {
					ul.find("li").last().addClass("active");
				}
				event.preventDefault();
			}
			
		}); // keydown
		
		return this;
	}; // $.fn.autocomplete
})(jQuery);