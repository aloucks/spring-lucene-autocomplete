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
			.autocomplete-dropdown ul {
				list-style-type: none;
				margin:0px;
				padding:0px;
			}
			.autocomplete-dropdown ul li {
				margin:0px;
				padding:3px 5px 3px 5px;
			}
			.autocomplete-dropdown ul li:hover {
				background-color:#3366FF;
				color:#FFFFFF;
				cursor:pointer;
			}
		</style>
		<script type="text/javascript">
			var id = "codes";
			$(document).ready(function(){
				var jqXHR;
				var input = $("#"+id);
				var url = "autocomplete.json";
				var max = 10;
				var dropdown = $('<div class="autocomplete-dropdown" id="'+id+'-autocomplete-dropdown'+'" style="display:none;position:absolute;border:1px solid #CCCCCC;background-color:#FFFFFF"></div>');
				dropdown.css('min-width', (input.outerWidth() - 2) + "px");
				console.log(input.css('margin-bottom'));
				dropdown.css('margin-top', "-" + input.css('margin-bottom'));
				input.after(dropdown);
				input.blur(function(){
					setTimeout(function(){
						dropdown.hide();
					}, 150);
				});
				$(document).on('click', ".autocomplete-dropdown ul li", function() {
					$(input).val($(this).attr('autocomplete-value'));
					setTimeout(function(){
						dropdown.hide();
					}, 150);
				});
				var timer;
				$(input).keyup(function(){
					var value = $(this).val();
					clearTimeout(timer);
					if ( jqXHR ) {
						jqXHR.abort();
					}
					timer = setTimeout(function(){
						if ( value ) {
							jqXHR = $.getJSON(url, { "query" : value, "max" : max }, function(data){
								console.log(data);
								dropdown.html('');
								if ( data.results && data.results.length > 0 ) {
									var ul = $("<ul></ul>");
									dropdown.append(ul);
									for ( var i in data.results ) {
										var result = data.results[i];
										ul.append('<li autocomplete-value="'+result['raw-code']+'">'+result['raw-code']+" - "+result['description']+"</li>");
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
			});
		</script>
	</tiles:putAttribute>
	<tiles:putAttribute name="body">
		<p>Type a number</p>
		<input type="text" id="codes" autocomplete="off"/>
	</tiles:putAttribute>
</tiles:insertDefinition>