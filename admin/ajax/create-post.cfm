<!--- Create New Post AJAX Endpoint --->
<cfheader name="Content-Type" value="application/json">

<cfinclude template="../includes/posts-functions.cfm">

<cfset response = {success: false, message: "", id: ""}>

<cftry>
    <!--- Get POST data --->
    <cfset requestBody = getHttpRequestData().content>
    <cfif len(trim(requestBody)) eq 0>
        <cfset response.message = "No data received">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Parse JSON data --->
    <cfset postData = deserializeJSON(requestBody)>
    
    <!--- Validate required fields --->
    <cfif not structKeyExists(postData, "title") or len(trim(postData.title)) eq 0>
        <cfset response.message = "Title is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Generate unique ID for new post --->
    <cfset newPostId = createUUID()>
    
    <!--- Prepare post data for database --->
    <cfset postRecord = {
        id: newPostId,
        title: trim(postData.title),
        html: structKeyExists(postData, "html") ? postData.html : "",
        plaintext: structKeyExists(postData, "plaintext") ? postData.plaintext : "",
        feature_image: structKeyExists(postData, "feature_image") ? postData.feature_image : "",
        featured: structKeyExists(postData, "featured") ? postData.featured : false,
        status: structKeyExists(postData, "status") ? postData.status : "draft",
        visibility: structKeyExists(postData, "visibility") ? postData.visibility : "public",
        slug: structKeyExists(postData, "slug") ? postData.slug : generateSlugFromTitle(postData.title),
        custom_excerpt: structKeyExists(postData, "custom_excerpt") ? postData.custom_excerpt : "",
        meta_title: structKeyExists(postData, "meta_title") ? postData.meta_title : "",
        meta_description: structKeyExists(postData, "meta_description") ? postData.meta_description : "",
        canonical_url: structKeyExists(postData, "canonical_url") ? postData.canonical_url : "",
        type: structKeyExists(postData, "type") ? postData.type : "post",
        published_at: "",
        created_by: "1",
        updated_by: "1",
        created_at: now(),
        updated_at: now()
    }>
    
    <!--- Handle publish date --->
    <cfif structKeyExists(postData, "published_at") and len(trim(postData.published_at)) gt 0>
        <cftry>
            <cfset postRecord.published_at = parseDateTime(postData.published_at)>
            <cfcatch>
                <!--- If date parsing fails, set to now for published posts --->
                <cfif postRecord.status eq "published">
                    <cfset postRecord.published_at = now()>
                </cfif>
            </cfcatch>
        </cftry>
    <cfelseif postRecord.status eq "published">
        <cfset postRecord.published_at = now()>
    </cfif>
    
    <!--- Insert post into database --->
    <cfset result = createPost(postRecord)>
    
    <cfif result.success>
        <!--- Handle tags if provided --->
        <cfif structKeyExists(postData, "tags") and isArray(postData.tags) and arrayLen(postData.tags) gt 0>
            <cfset tagResult = addPostTags(newPostId, postData.tags)>
            <!--- Tag errors are non-critical, don't fail the whole operation --->
        </cfif>
        
        <cfset response.success = true>
        <cfset response.message = "Post created successfully">
        <cfset response.id = newPostId>
    <cfelse>
        <cfset response.message = result.message>
    </cfif>
    
    <cfcatch any>
        <cfset response.message = "Error creating post: " & cfcatch.message>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>

<!--- Helper function to generate slug from title --->
<cffunction name="generateSlugFromTitle" access="private" returntype="string">
    <cfargument name="title" type="string" required="true">
    
    <cfset var slug = lcase(trim(arguments.title))>
    <!--- Remove special characters, keep only alphanumeric, spaces, and hyphens --->
    <cfset slug = reReplace(slug, "[^a-z0-9\s\-]", "", "all")>
    <!--- Replace spaces with hyphens --->
    <cfset slug = reReplace(slug, "\s+", "-", "all")>
    <!--- Remove multiple consecutive hyphens --->
    <cfset slug = reReplace(slug, "\-+", "-", "all")>
    <!--- Remove leading/trailing hyphens --->
    <cfset slug = reReplace(slug, "^-|-$", "", "all")>
    
    <cfreturn slug>
</cffunction>

<!--- Helper function to add tags to post --->
<cffunction name="addPostTags" access="private" returntype="struct">
    <cfargument name="postId" type="string" required="true">
    <cfargument name="tags" type="array" required="true">
    
    <cfset var result = {success: true, message: ""}>
    
    <cftry>
        <!--- First, remove existing tags for this post --->
        <cfset deleteQuery = queryExecute("DELETE FROM posts_tags WHERE post_id = ?", [arguments.postId], {datasource: "blog"})>
        
        <!--- Add each tag --->
        <cfloop array="#arguments.tags#" index="tagName">
            <cfif len(trim(tagName)) gt 0>
                <!--- Check if tag exists --->
                <cfset tagQuery = queryExecute("SELECT id FROM tags WHERE name = ?", [trim(tagName)], {datasource: "blog"})>
                
                <cfif tagQuery.recordCount eq 0>
                    <!--- Create new tag --->
                    <cfset tagId = createUUID()>
                    <cfset insertTagQuery = queryExecute("INSERT INTO tags (id, name, slug, created_at, updated_at) VALUES (?, ?, ?, ?, ?)", 
                        [tagId, trim(tagName), generateSlugFromTitle(tagName), now(), now()], {datasource: "blog"})>
                <cfelse>
                    <cfset tagId = tagQuery.id[1]>
                </cfif>
                
                <!--- Link tag to post --->
                <cfset linkQuery = queryExecute("INSERT INTO posts_tags (id, post_id, tag_id) VALUES (?, ?, ?)", 
                    [createUUID(), arguments.postId, tagId], {datasource: "blog"})>
            </cfif>
        </cfloop>
        
        <cfcatch any>
            <cfset result.success = false>
            <cfset result.message = "Error adding tags: " & cfcatch.message>
        </cfcatch>
    </cftry>
    
    <cfreturn result>
</cffunction>