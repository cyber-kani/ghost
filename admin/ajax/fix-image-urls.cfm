<!--- Fix Image URLs in Database --->
<cfcontent type="application/json">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Update settings table --->
    <cfquery datasource="#request.dsn#">
        UPDATE settings 
        SET value = REPLACE(value, '__GHOST_URL__', '/ghost')
        WHERE `key` IN ('icon', 'logo', 'cover_image')
        AND value LIKE '%__GHOST_URL__%'
    </cfquery>
    
    <!--- Update posts table --->
    <cfquery datasource="#request.dsn#">
        UPDATE posts 
        SET feature_image = REPLACE(feature_image, '__GHOST_URL__', '/ghost')
        WHERE feature_image LIKE '%__GHOST_URL__%'
    </cfquery>
    
    <cfset response = {
        "success": true,
        "message": "Image URLs updated successfully"
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>