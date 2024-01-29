<html>
	<head>
		<!--- title set by a view - there is no default --->
		<title>Framework Zero Skeleton</title>
	</head>
	<body>
		<h1>Framework Zero Default Layout</h1>
		<cfoutput>
		<strong>Subsystem:</strong> #request.subsystem# <br />
		<strong>Action:</strong> #request.action# <br />
		<strong>Item:</strong> #request.item# <br />

		#body#
		</cfoutput>	<!--- body is result of views --->
		<p style="font-size: small;">
			Powered by Framework Zero
		</p>
	</body>
</html>