<!--- Simple Blog Renderer without Complex Handlebars --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">

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
    WHERE `key` IN ('site_title', 'site_description', 'site_url', 'site_icon')
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<cfset siteTitle = structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML">
<cfset siteDescription = structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><cfoutput>#siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#siteDescription#</cfoutput>" />
    <link rel="canonical" href="<cfoutput>#siteUrl#/blog/</cfoutput>" />
    
    <style>
        * {
            box-sizing: border-box;
        }
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
        .post-feed {
            display: grid;
            gap: 30px;
        }
        .post-card {
            border-bottom: 1px solid #eee;
            padding-bottom: 30px;
        }
        .post-card:last-child {
            border-bottom: none;
        }
        .post-card h2 {
            margin: 0 0 10px 0;
        }
        .post-card h2 a {
            color: #333;
            text-decoration: none;
        }
        .post-card h2 a:hover {
            color: #0066cc;
        }
        .post-meta {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 15px;
        }
        .post-excerpt {
            color: #555;
            line-height: 1.6;
        }
        .post-tags {
            margin-top: 15px;
        }
        .post-tag {
            display: inline-block;
            background: #f0f0f0;
            color: #666;
            padding: 5px 12px;
            border-radius: 3px;
            font-size: 0.85em;
            text-decoration: none;
            margin-right: 10px;
        }
        .post-tag:hover {
            background: #e0e0e0;
        }
        .pagination {
            margin-top: 40px;
            text-align: center;
        }
        .pagination a, .pagination span {
            display: inline-block;
            padding: 8px 16px;
            margin: 0 5px;
            background: #f0f0f0;
            color: #333;
            text-decoration: none;
            border-radius: 3px;
        }
        .pagination a:hover {
            background: #e0e0e0;
        }
        .pagination .current {
            background: #333;
            color: white;
        }
        .no-posts {
            text-align: center;
            color: #666;
            padding: 60px 0;
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
            .post-tag {
                margin-bottom: 5px;
            }
        }
    </style>
    
    <!-- Ghost Head -->
    <meta name="generator" content="Ghost CFML" />
</head>
<body class="home-template">
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
        <div class="post-feed">
            <cfif qPosts.recordCount GT 0>
                <cfoutput query="qPosts">
                    <!--- Get tags for this post --->
                    <cfquery name="qPostTags" datasource="#request.dsn#">
                        SELECT t.id, t.name, t.slug
                        FROM tags t
                        INNER JOIN posts_tags pt ON t.id = pt.tag_id
                        WHERE pt.post_id = <cfqueryparam value="#qPosts.id#" cfsqltype="cf_sql_varchar">
                        ORDER BY t.name
                    </cfquery>
                    
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
                    
                    <article class="post-card">
                        <h2><a href="/ghost/blog/#qPosts.slug#/">#qPosts.title#</a></h2>
                        <div class="post-meta">
                            <cfif len(qPosts.author_name)>
                                By #qPosts.author_name# &middot; 
                            </cfif>
                            #dateFormat(qPosts.published_at, "mmm dd, yyyy")#
                        </div>
                        <cfif len(excerpt)>
                            <div class="post-excerpt">
                                #excerpt#
                            </div>
                        </cfif>
                        <cfif qPostTags.recordCount GT 0>
                            <div class="post-tags">
                                <cfloop query="qPostTags">
                                    <a href="/ghost/blog/tag/#qPostTags.slug#/" class="post-tag">#qPostTags.name#</a>
                                </cfloop>
                            </div>
                        </cfif>
                    </article>
                </cfoutput>
            <cfelse>
                <div class="no-posts">
                    <h2>No posts found</h2>
                    <p>There are no published posts to display.</p>
                </div>
            </cfif>
        </div>
        
        <cfif totalPages GT 1>
            <nav class="pagination">
                <cfif url.page GT 1>
                    <a href="?page=<cfoutput>#url.page - 1#</cfoutput>">Previous</a>
                </cfif>
                
                <cfloop from="1" to="#totalPages#" index="i">
                    <cfif i EQ url.page>
                        <span class="current"><cfoutput>#i#</cfoutput></span>
                    <cfelse>
                        <a href="?page=<cfoutput>#i#</cfoutput>"><cfoutput>#i#</cfoutput></a>
                    </cfif>
                </cfloop>
                
                <cfif url.page LT totalPages>
                    <a href="?page=<cfoutput>#url.page + 1#</cfoutput>">Next</a>
                </cfif>
            </nav>
        </cfif>
    </main>
    </div>
    
    <footer>
        &copy; <cfoutput>#year(now())#</cfoutput> <cfoutput>#siteTitle#</cfoutput> &middot; 
        <a href="https://ghost.org" target="_blank" rel="noopener">Powered by Ghost</a>
    </footer>
    
    <!-- Ghost Foot -->
</body>
</html>