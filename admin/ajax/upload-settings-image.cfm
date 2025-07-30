<cfheader name="Content-Type" value="application/json">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if file was uploaded --->
    <cfif NOT structKeyExists(form, "image")>
        <cfthrow message="No image file provided">
    </cfif>
    
    <cfif structKeyExists(form, "type") AND len(trim(form.type)) GT 0>
        <cfset type = form.type>
    <cfelse>
        <cfset type = "logo">
    </cfif>
    
    <!--- Set upload directory --->
    <cfset uploadDir = expandPath("/ghost/content/images/settings/")>
    
    <!--- Create directory if it doesn't exist --->
    <cfif NOT directoryExists(uploadDir)>
        <cfdirectory action="create" directory="#uploadDir#" mode="755">
    </cfif>
    
    <!--- Upload the file --->
    <cffile action="upload" 
            filefield="image" 
            destination="#uploadDir#" 
            nameconflict="makeunique"
            accept="image/jpeg,image/jpg,image/png,image/gif,image/webp,image/svg+xml"
            result="uploadResult">
    
    <!--- Generate web-accessible URL --->
    <cfset imageUrl = "/ghost/content/images/settings/" & uploadResult.serverFile>
    
    <!--- Update the setting in database --->
    <cfquery name="checkSetting" datasource="#request.dsn#">
        SELECT id FROM settings WHERE `key` = <cfqueryparam value="#type#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkSetting.recordCount GT 0>
        <cfquery datasource="#request.dsn#">
            UPDATE settings 
            SET value = <cfqueryparam value="#imageUrl#" cfsqltype="cf_sql_varchar">,
                updated_at = NOW(),
                updated_by = <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
            WHERE `key` = <cfqueryparam value="#type#" cfsqltype="cf_sql_varchar">
        </cfquery>
    <cfelse>
        <cfquery datasource="#request.dsn#">
            INSERT INTO settings (id, `group`, `key`, value, type, created_at, created_by, updated_at)
            VALUES (
                <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                'core',
                <cfqueryparam value="#type#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#imageUrl#" cfsqltype="cf_sql_varchar">,
                'string',
                NOW(),
                <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                NOW()
            )
        </cfquery>
    </cfif>
    
    <cfset response = {
        "success": true,
        "url": imageUrl,
        "filename": uploadResult.serverFile
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": "Failed to upload image: #cfcatch.message#"
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>