<!--- Test datasource --->
<cfoutput>
<h1>Datasource Test</h1>
<p>Application datasource: #application.datasource#</p>
</cfoutput>

<cftry>
    <cfquery name="qTest" datasource="#application.datasource#">
        SELECT `key`, value FROM settings WHERE `key` = 'active_theme'
    </cfquery>
    <cfoutput>
    <p>Active theme from DB: #qTest.value#</p>
    </cfoutput>
<cfcatch>
    <cfoutput>
    <p>Error with datasource "#application.datasource#": #cfcatch.message#</p>
    <p>Detail: #cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>

<hr>

<cftry>
    <cfquery name="qTest2" datasource="ghost_prod">
        SELECT `key`, value FROM settings WHERE `key` = 'active_theme'
    </cfquery>
    <cfoutput>
    <p>Active theme from ghost_prod: #qTest2.value#</p>
    </cfoutput>
<cfcatch>
    <cfoutput>
    <p>Error with ghost_prod: #cfcatch.message#</p>
    </cfoutput>
</cfcatch>
</cftry>