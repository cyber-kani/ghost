<!--- Theme Activation Handler --->
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
    
    <!--- Validate input --->
    <cfif NOT structKeyExists(jsonData, "themeName")>
        <cfthrow message="Theme name is required">
    </cfif>
    
    <cfset themeName = jsonData.themeName>
    
    <!--- Validate theme exists --->
    <cfset themePath = expandPath("/ghost/themes/#themeName#/")>
    <cfif NOT directoryExists(themePath)>
        <cfthrow message="Theme not found: #themeName#">
    </cfif>
    
    <!--- Validate theme has required files --->
    <cfset requiredFiles = ["package.json", "index.hbs", "post.hbs", "default.hbs"]>
    <cfloop array="#requiredFiles#" index="requiredFile">
        <cfif NOT fileExists("#themePath##requiredFile#")>
            <cfthrow message="Invalid theme: Missing #requiredFile#">
        </cfif>
    </cfloop>
    
    <!--- Check if setting exists --->
    <cfquery name="qExistingSetting" datasource="#request.dsn#">
        SELECT id FROM settings
        WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qExistingSetting.recordCount GT 0>
        <!--- Update existing setting --->
        <cfquery datasource="#request.dsn#">
            UPDATE settings
            SET value = <cfqueryparam value="#themeName#" cfsqltype="cf_sql_varchar">,
                updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
        </cfquery>
    <cfelse>
        <!--- Insert new setting with UUID --->
        <cfset settingId = createUUID()>
        <cfquery datasource="#request.dsn#">
            INSERT INTO settings (id, `key`, value, type, created_at, updated_at)
            VALUES (
                <cfqueryparam value="#settingId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#themeName#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="core" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            )
        </cfquery>
    </cfif>
    
    <!--- Return success response --->
    <cfset response = {
        "success": true,
        "message": "Theme activated successfully",
        "theme": themeName
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>