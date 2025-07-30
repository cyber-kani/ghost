<!--- Ghost Modern Blog Homepage with Featured Posts --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value FROM settings
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<cfset siteTitle = structKeyExists(siteSettings, "title") ? siteSettings.title : "Ghost Blog">
<cfset siteDescription = structKeyExists(siteSettings, "description") ? siteSettings.description : "A modern publishing platform">
<cfset siteLogo = structKeyExists(siteSettings, "logo") ? siteSettings.logo : "">
<cfset siteIcon = structKeyExists(siteSettings, "icon") ? siteSettings.icon : "">
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : "##0066cc">
<cfset colorScheme = structKeyExists(siteSettings, "color_scheme") ? siteSettings.color_scheme : "auto">
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- For demo purposes, let's mark posts with certain tags as featured --->
<cfset featuredTag = structKeyExists(siteSettings, "special_section_tag") ? siteSettings.special_section_tag : "featured">

<!--- Get featured posts (posts with featured tag) --->
<cfquery name="qFeaturedPosts" datasource="#request.dsn#">
    SELECT DISTINCT
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
    LEFT JOIN posts_tags pt ON p.id = pt.post_id
    LEFT JOIN tags t ON pt.tag_id = t.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    AND t.slug = <cfqueryparam value="#featuredTag#" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT 3
</cfquery>

<!--- Get recent posts (excluding featured ones) --->
<cfset postsPerPage = 12>
<cfset offset = (url.page - 1) * postsPerPage>

<cfquery name="qPosts" datasource="#request.dsn#">
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
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    <cfif qFeaturedPosts.recordCount>
        AND p.id NOT IN (
            <cfloop query="qFeaturedPosts">
                <cfqueryparam value="#qFeaturedPosts.id#" cfsqltype="cf_sql_varchar">
                <cfif qFeaturedPosts.currentRow LT qFeaturedPosts.recordCount>,</cfif>
            </cfloop>
        )
    </cfif>
    ORDER BY p.published_at DESC
    LIMIT <cfqueryparam value="#offset#" cfsqltype="cf_sql_integer">, 
          <cfqueryparam value="#postsPerPage#" cfsqltype="cf_sql_integer">
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><cfoutput>#siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#htmlEditFormat(siteDescription)#</cfoutput>">
    
    <!--- Favicon --->
    <cfif len(siteIcon)>
        <link rel="icon" href="<cfoutput>#siteIcon#</cfoutput>" type="image/png">
    </cfif>
    
    <style>
        :root {
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --bg-color: #ffffff;
            --text-color: #15171a;
            --text-secondary: #626d79;
            --border-color: #e6e9ed;
            --card-bg: #ffffff;
            --featured-bg: #fafbfc;
        }
        
        <cfif colorScheme EQ "dark">
        :root {
            --bg-color: #0e0f11;
            --text-color: #ffffff;
            --text-secondary: #a3a9b5;
            --border-color: #2b2d31;
            --card-bg: #15171a;
            --featured-bg: #0a0b0c;
        }
        <cfelseif colorScheme EQ "auto">
        @media (prefers-color-scheme: dark) {
            :root {
                --bg-color: #0e0f11;
                --text-color: #ffffff;
                --text-secondary: #a3a9b5;
                --border-color: #2b2d31;
                --card-bg: #15171a;
                --featured-bg: #0a0b0c;
            }
        }
        </cfif>
        
        * {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-color);
            color: var(--text-color);
            line-height: 1.6;
        }
        
        /* Header */
        .site-header {
            padding: 2rem 0;
            border-bottom: 1px solid var(--border-color);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1.5rem;
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .site-branding {
            display: flex;
            align-items: center;
            gap: 1rem;
            text-decoration: none;
            color: var(--text-color);
        }
        
        .site-logo {
            height: 40px;
        }
        
        .site-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
        }
        
        .site-nav {
            display: flex;
            gap: 2rem;
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .site-nav a {
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
        }
        
        .site-nav a:hover {
            color: var(--accent-color);
        }
        
        /* Featured Section */
        .featured-section {
            background: var(--featured-bg);
            padding: 4rem 0;
            margin-bottom: 4rem;
        }
        
        .featured-header {
            text-align: center;
            margin-bottom: 3rem;
        }
        
        .featured-label {
            color: var(--accent-color);
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
        }
        
        .featured-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin: 0 0 1rem;
        }
        
        .featured-description {
            font-size: 1.25rem;
            color: var(--text-secondary);
            max-width: 600px;
            margin: 0 auto;
        }
        
        .featured-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
        }
        
        .featured-card {
            background: var(--card-bg);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            text-decoration: none;
            color: var(--text-color);
            display: flex;
            flex-direction: column;
        }
        
        .featured-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.15);
        }
        
        .featured-card-image {
            aspect-ratio: 16/9;
            overflow: hidden;
            background: var(--border-color);
        }
        
        .featured-card-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        
        .featured-card:hover .featured-card-image img {
            transform: scale(1.05);
        }
        
        .featured-card-content {
            padding: 2rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .featured-card-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0 0 1rem;
            line-height: 1.3;
        }
        
        .featured-card-excerpt {
            color: var(--text-secondary);
            margin: 0 0 1.5rem;
            flex: 1;
        }
        
        .featured-card-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
        }
        
        .author-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        /* Main Content */
        .main-content {
            padding: 4rem 0;
        }
        
        .section-title {
            font-size: 2rem;
            font-weight: 700;
            margin: 0 0 3rem;
            text-align: center;
        }
        
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 2rem;
            margin-bottom: 4rem;
        }
        
        .post-card {
            background: var(--card-bg);
            border-radius: 8px;
            overflow: hidden;
            transition: all 0.3s ease;
            text-decoration: none;
            color: var(--text-color);
            display: flex;
            flex-direction: column;
            border: 1px solid var(--border-color);
        }
        
        .post-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        }
        
        .post-card-image {
            aspect-ratio: 16/9;
            overflow: hidden;
            background: var(--border-color);
        }
        
        .post-card-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .post-card-content {
            padding: 1.5rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .post-card-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin: 0 0 0.75rem;
            line-height: 1.3;
        }
        
        .post-card-excerpt {
            color: var(--text-secondary);
            font-size: 0.875rem;
            margin: 0 0 1rem;
            flex: 1;
        }
        
        .post-card-meta {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }
        
        /* Footer */
        .site-footer {
            padding: 3rem 0;
            border-top: 1px solid var(--border-color);
            text-align: center;
            color: var(--text-secondary);
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 1.5rem;
            }
            
            .featured-grid {
                grid-template-columns: 1fr;
            }
            
            .posts-grid {
                grid-template-columns: 1fr;
            }
            
            .featured-title {
                font-size: 2rem;
            }
            
            .section-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!--- Announcement Bar --->
    <cfinclude template="/ghost/includes/announcement-bar.cfm">
    
    <!--- Header --->
    <header class="site-header">
        <div class="container">
            <div class="header-content">
                <a href="/ghost/" class="site-branding">
                    <cfif len(siteLogo)>
                        <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>" class="site-logo">
                    <cfelse>
                        <h1 class="site-title"><cfoutput>#siteTitle#</cfoutput></h1>
                    </cfif>
                </a>
                
                <nav>
                    <ul class="site-nav">
                        <cfloop array="#primaryNav#" index="navItem">
                            <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                        </cfloop>
                    </ul>
                </nav>
            </div>
        </div>
    </header>
    
    <!--- Featured Posts Section --->
    <cfif qFeaturedPosts.recordCount>
        <section class="featured-section">
            <div class="container">
                <div class="featured-header">
                    <div class="featured-label">Featured</div>
                    <h2 class="featured-title">Editor's Picks</h2>
                    <p class="featured-description">The best stories, handpicked by our editorial team</p>
                </div>
                
                <div class="featured-grid">
                    <cfloop query="qFeaturedPosts">
                        <cfset cleanSlug = replace(trim(qFeaturedPosts.slug), "\", "", "all")>
                        <cfset postUrl = "/ghost/" & cleanSlug & "/">
                        
                        <a href="<cfoutput>#postUrl#</cfoutput>" class="featured-card">
                            <cfif len(trim(qFeaturedPosts.feature_image))>
                                <div class="featured-card-image">
                                    <img src="<cfoutput>#qFeaturedPosts.feature_image#</cfoutput>" 
                                         alt="<cfoutput>#htmlEditFormat(qFeaturedPosts.title)#</cfoutput>" 
                                         loading="lazy">
                                </div>
                            </cfif>
                            
                            <div class="featured-card-content">
                                <h3 class="featured-card-title"><cfoutput>#qFeaturedPosts.title#</cfoutput></h3>
                                
                                <cfset excerpt = len(trim(qFeaturedPosts.custom_excerpt)) ? qFeaturedPosts.custom_excerpt : left(qFeaturedPosts.plaintext, 160)>
                                <p class="featured-card-excerpt"><cfoutput>#excerpt#</cfoutput></p>
                                
                                <div class="featured-card-meta">
                                    <cfif len(qFeaturedPosts.author_profile_image)>
                                        <img src="<cfoutput>#qFeaturedPosts.author_profile_image#</cfoutput>" 
                                             alt="<cfoutput>#qFeaturedPosts.author_name#</cfoutput>" 
                                             class="author-avatar">
                                    </cfif>
                                    <span><cfoutput>#qFeaturedPosts.author_name#</cfoutput></span>
                                    <span>•</span>
                                    <time><cfoutput>#dateFormat(qFeaturedPosts.published_at, "mmm d, yyyy")#</cfoutput></time>
                                </div>
                            </div>
                        </a>
                    </cfloop>
                </div>
            </div>
        </section>
    </cfif>
    
    <!--- Recent Posts --->
    <main class="main-content">
        <div class="container">
            <h2 class="section-title">Latest Stories</h2>
            
            <div class="posts-grid">
                <cfloop query="qPosts">
                    <cfset cleanSlug = replace(trim(qPosts.slug), "\", "", "all")>
                    <cfset postUrl = "/ghost/" & cleanSlug & "/">
                    
                    <a href="<cfoutput>#postUrl#</cfoutput>" class="post-card">
                        <cfif len(trim(qPosts.feature_image))>
                            <div class="post-card-image">
                                <img src="<cfoutput>#qPosts.feature_image#</cfoutput>" 
                                     alt="<cfoutput>#htmlEditFormat(qPosts.title)#</cfoutput>" 
                                     loading="lazy">
                            </div>
                        </cfif>
                        
                        <div class="post-card-content">
                            <h3 class="post-card-title"><cfoutput>#qPosts.title#</cfoutput></h3>
                            
                            <cfset excerpt = len(trim(qPosts.custom_excerpt)) ? qPosts.custom_excerpt : left(qPosts.plaintext, 120)>
                            <p class="post-card-excerpt"><cfoutput>#excerpt#</cfoutput></p>
                            
                            <div class="post-card-meta">
                                <cfoutput>#qPosts.author_name# • #dateFormat(qPosts.published_at, "mmm d")#</cfoutput>
                            </div>
                        </div>
                    </a>
                </cfloop>
            </div>
            
            <!--- Pagination could go here --->
        </div>
    </main>
    
    <!--- Footer --->
    <footer class="site-footer">
        <div class="container">
            <p>&copy; <cfoutput>#year(now())# #siteTitle#</cfoutput> • Powered by Ghost</p>
        </div>
    </footer>
</body>
</html>