<!--- Simple Test --->
<cfoutput>
<h1>Simple Test</h1>
<p>Datasource: #application.datasource#</p>
</cfoutput>

<cftry>
    <cfquery name="qTest" datasource="#application.datasource#">
        SELECT value FROM settings WHERE `key` = 'active_theme'
    </cfquery>
    <cfoutput>
    <p>Active theme: #qTest.value#</p>
    </cfoutput>
<cfcatch>
    <cfoutput>
    <p>Error: #cfcatch.message#</p>
    </cfoutput>
</cfcatch>
</cftry>