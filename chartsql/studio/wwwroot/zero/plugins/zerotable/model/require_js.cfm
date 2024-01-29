<!---
JS Loader for the ZeroTable progress indicator. Include this within your application or views to ensure that the javascript
files are loaded
--->
<!--- Require js is a flag to ensure that this is only loaded into
	the html head once --->
<cfparam name="request.require_js" default="false">
<cfif  request.require_js == false>
	<!--- Exclude this javascript if .json is in the URL because
		it makes the request return invalid json --->
	<cfif right(cgi.path_info,5) != ".json">
		<cfsavecontent variable="htmlhead">
			<!-- Progress Indicator for Zero Ajax, added from zerotable.cfc-->
			<link href='/assets/vendor/nprogress-master/nprogress.css' rel='stylesheet' />
			<script src='/assets/vendor/nprogress-master/nprogress.js'></script>
		</cfsavecontent>
		<cfhtmlhead text="#htmlhead#"/>
		<cfset request.require_js = true>
	</cfif>
</cfif>