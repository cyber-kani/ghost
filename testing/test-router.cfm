<!--- Test router preview route --->
<cfset testPath = "preview/687de71ebc740c1b43f0a355">

<h3>Testing Router for Preview Route</h3>

<cfoutput>
<p>Test Path: <strong>#testPath#</strong></p>

<cfif reFindNoCase("^preview/([a-zA-Z0-9-]+)$", testPath)>
    <p style="color: green;">✅ Regex matches!</p>
    <cfset postId = reReplaceNoCase(testPath, "^preview/([a-zA-Z0-9-]+)$", "\1")>
    <p>Extracted Post ID: <strong>#postId#</strong></p>
<cfelse>
    <p style="color: red;">❌ Regex does NOT match</p>
</cfif>

<h4>Testing different patterns:</h4>
<cfset patterns = [
    "preview/123",
    "preview/abc123",
    "preview/687de71ebc740c1b43f0a355",
    "admin/preview/687de71ebc740c1b43f0a355",
    "/preview/687de71ebc740c1b43f0a355"
]>

<table border="1" cellpadding="5">
    <tr>
        <th>Pattern</th>
        <th>Matches?</th>
        <th>Extracted ID</th>
    </tr>
    <cfloop array="#patterns#" index="pattern">
        <tr>
            <td>#pattern#</td>
            <td>
                <cfif reFindNoCase("^preview/([a-zA-Z0-9-]+)$", pattern)>
                    <span style="color: green;">✅ Yes</span>
                <cfelse>
                    <span style="color: red;">❌ No</span>
                </cfif>
            </td>
            <td>
                <cfif reFindNoCase("^preview/([a-zA-Z0-9-]+)$", pattern)>
                    #reReplaceNoCase(pattern, "^preview/([a-zA-Z0-9-]+)$", "\1")#
                </cfif>
            </td>
        </tr>
    </cfloop>
</table>
</cfoutput>