<!--- Delete Tag AJAX Handler --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">

<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Get JSON data from request body --->
    <cfset requestData = getHttpRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Validate required fields --->
    <cfif NOT structKeyExists(jsonData, "tagId") OR NOT len(trim(jsonData.tagId))>
        <cfthrow message="Invalid tag ID">
    </cfif>
    
    <!--- Check if tag exists and get post count --->
    <cfquery name="qCheckTag" datasource="#request.dsn#">
        SELECT 
            t.id,
            t.name,
            COUNT(pt.post_id) as post_count
        FROM tags t
        LEFT JOIN posts_tags pt ON t.id = pt.tag_id
        WHERE t.id = <cfqueryparam value="#jsonData.tagId#" cfsqltype="cf_sql_varchar">
        GROUP BY t.id, t.name
    </cfquery>
    
    <cfif qCheckTag.recordCount EQ 0>
        <cfthrow message="Tag not found">
    </cfif>
    
    <!--- Check if tag has posts --->
    <cfif qCheckTag.post_count GT 0>
        <cfthrow message="Cannot delete tag with associated posts. Please remove the tag from all posts first.">
    </cfif>
    
    <!--- Delete tag --->
    <cfquery datasource="#request.dsn#">
        DELETE FROM tags
        WHERE id = <cfqueryparam value="#jsonData.tagId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Return success response --->
    <cfset response = {
        "success": true,
        "message": "Tag deleted successfully"
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
<cfcatch>
    <!--- Return error response --->
    <cfset response = {
        "success": false,
        "message": cfcatch.message
    }>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
</cfcatch>
</cftry>