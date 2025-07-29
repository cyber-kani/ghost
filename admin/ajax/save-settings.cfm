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
        <!--- Check if setting exists --->
        <cfquery name="qExisting" datasource="#request.dsn#">
            SELECT id FROM settings 
            WHERE `key` = <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qExisting.recordCount GT 0>
            <!--- Update existing setting --->
            <cfquery datasource="#request.dsn#">
                UPDATE settings
                SET value = <cfqueryparam value="#jsonData[key]#" cfsqltype="cf_sql_longvarchar">,
                    updated_at = CURRENT_TIMESTAMP
                WHERE `key` = <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">
            </cfquery>
        <cfelse>
            <!--- Insert new setting with shorter ID --->
            <cfset settingId = left(replace(createUUID(), "-", "", "all"), 16)>
            <cfquery datasource="#request.dsn#">
                INSERT INTO settings (id, `key`, value, type, created_by, created_at, updated_at)
                VALUES (
                    <cfqueryparam value="#settingId#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#jsonData[key]#" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="string" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_varchar">,
                    CURRENT_TIMESTAMP,
                    CURRENT_TIMESTAMP
                )
            </cfquery>
        </cfif>
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