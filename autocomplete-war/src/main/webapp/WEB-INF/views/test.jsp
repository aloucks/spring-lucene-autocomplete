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
				padding:1px;
				background-color:#FFFFFF;
				overflow-y:auto;
				-moz-box-shadow: 2px 2px 2px #CCCCCC;
				-webkit-box-shadow: 2px 2px 2px #CCCCCC;
 				box-shadow: 2px 2px 2px #CCCCCC;
 				/* For IE 8 */
 				-ms-filter: "progid:DXImageTransform.Microsoft.Shadow(Strength=2, Direction=135, Color='#CCCCCC')";
 				/* For IE 5.5 - 7 */
 				filter: progid:DXImageTransform.Microsoft.Shadow(Strength=2, Direction=135, Color='#CCCCCC');

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
				
				// Global initialization - Handle dropdown element click events
				var $document = $(document);
				var clickHandler = function() {
					var input = $(this).parent('ul').data('ref-input');
					var dropdown = input.data('ref-dropdown');
					input.val($(this).attr('autocomplete-value'));
					setTimeout(function(){
						dropdown.hide();
					}, 150);
				};
				// 1.7+
				if ( $document.on ) {
					$document.on('click', ".autocomplete-dropdown ul li", clickHandler);
				}
				// 1.4.3+
				else if ( $document.delegate ) {
					$document.delegate(".autocomplete-dropdown ul li", 'click', clickHandler);
				}
				// 1.3+ 
				else if ( $document.live ) {
					$(".autocomplete-dropdown ul li").live('click', clickHandler);
					// first() and last() weren't introduced until 1.4
					if ( ! $.fn.first ) {
						$.fn.first = function() {
							return $($(this)[0]);
						}
					}
					if ( ! $.fn.last ) {
						$.fn.last = function() {
							var $this = $(this);
							return $($this[$this.length - 1]);
						}
					}
				} 
				else {
					if ( console ) {
						console.log("Autocomplete: unsupported jQuery version: " + $().jquery);
					}
				}
				
				// Plugin method
				$.fn.autocomplete = function(options) {
					var settings = $.extend({
						'url'				: null,
						'max'				: 10,
						'resultsProperty'	: "results",
						'valueCallback' 	: function(result) {
							return result['value'];
						},
						'displayCallback' 	: function(result) {
							return result['value'] + " - " + result['description'];
						},
						'dataCallback'		: function(value, max) {
							return { "query" : value, "max" : max };
						}
					}, options);
					
					var input = $(this);
					var jqXHR = null;
					var timer = null;
					var dropdown = $('<div class="autocomplete-dropdown"></div>');
					
					input.data('ref-dropdown', dropdown); // Reference to the dropdown
					
					dropdown.css('min-width', (input.outerWidth() - (dropdown.outerWidth() - dropdown.width()) ) + "px");
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
								jqXHR = $.getJSON(settings.url, settings.dataCallback(value, settings.max), function(data){
									dropdown.html('');
									var results = data[settings.resultsProperty] ? data[settings.resultsProperty] : data;
									if ( results && results.length > 0 ) {
										var ul = $('<ul></ul>');
										ul.data('ref-input', input); // Reference to the input
										dropdown.append(ul);
										for ( var i in results ) {
											var result = data.results[i];
											var li = $('<li autocomplete-value="'+settings.valueCallback(result)+'">'+settings.displayCallback(result)+"</li>");
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
					});
					
					// Move the active selection
					$(input).keydown(function(event){
						var ul = dropdown.find("ul");
						
						// When the user hits enter, set the input text to the active code if it exists
						if ( event.keyCode == 13 ) {
							var activeLi = ul.find("li.active");
							if ( activeLi.length > 0 ) {
								activeLi.click();
								activeLi.removeClass("active");
								event.preventDefault();
							}
						}
						
						// Ignore non-arrow keys
						else if ( event.keyCode < 37 || event.keyCode > 40 ) {
							return;
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
					});
				};
			})(jQuery);
		
			$(document).ready(function(){
				var valueCallback = function(result){return result['raw-code'];};
				var displayCallback = function(result){return result['raw-code'] + " - " + result['description'];};
				$("#codes1").autocomplete({'url' : "autocomplete.json", 'valueCallback' : valueCallback, 'displayCallback' : displayCallback});
				$("#codes2").autocomplete({url : "autocomplete.json"});
			});
		
		</script>
	</tiles:putAttribute>
	<tiles:putAttribute name="body">
		<form>
			<p>Type a number</p>
			<input type="text" id="codes1" autocomplete="off"/>
			<p>Type a number</p>
			<input type="text" id="codes2" autocomplete="off"/>
			<p>Normal Select</p>
			<select>
				<option>Test</option>
				<option>Test</option>
			</select>
			<br/><br/>
			<input type="submit" value="Reset"/>
		</form>
	</tiles:putAttribute>
</tiles:insertDefinition>