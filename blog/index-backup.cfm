<!--- Ghost Blog Index Page --->
<cfparam name="request.dsn" default="ghost_prod">
<cfparam name="url.page" default="1">

<!--- Include Handlebars functions --->
<cfinclude template="/ghost/admin/includes/handlebars-functions.cfm">

<!--- Get posts per page from theme config --->
<cfset postsPerPage = 10>

<!--- Calculate pagination --->
<cfset startRow = ((url.page - 1) * postsPerPage) + 1>

<!--- Get total post count --->
<cfquery name="qPostCount" datasource="#request.dsn#">
    SELECT COUNT(*) as total
    FROM posts
    WHERE status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset totalPosts = qPostCount.total>
<cfset totalPages = ceiling(totalPosts / postsPerPage)>

<!--- Get posts for current page --->
<cfquery name="qPosts" datasource="#request.dsn#" maxrows="#postsPerPage#">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.custom_excerpt,
        p.plaintext,
        p.feature_image,
        p.published_at,
        p.created_at,
        p.created_by as author_id,
        u.name as author_name,
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT #postsPerPage# OFFSET #startRow - 1#
</cfquery>

<!--- Build posts array for template --->
<cfset posts = []>
<cfif qPosts.recordCount GT 0>
<cfloop query="qPosts">
    <!--- Get tags for this post --->
    <cfquery name="qPostTags" datasource="#request.dsn#">
        SELECT t.id, t.name, t.slug
        FROM tags t
        INNER JOIN posts_tags pt ON t.id = pt.tag_id
        WHERE pt.post_id = <cfqueryparam value="#qPosts.id#" cfsqltype="cf_sql_varchar">
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
    
    <!--- Create excerpt from custom_excerpt or plaintext --->
    <cfset excerpt = "">
    <cfif len(trim(qPosts.custom_excerpt))>
        <cfset excerpt = qPosts.custom_excerpt>
    <cfelseif len(trim(qPosts.plaintext))>
        <cfset excerpt = left(qPosts.plaintext, 200)>
        <cfif len(qPosts.plaintext) GT 200>
            <cfset excerpt = excerpt & "...">
        </cfif>
    </cfif>
    
    <cfset post = {
        "id": qPosts.id,
        "title": qPosts.title,
        "url": "/blog/" & qPosts.slug & "/",
        "excerpt": excerpt,
        "feature_image": qPosts.feature_image,
        "tags": tags,
        "author": {
            "name": qPosts.author_name,
            "profile_image": qPosts.author_profile_image,
            "url": "/blog/author/" & qPosts.author_id & "/"
        },
        "date": qPosts.published_at,
        "post_class": ""
    }>
    
    <cfset arrayAppend(posts, post)>
</cfloop>
</cfif>

<!--- Build pagination object --->
<cfset pagination = {
    "page": url.page,
    "pages": totalPages,
    "total": totalPosts,
    "limit": postsPerPage,
    "prev": url.page GT 1 ? url.page - 1 : false,
    "next": url.page LT totalPages ? url.page + 1 : false
}>

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
    "posts": posts,
    "pagination": pagination,
    "site": {
        "title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
        "description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
        "url": structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost",
        "icon": structKeyExists(siteSettings, "site_icon") ? siteSettings.site_icon : "/ghost/admin/assets/img/ghost-icon.png",
        "locale": "en"
    },
    "theme": getActiveTheme(request.dsn),
    "meta_title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
    "meta_description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
    "canonical_url": (structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost") & "/blog/",
    "body_class": "home-template",
    "navigation": []
}>

<!--- Render the theme template --->
<cftry>
    <cfset output = renderThemeTemplate("index.hbs", context, context.theme)>
    
    <!--- Make sure we have output --->
    <cfif NOT len(trim(output))>
        <cfthrow message="Template rendered but produced no output">
    </cfif>
    
    <!--- Output the rendered template --->
    <cfcontent reset="true" type="text/html">
    <cfoutput>#output#</cfoutput>
    
<cfcatch>
    <cfcontent reset="true">
    <cfoutput>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Theme Rendering Error</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; }
            .error { background: ##fee; color: ##c00; padding: 20px; border-radius: 5px; }
            pre { background: ##f5f5f5; padding: 10px; overflow-x: auto; }
        </style>
    </head>
    <body>
        <div class="error">
            <h1>Theme Rendering Error</h1>
            <p><strong>Error:</strong> #cfcatch.message#</p>
            <p><strong>Details:</strong> #cfcatch.detail#</p>
            <p><strong>Type:</strong> #cfcatch.type#</p>
            <hr>
            <p>Active Theme: #context.theme.name#</p>
            <p>Template: index.hbs</p>
            
            <cfif structKeyExists(cfcatch, "tagContext") AND isArray(cfcatch.tagContext) AND arrayLen(cfcatch.tagContext)>
                <h3>Error Location:</h3>
                <cfloop array="#cfcatch.tagContext#" index="tc">
                    <p>#tc.template# (line #tc.line#)</p>
                </cfloop>
            </cfif>
        </div>
        
        <h3>Debug Info:</h3>
        <pre>Posts Count: #arrayLen(context.posts)#
Theme: #context.theme.name#
Theme Path: #context.theme.path#</pre>
    </body>
    </html>
    </cfoutput>
</cfcatch>
</cftry>