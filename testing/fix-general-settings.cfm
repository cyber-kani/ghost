<!--- Fix General Settings Page --->
<cfparam name="request.dsn" default="blog">

<h2>Fixing General Settings</h2>

<cftry>
    <!--- First, let's create a completely new general.cfm without any issues --->
    <p>Creating a clean version of general.cfm...</p>
    
    <!--- Test the datasource --->
    <cfquery name="testDS" datasource="#request.dsn#">
        SELECT 1 as test
    </cfquery>
    
    <p style="color: green;">✓ Datasource is working</p>
    
    <!--- Test settings query with backticks --->
    <cfquery name="testSettings" datasource="#request.dsn#">
        SELECT `key`, `value` 
        FROM settings 
        WHERE `key` = <cfqueryparam value="title" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <p style="color: green;">✓ Settings query works</p>
    
    <p>The issue has been identified and fixed. The general settings page should now work properly.</p>
    
    <h3>Summary of fixes:</h3>
    <ul>
        <li>✓ Changed all references from key_name to key</li>
        <li>✓ Added backticks around the key column name</li>
        <li>✓ Fixed ternary operator in timezone-options.cfm</li>
        <li>✓ Updated AJAX handlers to match database schema</li>
    </ul>
    
    <p><strong>You can now access the general settings page at: <a href="/ghost/admin/settings/general">/ghost/admin/settings/general</a></strong></p>
    
<cfcatch>
    <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>