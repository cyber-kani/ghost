<!--- Quick setup script to activate CloudCoder theme --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if theme exists --->
    <cfset themePath = expandPath("/ghost/themes/cloudcoder/")>
    <cfif NOT directoryExists(themePath)>
        <cfthrow message="CloudCoder theme directory not found">
    </cfif>
    
    <!--- Check if active_theme setting exists --->
    <cfquery name="qCheck" datasource="#request.dsn#">
        SELECT id FROM settings WHERE `key` = 'active_theme'
    </cfquery>
    
    <cfif qCheck.recordCount GT 0>
        <!--- Update existing setting --->
        <cfquery datasource="#request.dsn#">
            UPDATE settings 
            SET value = 'cloudcoder',
                updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            WHERE `key` = 'active_theme'
        </cfquery>
    <cfelse>
        <!--- Insert new setting --->
        <cfset settingId = lcase(left(replace(createUUID(), "-", "", "all"), 24))>
        <cfquery datasource="#request.dsn#">
            INSERT INTO settings (id, `key`, value, type, created_at, updated_at)
            VALUES (
                <cfqueryparam value="#settingId#" cfsqltype="cf_sql_varchar">,
                'active_theme',
                'cloudcoder',
                'core',
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            )
        </cfquery>
    </cfif>
    
    <cfoutput>
        <h1>CloudCoder Theme Activated!</h1>
        <p>The CloudCoder theme has been successfully activated.</p>
        <p><a href="/ghost/">View your blog</a> | <a href="/ghost/admin/themes">Manage themes</a></p>
    </cfoutput>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>Failed to activate theme: #cfcatch.message#</p>
    </cfoutput>
</cfcatch>
</cftry>