<!--- Simple Blog Post Renderer without Complex Handlebars --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">

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

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value
    FROM settings
    WHERE `key` IN ('site_title', 'site_description', 'site_url', 'site_icon', 'active_theme')
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<cfset siteTitle = structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML">
<cfset siteDescription = structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost">
<cfset activeTheme = structKeyExists(siteSettings, "active_theme") ? siteSettings.active_theme : "default">

<!--- Include theme styles --->
<cfinclude template="/ghost/admin/includes/theme-styles.cfm">
<cfset themeStyles = getThemeStyles(activeTheme)>

<!--- Process content to replace Ghost image URLs --->
<cfset postContent = qPost.html>
<cfset postContent = replace(postContent, "__GHOST_URL__", "/ghost", "all")>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><cfoutput>#qPost.title# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#len(qPost.custom_excerpt) ? qPost.custom_excerpt : left(reReplace(qPost.html, "<[^>]*>", "", "all"), 160)#</cfoutput>" />
    <link rel="canonical" href="<cfoutput>#siteUrl#/blog/#qPost.slug#/</cfoutput>" />
    
    <style>
        * {
            box-sizing: border-box;
        }
        
        <cfoutput>#themeStyles#</cfoutput>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0 20px;
            background: #f5f5f5;
        }
        header {
            background: white;
            margin-bottom: 30px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            width: 100%;
            margin-left: -20px;
            margin-right: -20px;
            padding-left: 20px;
            padding-right: 20px;
        }
        .header-inner {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
        }
        .header-left {
            flex: 1;
        }
        .content-wrapper {
            max-width: 1200px;
            margin: 0 auto;
        }
        nav ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        nav li {
            display: inline-block;
            margin-right: 20px;
        }
        nav a {
            color: #333;
            text-decoration: none;
            font-weight: 500;
        }
        nav a:hover {
            color: #0066cc;
        }
        main {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            min-height: 400px;
            width: 100%;
        }
        footer {
            text-align: center;
            padding: 40px 20px;
            color: #666;
            font-size: 0.9em;
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            margin: 0;
            font-size: 2em;
        }
        .site-title {
            color: #333;
            text-decoration: none;
        }
        .site-description {
            color: #666;
            margin: 5px 0 0 0;
            font-size: 1.1em;
        }
        .post-header {
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .post-feature-image {
            margin: -40px -40px 40px -40px;
            overflow: hidden;
            border-radius: 8px 8px 0 0;
        }
        .post-feature-image img {
            width: 100%;
            height: auto;
            display: block;
        }
        .post-title {
            margin: 0 0 20px 0;
            font-size: 2.5em;
            line-height: 1.2;
        }
        .post-meta {
            color: #666;
            font-size: 0.95em;
        }
        .post-meta .author {
            font-weight: 500;
            color: #333;
        }
        .post-content {
            font-size: 1.1em;
            line-height: 1.8;
        }
        .post-content h1, .post-content h2, .post-content h3,
        .post-content h4, .post-content h5, .post-content h6 {
            margin: 30px 0 15px 0;
        }
        .post-content p {
            margin: 0 0 20px 0;
        }
        .post-content img {
            max-width: 100%;
            height: auto;
            margin: 20px 0;
        }
        .post-content blockquote {
            border-left: 4px solid #ddd;
            padding-left: 20px;
            margin: 20px 0;
            color: #666;
            font-style: italic;
        }
        .post-content pre {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        .post-content code {
            background: #f5f5f5;
            padding: 2px 5px;
            border-radius: 3px;
            font-size: 0.9em;
        }
        .post-tags {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .post-tag {
            display: inline-block;
            background: #f0f0f0;
            color: #666;
            padding: 6px 15px;
            border-radius: 3px;
            font-size: 0.9em;
            text-decoration: none;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        .post-tag:hover {
            background: #e0e0e0;
        }
        .back-link {
            display: inline-block;
            margin-top: 40px;
            color: #0066cc;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .header-inner {
                flex-direction: column;
                text-align: center;
            }
            .header-left {
                margin-bottom: 20px;
            }
            main {
                padding: 20px;
            }
            .post-title {
                font-size: 2em;
            }
            .post-feature-image {
                margin: -20px -20px 30px -20px;
            }
        }
    </style>
    
    <!-- Ghost Head -->
    <meta name="generator" content="Ghost CFML" />
</head>
<body class="post-template">
    <header>
        <div class="header-inner">
            <div class="header-left">
                <h1><a href="<cfoutput>#siteUrl#</cfoutput>" class="site-title"><cfoutput>#siteTitle#</cfoutput></a></h1>
                <cfif len(siteDescription)>
                    <p class="site-description"><cfoutput>#siteDescription#</cfoutput></p>
                </cfif>
            </div>
            <nav>
                <ul class="nav">
                    <li class="nav-home"><a href="/ghost/blog/">Home</a></li>
                    <li><a href="/ghost/admin/">Admin</a></li>
                </ul>
            </nav>
        </div>
    </header>
    
    <div class="content-wrapper">
    <main>
        <article class="post">
            <header class="post-header">
                <h1 class="post-title"><cfoutput>#qPost.title#</cfoutput></h1>
                <div class="post-meta">
                    <cfif len(qPost.author_name)>
                        By <span class="author"><cfoutput>#qPost.author_name#</cfoutput></span>
                    </cfif>
                    <cfif NOT isNull(qPost.published_at)>
                        on <cfoutput>#dateFormat(qPost.published_at, "mmmm d, yyyy")#</cfoutput>
                    </cfif>
                </div>
            </header>
            
            <cfif len(trim(qPost.feature_image))>
                <cfset featureImageUrl = replace(qPost.feature_image, "__GHOST_URL__", "/ghost", "all")>
                <div class="post-feature-image">
                    <img src="<cfoutput>#featureImageUrl#</cfoutput>" alt="<cfoutput>#qPost.title#</cfoutput>" loading="lazy">
                </div>
            </cfif>
            
            <div class="post-content">
                <cfoutput>#postContent#</cfoutput>
            </div>
            
            <cfif qPostTags.recordCount GT 0>
                <div class="post-tags">
                    <cfloop query="qPostTags">
                        <a href="/ghost/blog/tag/<cfoutput>#qPostTags.slug#</cfoutput>/" class="post-tag"><cfoutput>#qPostTags.name#</cfoutput></a>
                    </cfloop>
                </div>
            </cfif>
        </article>
        
        <a href="/ghost/blog/" class="back-link">&larr; Back to all posts</a>
    </main>
    </div>
    
    <footer>
        &copy; <cfoutput>#year(now())#</cfoutput> <cfoutput>#siteTitle#</cfoutput> &middot; 
        <a href="https://ghost.org" target="_blank" rel="noopener">Powered by Ghost</a>
    </footer>
    
    <!-- Ghost Foot -->
</body>
</html>