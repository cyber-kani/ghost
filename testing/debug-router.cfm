<!--- Debug Router --->
<cfset url.originalPath = "preview/687de71ebc740c1b43f0a355">
<cfset testRequestUri = "/ghost/preview/687de71ebc740c1b43f0a355?member_status=public">

<h3>Router Debug</h3>

<!--- Include router logic --->
<cfset requestPath = "">
<cfset templateFile = "">
<cfset routeFound = false>

<!--- Parse the request URI to get clean path --->
<cfif len(trim(url.originalPath)) gt 0>
    <cfset requestPath = url.originalPath>
<cfelseif len(trim(testRequestUri)) gt 0>
    <cfset requestPath = testRequestUri>
</cfif>

<cfoutput>
<p>1. Initial requestPath: <strong>#requestPath#</strong></p>
</cfoutput>

<!--- Remove /ghost prefix if present --->
<cfif findNoCase("/ghost", requestPath) eq 1>
    <cfset requestPath = replaceNoCase(requestPath, "/ghost", "", "one")>
</cfif>

<cfoutput>
<p>2. After removing /ghost: <strong>#requestPath#</strong></p>
</cfoutput>

<!--- Remove query string if present --->
<cfif find("?", requestPath) gt 0>
    <cfset requestPath = listFirst(requestPath, "?")>
</cfif>

<cfoutput>
<p>3. After removing query string: <strong>#requestPath#</strong></p>
</cfoutput>

<!--- Remove leading slash if present --->
<cfif left(requestPath, 1) eq "/">
    <cfset requestPath = right(requestPath, len(requestPath) - 1)>
</cfif>

<cfoutput>
<p>4. After removing leading slash: <strong>#requestPath#</strong></p>
</cfoutput>

<!--- Test preview route --->
<cfif reFindNoCase("^preview/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset postId = reReplaceNoCase(requestPath, "^preview/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.id = postId>
    <cfset templateFile = "admin/preview.cfm">
    <cfset routeFound = true>
    <cfoutput>
    <p style="color: green;">✅ Preview route matched!</p>
    <p>Post ID: <strong>#postId#</strong></p>
    <p>Template: <strong>#templateFile#</strong></p>
    </cfoutput>
<cfelse>
    <cfoutput>
    <p style="color: red;">❌ Preview route did NOT match!</p>
    </cfoutput>
</cfif>

<h4>Check if template exists:</h4>
<cfif len(templateFile)>
    <cfset fullPath = expandPath(templateFile)>
    <cfoutput>
    <p>Full path: <strong>#fullPath#</strong></p>
    <p>File exists: <cfif fileExists(fullPath)><span style="color: green;">✅ YES</span><cfelse><span style="color: red;">❌ NO</span></cfif></p>
    </cfoutput>
</cfif>