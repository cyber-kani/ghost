<!--- Insert missing settings for General Settings page --->
<cfparam name="request.dsn" default="blog">

<h2>Inserting Missing Settings</h2>

<cftry>
    <!--- List of settings we need --->
    <cfset requiredSettings = [
        {key="posts_per_page", value="10", type="number"},
        {key="google_analytics", value="", type="text"},
        {key="enable_comments", value="false", type="boolean"},
        {key="is_private", value="false", type="boolean"},
        {key="password", value="", type="string"}
    ]>
    
    <cfloop array="#requiredSettings#" index="setting">
        <!--- Check if setting exists --->
        <cfquery name="checkSetting" datasource="#request.dsn#">
            SELECT id FROM settings 
            WHERE `key` = <cfqueryparam value="#setting.key#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif checkSetting.recordCount EQ 0>
            <!--- Insert missing setting --->
            <cfquery datasource="#request.dsn#">
                INSERT INTO settings (id, `group`, `key`, value, type, created_at, created_by)
                VALUES (
                    <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                    'core',
                    <cfqueryparam value="#setting.key#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#setting.value#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#setting.type#" cfsqltype="cf_sql_varchar">,
                    NOW(),
                    <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
            <p>Inserted setting: <cfoutput>#setting.key#</cfoutput></p>
        <cfelse>
            <p>Setting already exists: <cfoutput>#setting.key#</cfoutput></p>
        </cfif>
    </cfloop>
    
    <p class="success">✓ All required settings have been checked/inserted</p>
    
<cfcatch>
    <p class="error">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>