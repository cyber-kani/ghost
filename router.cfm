<!--- Single Entry Point Router for Ghost CFML --->
<!--- This file handles all URL routing using CFML tags --->

<!--- Get the requested path information --->
<cfparam name="url.path" default="#cgi.path_info#">
<cfparam name="url.originalPath" default="">
<cfparam name="cgi.request_uri" default="">

<!--- Clean up duplicate query parameters from nginx rewrite --->
<cfif structKeyExists(url, "type") and find(",", url.type)>
    <cfset url.type = listFirst(url.type, ",")>
</cfif>
<cfif structKeyExists(url, "page") and find(",", url.page)>
    <cfset url.page = listFirst(url.page, ",")>
</cfif>
<cfif structKeyExists(url, "author") and find(",", url.author)>
    <cfset url.author = listFirst(url.author, ",")>
</cfif>
<cfif structKeyExists(url, "search") and find(",", url.search)>
    <cfset url.search = listFirst(url.search, ",")>
</cfif>
<cfset requestPath = "">
<cfset templateFile = "">
<cfset routeFound = false>

<!--- Parse the request URI to get clean path --->
<cfif len(trim(url.originalPath)) gt 0>
    <cfset requestPath = url.originalPath>
<cfelseif len(trim(cgi.request_uri)) gt 0>
    <cfset requestPath = cgi.request_uri>
<cfelse>
    <cfset requestPath = url.path>
</cfif>

<!--- Remove /ghost prefix if present --->
<cfif findNoCase("/ghost", requestPath) eq 1>
    <cfset requestPath = replaceNoCase(requestPath, "/ghost", "", "one")>
</cfif>

<!--- Remove query string if present --->
<cfif find("?", requestPath) gt 0>
    <cfset requestPath = listFirst(requestPath, "?")>
</cfif>

<!--- Remove leading slash if present --->
<cfif left(requestPath, 1) eq "/">
    <cfset requestPath = right(requestPath, len(requestPath) - 1)>
</cfif>

<!--- Remove trailing slash if present --->
<cfif right(requestPath, 1) eq "/" and len(requestPath) gt 1>
    <cfset requestPath = left(requestPath, len(requestPath) - 1)>
</cfif>

<!--- Set default path if empty --->
<!--- No longer redirecting - will serve blog at root --->

<!--- Route Matching Logic --->
<cfset routeFound = false>

<!--- Admin Routes --->
<cfif requestPath eq "admin" or requestPath eq "admin/dashboard">
    <cfset templateFile = "admin/index.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/posts">
    <cfset templateFile = "admin/posts.cfm">
    <!--- Check for type parameter in URL scope (from query string) --->
    <cfif structKeyExists(url, "type") and len(trim(url.type)) gt 0>
        <!--- Type parameter already exists from query string, keep it --->
    </cfif>
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/posts/drafts">
    <cfset templateFile = "admin/posts.cfm">
    <cfset url.type = "draft">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/posts/published">
    <cfset templateFile = "admin/posts.cfm">
    <cfset url.type = "published">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/posts/scheduled">
    <cfset templateFile = "admin/posts.cfm">
    <cfset url.type = "scheduled">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/posts/new">
    <cfset templateFile = "admin/posts/new.cfm">
    <cfset routeFound = true>

<!--- Posts edit with ID parameter - handles both /admin/posts/edit/ID and /admin/posts/edit/ID/ --->
<cfelseif reFindNoCase("^admin/posts/edit/([a-zA-Z0-9-]+)/?$", requestPath)>
    <cfset postId = reReplaceNoCase(requestPath, "^admin/posts/edit/([a-zA-Z0-9-]+)/?$", "\1")>
    <cfset url.id = postId>
    <cfset templateFile = "admin/posts/edit-ghost-style.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/pages">
    <cfset templateFile = "admin/pages.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/pages/new">
    <cfset templateFile = "admin/pages/new.cfm">
    <cfset routeFound = true>

<!--- Pages edit with ID parameter - handles both /admin/pages/edit/ID and /admin/pages/edit/ID/ --->
<cfelseif reFindNoCase("^admin/pages/edit/([a-zA-Z0-9-]+)/?$", requestPath)>
    <cfset pageId = reReplaceNoCase(requestPath, "^admin/pages/edit/([a-zA-Z0-9-]+)/?$", "\1")>
    <cfset url.id = pageId>
    <cfset url.type = "page">
    <cfset templateFile = "admin/posts/edit-ghost-style.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/tags">
    <cfset templateFile = "admin/tags.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/tags/new">
    <cfset templateFile = "admin/tags/new.cfm">
    <cfset routeFound = true>

<!--- Tags edit with ID parameter - handles both /admin/tags/edit/ID and /admin/tags/edit/ID/ --->
<cfelseif reFindNoCase("^admin/tags/edit/([a-zA-Z0-9-]+)/?$", requestPath)>
    <cfset tagId = reReplaceNoCase(requestPath, "^admin/tags/edit/([a-zA-Z0-9-]+)/?$", "\1")>
    <cfset url.id = tagId>
    <cfset templateFile = "admin/tags/edit.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/members">
    <cfset templateFile = "admin/members.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/settings">
    <cfset templateFile = "admin/settings.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/design">
    <cfset templateFile = "admin/design.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/profile">
    <cfset templateFile = "admin/profile.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/login">
    <cfset templateFile = "admin/login.cfm">
    <cfset routeFound = true>
    
<cfelseif requestPath eq "admin/logout">
    <cfset templateFile = "admin/logout.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/setup-test-user">
    <cfset templateFile = "admin/setup-test-user.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/preview-modal">
    <cfset templateFile = "admin/preview-modal.cfm">
    <cfset routeFound = true>

<!--- Settings with section parameter --->
<cfelseif reFindNoCase("^admin/settings/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset section = reReplaceNoCase(requestPath, "^admin/settings/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.section = section>
    <cfset templateFile = "admin/settings.cfm">
    <cfset routeFound = true>

<!--- Authentication Routes --->
<cfelseif requestPath eq "admin/login">
    <cfset templateFile = "admin/login.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "admin/logout">
    <cfset templateFile = "admin/logout.cfm">
    <cfset routeFound = true>

<!--- API Routes --->
<cfelseif requestPath eq "api/admin/posts">
    <cfset templateFile = "api/admin/posts.cfm">
    <cfset routeFound = true>

<!--- API Posts with ID parameter --->
<cfelseif reFindNoCase("^api/admin/posts/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset postId = reReplaceNoCase(requestPath, "^api/admin/posts/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.id = postId>
    <cfset templateFile = "api/admin/posts.cfm">
    <cfset routeFound = true>

<!--- Content API Routes --->
<cfelseif requestPath eq "api/content/posts">
    <cfset templateFile = "api/content/posts.cfm">
    <cfset routeFound = true>

<cfelseif reFindNoCase("^api/content/posts/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset postId = reReplaceNoCase(requestPath, "^api/content/posts/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.id = postId>
    <cfset templateFile = "api/content/posts.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "api/content/tags">
    <cfset templateFile = "api/content/tags.cfm">
    <cfset routeFound = true>

<cfelseif requestPath eq "api/content/authors">
    <cfset templateFile = "api/content/authors.cfm">
    <cfset routeFound = true>

<!--- Blog Routes --->
<cfelseif requestPath eq "blog" or requestPath eq "blog/index">
    <!--- Redirect old blog URLs to root --->
    <cflocation url="/ghost/" addtoken="false">
<cfelseif requestPath eq "">
    <cfset templateFile = "blog/index.cfm">
    <cfset routeFound = true>

<!--- New blog with theme support --->
<cfelseif requestPath eq "blog-new">
    <cfset templateFile = "blog/index-new.cfm">
    <cfset routeFound = true>

<!--- Blog pagination --->
<cfelseif reFindNoCase("^page/([0-9]+)$", requestPath)>
    <cfset pageNum = reReplaceNoCase(requestPath, "^page/([0-9]+)$", "\1")>
    <cfset url.page = pageNum>
    <cfset templateFile = "blog/index.cfm">
    <cfset routeFound = true>

<!--- Legacy blog pagination redirect --->
<cfelseif reFindNoCase("^blog/page/([0-9]+)$", requestPath)>
    <cfset pageNum = reReplaceNoCase(requestPath, "^blog/page/([0-9]+)$", "\1")>
    <cflocation url="/ghost/page/#pageNum#" addtoken="false">

<!--- Blog tag archive --->
<cfelseif reFindNoCase("^tag/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset tagSlug = reReplaceNoCase(requestPath, "^tag/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.slug = tagSlug>
    <cfset templateFile = "blog/tag.cfm">
    <cfset routeFound = true>

<!--- Legacy blog tag redirect --->
<cfelseif reFindNoCase("^blog/tag/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset tagSlug = reReplaceNoCase(requestPath, "^blog/tag/([a-zA-Z0-9-]+)$", "\1")>
    <cflocation url="/ghost/tag/#tagSlug#" addtoken="false">

<!--- Blog author archive --->
<cfelseif reFindNoCase("^author/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset authorSlug = reReplaceNoCase(requestPath, "^author/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.slug = authorSlug>
    <cfset templateFile = "blog/author.cfm">
    <cfset routeFound = true>

<!--- Legacy blog author redirect --->
<cfelseif reFindNoCase("^blog/author/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset authorSlug = reReplaceNoCase(requestPath, "^blog/author/([a-zA-Z0-9-]+)$", "\1")>
    <cflocation url="/ghost/author/#authorSlug#" addtoken="false">

<!--- Legacy blog post redirect --->
<cfelseif reFindNoCase("^blog/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset postSlug = reReplaceNoCase(requestPath, "^blog/([a-zA-Z0-9-]+)$", "\1")>
    <cflocation url="/ghost/#postSlug#" addtoken="false">

<!--- Individual blog post or static page --->
<cfelseif reFindNoCase("^([a-zA-Z0-9-]+)$", requestPath) AND requestPath NEQ "admin">
    <!--- First check if it's a post --->
    <cfquery name="qCheckPost" datasource="#request.dsn#">
        SELECT id, type FROM posts
        WHERE slug = <cfqueryparam value="#requestPath#" cfsqltype="cf_sql_varchar">
        AND status = 'published'
        LIMIT 1
    </cfquery>
    
    <cfif qCheckPost.recordCount>
        <cfset url.slug = requestPath>
        <cfif qCheckPost.type EQ "post">
            <cfset templateFile = "blog/post-modern.cfm">
        <cfelse>
            <cfset templateFile = "blog/page-modern.cfm">
        </cfif>
        <cfset routeFound = true>
    </cfif>

<!--- Preview route --->
<cfelseif reFindNoCase("^preview/([a-zA-Z0-9-]+)$", requestPath)>
    <cfset postId = reReplaceNoCase(requestPath, "^preview/([a-zA-Z0-9-]+)$", "\1")>
    <cfset url.id = postId>
    <cfset templateFile = "admin/preview.cfm">
    <cfset routeFound = true>

<!--- Test theme route --->
<cfelseif requestPath EQ "test-theme">
    <cfset templateFile = "test-theme.cfm">
    <cfset routeFound = true>

<!--- Test simple route --->
<cfelseif requestPath EQ "test-simple">
    <cfset templateFile = "test-simple.cfm">
    <cfset routeFound = true>

<!--- Test datasource route --->
<cfelseif requestPath EQ "test-datasource">
    <cfset templateFile = "test-datasource.cfm">
    <cfset routeFound = true>

<!--- Test theme render route --->
<cfelseif requestPath EQ "test-theme-render">
    <cfset templateFile = "test-theme-render.cfm">
    <cfset routeFound = true>

<!--- Test blog theme route --->
<cfelseif requestPath EQ "test-blog-theme">
    <cfset templateFile = "test-blog-theme.cfm">
    <cfset routeFound = true>

</cfif>

<!--- Debug output if debug mode is enabled --->
<cfif application.debugMode>
    <cfoutput>
        <!-- Debug Router Info:
        Original URI: #cgi.request_uri#
        Path Info: #url.path#  
        Original Path: #url.originalPath#
        Parsed Path: #requestPath#
        Template File: #templateFile#
        Route Found: #routeFound#
        URL Scope: #serializeJSON(url)#
        -->
    </cfoutput>
</cfif>

<!--- Handle the route --->
<cfif routeFound and len(trim(templateFile)) gt 0>
    <!--- Check if template file exists --->
    <cfset fullTemplatePath = expandPath(templateFile)>
    
    <cfif fileExists(fullTemplatePath)>
        <!--- Include the template --->
        <cfif application.debugMode>
            <cfoutput><!-- Including template: #templateFile# --></cfoutput>
        </cfif>
        <cfinclude template="#templateFile#">
    <cfelse>
        <!--- Template file not found --->
        <cfif application.debugMode>
            <cfoutput><!-- Template not found: #templateFile# (#fullTemplatePath#) --></cfoutput>
        </cfif>
        <cfinclude template="404.cfm">
    </cfif>
<cfelse>
    <!--- No route found --->
    <cfif application.debugMode>
        <cfoutput><!-- No route found for path: #requestPath# --></cfoutput>
    </cfif>
    <cfinclude template="404.cfm">
</cfif>