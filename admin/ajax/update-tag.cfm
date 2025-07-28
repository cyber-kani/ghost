<!--- Update Tag AJAX Handler --->
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
    
    <cfif NOT structKeyExists(jsonData, "name") OR len(trim(jsonData.name)) EQ 0>
        <cfthrow message="Tag name is required">
    </cfif>
    
    <!--- Get user ID from session --->
    <cfset userId = session.USERID ?: "1">
    
    <!--- Prepare slug --->
    <cfset tagSlug = structKeyExists(jsonData, "slug") AND len(trim(jsonData.slug)) GT 0 
                     ? jsonData.slug 
                     : reReplace(lCase(jsonData.name), "[^a-z0-9]+", "-", "all")>
    <cfset tagSlug = reReplace(tagSlug, "^-+|-+$", "", "all")>
    
    <!--- Check if slug is unique (excluding current tag) --->
    <cfquery name="qCheckSlug" datasource="#request.dsn#">
        SELECT id 
        FROM tags 
        WHERE slug = <cfqueryparam value="#tagSlug#" cfsqltype="cf_sql_varchar">
        AND id != <cfqueryparam value="#jsonData.tagId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qCheckSlug.recordCount GT 0>
        <!--- Append number to make it unique --->
        <cfset counter = 2>
        <cfset baseSlug = tagSlug>
        <cfloop condition="true">
            <cfset tagSlug = baseSlug & "-" & counter>
            <cfquery name="qCheckSlug" datasource="#request.dsn#">
                SELECT id 
                FROM tags 
                WHERE slug = <cfqueryparam value="#tagSlug#" cfsqltype="cf_sql_varchar">
                AND id != <cfqueryparam value="#jsonData.tagId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfif qCheckSlug.recordCount EQ 0>
                <cfbreak>
            </cfif>
            <cfset counter++>
        </cfloop>
    </cfif>
    
    <!--- Update tag --->
    <cfquery datasource="#request.dsn#">
        UPDATE tags SET
            name = <cfqueryparam value="#jsonData.name#" cfsqltype="cf_sql_varchar">,
            slug = <cfqueryparam value="#tagSlug#" cfsqltype="cf_sql_varchar">,
            description = <cfqueryparam value="#jsonData.description ?: ''#" cfsqltype="cf_sql_longvarchar" null="#NOT structKeyExists(jsonData, 'description') OR len(trim(jsonData.description)) EQ 0#">,
            feature_image = <cfqueryparam value="#jsonData.feature_image ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'feature_image') OR len(trim(jsonData.feature_image)) EQ 0#">,
            visibility = <cfqueryparam value="#jsonData.visibility ?: 'public'#" cfsqltype="cf_sql_varchar">,
            meta_title = <cfqueryparam value="#jsonData.meta_title ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'meta_title') OR len(trim(jsonData.meta_title)) EQ 0#">,
            meta_description = <cfqueryparam value="#jsonData.meta_description ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'meta_description') OR len(trim(jsonData.meta_description)) EQ 0#">,
            canonical_url = <cfqueryparam value="#jsonData.canonical_url ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'canonical_url') OR len(trim(jsonData.canonical_url)) EQ 0#">,
            accent_color = <cfqueryparam value="#jsonData.accent_color ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'accent_color') OR len(trim(jsonData.accent_color)) EQ 0#">,
            og_title = <cfqueryparam value="#jsonData.og_title ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'og_title') OR len(trim(jsonData.og_title)) EQ 0#">,
            og_description = <cfqueryparam value="#jsonData.og_description ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'og_description') OR len(trim(jsonData.og_description)) EQ 0#">,
            og_image = <cfqueryparam value="#jsonData.og_image ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'og_image') OR len(trim(jsonData.og_image)) EQ 0#">,
            twitter_title = <cfqueryparam value="#jsonData.twitter_title ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'twitter_title') OR len(trim(jsonData.twitter_title)) EQ 0#">,
            twitter_description = <cfqueryparam value="#jsonData.twitter_description ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'twitter_description') OR len(trim(jsonData.twitter_description)) EQ 0#">,
            twitter_image = <cfqueryparam value="#jsonData.twitter_image ?: ''#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'twitter_image') OR len(trim(jsonData.twitter_image)) EQ 0#">,
            codeinjection_head = <cfqueryparam value="#jsonData.codeinjection_head ?: ''#" cfsqltype="cf_sql_longvarchar" null="#NOT structKeyExists(jsonData, 'codeinjection_head') OR len(trim(jsonData.codeinjection_head)) EQ 0#">,
            codeinjection_foot = <cfqueryparam value="#jsonData.codeinjection_foot ?: ''#" cfsqltype="cf_sql_longvarchar" null="#NOT structKeyExists(jsonData, 'codeinjection_foot') OR len(trim(jsonData.codeinjection_foot)) EQ 0#">,
            updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
            updated_by = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
        WHERE id = <cfqueryparam value="#jsonData.tagId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Return success response --->
    <cfset response = {
        "success": true,
        "message": "Tag updated successfully",
        "tagId": jsonData.tagId,
        "slug": tagSlug
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