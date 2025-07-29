<!--- Save Settings AJAX Handler --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if user is logged in --->
    <cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
        <cfthrow message="Unauthorized access">
    </cfif>
    
    <!--- Get JSON data from request body --->
    <cfset requestData = getHttpRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Update each setting --->
    <cfloop collection="#jsonData#" item="key">
        <cfquery datasource="#request.dsn#">
            INSERT INTO settings (`key`, value, type)
            VALUES (
                <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#jsonData[key]#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="string" cfsqltype="cf_sql_varchar">
            )
            ON DUPLICATE KEY UPDATE
                value = VALUES(value),
                updated_at = CURRENT_TIMESTAMP
        </cfquery>
    </cfloop>
    
    <!--- Return success response --->
    <cfset response = {
        "success": true,
        "message": "Settings saved successfully"
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>