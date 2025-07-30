<!--- Debug Settings Error --->
<cfparam name="request.dsn" default="blog">

<h2>Debug Settings Error</h2>

<!--- Set session for testing --->
<cfset session.ISLOGGEDIN = true>

<p>Session set: ISLOGGEDIN = true</p>

<!--- Try to access general settings page --->
<cftry>
    <h3>Test 1: Query settings table</h3>
    <cfquery name="testQuery" datasource="#request.dsn#">
        SELECT `key`, value, type FROM settings
        WHERE `key` IN ('title', 'description', 'timezone')
        LIMIT 3
    </cfquery>
    
    <p style="color: green;">✓ Query successful</p>
    <table border="1" cellpadding="5">
        <cfoutput query="testQuery">
        <tr>
            <td>#key#</td>
            <td>#value#</td>
            <td>#type#</td>
        </tr>
        </cfoutput>
    </table>
    
    <h3>Test 2: Include general.cfm</h3>
    <cfinclude template="../admin/settings/general.cfm">
    
<cfcatch>
    <h3 style="color: red;">Error Details:</h3>
    <p>Message: <cfoutput>#cfcatch.message#</cfoutput></p>
    <p>Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>