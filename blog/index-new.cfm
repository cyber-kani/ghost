<!--- Blog Index using Theme Templates --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">

<!--- Ensure datasource is set --->
<cfif NOT structKeyExists(request, "dsn") OR NOT len(request.dsn)>
    <cfset request.dsn = application.datasource>
</cfif>

<!--- Include theme renderer --->
<cfinclude template="/ghost/admin/includes/theme-renderer.cfm">

<!--- Get posts per page --->
<cfset postsPerPage = 10>

<!--- Calculate pagination --->
<cfset startRow = ((url.page - 1) * postsPerPage) + 1>

<!--- Get total post count --->
<cfquery name="qPostCount" datasource="#request.dsn#">
    SELECT COUNT(*) as total
    FROM posts
    WHERE status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset totalPosts = qPostCount.total>
<cfset totalPages = ceiling(totalPosts / postsPerPage)>

<!--- Get posts for current page --->
<cfquery name="qPosts" datasource="#request.dsn#" maxrows="#postsPerPage#">
    SELECT 
        p.id,
        p.uuid,
        p.title,
        p.slug,
        p.custom_excerpt,
        p.plaintext,
        p.feature_image,
        p.feature_image_alt,
        p.published_at,
        p.created_at,
        p.created_by as author_id,
        p.featured,
        u.name as author_name,
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT #postsPerPage# OFFSET #startRow - 1#
</cfquery>

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value
    FROM settings
    WHERE `key` IN ('site_title', 'site_description', 'site_url', 'site_icon', 'site_logo', 'site_cover_image', 'accent_color')
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Build context for Handlebars --->
<cfset context = {
    "@site": {
        "title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
        "description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
        "url": structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost",
        "logo": structKeyExists(siteSettings, "site_logo") ? siteSettings.site_logo : "",
        "icon": structKeyExists(siteSettings, "site_icon") ? siteSettings.site_icon : "",
        "cover_image": structKeyExists(siteSettings, "site_cover_image") ? siteSettings.site_cover_image : "",
        "accent_color": structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : "##15171A",
        "locale": "en",
        "timezone": "UTC",
        "members_enabled": false
    },
    "site": {
        "title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
        "description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
        "url": structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost",
        "logo": structKeyExists(siteSettings, "site_logo") ? siteSettings.site_logo : ""
    },
    "@custom": {
        "navigation_layout": "Logo on cover",
        "title_font": "Modern sans-serif",
        "body_font": "Elegant serif",
        "show_publication_cover": true,
        "header_style": "Center aligned",
        "feed_layout": "Classic",
        "color_scheme": "Light"
    },
    "@member": "",
    "posts": [],
    "pagination": {
        "page": url.page,
        "limit": postsPerPage,
        "pages": totalPages,
        "total": totalPosts,
        "next": url.page LT totalPages ? url.page + 1 : "",
        "prev": url.page GT 1 ? url.page - 1 : ""
    }
}>

<!--- Convert posts query to array for Handlebars --->
<cfloop query="qPosts">
    <cfset post = {
        "id": qPosts.uuid,
        "uuid": qPosts.uuid,
        "title": qPosts.title,
        "slug": qPosts.slug,
        "excerpt": len(qPosts.custom_excerpt) ? qPosts.custom_excerpt : left(qPosts.plaintext, 200) & "...",
        "custom_excerpt": qPosts.custom_excerpt,
        "feature_image": qPosts.feature_image,
        "feature_image_alt": qPosts.feature_image_alt,
        "published_at": qPosts.published_at,
        "created_at": qPosts.created_at,
        "featured": qPosts.featured EQ 1,
        "page": false,
        "access": true,
        "visibility": "public",
        "url": "/ghost/blog/" & qPosts.slug & "/",
        "author": {
            "name": qPosts.author_name,
            "profile_image": qPosts.author_profile_image
        },
        "tags": [],
        "primary_tag": "",
        "reading_time": 1
    }>
    
    <!--- Get tags for this post --->
    <cfquery name="qPostTags" datasource="#request.dsn#">
        SELECT t.id, t.name, t.slug
        FROM tags t
        INNER JOIN posts_tags pt ON t.id = pt.tag_id
        WHERE pt.post_id = <cfqueryparam value="#qPosts.id#" cfsqltype="cf_sql_varchar">
        ORDER BY t.name
    </cfquery>
    
    <cfif qPostTags.recordCount>
        <cfloop query="qPostTags">
            <cfset arrayAppend(post.tags, {
                "name": qPostTags.name,
                "slug": qPostTags.slug,
                "url": "/ghost/blog/tag/" & qPostTags.slug & "/"
            })>
        </cfloop>
        <cfset post.primary_tag = post.tags[1]>
    </cfif>
    
    <cfset arrayAppend(context.posts, post)>
</cfloop>

<!--- Additional context for index template --->
<cfset context["body_class"] = "home-template">
<cfset context["template"] = "home">

<!--- Render the theme template --->
<cftry>
    <cfset output = renderTheme("index.hbs", context)>
    <cfoutput>#output#</cfoutput>
<cfcatch>
    <!--- Error rendering theme, show error details --->
    <cfoutput>
        <!DOCTYPE html>
        <html>
        <head>
            <title>Theme Rendering Error</title>
            <style>
                body { font-family: sans-serif; margin: 40px; }
                .error { background: ##fee; border: 1px solid ##fcc; padding: 20px; margin: 20px 0; }
                pre { background: ##f5f5f5; padding: 15px; overflow: auto; }
            </style>
        </head>
        <body>
            <h1>Theme Rendering Error</h1>
            <div class="error">
                <h2>Error Message</h2>
                <p>#cfcatch.message#</p>
                <cfif len(cfcatch.detail)>
                    <h2>Details</h2>
                    <p>#cfcatch.detail#</p>
                </cfif>
                <h2>Stack Trace</h2>
                <pre>#cfcatch.stacktrace#</pre>
            </div>
        </body>
        </html>
    </cfoutput>
</cfcatch>
</cftry>