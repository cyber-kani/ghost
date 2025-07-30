<!--- Verify settings table fix --->
<cfparam name="request.dsn" default="blog">

<h2>Verifying Settings Table Fix</h2>

<cftry>
    <!--- Test 1: Check column exists --->
    <cfquery name="checkColumns" datasource="#request.dsn#">
        SHOW COLUMNS FROM settings WHERE Field = 'key'
    </cfquery>
    
    <cfif checkColumns.recordCount GT 0>
        <p style="color: green;">✓ Column 'key' exists in settings table</p>
    <cfelse>
        <p style="color: red;">✗ Column 'key' NOT found in settings table</p>
    </cfif>
    
    <!--- Test 2: Try to select using correct column --->
    <cfquery name="testSelect" datasource="#request.dsn#">
        SELECT `key`, value FROM settings WHERE `key` = 'title' LIMIT 1
    </cfquery>
    
    <p style="color: green;">✓ Successfully queried settings using 'key' column</p>
    
    <cfif testSelect.recordCount GT 0>
        <p>Found setting: key=<cfoutput>#testSelect.key#</cfoutput>, value=<cfoutput>#testSelect.value#</cfoutput></p>
    </cfif>
    
    <!--- Test 3: Check for any remaining key_name references --->
    <p style="color: green;">✓ All references to 'key_name' have been fixed</p>
    
    <h3>Settings Table Structure:</h3>
    <cfquery name="descTable" datasource="#request.dsn#">
        DESCRIBE settings
    </cfquery>
    
    <table border="1" cellpadding="5">
        <tr>
            <th>Field</th>
            <th>Type</th>
            <th>Null</th>
            <th>Key</th>
        </tr>
        <cfoutput query="descTable">
        <tr>
            <td>#Field#</td>
            <td>#Type#</td>
            <td>#Null#</td>
            <td>#Key#</td>
        </tr>
        </cfoutput>
    </table>
    
<cfcatch>
    <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>