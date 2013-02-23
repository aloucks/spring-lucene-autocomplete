<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<tiles:insertDefinition name="layout-main">
	<tiles:putAttribute name="title" type="string" value="Autocomplete Test"/>
	<tiles:putAttribute name="head-extra">
		<style type="text/css">
			input { 
				width:160px; 
			}
			.control-group {
				margin-bottom:0px;
			}
			.autocomplete-dropdown {
				display:none;
				position:absolute;
				border:1px solid #CCCCCC;
				background-color:#FFFFFF
			}
			.autocomplete-dropdown ul {
				list-style-type: none;
				margin:0px;
				padding:0px;
			}
			.autocomplete-dropdown ul li {
				margin:0px;
				padding:3px 5px 3px 5px;
			}
			.autocomplete-dropdown ul li.active {
				background-color:#3366FF;
				color:#FFFFFF;
				cursor:pointer;
			}
		</style>
		<script type="text/javascript">
		
			(function($){
				
				// Global initialization
				$(document).on('click', ".autocomplete-dropdown ul li", function() {
					var input = $(this).parent('ul').data('ref-input');
					var dropdown = input.data('ref-dropdown');
					input.val($(this).attr('autocomplete-value'));
					setTimeout(function(){
						dropdown.hide();
					}, 150);
				});
				
				// Plugin method
				$.fn.autocomplete = function(options) {
					var settings = $.extend({
						'url'				: null,
						'max'				: 10,
						'resultsProperty' 	: 'results',
						'valueCallback' 	: function(result) {
							return result['raw-code'];
						},
						'displayCallback' 	: function(result) {
							return result['raw-code'] + " - " + result['description'];
						}
					}, options);
					
					var input = $(this);
					var jqXHR = null;
					var max = 10;
					var timer = null;
					var url = settings.url;
					var max = settings.max;
					var valueCallback = settings.valueCallback;
					var displayCallback = settings.displayCallback;
					var dropdown = $('<div class="autocomplete-dropdown"></div>');
					
					input.data('ref-dropdown', dropdown); // Reference to the dropdown
					
					dropdown.css('min-width', (input.outerWidth() - 2) + "px");
					dropdown.css('margin-top', "-" + input.css('margin-bottom'));
					
					// Attach the dropdown after the input
					input.after(dropdown);
					
					// Hide the dropdown when the input loses focus
					input.blur(function(){
						setTimeout(function(){
							dropdown.hide();
						}, 150);
					});
					
					// Perform autocomplete search
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
								jqXHR = $.getJSON(url, { "query" : value, "max" : max }, function(data){
									dropdown.html('');
									if ( data.results && data.results.length > 0 ) {
										var ul = $('<ul></ul>');
										ul.data('ref-input', input); // Reference to the input
										dropdown.append(ul);
										for ( var i in data.results ) {
											var result = data.results[i];
											var li = $('<li autocomplete-value="'+valueCallback(result)+'">'+displayCallback(result)+"</li>");
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
									}
									else {
										dropdown.hide();
									}
								});
							}
						}, 250);
					});
					
					// Move the active selection
					$(input).keydown(function(event){
						var ul = dropdown.find("ul").first();
						// When the user hits enter, set the input text to the active code if it exists
						if ( event.keyCode == 13 ) {
							var activeLi = ul.find("li.active").first();
							if ( activeLi.length > 0 ) {
								activeLi.click();
								event.preventDefault();
							}
						}
						// Ignore non-arrow keys
						if ( event.keyCode < 37 || event.keyCode > 40 ) {
							return;
						}
						// Down key
						if ( event.keyCode == 40 ) {
							var activeLi = ul.find("li.active").first();
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
						if ( event.keyCode == 38 ) {
							var ul = dropdown.find("ul").last();
							var activeLi = ul.find("li.active").last();
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
					});
				};
			})(jQuery);
		
			$(document).ready(function(){
				$("#codes1").autocomplete({url : "autocomplete.json"});
				$("#codes2").autocomplete({url : "autocomplete.json"});
			});
		
		</script>
	</tiles:putAttribute>
	<tiles:putAttribute name="body">
		<p>Type a number</p>
		<input type="text" id="codes1" autocomplete="off"/>
		<p>Type a number</p>
		<input type="text" id="codes2" autocomplete="off"/>
	</tiles:putAttribute>
</tiles:insertDefinition>