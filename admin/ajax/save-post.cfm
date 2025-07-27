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
    
    <!--- Clean up postId - ensure it's 24 characters --->
    <cfif len(postId) gt 24>
        <!--- If it has dashes, remove them and take first 24 chars --->
        <cfset postId = left(replace(postId, "-", "", "all"), 24)>
    </cfif>
    
    <!--- Debug: Log the postId --->
    <cflog file="ghost-save-post" text="PostId received: #postId# (Length: #len(postId)#)">
    
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
    <cfset authors = form.authors ?: "[]">
    <cfset status = form.status ?: "draft">
    
    <!--- Additional fields from settings --->
    <cfset customTemplate = form.custom_template ?: "">
    <cfset codeinjectionHead = form.codeinjection_head ?: "">
    <cfset codeinjectionFoot = form.codeinjection_foot ?: "">
    <cfset canonicalUrl = form.canonical_url ?: "">
    <cfset showTitleAndFeatureImage = form.show_title_and_feature_image ?: "1">
    
    <!--- Social media fields --->
    <cfset ogTitle = form.og_title ?: "">
    <cfset ogDescription = form.og_description ?: "">
    <cfset ogImage = form.og_image ?: "">
    <cfset twitterTitle = form.twitter_title ?: "">
    <cfset twitterDescription = form.twitter_description ?: "">
    <cfset twitterImage = form.twitter_image ?: "">
    
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
    
    <!--- Parse tags and authors JSON --->
    <cfif len(trim(tags))>
        <cfset tagArray = deserializeJSON(tags)>
    <cfelse>
        <cfset tagArray = []>
    </cfif>
    
    <cfif len(trim(authors))>
        <cfset authorArray = deserializeJSON(authors)>
    <cfelse>
        <cfset authorArray = []>
    </cfif>
    
    <!--- Check if post exists --->
    <cfquery name="checkPost" datasource="#request.dsn#">
        SELECT id FROM posts WHERE id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkPost.recordCount gt 0>
        <!--- Update existing post --->
        <cfquery datasource="#request.dsn#">
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
                custom_template = <cfqueryparam value="#customTemplate#" cfsqltype="cf_sql_varchar">,
                codeinjection_head = <cfqueryparam value="#codeinjectionHead#" cfsqltype="cf_sql_longvarchar">,
                codeinjection_foot = <cfqueryparam value="#codeinjectionFoot#" cfsqltype="cf_sql_longvarchar">,
                canonical_url = <cfqueryparam value="#canonicalUrl#" cfsqltype="cf_sql_longvarchar">,
                show_title_and_feature_image = <cfqueryparam value="#showTitleAndFeatureImage eq '1' ? 1 : 0#" cfsqltype="cf_sql_bit">,
                updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                updated_by = <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">
                <cfif len(publishedAt) and isDate(publishedAt)>
                    , published_at = <cfqueryparam value="#parseDateTime(publishedAt)#" cfsqltype="cf_sql_timestamp">
                <cfelseif status eq "published" and not len(publishedAt)>
                    , published_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                </cfif>
            WHERE id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <!--- Update or insert posts_meta --->\
        <cfquery name="checkMeta" datasource="#request.dsn#">
            SELECT id FROM posts_meta WHERE post_id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif checkMeta.recordCount gt 0>
            <!--- Update existing meta --->\
            <cfquery datasource="#request.dsn#">
                UPDATE posts_meta SET
                    meta_title = <cfqueryparam value="#metaTitle#" cfsqltype="cf_sql_varchar">,
                    meta_description = <cfqueryparam value="#metaDescription#" cfsqltype="cf_sql_varchar">,
                    og_title = <cfqueryparam value="#ogTitle#" cfsqltype="cf_sql_varchar">,
                    og_description = <cfqueryparam value="#ogDescription#" cfsqltype="cf_sql_varchar">,
                    og_image = <cfqueryparam value="#ogImage#" cfsqltype="cf_sql_varchar">,
                    twitter_title = <cfqueryparam value="#twitterTitle#" cfsqltype="cf_sql_varchar">,
                    twitter_description = <cfqueryparam value="#twitterDescription#" cfsqltype="cf_sql_varchar">,
                    twitter_image = <cfqueryparam value="#twitterImage#" cfsqltype="cf_sql_varchar">
                WHERE post_id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
            </cfquery>
        <cfelse>
            <!--- Insert new meta --->\
            <cfquery datasource="#request.dsn#">
                INSERT INTO posts_meta (
                    id, post_id, meta_title, meta_description,
                    og_title, og_description, og_image,
                    twitter_title, twitter_description, twitter_image
                ) VALUES (
                    <cfqueryparam value="#left(replace(createUUID(), '-', '', 'all'), 24)#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#metaTitle#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#metaDescription#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#ogTitle#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#ogDescription#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#ogImage#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#twitterTitle#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#twitterDescription#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#twitterImage#" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
        </cfif>
        
        <cfset response.message = "Post updated successfully">
    <cfelse>
        <!--- Create new post --->
        <cfquery datasource="#request.dsn#">
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
        <cfquery datasource="#request.dsn#">
            INSERT INTO posts_authors (id, post_id, author_id, sort_order)
            VALUES (
                <cfqueryparam value="#left(replace(createUUID(), '-', '', 'all'), 24)#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        
        <cfset response.message = "Post created successfully">
    </cfif>
    
    <!--- Update tags --->
    <!--- First, remove all existing tags --->
    <cfquery datasource="#request.dsn#">
        DELETE FROM posts_tags WHERE post_id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Then add new tags --->
    <cfloop array="#tagArray#" index="tag">
        <cfquery datasource="#request.dsn#">
            INSERT INTO posts_tags (id, post_id, tag_id, sort_order)
            VALUES (
                <cfqueryparam value="#left(replace(createUUID(), '-', '', 'all'), 24)#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#tag.id#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cfloop>
    
    <!--- Update authors --->
    <!--- First, remove all existing authors --->
    <cfquery datasource="#request.dsn#">
        DELETE FROM posts_authors WHERE post_id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <!--- Then add new authors --->
    <cfif arrayLen(authorArray) gt 0>
        <cfset sortOrder = 0>
        <cfloop array="#authorArray#" index="author">
            <cfquery datasource="#request.dsn#">
                INSERT INTO posts_authors (id, post_id, author_id, sort_order)
                VALUES (
                    <cfqueryparam value="#left(replace(createUUID(), '-', '', 'all'), 24)#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#author.id#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#sortOrder#" cfsqltype="cf_sql_integer">
                )
            </cfquery>
            <cfset sortOrder = sortOrder + 1>
        </cfloop>
    <cfelse>
        <!--- If no authors specified, default to current user --->
        <cfquery datasource="#request.dsn#">
            INSERT INTO posts_authors (id, post_id, author_id, sort_order)
            VALUES (
                <cfqueryparam value="#left(replace(createUUID(), '-', '', 'all'), 24)#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="0" cfsqltype="cf_sql_integer">
            )
        </cfquery>
    </cfif>
    
    <cfset response.success = true>
    <cfset response.postId = postId>
    <cfset response.status = status>
    <cfset response.SUCCESS = true> <!--- For JS compatibility --->
    <cfset response.MESSAGE = response.message>
    <cfset response.STATUS = status> <!--- For JS compatibility --->
    <cfset response.POSTID = postId> <!--- For JS compatibility --->
    
    <cfcatch>
        <cfset response.message = "Error saving post: " & cfcatch.message>
        <cflog file="ghost-save-post" text="Save post error: #cfcatch.message# - #cfcatch.detail# - SQL: #cfcatch.sql ?: 'No SQL'# - PostId: #postId# (Length: #len(postId)#)">
    </cfcatch>
</cftry>

<!--- Output JSON response --->
<cfoutput>#serializeJSON(response)#</cfoutput>