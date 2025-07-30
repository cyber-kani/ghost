<!--- Deactivate Theme / Return to Default --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Remove active theme setting to use default templates --->
    <cfquery datasource="#request.dsn#">
        DELETE FROM settings WHERE `key` = 'active_theme'
    </cfquery>
    
    <cfoutput>
        <h1>Theme Deactivated</h1>
        <p>Your blog is now using the default theme.</p>
        <p><a href="/ghost/">View your blog</a> | <a href="/ghost/admin/themes">Manage themes</a></p>
    </cfoutput>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>Failed to deactivate theme: #cfcatch.message#</p>
    </cfoutput>
</cfcatch>
</cftry>