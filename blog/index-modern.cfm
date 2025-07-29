<!--- Modern Blog Theme Inspired by The King's Trust --->
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
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : "##E4002B">
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "https://clitools.app">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Pagination setup --->
<cfset postsPerPage = 9>
<cfset startRow = ((url.page - 1) * postsPerPage) + 1>

<!--- Get featured post for hero --->
<cfquery name="qFeaturedPost" datasource="#request.dsn#" maxrows="1">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.custom_excerpt,
        p.plaintext,
        p.feature_image,
        p.published_at,
        p.created_by as author_id,
        u.name as author_name
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    AND p.featured = 1
    ORDER BY p.published_at DESC
</cfquery>

<!--- Get total post count --->
<cfquery name="qPostCount" datasource="#request.dsn#">
    SELECT COUNT(*) as total
    FROM posts
    WHERE status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    <cfif qFeaturedPost.recordCount GT 0>
        AND id != <cfqueryparam value="#qFeaturedPost.id#" cfsqltype="cf_sql_varchar">
    </cfif>
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
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    <cfif qFeaturedPost.recordCount GT 0 AND url.page EQ 1>
        AND p.id != <cfqueryparam value="#qFeaturedPost.id#" cfsqltype="cf_sql_varchar">
    </cfif>
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
    <link rel="canonical" href="<cfoutput>#siteUrl#/ghost/blog/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="website">
    <meta property="og:title" content="<cfoutput>#siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput>">
    <meta property="og:description" content="<cfoutput>#siteDescription#</cfoutput>">
    <meta property="og:url" content="<cfoutput>#siteUrl#/ghost/blog/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
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
    
    <!--- Modern CSS inspired by The King's Trust --->
    <style>
        :root {
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --text-primary: #1a1a1a;
            --text-secondary: #666666;
            --text-light: #999999;
            --bg-primary: #ffffff;
            --bg-secondary: #f8f8f8;
            --bg-dark: #1a1a1a;
            --border-color: #e0e0e0;
            --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.08);
            --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.12);
            --shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.16);
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --max-width: 1400px;
            --header-height: 80px;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            font-size: 16px;
            line-height: 1.6;
            color: var(--text-primary);
            background-color: var(--bg-primary);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Header - King's Trust Style */
        .site-header {
            background-color: var(--bg-primary);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            box-shadow: 0 1px 0 rgba(0, 0, 0, 0.1);
            transition: var(--transition);
        }
        
        .header-inner {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 0 2rem;
            height: var(--header-height);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .site-logo {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--text-primary);
            font-size: 1.5rem;
            font-weight: 700;
            letter-spacing: -0.02em;
        }
        
        .site-logo img {
            height: 48px;
            width: auto;
        }
        
        /* Navigation */
        .site-nav {
            display: flex;
            align-items: center;
            gap: 3rem;
        }
        
        .nav-menu {
            display: flex;
            list-style: none;
            gap: 2.5rem;
        }
        
        .nav-menu a {
            color: var(--text-primary);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9375rem;
            letter-spacing: 0.01em;
            transition: var(--transition);
            position: relative;
        }
        
        .nav-menu a::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            width: 0;
            height: 2px;
            background-color: var(--accent-color);
            transition: width 0.3s ease;
        }
        
        .nav-menu a:hover::after {
            width: 100%;
        }
        
        .nav-cta {
            background-color: var(--accent-color);
            color: white;
            padding: 0.75rem 1.75rem;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9375rem;
            transition: var(--transition);
            border: 2px solid var(--accent-color);
        }
        
        .nav-cta:hover {
            background-color: transparent;
            color: var(--accent-color);
        }
        
        /* Hero Section - Featured Post */
        .hero-section {
            margin-top: var(--header-height);
            background-color: var(--bg-secondary);
            position: relative;
            overflow: hidden;
        }
        
        .hero-inner {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 5rem 2rem;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            align-items: center;
        }
        
        .hero-content {
            z-index: 1;
        }
        
        .hero-tag {
            display: inline-block;
            background-color: var(--accent-color);
            color: white;
            padding: 0.375rem 1rem;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            letter-spacing: -0.03em;
            color: var(--text-primary);
        }
        
        .hero-excerpt {
            font-size: 1.25rem;
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 2rem;
        }
        
        .hero-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.9375rem;
            color: var(--text-secondary);
            margin-bottom: 2rem;
        }
        
        .hero-cta {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            background-color: var(--text-primary);
            color: white;
            padding: 1rem 2rem;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: var(--transition);
        }
        
        .hero-cta:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        
        .hero-cta svg {
            width: 20px;
            height: 20px;
            transition: transform 0.3s ease;
        }
        
        .hero-cta:hover svg {
            transform: translateX(4px);
        }
        
        .hero-image {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: var(--shadow-lg);
        }
        
        .hero-image img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        /* Main Content */
        .main-content {
            padding: 5rem 0;
        }
        
        .content-inner {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        /* Section Header */
        .section-header {
            text-align: center;
            margin-bottom: 4rem;
        }
        
        .section-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            letter-spacing: -0.02em;
        }
        
        .section-subtitle {
            font-size: 1.125rem;
            color: var(--text-secondary);
            max-width: 600px;
            margin: 0 auto;
        }
        
        /* Posts Grid */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2.5rem;
            margin-bottom: 5rem;
        }
        
        /* Post Card - King's Trust Style */
        .post-card {
            background-color: var(--bg-primary);
            border-radius: 8px;
            overflow: hidden;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            height: 100%;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }
        
        .post-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
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
            padding-top: 66.67%; /* 3:2 aspect ratio */
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
            padding: 2rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .post-card-tag {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            color: var(--accent-color);
            letter-spacing: 0.1em;
            margin-bottom: 0.75rem;
        }
        
        .post-card-title {
            font-size: 1.375rem;
            font-weight: 700;
            line-height: 1.3;
            margin-bottom: 1rem;
            letter-spacing: -0.01em;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .post-card-excerpt {
            font-size: 0.9375rem;
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 1.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            flex: 1;
        }
        
        .post-card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.875rem;
            color: var(--text-light);
        }
        
        .post-author-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .author-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background-color: var(--accent-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: 600;
            color: white;
            text-transform: uppercase;
            overflow: hidden;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .post-date {
            color: var(--text-light);
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.75rem;
        }
        
        .pagination a,
        .pagination span {
            min-width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid var(--border-color);
            border-radius: 4px;
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 600;
            font-size: 0.9375rem;
            transition: var(--transition);
        }
        
        .pagination a:hover {
            background-color: var(--accent-color);
            border-color: var(--accent-color);
            color: white;
        }
        
        .pagination .current {
            background-color: var(--accent-color);
            border-color: var(--accent-color);
            color: white;
        }
        
        .pagination .prev,
        .pagination .next {
            padding: 0 1.25rem;
            width: auto;
        }
        
        /* Newsletter Section */
        .newsletter-section {
            background-color: var(--bg-dark);
            color: white;
            padding: 5rem 0;
            margin-top: 5rem;
        }
        
        .newsletter-inner {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 2rem;
            text-align: center;
        }
        
        .newsletter-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            letter-spacing: -0.02em;
        }
        
        .newsletter-description {
            font-size: 1.125rem;
            color: rgba(255, 255, 255, 0.8);
            margin-bottom: 2.5rem;
        }
        
        .newsletter-form {
            display: flex;
            gap: 1rem;
            max-width: 500px;
            margin: 0 auto;
        }
        
        .newsletter-input {
            flex: 1;
            padding: 1rem 1.5rem;
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 4px;
            background-color: transparent;
            color: white;
            font-size: 1rem;
            transition: var(--transition);
        }
        
        .newsletter-input::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }
        
        .newsletter-input:focus {
            outline: none;
            border-color: white;
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .newsletter-button {
            padding: 1rem 2rem;
            background-color: white;
            color: var(--text-primary);
            border: 2px solid white;
            border-radius: 4px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: var(--transition);
        }
        
        .newsletter-button:hover {
            background-color: transparent;
            color: white;
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-secondary);
            padding: 4rem 0 2rem;
        }
        
        .footer-inner {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        .footer-content {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr;
            gap: 3rem;
            margin-bottom: 3rem;
            padding-bottom: 3rem;
            border-bottom: 1px solid var(--border-color);
        }
        
        .footer-brand h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            letter-spacing: -0.02em;
        }
        
        .footer-brand p {
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }
        
        .footer-social {
            display: flex;
            gap: 1rem;
        }
        
        .social-link {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--bg-primary);
            border-radius: 50%;
            color: var(--text-primary);
            text-decoration: none;
            transition: var(--transition);
        }
        
        .social-link:hover {
            background-color: var(--accent-color);
            color: white;
            transform: translateY(-2px);
        }
        
        .footer-column h4 {
            font-size: 1rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .footer-column ul {
            list-style: none;
        }
        
        .footer-column ul li {
            margin-bottom: 0.75rem;
        }
        
        .footer-column a {
            color: var(--text-secondary);
            text-decoration: none;
            transition: var(--transition);
        }
        
        .footer-column a:hover {
            color: var(--accent-color);
        }
        
        .footer-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--text-light);
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
        
        .mobile-menu-toggle span {
            display: block;
            width: 24px;
            height: 2px;
            background-color: var(--text-primary);
            margin: 4px 0;
            transition: var(--transition);
        }
        
        /* Responsive */
        @media (max-width: 1024px) {
            .posts-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .hero-inner {
                grid-template-columns: 1fr;
                gap: 3rem;
            }
            
            .hero-image {
                order: -1;
            }
            
            .footer-content {
                grid-template-columns: 1fr 1fr;
            }
        }
        
        @media (max-width: 768px) {
            .nav-menu,
            .nav-cta {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .hero-title {
                font-size: 2.5rem;
            }
            
            .posts-grid {
                grid-template-columns: 1fr;
                gap: 2rem;
            }
            
            .newsletter-form {
                flex-direction: column;
            }
            
            .footer-content {
                grid-template-columns: 1fr;
                gap: 2rem;
            }
            
            .footer-bottom {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
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
    </style>
    
    <!--- Code Injection Head --->
    <cfif len(codeInjectionHead)>
        <cfoutput>#codeInjectionHead#</cfoutput>
    </cfif>
</head>
<body>
    <!--- Header --->
    <header class="site-header">
        <div class="header-inner">
            <a href="/ghost/blog/" class="site-logo">
                <cfif len(siteLogo)>
                    <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>">
                <cfelse>
                    <cfoutput>#siteTitle#</cfoutput>
                </cfif>
            </a>
            
            <nav class="site-nav">
                <ul class="nav-menu">
                    <cfloop array="#primaryNav#" index="navItem">
                        <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                    </cfloop>
                </ul>
                
                <a href="/ghost/admin/" class="nav-cta">Get Started</a>
                
                <button class="mobile-menu-toggle" aria-label="Menu">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
            </nav>
        </div>
    </header>
    
    <!--- Hero Section with Featured Post --->
    <cfif qFeaturedPost.recordCount GT 0 AND url.page EQ 1>
        <section class="hero-section">
            <div class="hero-inner">
                <div class="hero-content">
                    <span class="hero-tag">Featured Story</span>
                    <h1 class="hero-title"><cfoutput>#qFeaturedPost.title#</cfoutput></h1>
                    <cfif len(qFeaturedPost.custom_excerpt)>
                        <p class="hero-excerpt"><cfoutput>#qFeaturedPost.custom_excerpt#</cfoutput></p>
                    </cfif>
                    <div class="hero-meta">
                        <span>By <cfoutput>#qFeaturedPost.author_name#</cfoutput></span>
                        <span>•</span>
                        <time><cfoutput>#dateFormat(qFeaturedPost.published_at, 'mmmm dd, yyyy')#</cfoutput></time>
                    </div>
                    <a href="/ghost/blog/<cfoutput>#qFeaturedPost.slug#</cfoutput>/" class="hero-cta">
                        Read Full Story
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                        </svg>
                    </a>
                </div>
                <cfif len(qFeaturedPost.feature_image)>
                    <div class="hero-image">
                        <img src="<cfoutput>#qFeaturedPost.feature_image#</cfoutput>" 
                             alt="<cfoutput>#htmlEditFormat(qFeaturedPost.title)#</cfoutput>">
                    </div>
                </cfif>
            </div>
        </section>
    <cfelse>
        <!--- Simple Hero for other pages --->
        <section class="hero-section" style="padding: 3rem 0; margin-top: var(--header-height);">
            <div class="hero-inner" style="text-align: center;">
                <h1 class="hero-title" style="font-size: 2.5rem;"><cfoutput>#siteTitle#</cfoutput></h1>
                <p class="hero-excerpt"><cfoutput>#siteDescription#</cfoutput></p>
            </div>
        </section>
    </cfif>
    
    <!--- Main Content --->
    <main class="main-content">
        <div class="content-inner">
            <div class="section-header">
                <h2 class="section-title">Latest Stories</h2>
                <p class="section-subtitle">Discover insights, updates, and stories from our community</p>
            </div>
            
            <!--- Posts Grid --->
            <div class="posts-grid">
                <cfoutput query="qPosts">
                    <!--- Get first tag for this post --->
                    <cfquery name="qFirstTag" datasource="#request.dsn#" maxrows="1">
                        SELECT t.name
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
                        <cfset excerpt = left(qPosts.plaintext, 150)>
                        <cfif len(qPosts.plaintext) GT 150>
                            <cfset excerpt = excerpt & "...">
                        </cfif>
                    </cfif>
                    
                    <article class="post-card">
                        <a href="/ghost/blog/#qPosts.slug#/" class="post-card-link">
                            <cfif len(trim(qPosts.feature_image))>
                                <div class="post-card-image">
                                    <img src="#qPosts.feature_image#" 
                                         alt="#htmlEditFormat(qPosts.title)#" 
                                         loading="lazy">
                                </div>
                            </cfif>
                            
                            <div class="post-card-content">
                                <cfif qFirstTag.recordCount GT 0>
                                    <div class="post-card-tag">#qFirstTag.name#</div>
                                </cfif>
                                
                                <h3 class="post-card-title">#qPosts.title#</h3>
                                
                                <cfif len(excerpt)>
                                    <p class="post-card-excerpt">#excerpt#</p>
                                </cfif>
                                
                                <div class="post-card-footer">
                                    <div class="post-author-info">
                                        <div class="author-avatar">
                                            <cfif len(trim(qPosts.author_profile_image))>
                                                <img src="#qPosts.author_profile_image#" 
                                                     alt="#qPosts.author_name#">
                                            <cfelse>
                                                #left(qPosts.author_name, 1)#
                                            </cfif>
                                        </div>
                                        <span>#qPosts.author_name#</span>
                                    </div>
                                    <time class="post-date">#dateFormat(qPosts.published_at, 'mmm dd')#</time>
                                </div>
                            </div>
                        </a>
                    </article>
                </cfoutput>
            </div>
            
            <!--- Pagination --->
            <cfif totalPages GT 1>
                <nav class="pagination" aria-label="Pagination">
                    <cfif url.page GT 1>
                        <a href="?page=#url.page - 1#" class="prev">Previous</a>
                    </cfif>
                    
                    <cfloop from="1" to="#totalPages#" index="i">
                        <cfif abs(i - url.page) LT 3 OR i EQ 1 OR i EQ totalPages>
                            <cfif i EQ url.page>
                                <span class="current" aria-current="page">#i#</span>
                            <cfelse>
                                <a href="?page=#i#">#i#</a>
                            </cfif>
                        <cfelseif abs(i - url.page) EQ 3>
                            <span>...</span>
                        </cfif>
                    </cfloop>
                    
                    <cfif url.page LT totalPages>
                        <a href="?page=#url.page + 1#" class="next">Next</a>
                    </cfif>
                </nav>
            </cfif>
        </div>
    </main>
    
    <!--- Newsletter Section --->
    <section class="newsletter-section">
        <div class="newsletter-inner">
            <h2 class="newsletter-title">Stay Connected</h2>
            <p class="newsletter-description">Get the latest updates, stories, and insights delivered to your inbox</p>
            <form class="newsletter-form" onsubmit="return false;">
                <input type="email" class="newsletter-input" placeholder="Enter your email" required>
                <button type="submit" class="newsletter-button">Subscribe</button>
            </form>
        </div>
    </section>
    
    <!--- Footer --->
    <footer class="site-footer">
        <div class="footer-inner">
            <div class="footer-content">
                <div class="footer-brand">
                    <h3><cfoutput>#siteTitle#</cfoutput></h3>
                    <p><cfoutput>#siteDescription#</cfoutput></p>
                    <div class="footer-social">
                        <a href="#" class="social-link" aria-label="Twitter">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                            </svg>
                        </a>
                        <a href="#" class="social-link" aria-label="Facebook">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                            </svg>
                        </a>
                        <a href="#" class="social-link" aria-label="LinkedIn">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                            </svg>
                        </a>
                    </div>
                </div>
                
                <div class="footer-column">
                    <h4>Quick Links</h4>
                    <ul>
                        <cfloop array="#primaryNav#" index="navItem">
                            <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                        </cfloop>
                    </ul>
                </div>
                
                <div class="footer-column">
                    <h4>Resources</h4>
                    <ul>
                        <li><a href="/ghost/admin/">Admin</a></li>
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Contact</a></li>
                    </ul>
                </div>
                
                <div class="footer-column">
                    <h4>Legal</h4>
                    <ul>
                        <cfif arrayLen(secondaryNav) GT 0>
                            <cfloop array="#secondaryNav#" index="navItem">
                                <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                            </cfloop>
                        <cfelse>
                            <li><a href="#">Privacy Policy</a></li>
                            <li><a href="#">Terms of Service</a></li>
                            <li><a href="#">Cookie Policy</a></li>
                        </cfif>
                    </ul>
                </div>
            </div>
            
            <div class="footer-bottom">
                <div class="footer-copyright">
                    &copy; <cfoutput>#year(now())# #siteTitle#</cfoutput>. All rights reserved.
                </div>
                <div class="footer-credit">
                    Powered by <a href="#" style="color: var(--text-light); text-decoration: none;">Ghost CFML</a>
                </div>
            </div>
        </div>
    </footer>
    
    <!--- Code Injection Foot --->
    <cfif len(codeInjectionFoot)>
        <cfoutput>#codeInjectionFoot#</cfoutput>
    </cfif>
    
    <!--- Scripts --->
    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            this.classList.toggle('active');
            document.querySelector('.nav-menu').classList.toggle('active');
        });
        
        // Smooth scroll for header on scroll
        let lastScroll = 0;
        window.addEventListener('scroll', function() {
            const currentScroll = window.pageYOffset;
            const header = document.querySelector('.site-header');
            
            if (currentScroll > lastScroll && currentScroll > 100) {
                header.style.transform = 'translateY(-100%)';
            } else {
                header.style.transform = 'translateY(0)';
            }
            
            lastScroll = currentScroll;
        });
        
        // Newsletter form
        document.querySelector('.newsletter-form').addEventListener('submit', function(e) {
            e.preventDefault();
            const button = this.querySelector('.newsletter-button');
            const originalText = button.textContent;
            button.textContent = 'Thank you!';
            button.disabled = true;
            
            setTimeout(() => {
                button.textContent = originalText;
                button.disabled = false;
                this.reset();
            }, 2000);
        });
    </script>
</body>
</html>