<cfheader name="Content-Type" value="application/json">
<cfparam name="request.dsn" default="blog">

<!--- Function to generate Ghost-compatible 24-character ID --->
<cffunction name="generateGhostId" returntype="string">
    <cfset var chars = "abcdefghijklmnopqrstuvwxyz0123456789">
    <cfset var id = "">
    <cfloop from="1" to="24" index="i">
        <cfset id = id & mid(chars, randRange(1, len(chars)), 1)>
    </cfloop>
    <cfreturn id>
</cffunction>

<cftry>
    <!--- Process each form field and update settings --->
    <cfset updatedSettings = []>
    
    <!--- Check if JSON data was sent --->
    <cfif structKeyExists(getHTTPRequestData().headers, "content-type") AND findNoCase("application/json", getHTTPRequestData().headers["content-type"])>
        <!--- Parse JSON data --->
        <cfset requestData = getHttpRequestData()>
        <cfset jsonData = deserializeJSON(toString(requestData.content))>
        
        <!--- Process JSON fields --->
        <cfloop collection="#jsonData#" item="key">
            <!--- Check if setting exists --->
            <cfquery name="checkSetting" datasource="#request.dsn#">
                SELECT id FROM settings WHERE `key` = <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkSetting.recordCount GT 0>
                <!--- Update existing setting --->
                <cfquery datasource="#request.dsn#">
                    UPDATE settings 
                    SET value = <cfqueryparam value="#jsonData[key]#" cfsqltype="cf_sql_varchar">,
                        updated_at = NOW(),
                        updated_by = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
                    WHERE `key` = <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">
                </cfquery>
            <cfelse>
                <!--- Insert new setting --->
                <cfquery datasource="#request.dsn#">
                    INSERT INTO settings (id, `group`, `key`, value, type, created_at, created_by, updated_at)
                    VALUES (
                        <cfqueryparam value="#generateGhostId()#" cfsqltype="cf_sql_varchar">,
                        'core',
                        <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#jsonData[key]#" cfsqltype="cf_sql_varchar">,
                        'string',
                        NOW(),
                        <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                        NOW()
                    )
                </cfquery>
            </cfif>
            
            <cfset arrayAppend(updatedSettings, key)>
        </cfloop>
    <cfelse>
        <!--- Process regular form data --->
        <cfloop collection="#form#" item="key">
            <cfif key NEQ "fieldnames">
                <!--- Check if setting exists --->
                <cfquery name="checkSetting" datasource="#request.dsn#">
                    SELECT id FROM settings WHERE `key` = <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif checkSetting.recordCount GT 0>
                    <!--- Update existing setting --->
                    <cfquery datasource="#request.dsn#">
                        UPDATE settings 
                        SET value = <cfqueryparam value="#form[key]#" cfsqltype="cf_sql_varchar">,
                            updated_at = NOW(),
                            updated_by = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
                        WHERE `key` = <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                <cfelse>
                    <!--- Insert new setting --->
                    <cfquery datasource="#request.dsn#">
                        INSERT INTO settings (id, `group`, `key`, value, type, created_at, created_by, updated_at)
                        VALUES (
                            <cfqueryparam value="#generateGhostId()#" cfsqltype="cf_sql_varchar">,
                            'core',
                            <cfqueryparam value="#key#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#form[key]#" cfsqltype="cf_sql_varchar">,
                            'string',
                            NOW(),
                            <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                            NOW()
                        )
                    </cfquery>
                </cfif>
                
                <cfset arrayAppend(updatedSettings, key)>
            </cfif>
        </cfloop>
    </cfif>
    
    <cfset response = {
        "success": true,
        "message": "Settings saved successfully",
        "updated": updatedSettings
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": "Failed to save settings: #cfcatch.message#"
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>