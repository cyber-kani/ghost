<!--- Create Tag AJAX Endpoint --->
<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">
<cfcontent reset="true">

<cfparam name="request.dsn" default="blog">

<cfset response = {success: false, message: ""}>

<cftry>
    <!--- Get JSON data from request body --->
    <cfset requestBody = getHttpRequestData().content>
    <cfif len(trim(requestBody)) eq 0>
        <cfset response.message = "No data received">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Parse JSON data --->
    <cfset tagData = deserializeJSON(requestBody)>
    
    <!--- Validate required fields --->
    <cfif not structKeyExists(tagData, "name") or len(trim(tagData.name)) eq 0>
        <cfset response.message = "Tag name is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Generate ID --->
    <cfset tagId = lcase(left(replace(createUUID(), "-", "", "all"), 24))>
    
    <!--- Generate slug if not provided --->
    <cfif not structKeyExists(tagData, "slug") or len(trim(tagData.slug)) eq 0>
        <cfset tagData.slug = lcase(reReplace(trim(tagData.name), "[^a-z0-9]+", "-", "all"))>
        <cfset tagData.slug = reReplace(tagData.slug, "^-+|-+$", "", "all")>
    </cfif>
    
    <!--- Check if slug already exists --->
    <cfquery name="checkSlug" datasource="#request.dsn#">
        SELECT id FROM tags WHERE slug = <cfqueryparam value="#tagData.slug#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkSlug.recordCount gt 0>
        <cfset response.message = "A tag with this slug already exists">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Insert new tag --->
    <cfquery datasource="#request.dsn#">
        INSERT INTO tags (
            id, name, slug, description, feature_image,
            visibility, meta_title, meta_description, 
            canonical_url, accent_color,
            og_title, og_description, og_image,
            twitter_title, twitter_description, twitter_image,
            codeinjection_head, codeinjection_foot,
            created_at, updated_at, created_by, updated_by
        ) VALUES (
            <cfqueryparam value="#tagId#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#tagData.name#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#tagData.slug#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'description') ? tagData.description : ''#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'feature_image') ? tagData.feature_image : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'visibility') ? tagData.visibility : 'public'#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'meta_title') ? tagData.meta_title : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'meta_description') ? tagData.meta_description : ''#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'canonical_url') ? tagData.canonical_url : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'accent_color') ? tagData.accent_color : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'og_title') ? tagData.og_title : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'og_description') ? tagData.og_description : ''#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'og_image') ? tagData.og_image : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'twitter_title') ? tagData.twitter_title : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'twitter_description') ? tagData.twitter_description : ''#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'twitter_image') ? tagData.twitter_image : ''#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'codeinjection_head') ? tagData.codeinjection_head : ''#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#structKeyExists(tagData, 'codeinjection_foot') ? tagData.codeinjection_foot : ''#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
            <cfqueryparam value="#session.USERID ?: '1'#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#session.USERID ?: '1'#" cfsqltype="cf_sql_varchar">
        )
    </cfquery>
    
    <cfset response.success = true>
    <cfset response.message = "Tag created successfully">
    <cfset response.tagId = tagId>
    <cfset response.slug = tagData.slug>
    
    <!--- Add uppercase versions for compatibility --->
    <cfset response.SUCCESS = true>
    <cfset response.MESSAGE = response.message>
    <cfset response.TAGID = tagId>
    
    <cfcatch>
        <cfset response.message = "Error creating tag: " & cfcatch.message>
        <cflog file="ghost-create-tag" text="Create tag error: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>