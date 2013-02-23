<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title><tiles:insertAttribute name="title"/></title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
	<!-- Styles -->
	<link href="${pageContext.request.contextPath}/resources/js/bootstrap-2.3.0/css/bootstrap.min.css" rel="stylesheet"/>
	<link href="${pageContext.request.contextPath}/resources/css/application.css" rel="stylesheet"/>
	<!-- Javascript -->
	<!--[if lt IE 9]>
		<script src="${pageContext.request.contextPath}/resources/js/html5shiv-0074154/html5shiv.js" type="text/javascript"></script>
    <![endif]-->
	<script src="${pageContext.request.contextPath}/resources/js/jquery-1.9.1/jquery-1.9.1.min.js" type="text/javascript"></script>
 	<script src="${pageContext.request.contextPath}/resources/js/bootstrap-2.3.0/js/bootstrap.min.js" type="text/javascript"></script>
	<script src="${pageContext.request.contextPath}/resources/js/application.js" type="text/javascript"></script>
	<tiles:insertAttribute name="head-extra" ignore="true"/>
</head>
	<body>
		<div class="container">
			<h1>Autocomplete Test</h1>
			<tiles:insertAttribute name="body"/>
		</div>
	</body>
</html>