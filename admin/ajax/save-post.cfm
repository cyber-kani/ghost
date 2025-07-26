<!--- Save Post AJAX Handler --->
<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">
<cfcontent reset="true">

<cfset response = {success: false, message: "", postId: ""}>

<cftry>
    <!--- Check if user is logged in --->
    <cfif not structKeyExists(session, "ISLOGGEDIN") or not session.ISLOGGEDIN>
        <cfset response.message = "User not logged in">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Get form data --->
    <cfset postId = form.postId ?: "">
    <cfset title = form.title ?: "">
    <cfset content = form.content ?: "">
    <cfset plaintext = form.plaintext ?: "">
    <cfset featureImage = form.feature_image ?: "">
    <cfset slug = form.slug ?: "">
    <cfset excerpt = form.excerpt ?: "">
    <cfset metaTitle = form.meta_title ?: "">
    <cfset metaDescription = form.meta_description ?: "">
    <cfset visibility = form.visibility ?: "public">
    <cfset featured = form.featured ?: "0">
    <cfset publishedAt = form.published_at ?: "">
    <cfset tags = form.tags ?: "[]">
    <cfset status = form.status ?: "draft">
    
    <!--- Validate required fields --->
    <cfif not len(trim(postId))>
        <cfset response.message = "Post ID is required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <cfif not len(trim(title))>
        <cfset title = "(Untitled)">
    </cfif>
    
    <!--- Generate slug if empty --->
    <cfif not len(trim(slug))>
        <cfset slug = lcase(reReplace(title, "[^a-zA-Z0-9]+", "-", "all"))>
        <cfset slug = reReplace(slug, "^-+|-+$", "", "all")>
    </cfif>
    
    <!--- Parse tags JSON --->
    <cfset tagArray = deserializeJSON(tags)>
    
    <!--- Check if post exists --->
    <cfquery name="checkPost" datasource="blog">
        SELECT id FROM posts WHERE id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkPost.recordCount gt 0>
        <!--- Update existing post --->
        <cfquery datasource="blog">
            UPDATE posts SET
                title = <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
                slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar">,
                html = <cfqueryparam value="#content#" cfsqltype="cf_sql_longvarchar">,
                plaintext = <cfqueryparam value="#plaintext#" cfsqltype="cf_sql_longvarchar">,
                feature_image = <cfqueryparam value="#featureImage#" cfsqltype="cf_sql_varchar">,
                custom_excerpt = <cfqueryparam value="#excerpt#" cfsqltype="cf_sql_longvarchar">,
                visibility = <cfqueryparam value="#visibility#" cfsqltype="cf_sql_varchar">,
                featured = <cfqueryparam value="#featured eq '1' ? 1 : 0#" cfsqltype="cf_sql_bit">,
                status = <cfqueryparam value="#status#" cfsqltype="cf_sql_varchar">,
                updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                updated_by = <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">
                <cfif len(publishedAt) and isDate(publishedAt)>
                    , published_at = <cfqueryparam value="#parseDateTime(publishedAt)#" cfsqltype="cf_sql_timestamp">
                <cfelseif status eq "published" and not len(publishedAt)>
                    , published_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                </cfif>
            WHERE id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfset response.message = "Post updated successfully">
    <cfelse>
        <!--- Create new post --->
        <cfquery datasource="blog">
            INSERT INTO posts (
                id, uuid, title, slug, html, plaintext, feature_image,
                custom_excerpt, visibility,
                featured, status, type, created_by, created_at, updated_at,
                email_recipient_filter
                <cfif len(publishedAt) and isDate(publishedAt)>
                    , published_at
                <cfelseif status eq "published">
                    , published_at
                </cfif>
            ) VALUES (
                <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#title#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#content#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#plaintext#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#featureImage#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#excerpt#" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="#visibility#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#featured eq '1' ? 1 : 0#" cfsqltype="cf_sql_bit">,
                <cfqueryparam value="#status#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="post" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="all" cfsqltype="cf_sql_varchar">
                <cfif len(publishedAt) and isDate(publishedAt)>
                    , <cfqueryparam value="#parseDateTime(publishedAt)#" cfsqltype="cf_sql_timestamp">
                <cfelseif status eq "published">
                    , <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                </cfif>
            )
        </cfquery>
        
        <!--- Add author relationship --->
        <cfquery datasource="blog">
            INSERT INTO posts_authors (id, post_id, author_id, sort_order)
            VALUES (
                <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        
        <cfset response.message = "Post created successfully">
    </cfif>
    
    <!--- Update tags --->
    <!--- First, remove all existing tags --->
    <cfquery datasource="blog">
        DELETE FROM posts_tags WHERE post_id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Then add new tags --->
    <cfloop array="#tagArray#" index="tag">
        <cfquery datasource="blog">
            INSERT INTO posts_tags (id, post_id, tag_id, sort_order)
            VALUES (
                <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#tag.id#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cfloop>
    
    <cfset response.success = true>
    <cfset response.postId = postId>
    <cfset response.status = status>
    <cfset response.SUCCESS = true> <!--- For JS compatibility --->
    <cfset response.MESSAGE = response.message>
    <cfset response.STATUS = status> <!--- For JS compatibility --->
    <cfset response.POSTID = postId> <!--- For JS compatibility --->
    
    <cfcatch>
        <cfset response.message = "Error saving post: " & cfcatch.message>
        <cflog file="ghost-save-post" text="Save post error: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<!--- Output JSON response --->
<cfoutput>#serializeJSON(response)#</cfoutput>