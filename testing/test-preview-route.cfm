<!--- Test Preview Route Processing --->
<cfset testURI = "/ghost/preview/687de71ebc740c1b43f0a355?member_status=public">

<h3>Testing Preview Route Processing</h3>

<cfoutput>
<p>Original URI: <strong>#testURI#</strong></p>

<!--- Step 1: Remove /ghost prefix --->
<cfset step1 = testURI>
<cfif findNoCase("/ghost", step1) eq 1>
    <cfset step1 = replaceNoCase(step1, "/ghost", "", "one")>
</cfif>
<p>After removing /ghost: <strong>#step1#</strong></p>

<!--- Step 2: Remove query string --->
<cfset step2 = step1>
<cfif find("?", step2) gt 0>
    <cfset step2 = listFirst(step2, "?")>
</cfif>
<p>After removing query string: <strong>#step2#</strong></p>

<!--- Step 3: Remove leading slash --->
<cfset step3 = step2>
<cfif left(step3, 1) eq "/">
    <cfset step3 = right(step3, len(step3) - 1)>
</cfif>
<p>After removing leading slash: <strong>#step3#</strong></p>

<!--- Step 4: Test regex --->
<p>Testing regex match: 
    <cfif reFindNoCase("^preview/([a-zA-Z0-9-]+)$", step3)>
        <span style="color: green;">✅ MATCHES!</span>
        <cfset postId = reReplaceNoCase(step3, "^preview/([a-zA-Z0-9-]+)$", "\1")>
        <br>Extracted Post ID: <strong>#postId#</strong>
    <cfelse>
        <span style="color: red;">❌ NO MATCH</span>
    </cfif>
</p>

<h4>Testing actual route processing:</h4>
</cfoutput>

<!--- Include the actual router logic --->
<cfset url.originalPath = "/preview/687de71ebc740c1b43f0a355">
<cfset cgi.request_uri = "/ghost/preview/687de71ebc740c1b43f0a355?member_status=public">

<cfinclude template="/ghost/router.cfm">