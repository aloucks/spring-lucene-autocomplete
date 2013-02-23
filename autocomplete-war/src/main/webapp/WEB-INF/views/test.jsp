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
		</style>
		<script type="text/javascript">
			$(document).ready(function(){
				var valueCallback = function(result){return result['raw-code'];};
				var textCallback = function(result){return result['raw-code'] + " - " + result['description'];};
				$("#codes1").autocomplete({'url' : "autocomplete.json", 'valueCallback' : valueCallback, 'textCallback' : textCallback});
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