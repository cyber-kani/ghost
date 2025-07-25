<!--- Duplicate Post AJAX Endpoint --->
<cfheader name="Content-Type" value="application/json">

<cfinclude template="../includes/posts-functions.cfm">

<cfset response = {success: false, message: "", newPostId: ""}>

<cftry>
    <!--- Validate required parameters --->
    <cfif not structKeyExists(form, "postId") or len(trim(form.postId)) eq 0>
        <cfset response.message = "Post ID is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfset postId = trim(form.postId)>
    
    <!--- Get original post data (simple query without joins) --->
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
        <cfset originalPost = {
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
        
        <!--- Get tags for the original post --->
        <cfset tagsQuery = queryExecute("
            SELECT t.name 
            FROM tags t
            INNER JOIN posts_tags pt ON t.id = pt.tag_id
            WHERE pt.post_id = :postId
            ORDER BY t.name
        ", {
            postId: {value: postId, cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"})>
        
        <cfset originalPost.tags = []>
        <cfloop query="tagsQuery">
            <cfset arrayAppend(originalPost.tags, {name: tagsQuery.name})>
        </cfloop>
        
        <cfcatch any>
            <cfset response.message = "Database error: " & cfcatch.message & " - Detail: " & (cfcatch.detail ?: "No detail")>
            <cfoutput>#serializeJSON(response)#</cfoutput>
            <cfabort>
        </cfcatch>
    </cftry>
    
    <!--- Generate new post ID (24-character hex like MongoDB ObjectId) --->
    <cfset timestamp = dateFormat(now(), "yyyymmdd") & timeFormat(now(), "HHmmss")>
    <cfset randomPart = "">
    <cfloop from="1" to="8" index="i">
        <cfset randomPart = randomPart & lcase(formatBaseN(randRange(0, 15), 16))>
    </cfloop>
    <cfset newPostId = lcase(hash(timestamp & randomPart & createUUID(), "MD5"))>
    <cfset newPostId = left(newPostId, 24)>
    
    <!--- Get current logged-in admin user --->
    <cfset currentAdminUser = "Admin User"> <!--- Default fallback --->
    <cfif structKeyExists(session, "adminUser")>
        <cfset currentAdminUser = session.adminUser>
    <cfelseif structKeyExists(session, "userName")>
        <cfset currentAdminUser = session.userName>
    <cfelseif structKeyExists(session, "user")>
        <cfif isStruct(session.user) and structKeyExists(session.user, "name")>
            <cfset currentAdminUser = session.user.name>
        <cfelseif isStruct(session.user) and structKeyExists(session.user, "username")>
            <cfset currentAdminUser = session.user.username>
        <cfelse>
            <cfset currentAdminUser = session.user>
        </cfif>
    </cfif>
    
    <!--- Prepare duplicate post data --->
    <cfset duplicateData = {
        id: newPostId,
        uuid: createUUID(),
        title: originalPost.title & " (Copy)",
        html: originalPost.html,
        plaintext: originalPost.plaintext,
        featured: false,
        status: "draft",
        visibility: originalPost.visibility,
        slug: originalPost.slug & "-copy-" & lcase(left(newPostId, 8)),
        type: originalPost.type,
        created_by: currentAdminUser,
        created_at: now(),
        updated_at: now(),
        email_recipient_filter: "all"
    }>
    
    <!--- Create the duplicate post --->
    <cfset createResult = createPost(duplicateData)>
    
    <cfif createResult.success>
        <!--- Duplicate tags if they exist --->
        <cfif arrayLen(originalPost.tags) gt 0>
            <cfset tagNames = []>
            <cfloop array="#originalPost.tags#" index="tag">
                <cfset arrayAppend(tagNames, tag.name)>
            </cfloop>
            
            <!--- Add tags to duplicate post --->
            <cfset addTagsResult = addPostTags(newPostId, tagNames)>
        </cfif>
        
        <cfset response.success = true>
        <cfset response.message = "Post duplicated successfully">
        <cfset response.newPostId = newPostId>
    <cfelse>
        <cfset response.message = createResult.message>
    </cfif>
    
    <cfcatch any>
        <cfset response.message = "Error duplicating post: " & cfcatch.message>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>

<!--- Helper function to add tags to post --->
<cffunction name="addPostTags" access="private" returntype="struct">
    <cfargument name="postId" type="string" required="true">
    <cfargument name="tags" type="array" required="true">
    
    <cfset var result = {success: true, message: ""}>
    
    <cftry>
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