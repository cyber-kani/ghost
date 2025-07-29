<!--- Blog Index with Theme Support --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">

<!--- Include the theme renderer --->
<cfinclude template="/ghost/admin/includes/handlebars-renderer.cfm">

<!--- Get posts per page --->
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
        p.html,
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

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value
    FROM settings
    WHERE `key` IN ('site_title', 'site_description', 'site_url', 'site_icon', 'navigation')
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Build posts array for template --->
<cfset posts = []>
<cfloop query="qPosts">
    <!--- Get tags for this post --->
    <cfquery name="qPostTags" datasource="#request.dsn#">
        SELECT t.id, t.name, t.slug
        FROM tags t
        INNER JOIN posts_tags pt ON t.id = pt.tag_id
        WHERE pt.post_id = <cfqueryparam value="#qPosts.id#" cfsqltype="cf_sql_varchar">
        ORDER BY t.name
    </cfquery>
    
    <cfset postTags = []>
    <cfloop query="qPostTags">
        <cfset arrayAppend(postTags, {
            "name": qPostTags.name,
            "slug": qPostTags.slug,
            "url": "/ghost/blog/tag/" & qPostTags.slug & "/"
        })>
    </cfloop>
    
    <!--- Create excerpt --->
    <cfset excerpt = "">
    <cfif len(trim(qPosts.custom_excerpt))>
        <cfset excerpt = qPosts.custom_excerpt>
    <cfelseif len(trim(qPosts.plaintext))>
        <cfset excerpt = left(qPosts.plaintext, 200)>
        <cfif len(qPosts.plaintext) GT 200>
            <cfset excerpt = excerpt & "...">
        </cfif>
    </cfif>
    
    <cfset arrayAppend(posts, {
        "id": qPosts.id,
        "title": qPosts.title,
        "slug": qPosts.slug,
        "url": "/ghost/blog/" & qPosts.slug & "/",
        "excerpt": excerpt,
        "feature_image": qPosts.feature_image,
        "published_at": qPosts.published_at,
        "reading_time": "2 min read",
        "tags": postTags,
        "author": {
            "name": qPosts.author_name,
            "profile_image": qPosts.author_profile_image,
            "url": "/ghost/blog/author/" & qPosts.author_id & "/"
        }
    })>
</cfloop>

<!--- Parse navigation if exists --->
<cfset navigation = []>
<cfif structKeyExists(siteSettings, "navigation") AND len(siteSettings.navigation)>
    <cftry>
        <cfset navigation = deserializeJSON(siteSettings.navigation)>
    <cfcatch>
        <cfset navigation = [
            {"label": "Home", "url": "/ghost/blog/"},
            {"label": "Admin", "url": "/ghost/admin/"}
        ]>
    </cfcatch>
    </cftry>
<cfelse>
    <cfset navigation = [
        {"label": "Home", "url": "/ghost/blog/"},
        {"label": "Admin", "url": "/ghost/admin/"}
    ]>
</cfif>

<!--- Build pagination info --->
<cfset pagination = {
    "page": url.page,
    "limit": postsPerPage,
    "pages": totalPages,
    "total": totalPosts,
    "next": url.page LT totalPages ? url.page + 1 : "",
    "prev": url.page GT 1 ? url.page - 1 : ""
}>

<!--- Build template context --->
<cfset context = {
    "site": {
        "title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
        "description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
        "url": structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost",
        "navigation": navigation
    },
    "posts": posts,
    "pagination": pagination,
    "body_class": "home-template",
    "meta_title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
    "meta_description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform"
}>

<!--- Render the theme template --->
<cftry>
    <cfset output = renderThemeTemplate("index", context, request.dsn)>
    <cfcontent reset="true">
    <cfoutput>#output#</cfoutput>
<cfcatch>
    <!--- Fallback to simple template if theme rendering fails --->
    <cfinclude template="index.cfm">
</cfcatch>
</cftry>