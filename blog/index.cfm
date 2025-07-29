<!--- Modern SEO-Optimized Blog Theme with Apple HIG --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">

<!--- Get site settings including branding --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value FROM settings
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Set defaults --->
<cfset siteTitle = structKeyExists(siteSettings, "title") ? siteSettings.title : "Ghost Blog">
<cfset siteDescription = structKeyExists(siteSettings, "description") ? siteSettings.description : "A modern publishing platform">
<cfset siteLogo = structKeyExists(siteSettings, "logo") ? siteSettings.logo : "">
<cfset siteIcon = structKeyExists(siteSettings, "icon") ? siteSettings.icon : "">
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : "##5A67D8">
<cfset showAuthor = structKeyExists(siteSettings, "show_author") ? siteSettings.show_author : "true">
<cfset headingFont = structKeyExists(siteSettings, "heading_font") ? siteSettings.heading_font : "sans-serif">
<cfset bodyFont = structKeyExists(siteSettings, "body_font") ? siteSettings.body_font : "sans-serif">
<cfset colorScheme = structKeyExists(siteSettings, "color_scheme") ? siteSettings.color_scheme : "auto">
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "https://clitools.app">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Pagination setup --->
<cfset postsPerPage = 12>
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
        u.profile_image as author_profile_image,
        u.bio as author_bio
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT #postsPerPage# OFFSET #startRow - 1#
</cfquery>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <!--- SEO Meta Tags --->
    <title><cfoutput>#siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput></title>
    <meta name="description" content="<cfoutput>#siteDescription#</cfoutput>">
    <link rel="canonical" href="<cfoutput>/ghost/blog/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="website">
    <meta property="og:title" content="<cfoutput>#siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput>">
    <meta property="og:description" content="<cfoutput>#siteDescription#</cfoutput>">
    <meta property="og:url" content="<cfoutput>/ghost/blog/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
    <cfif len(coverImage)>
        <meta property="og:image" content="<cfoutput>#siteUrl##coverImage#</cfoutput>">
    </cfif>
    
    <!--- Twitter Card --->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<cfoutput>#siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput>">
    <meta name="twitter:description" content="<cfoutput>#siteDescription#</cfoutput>">
    <cfif len(coverImage)>
        <meta name="twitter:image" content="<cfoutput>#siteUrl##coverImage#</cfoutput>">
    </cfif>
    
    <!--- Favicon --->
    <cfif len(siteIcon)>
        <link rel="icon" href="<cfoutput>#siteIcon#</cfoutput>" type="image/png">
        <link rel="apple-touch-icon" href="<cfoutput>#siteIcon#</cfoutput>">
    </cfif>
    
    <!--- Structured Data --->
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "Blog",
        "name": "<cfoutput>#siteTitle#</cfoutput>",
        "description": "<cfoutput>#siteDescription#</cfoutput>",
        "url": "<cfoutput>/ghost/blog/</cfoutput>",
        "publisher": {
            "@type": "Organization",
            "name": "<cfoutput>#siteTitle#</cfoutput>",
            "logo": {
                "@type": "ImageObject",
                "url": "<cfoutput>#siteUrl##siteLogo#</cfoutput>"
            }
        }
    }
    </script>
    
    <!--- Google Fonts --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Merriweather:wght@300;400;700&family=Roboto+Slab:wght@300;400;700&family=Playfair+Display:wght@400;700;900&family=Lora:wght@400;500;700&family=Source+Sans+3:wght@400;600;700&family=Raleway:wght@400;600;700&family=Libre+Baskerville:wght@400;700&display=swap" rel="stylesheet">
    
    <!--- Modern CSS with Apple HIG principles --->
    <style>
        <cfif headingFont EQ "sans-serif">
            <cfset headingFontFamily = "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif">
        <cfelseif headingFont EQ "serif">
            <cfset headingFontFamily = "'Merriweather', Georgia, 'Times New Roman', serif">
        <cfelseif headingFont EQ "slab">
            <cfset headingFontFamily = "'Roboto Slab', Georgia, serif">
        <cfelse>
            <cfset headingFontFamily = "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif">
        </cfif>
        
        <cfif bodyFont EQ "sans-serif">
            <cfset bodyFontFamily = "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif">
        <cfelseif bodyFont EQ "serif">
            <cfset bodyFontFamily = "'Merriweather', Georgia, 'Times New Roman', serif">
        <cfelse>
            <cfset bodyFontFamily = "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif">
        </cfif>
        
        :root {
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --text-primary: #1a1a1a;
            --text-secondary: #6b7280;
            --bg-primary: #ffffff;
            --bg-secondary: #f9fafb;
            --border-color: #e5e7eb;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --radius-sm: 0.375rem;
            --radius-md: 0.5rem;
            --radius-lg: 0.75rem;
            --transition: all 0.2s ease;
            --font-heading: <cfoutput>#headingFontFamily#</cfoutput>;
            --font-body: <cfoutput>#bodyFontFamily#</cfoutput>;
        }
        
        <cfif colorScheme EQ "dark">
            /* Force dark mode */
            :root {
                --text-primary: #f3f4f6;
                --text-secondary: #9ca3af;
                --bg-primary: #111827;
                --bg-secondary: #1f2937;
                --border-color: #374151;
            }
        <cfelseif colorScheme EQ "auto">
            @media (prefers-color-scheme: dark) {
                :root {
                    --text-primary: #f3f4f6;
                    --text-secondary: #9ca3af;
                    --bg-primary: #111827;
                    --bg-secondary: #1f2937;
                    --border-color: #374151;
                }
            }
        </cfif>
        
        * {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            font-family: var(--font-body);
            font-size: 16px;
            line-height: 1.6;
            color: var(--text-primary);
            background-color: var(--bg-primary);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Header */
        .site-header {
            border-bottom: 1px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 40;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }
        
        <cfif colorScheme EQ "light">
            .site-header {
                background-color: rgba(255, 255, 255, 0.9);
            }
        <cfelseif colorScheme EQ "dark">
            .site-header {
                background-color: rgba(17, 24, 39, 0.9);
            }
        <cfelse>
            .site-header {
                background-color: rgba(255, 255, 255, 0.9);
            }
            @media (prefers-color-scheme: dark) {
                .site-header {
                    background-color: rgba(17, 24, 39, 0.9);
                }
            }
        </cfif>
        
        .header-inner {
            max-width: 1200px;
            margin: 0 auto;
            padding: 1rem 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .site-logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: var(--text-primary);
            font-size: 1.25rem;
            font-weight: 700;
        }
        
        .site-logo img {
            height: 40px;
            width: auto;
        }
        
        /* Navigation */
        .site-nav {
            display: flex;
            gap: 2rem;
            align-items: center;
        }
        
        .nav-menu {
            display: flex;
            list-style: none;
            margin: 0;
            padding: 0;
            gap: 2rem;
        }
        
        .nav-menu a {
            color: var(--text-secondary);
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
            font-size: 0.9375rem;
        }
        
        .nav-menu a:hover {
            color: var(--accent-color);
        }
        
        /* Hero Section */
        .hero-section {
            position: relative;
            background-color: var(--bg-secondary);
            padding: 4rem 1.5rem;
            text-align: center;
            <cfif len(coverImage)>
            background-image: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4)), url('<cfoutput>#coverImage#</cfoutput>');
            background-size: cover;
            background-position: center;
            color: white;
            </cfif>
        }
        
        .hero-content {
            max-width: 800px;
            margin: 0 auto;
        }
        
        .hero-title {
            font-size: 3rem;
            font-weight: 800;
            margin: 0 0 1rem;
            line-height: 1.2;
        }
        
        .hero-description {
            font-size: 1.25rem;
            margin: 0;
            opacity: 0.9;
        }
        
        /* Main Content */
        .main-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 4rem 1.5rem;
        }
        
        /* Posts Grid */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 2rem;
            margin-bottom: 4rem;
        }
        
        /* Post Card */
        .post-card {
            background-color: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            overflow: hidden;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        
        .post-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            border-color: var(--accent-color);
        }
        
        .post-card-link {
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        
        .post-card-image {
            position: relative;
            padding-top: 56.25%; /* 16:9 aspect ratio */
            background-color: var(--bg-secondary);
            overflow: hidden;
        }
        
        .post-card-image img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition);
        }
        
        .post-card:hover .post-card-image img {
            transform: scale(1.05);
        }
        
        .post-card-content {
            padding: 1.5rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .post-card-tags {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 0.75rem;
            flex-wrap: wrap;
        }
        
        .post-tag {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 500;
            color: white;
            background-color: var(--accent-color);
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            text-decoration: none;
            transition: var(--transition);
        }
        
        .post-tag:hover {
            background-color: var(--accent-color);
            color: white;
            opacity: 0.9;
            transform: translateY(-1px);
        }
        
        .post-card-title {
            font-size: 1.25rem;
            font-weight: 700;
            line-height: 1.4;
            margin: 0 0 0.75rem;
            flex: 1;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .post-card-excerpt {
            font-size: 0.9375rem;
            color: var(--text-secondary);
            line-height: 1.6;
            margin: 0 0 1rem;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .post-card-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
            margin-top: auto;
        }
        
        .post-author {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .author-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: var(--accent-color);
            flex-shrink: 0;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 600;
            color: white;
            text-transform: uppercase;
            position: relative;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .post-meta-divider {
            color: var(--border-color);
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
        }
        
        .pagination a,
        .pagination span {
            padding: 0.5rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 500;
            transition: var(--transition);
        }
        
        .pagination a:hover {
            background-color: var(--accent-color);
            color: white;
            border-color: var(--accent-color);
        }
        
        .pagination .current {
            background-color: var(--accent-color);
            color: white;
            border-color: var(--accent-color);
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-secondary);
            border-top: 1px solid var(--border-color);
            padding: 3rem 1.5rem;
            text-align: center;
        }
        
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .footer-nav {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        
        .footer-nav a {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9375rem;
            transition: var(--transition);
        }
        
        .footer-nav a:hover {
            color: var(--accent-color);
        }
        
        .footer-copyright {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        
        /* Mobile Menu */
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            cursor: pointer;
            padding: 0.5rem;
        }
        
        @media (max-width: 768px) {
            .nav-menu {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .hero-title {
                font-size: 2rem;
            }
            
            .posts-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
        }
        
        /* Accessibility */
        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border-width: 0;
        }
        
        /* Loading skeleton */
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        .skeleton {
            background-color: var(--bg-secondary);
            position: relative;
            overflow: hidden;
        }
        
        .skeleton::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            animation: shimmer 1.5s infinite;
        }
    </style>
    
    <!--- Code Injection Head --->
    <cfif len(codeInjectionHead)>
        <cfoutput>#codeInjectionHead#</cfoutput>
    </cfif>
</head>
<body>
    <!--- Header --->
    <header class="site-header" role="banner">
        <div class="header-inner">
            <a href="/ghost/blog/" class="site-logo">
                <cfif len(siteLogo)>
                    <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>" loading="lazy">
                <cfelse>
                    <cfoutput>#siteTitle#</cfoutput>
                </cfif>
            </a>
            
            <nav class="site-nav" role="navigation">
                <ul class="nav-menu">
                    <cfloop array="#primaryNav#" index="navItem">
                        <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                    </cfloop>
                </ul>
                
                <button class="mobile-menu-toggle" aria-label="Menu">
                    <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 12h18M3 6h18M3 18h18"/>
                    </svg>
                </button>
            </nav>
        </div>
    </header>
    
    <!--- Hero Section --->
    <cfif url.page EQ 1>
        <section class="hero-section">
            <div class="hero-content">
                <h1 class="hero-title"><cfoutput>#siteTitle#</cfoutput></h1>
                <p class="hero-description"><cfoutput>#siteDescription#</cfoutput></p>
            </div>
        </section>
    </cfif>
    
    <!--- Main Content --->
    <main class="main-content" role="main">
        <h2 class="sr-only">Latest Posts</h2>
        
        <!--- Posts Grid --->
        <div class="posts-grid">
            <cfoutput query="qPosts">
                <!--- Get tags for this post --->
                <cfquery name="qPostTags" datasource="#request.dsn#">
                    SELECT t.id, t.name, t.slug
                    FROM tags t
                    INNER JOIN posts_tags pt ON t.id = pt.tag_id
                    WHERE pt.post_id = <cfqueryparam value="#qPosts.id#" cfsqltype="cf_sql_varchar">
                    ORDER BY t.name
                    LIMIT 3
                </cfquery>
                
                <!--- Create excerpt --->
                <cfset excerpt = "">
                <cfif len(trim(qPosts.custom_excerpt))>
                    <cfset excerpt = qPosts.custom_excerpt>
                <cfelseif len(trim(qPosts.plaintext))>
                    <cfset excerpt = left(qPosts.plaintext, 160)>
                    <cfif len(qPosts.plaintext) GT 160>
                        <cfset excerpt = excerpt & "...">
                    </cfif>
                </cfif>
                
                <!--- Calculate reading time --->
                <cfset wordCount = listLen(qPosts.plaintext, " ")>
                <cfset readingTime = ceiling(wordCount / 200)>
                <cfif readingTime EQ 0>
                    <cfset readingTime = 1>
                </cfif>
                
                <article class="post-card">
                    <a href="/ghost/blog/#qPosts.slug#/" class="post-card-link">
                        <cfif len(trim(qPosts.feature_image))>
                            <div class="post-card-image">
                                <img src="#qPosts.feature_image#" 
                                     alt="#htmlEditFormat(qPosts.title)#" 
                                     loading="lazy"
                                     width="680"
                                     height="383">
                            </div>
                        </cfif>
                        
                        <div class="post-card-content">
                            <cfif qPostTags.recordCount GT 0>
                                <div class="post-card-tags">
                                    <cfloop query="qPostTags">
                                        <span class="post-tag">#qPostTags.name#</span>
                                    </cfloop>
                                </div>
                            </cfif>
                            
                            <h3 class="post-card-title">#qPosts.title#</h3>
                            
                            <cfif len(excerpt)>
                                <p class="post-card-excerpt">#excerpt#</p>
                            </cfif>
                            
                            <div class="post-card-meta">
                                <cfif showAuthor EQ "true">
                                    <div class="post-author">
                                        <div class="author-avatar">
                                            <cfif len(trim(qPosts.author_profile_image))>
                                                <img src="#qPosts.author_profile_image#" 
                                                     alt="#qPosts.author_name#" 
                                                     loading="lazy">
                                            <cfelse>
                                                #left(qPosts.author_name, 1)#
                                            </cfif>
                                        </div>
                                        <span>#qPosts.author_name#</span>
                                    </div>
                                    <span class="post-meta-divider">•</span>
                                </cfif>
                                <time datetime="#dateFormat(qPosts.published_at, 'yyyy-mm-dd')#">
                                    #dateFormat(qPosts.published_at, 'mmm dd, yyyy')#
                                </time>
                                <span class="post-meta-divider">•</span>
                                <span>#readingTime# min read</span>
                            </div>
                        </div>
                    </a>
                </article>
            </cfoutput>
        </div>
        
        <!--- Pagination --->
        <cfif totalPages GT 1>
            <nav class="pagination" role="navigation" aria-label="Pagination">
                <cfif url.page GT 1>
                    <a href="?page=#url.page - 1#" rel="prev">← Previous</a>
                </cfif>
                
                <cfloop from="1" to="#totalPages#" index="i">
                    <cfif i EQ url.page>
                        <span class="current" aria-current="page">#i#</span>
                    <cfelse>
                        <a href="?page=#i#">#i#</a>
                    </cfif>
                </cfloop>
                
                <cfif url.page LT totalPages>
                    <a href="?page=#url.page + 1#" rel="next">Next →</a>
                </cfif>
            </nav>
        </cfif>
    </main>
    
    <!--- Footer --->
    <footer class="site-footer" role="contentinfo">
        <div class="footer-content">
            <cfif arrayLen(secondaryNav) GT 0>
                <nav class="footer-nav">
                    <cfloop array="#secondaryNav#" index="navItem">
                        <a href="#navItem.url#">#navItem.label#</a>
                    </cfloop>
                </nav>
            </cfif>
            
            <div class="footer-copyright">
                &copy; <cfoutput>#year(now())# #siteTitle#</cfoutput> • Powered by Ghost CFML
            </div>
        </div>
    </footer>
    
    <!--- Code Injection Foot --->
    <cfif len(codeInjectionFoot)>
        <cfoutput>#codeInjectionFoot#</cfoutput>
    </cfif>
    
    <!--- Mobile Menu Script --->
    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            const menu = document.querySelector('.nav-menu');
            menu.style.display = menu.style.display === 'flex' ? 'none' : 'flex';
            menu.style.position = 'absolute';
            menu.style.top = '100%';
            menu.style.right = '0';
            menu.style.background = 'var(--bg-primary)';
            menu.style.flexDirection = 'column';
            menu.style.padding = '1rem';
            menu.style.border = '1px solid var(--border-color)';
            menu.style.borderRadius = 'var(--radius-md)';
            menu.style.boxShadow = 'var(--shadow-lg)';
        });
        
        // Lazy loading for images
        if ('loading' in HTMLImageElement.prototype) {
            const images = document.querySelectorAll('img[loading="lazy"]');
            images.forEach(img => {
                img.src = img.src;
            });
        }
    </script>
</body>
</html>