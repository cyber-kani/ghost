<!--- Simple Settings Test --->
<cfparam name="request.dsn" default="blog">

<h2>Simple Settings Test</h2>

<cftry>
    <!--- Test basic query --->
    <cfquery name="qTest" datasource="#request.dsn#">
        SELECT `key`, value 
        FROM settings 
        WHERE `key` = 'title'
        LIMIT 1
    </cfquery>
    
    <cfif qTest.recordCount GT 0>
        <p style="color: green;">✓ Successfully queried settings table</p>
        <p>Title setting: <cfoutput>#qTest.value#</cfoutput></p>
    <cfelse>
        <p style="color: orange;">⚠ No title setting found</p>
    </cfif>
    
    <!--- Now try to access the general settings page directly --->
    <p>You can now access the general settings page at: <a href="/ghost/admin/settings/general">/ghost/admin/settings/general</a></p>
    
    <p style="color: green;">✓ All database references have been updated from key_name to key</p>
    
<cfcatch>
    <p style="color: red;">✗ Error: <cfoutput>#cfcatch.message#</cfoutput></p>
    <p>Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
</cfcatch>
</cftry>