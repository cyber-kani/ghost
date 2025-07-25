<!--- Quick Publish/Unpublish AJAX Endpoint --->
<cfheader name="Content-Type" value="application/json">

<cfinclude template="../includes/posts-functions.cfm">

<cfset response = {success: false, message: ""}>

<cftry>
    <!--- Validate required parameters --->
    <cfif not structKeyExists(form, "postId") or len(trim(form.postId)) eq 0>
        <cfset response.message = "Post ID is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfif not structKeyExists(form, "status") or len(trim(form.status)) eq 0>
        <cfset response.message = "Status is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfset postId = trim(form.postId)>
    <cfset newStatus = trim(form.status)>
    
    <!--- Get current post data (simple query without joins for quick publish) --->
    <cftry>
        <cfset postQuery = queryExecute("
            SELECT id, title, html, plaintext, featured, status, 
                   visibility, slug, type, published_at, created_at, updated_at, 
                   created_by
            FROM posts 
            WHERE id = :id
        ", {
            id: {value: postId, cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"})>
        
        <cfif postQuery.recordCount eq 0>
            <cfset response.message = "Post not found in database. ID: " & postId>
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfif>
        
        <!--- Convert to struct --->
        <cfset currentPost = {
            id: postQuery.id[1],
            title: postQuery.title[1] ?: "",
            html: postQuery.html[1] ?: "",
            plaintext: postQuery.plaintext[1] ?: "",
            featured: postQuery.featured[1] ?: false,
            status: postQuery.status[1] ?: "draft",
            visibility: postQuery.visibility[1] ?: "public",
            slug: postQuery.slug[1] ?: "",
            type: postQuery.type[1] ?: "post",
            published_at: postQuery.published_at[1],
            created_at: postQuery.created_at[1],
            updated_at: postQuery.updated_at[1],
            created_by: postQuery.created_by[1] ?: ""
        }>
        
        <cfcatch any>
            <cfset response.message = "Database error: " & cfcatch.message & " - Detail: " & (cfcatch.detail ?: "No detail")>
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfcatch>
    </cftry>
    
    <!--- Prepare update data --->
    <cfset updateData = {
        id: postId,
        title: currentPost.title,
        html: currentPost.html,
        plaintext: currentPost.plaintext,
        featured: currentPost.featured,
        status: newStatus,
        visibility: currentPost.visibility,
        slug: currentPost.slug,
        type: currentPost.type,
        updated_at: now(),
        created_by: currentPost.created_by
    }>
    
    <!--- Set published_at if publishing --->
    <cfif newStatus eq "published" and (not structKeyExists(currentPost, "published_at") or not isDate(currentPost.published_at))>
        <cfset updateData.published_at = now()>
    <cfelseif newStatus eq "published" and isDate(currentPost.published_at)>
        <cfset updateData.published_at = currentPost.published_at>
    </cfif>
    
    <!--- Update the post --->
    <cfset updateResult = updatePost(updateData)>
    
    <cfif updateResult.success>
        <cfset response.success = true>
        <cfset response.message = newStatus eq "published" ? "Post published successfully" : "Post unpublished successfully">
    <cfelse>
        <cfset response.message = updateResult.message>
    </cfif>
    
    <cfcatch any>
        <cfset response.message = "Error updating post status: " & cfcatch.message>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>