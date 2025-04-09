<!--- Set a URL variable that we will use to control the output --->
<cfparam name="url.hello" default="true">
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<script src="../src/zero.js"></script>
	<title>ZeroJS - QuickStart</title>
</head>
<body>
	<h1>ZeroJS QuickStart</h1>

	<a href="?hello=true" zero-swap="#targetContent">Hello</a>
	<a href="?hello=false" zero-swap="#targetContent">Good Bye</a>

	<div id="targetContent" style="width: 300px; height:100px;">
		<cfif url.hello>
			Hello World
		<cfelse>
			Goodbye World
		</cfif>
	</div>
</body>
</html>
<cfset request.layout = false>