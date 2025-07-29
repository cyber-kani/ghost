<!--- Ghost Blog Single Post Page --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">

<!--- Include Handlebars functions --->
<cfinclude template="/ghost/admin/includes/handlebars-functions.cfm">

<!--- Get post by slug --->
<cfquery name="qPost" datasource="#request.dsn#">
    SELECT 
        p.*,
        u.id as author_id,
        u.name as author_name,
        u.email as author_email,
        u.profile_image as author_profile_image,
        u.bio as author_bio
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- If post not found, show 404 --->
<cfif qPost.recordCount EQ 0>
    <cfheader statuscode="404" statustext="Not Found">
    <cfcontent reset="true">
    <h1>Post not found</h1>
    <p>The post you're looking for doesn't exist.</p>
    <cfabort>
</cfif>

<!--- Get tags for this post --->
<cfquery name="qPostTags" datasource="#request.dsn#">
    SELECT t.id, t.name, t.slug
    FROM tags t
    INNER JOIN posts_tags pt ON t.id = pt.tag_id
    WHERE pt.post_id = <cfqueryparam value="#qPost.id#" cfsqltype="cf_sql_varchar">
    ORDER BY t.name
</cfquery>

<cfset tags = []>
<cfloop query="qPostTags">
    <cfset arrayAppend(tags, {
        "name": qPostTags.name,
        "slug": qPostTags.slug,
        "url": "/blog/tag/" & qPostTags.slug & "/"
    })>
</cfloop>

<!--- Process content to replace Ghost image URLs --->
<cffunction name="replaceGhostUrl" access="public" returntype="string">
    <cfargument name="content" type="string" required="true">
    <cfset var processedContent = arguments.content>
    <cfset processedContent = replace(processedContent, "__GHOST_URL__", "/ghost", "all")>
    <cfreturn processedContent>
</cffunction>

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value
    FROM settings
    WHERE `key` IN ('site_title', 'site_description', 'site_url', 'site_icon')
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Build template context --->
<cfset context = {
    "post": {
        "id": qPost.id,
        "title": qPost.title,
        "content": replaceGhostUrl(qPost.html),
        "excerpt": qPost.custom_excerpt,
        "feature_image": qPost.feature_image,
        "tags": tags,
        "author": {
            "id": qPost.author_id,
            "name": qPost.author_name,
            "profile_image": qPost.author_profile_image,
            "bio": qPost.author_bio,
            "url": "/blog/author/" & qPost.author_id & "/"
        },
        "date": qPost.published_at,
        "url": "/blog/" & qPost.slug & "/"
    },
    "site": {
        "title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
        "description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
        "url": structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost",
        "icon": structKeyExists(siteSettings, "site_icon") ? siteSettings.site_icon : "/ghost/admin/assets/img/ghost-icon.png",
        "locale": "en"
    },
    "theme": getActiveTheme(request.dsn),
    "meta_title": qPost.title & " - " & (structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML"),
    "meta_description": len(qPost.custom_excerpt) ? qPost.custom_excerpt : left(reReplace(qPost.html, "<[^>]*>", "", "all"), 160),
    "canonical_url": (structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost") & "/blog/" & qPost.slug & "/",
    "body_class": "post-template",
    "post_class": "post",
    "navigation": []
}>

<!--- Add current post data for Handlebars access --->
<cfset structAppend(context, context.post)>

<!--- Render the theme template --->
<cfset output = renderThemeTemplate("post.hbs", context, context.theme)>

<!--- Output the rendered template --->
<cfcontent reset="true">
<cfoutput>#output#</cfoutput>