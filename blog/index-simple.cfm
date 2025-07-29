<!--- Simplified Blog Index --->
<cfparam name="request.dsn" default="ghost_prod">
<cfparam name="url.page" default="1">

<!--- Get posts --->
<cfquery name="qPosts" datasource="#request.dsn#">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.custom_excerpt,
        p.plaintext,
        p.feature_image,
        p.published_at,
        p.created_by as author_id,
        u.name as author_name,
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT 10
</cfquery>

<!--- Build posts array --->
<cfset posts = []>
<cfloop query="qPosts">
    <cfset post = {
        "id": qPosts.id,
        "title": qPosts.title,
        "url": "/ghost/blog/" & qPosts.slug & "/",
        "excerpt": len(trim(qPosts.custom_excerpt)) ? qPosts.custom_excerpt : left(qPosts.plaintext, 200) & "...",
        "feature_image": qPosts.feature_image,
        "author": {
            "name": qPosts.author_name,
            "profile_image": qPosts.author_profile_image
        },
        "date": qPosts.published_at,
        "post_class": ""
    }>
    <cfset arrayAppend(posts, post)>
</cfloop>

<!--- Simple template --->
<cfset simpleTemplate = '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ghost CFML Blog</title>
    <link rel="stylesheet" href="{{asset "css/style.css"}}">
</head>
<body class="home-template">
    <div class="site-wrapper">
        <header class="site-header">
            <div class="container">
                <div class="site-header-inner">
                    <div class="site-brand">
                        <h1 class="site-title">
                            <a href="/ghost/blog/">{{@site.title}}</a>
                        </h1>
                        <p class="site-description">{{@site.description}}</p>
                    </div>
                </div>
            </div>
        </header>

        <main class="site-main">
            <div class="container">
                <div class="post-feed">
                    {{##foreach posts}}
                        <article class="post-card {{post_class}}">
                            {{##if feature_image}}
                                <a class="post-card-image-link" href="{{url}}">
                                    <img class="post-card-image" src="{{feature_image}}" alt="{{title}}">
                                </a>
                            {{/if}}
                            
                            <div class="post-card-content">
                                <a class="post-card-content-link" href="{{url}}">
                                    <header class="post-card-header">
                                        <h2 class="post-card-title">{{title}}</h2>
                                    </header>
                                    
                                    {{##if excerpt}}
                                        <div class="post-card-excerpt">
                                            <p>{{excerpt}}</p>
                                        </div>
                                    {{/if}}
                                </a>
                                
                                <footer class="post-card-meta">
                                    <div class="post-card-author">
                                        <span class="post-card-author-name">{{author.name}}</span>
                                    </div>
                                    <time class="post-card-date">
                                        {{date}}
                                    </time>
                                </footer>
                            </div>
                        </article>
                    {{/foreach}}
                </div>
            </div>
        </main>

        <footer class="site-footer">
            <div class="container">
                <div class="site-footer-content">
                    <p>&copy; {{date format="YYYY"}} {{@site.title}}. All rights reserved.</p>
                </div>
            </div>
        </footer>
    </div>
</body>
</html>'>

<!--- Context --->
<cfset context = {
    "posts": posts,
    "site": {
        "title": "Ghost CFML Blog",
        "description": "A simple publishing platform",
        "url": "https://clitools.app"
    },
    "theme": {
        "name": "default",
        "path": "/ghost/themes/default/"
    }
}>

<!--- Include handlebars functions and process --->
<cfinclude template="/ghost/admin/includes/handlebars-functions.cfm">

<cftry>
    <cfset output = processHandlebarsTemplate(simpleTemplate, context)>
    <cfcontent reset="true">
    <cfoutput>#output#</cfoutput>
<cfcatch>
    <cfcontent reset="true">
    <cfoutput>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Error</title>
        <style>
            body { font-family: Arial, sans-serif; padding: 20px; }
            .error { background: ##fee; padding: 20px; }
        </style>
    </head>
    <body>
        <div class="error">
            <h1>Template Processing Error</h1>
            <p>#cfcatch.message#</p>
            <p>#cfcatch.detail#</p>
        </div>
    </body>
    </html>
    </cfoutput>
</cfcatch>
</cftry>