<!--- Insert missing staff settings --->
<cfparam name="request.dsn" default="blog">

<h2>Inserting Staff Settings</h2>

<cftry>
    <!--- List of staff settings we need --->
    <cfset staffSettings = [
        {key="staff_display_name", value="true", type="boolean"},
        {key="show_headline", value="true", type="boolean"}
    ]>
    
    <cfloop array="#staffSettings#" index="setting">
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
            <p style="color: green;">✓ Inserted setting: <cfoutput>#setting.key#</cfoutput></p>
        <cfelse>
            <p>Setting already exists: <cfoutput>#setting.key#</cfoutput></p>
        </cfif>
    </cfloop>
    
    <p style="color: green;">✓ All staff settings have been checked/inserted</p>
    
<cfcatch>
    <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>