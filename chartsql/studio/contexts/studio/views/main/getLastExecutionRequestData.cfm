
<cfset request.layout = false>
<cfsetting enablecfoutputonly="true">
<!--- logic/calculation --->
<cfset jsonData = SerializeJSON( rc.data.datatable )>
<!--- lastly, output the result --->
<cfoutput>#jsonData#</cfoutput>
<cfabort/>