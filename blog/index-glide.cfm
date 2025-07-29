<!--- Glide-Inspired Modern Blog Theme --->\
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
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : "##09090b">
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "https://clitools.app">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Pagination setup --->
<cfset postsPerPage = 15>
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

<!--- Get featured posts for hero --->
<cfquery name="qFeaturedPosts" datasource="#request.dsn#">
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
    AND p.featured = 1
    ORDER BY p.published_at DESC
    LIMIT 3
</cfquery>

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
    <meta name="viewport" content="width=device-width, initial-scale=1">
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
    
    <!--- Fonts --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Fraunces:opsz,wght@9..144,700;9..144,900&display=swap" rel="stylesheet">
    
    <!--- Modern CSS with Glide-inspired design --->
    <style>
        :root {
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --text-primary: #09090b;
            --text-secondary: #71717a;
            --text-tertiary: #a1a1aa;
            --bg-primary: #ffffff;
            --bg-secondary: #fafafa;
            --bg-tertiary: #f4f4f5;
            --border-color: #e4e4e7;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            --radius-sm: 0.375rem;
            --radius-md: 0.5rem;
            --radius-lg: 0.75rem;
            --radius-xl: 1rem;
            --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
            --font-serif: 'Fraunces', Georgia, serif;
            --transition-base: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            --transition-slow: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --max-width: 1320px;
        }
        
        @media (prefers-color-scheme: dark) {
            :root {
                --text-primary: #fafafa;
                --text-secondary: #a1a1aa;
                --text-tertiary: #71717a;
                --bg-primary: #09090b;
                --bg-secondary: #18181b;
                --bg-tertiary: #27272a;
                --border-color: #27272a;
            }
        }
        
        * {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            font-family: var(--font-sans);
            font-size: 16px;
            line-height: 1.6;
            color: var(--text-primary);
            background-color: var(--bg-primary);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Header */
        .site-header {
            background-color: var(--bg-primary);
            position: sticky;
            top: 0;
            z-index: 50;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            background-color: rgba(255, 255, 255, 0.9);
            border-bottom: 1px solid var(--border-color);
        }
        
        @media (prefers-color-scheme: dark) {
            .site-header {
                background-color: rgba(9, 9, 11, 0.9);
            }
        }
        
        .header-container {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 1.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .site-branding {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .site-logo-link {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 700;
            font-size: 1.5rem;
        }
        
        .site-logo-link img {
            height: 36px;
            width: auto;
        }
        
        /* Navigation */
        .main-nav {
            display: flex;
            align-items: center;
            gap: 3rem;
        }
        
        .nav-menu {
            display: flex;
            list-style: none;
            margin: 0;
            padding: 0;
            gap: 2.5rem;
        }
        
        .nav-menu a {
            color: var(--text-secondary);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9375rem;
            transition: var(--transition-base);
            position: relative;
        }
        
        .nav-menu a:hover {
            color: var(--text-primary);
        }
        
        .nav-menu a::after {
            content: '';
            position: absolute;
            bottom: -2px;
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
            display: flex;
            gap: 1rem;
        }
        
        .btn {
            padding: 0.625rem 1.25rem;
            border-radius: var(--radius-md);
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            transition: var(--transition-base);
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-secondary {
            background-color: transparent;
            color: var(--text-primary);
            border: 1px solid var(--border-color);
        }
        
        .btn-secondary:hover {
            background-color: var(--bg-secondary);
            border-color: var(--text-tertiary);
        }
        
        .btn-primary {
            background-color: var(--accent-color);
            color: white;
        }
        
        .btn-primary:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
        
        /* Hero Section */
        .hero-section {
            padding: 5rem 2rem 4rem;
            text-align: center;
            max-width: 900px;
            margin: 0 auto;
        }
        
        .hero-title {
            font-family: var(--font-serif);
            font-size: clamp(2.5rem, 5vw, 4rem);
            font-weight: 900;
            margin: 0 0 1.5rem;
            line-height: 1.1;
            letter-spacing: -0.02em;
        }
        
        .hero-description {
            font-size: 1.25rem;
            color: var(--text-secondary);
            margin: 0 0 3rem;
            line-height: 1.6;
        }
        
        /* Featured Posts */
        .featured-section {
            max-width: var(--max-width);
            margin: 0 auto 5rem;
            padding: 0 2rem;
        }
        
        .featured-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 2rem;
        }
        
        .featured-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
        }
        
        .featured-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 2rem;
        }
        
        .featured-card {
            background-color: var(--bg-secondary);
            border-radius: var(--radius-xl);
            overflow: hidden;
            transition: var(--transition-slow);
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        
        .featured-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-xl);
        }
        
        .featured-image {
            position: relative;
            padding-top: 60%;
            background-color: var(--bg-tertiary);
            overflow: hidden;
        }
        
        .featured-image img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition-slow);
        }
        
        .featured-card:hover .featured-image img {
            transform: scale(1.05);
        }
        
        .featured-content {
            padding: 2rem;
        }
        
        .featured-meta {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            color: var(--text-tertiary);
        }
        
        .featured-card-title {
            font-size: 1.375rem;
            font-weight: 700;
            line-height: 1.3;
            margin: 0 0 0.75rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .featured-excerpt {
            color: var(--text-secondary);
            line-height: 1.6;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        /* Main Content */
        .main-content {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 0 2rem 5rem;
        }
        
        .section-header {
            margin-bottom: 3rem;
        }
        
        .section-title {
            font-size: 2rem;
            font-weight: 700;
            margin: 0 0 0.5rem;
        }
        
        .section-subtitle {
            color: var(--text-secondary);
            font-size: 1.125rem;
        }
        
        /* Masonry Grid */
        .posts-masonry {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
            gap: 2rem;
            margin-bottom: 5rem;
        }
        
        /* Post Card */
        .post-card {
            background-color: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-xl);
            overflow: hidden;
            transition: var(--transition-slow);
            display: flex;
            flex-direction: column;
            cursor: pointer;
        }
        
        .post-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            border-color: var(--text-tertiary);
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
            padding-top: 66.67%;
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
            transition: var(--transition-slow);
        }
        
        .post-card:hover .post-card-image img {
            transform: scale(1.03);
        }
        
        .post-card-content {
            padding: 1.75rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .post-card-tags {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }
        
        .post-tag {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 600;
            color: white;
            background-color: var(--accent-color);
            padding: 0.375rem 0.875rem;
            border-radius: 9999px;
            text-decoration: none;
            transition: var(--transition-base);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .post-tag:hover {
            opacity: 0.85;
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
            margin: 0 0 1.25rem;
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
            color: var(--text-tertiary);
            margin-top: auto;
        }
        
        .post-author {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .author-avatar {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background-color: var(--bg-tertiary);
            flex-shrink: 0;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .meta-divider {
            color: var(--border-color);
        }
        
        /* Newsletter Section */
        .newsletter-section {
            background-color: var(--bg-secondary);
            border-radius: var(--radius-xl);
            padding: 4rem;
            max-width: 800px;
            margin: 5rem auto;
            text-align: center;
        }
        
        .newsletter-title {
            font-family: var(--font-serif);
            font-size: 2.5rem;
            font-weight: 900;
            margin: 0 0 1rem;
        }
        
        .newsletter-description {
            font-size: 1.125rem;
            color: var(--text-secondary);
            margin: 0 0 2rem;
        }
        
        .newsletter-form {
            display: flex;
            gap: 1rem;
            max-width: 500px;
            margin: 0 auto;
        }
        
        .newsletter-input {
            flex: 1;
            padding: 0.875rem 1.25rem;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            background-color: var(--bg-primary);
            color: var(--text-primary);
            font-size: 1rem;
            transition: var(--transition-base);
        }
        
        .newsletter-input:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 3px rgba(90, 103, 216, 0.1);
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
            margin-top: 5rem;
        }
        
        .pagination a,
        .pagination span {
            padding: 0.625rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 500;
            font-size: 0.875rem;
            transition: var(--transition-base);
            min-width: 40px;
            text-align: center;
        }
        
        .pagination a:hover {
            background-color: var(--bg-secondary);
            border-color: var(--text-tertiary);
        }
        
        .pagination .current {
            background-color: var(--accent-color);
            color: white;
            border-color: var(--accent-color);
        }
        
        .pagination-ellipsis {
            color: var(--text-tertiary);
            border: none;
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-secondary);
            border-top: 1px solid var(--border-color);
            padding: 4rem 2rem 3rem;
        }
        
        .footer-container {
            max-width: var(--max-width);
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 3rem;
            margin-bottom: 3rem;
        }
        
        .footer-brand {
            grid-column: 1 / -1;
        }
        
        @media (min-width: 768px) {
            .footer-brand {
                grid-column: span 1;
            }
        }
        
        .footer-logo {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 700;
            font-size: 1.25rem;
            margin-bottom: 1rem;
        }
        
        .footer-logo img {
            height: 32px;
        }
        
        .footer-description {
            color: var(--text-secondary);
            line-height: 1.6;
            margin: 0;
        }
        
        .footer-section h3 {
            font-size: 0.875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--text-secondary);
            margin: 0 0 1rem;
        }
        
        .footer-links {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .footer-links li {
            margin-bottom: 0.75rem;
        }
        
        .footer-links a {
            color: var(--text-primary);
            text-decoration: none;
            transition: var(--transition-base);
        }
        
        .footer-links a:hover {
            color: var(--accent-color);
        }
        
        .footer-bottom {
            text-align: center;
            padding-top: 2rem;
            border-top: 1px solid var(--border-color);
            color: var(--text-tertiary);
            font-size: 0.875rem;
        }
        
        /* Mobile Menu */
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            cursor: pointer;
            padding: 0.5rem;
            color: var(--text-primary);
        }
        
        .mobile-menu-toggle svg {
            width: 24px;
            height: 24px;
        }
        
        /* Responsive Design */
        @media (max-width: 1024px) {
            .posts-masonry {
                grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            }
        }
        
        @media (max-width: 768px) {
            .header-container {
                padding: 1rem 1.5rem;
            }
            
            .nav-menu,
            .nav-cta {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .hero-section {
                padding: 3rem 1.5rem;
            }
            
            .hero-title {
                font-size: 2.5rem;
            }
            
            .main-content,
            .featured-section {
                padding-left: 1.5rem;
                padding-right: 1.5rem;
            }
            
            .posts-masonry {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .newsletter-section {
                padding: 3rem 2rem;
                margin: 3rem 1.5rem;
            }
            
            .newsletter-form {
                flex-direction: column;
            }
        }
        
        /* Loading Animation */
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .skeleton {
            animation: pulse 2s infinite;
            background-color: var(--bg-tertiary);
        }
        
        /* Smooth Scroll */
        html {
            scroll-behavior: smooth;
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
        
        /* Dark Mode Toggle */
        .theme-toggle {
            background: none;
            border: none;
            cursor: pointer;
            padding: 0.5rem;
            color: var(--text-primary);
            transition: var(--transition-base);
        }
        
        .theme-toggle:hover {
            color: var(--accent-color);
        }
        
        .theme-toggle svg {
            width: 20px;
            height: 20px;
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
        <div class="header-container">
            <div class="site-branding">
                <a href="/ghost/blog/" class="site-logo-link">
                    <cfif len(siteLogo)>
                        <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>">
                    <cfelse>
                        <cfoutput>#siteTitle#</cfoutput>
                    </cfif>
                </a>
            </div>
            
            <nav class="main-nav">
                <ul class="nav-menu">
                    <cfloop array="#primaryNav#" index="navItem">
                        <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                    </cfloop>
                </ul>
                
                <div class="nav-cta">
                    <button class="theme-toggle" aria-label="Toggle theme">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                        </svg>
                    </button>
                    <a href="/ghost/admin/" class="btn btn-secondary">Sign in</a>
                    <a href="##subscribe" class="btn btn-primary">Subscribe</a>
                </div>
                
                <button class="mobile-menu-toggle" aria-label="Menu">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                    </svg>
                </button>
            </nav>
        </div>
    </header>
    
    <!--- Hero Section --->
    <cfif url.page EQ 1>
        <section class="hero-section">
            <h1 class="hero-title"><cfoutput>#siteTitle#</cfoutput></h1>
            <p class="hero-description"><cfoutput>#siteDescription#</cfoutput></p>
        </section>
        
        <!--- Featured Posts --->
        <cfif qFeaturedPosts.recordCount GT 0>
            <section class="featured-section">
                <div class="featured-header">
                    <h2 class="featured-title">Featured Posts</h2>
                </div>
                
                <div class="featured-grid">
                    <cfoutput query="qFeaturedPosts">
                        <!--- Get tags for featured post --->
                        <cfquery name="qFeaturedTags" datasource="#request.dsn#">
                            SELECT t.name, t.slug
                            FROM tags t
                            INNER JOIN posts_tags pt ON t.id = pt.tag_id
                            WHERE pt.post_id = <cfqueryparam value="#qFeaturedPosts.id#" cfsqltype="cf_sql_varchar">
                            LIMIT 1
                        </cfquery>
                        
                        <!--- Create excerpt --->
                        <cfset excerpt = "">
                        <cfif len(trim(qFeaturedPosts.custom_excerpt))>
                            <cfset excerpt = qFeaturedPosts.custom_excerpt>
                        <cfelseif len(trim(qFeaturedPosts.plaintext))>
                            <cfset excerpt = left(qFeaturedPosts.plaintext, 120)>
                            <cfif len(qFeaturedPosts.plaintext) GT 120>
                                <cfset excerpt = excerpt & "...">
                            </cfif>
                        </cfif>
                        
                        <!--- Calculate reading time --->
                        <cfset wordCount = listLen(qFeaturedPosts.plaintext, " ")>
                        <cfset readingTime = ceiling(wordCount / 200)>
                        <cfif readingTime EQ 0>
                            <cfset readingTime = 1>
                        </cfif>
                        
                        <a href="/ghost/blog/#qFeaturedPosts.slug#/" class="featured-card">
                            <cfif len(trim(qFeaturedPosts.feature_image))>
                                <div class="featured-image">
                                    <img src="#qFeaturedPosts.feature_image#" 
                                         alt="#htmlEditFormat(qFeaturedPosts.title)#" 
                                         loading="lazy">
                                </div>
                            </cfif>
                            
                            <div class="featured-content">
                                <div class="featured-meta">
                                    <cfif qFeaturedTags.recordCount GT 0>
                                        <span class="post-tag">#qFeaturedTags.name#</span>
                                    </cfif>
                                    <span>#readingTime# min read</span>
                                </div>
                                
                                <h3 class="featured-card-title">#qFeaturedPosts.title#</h3>
                                
                                <cfif len(excerpt)>
                                    <p class="featured-excerpt">#excerpt#</p>
                                </cfif>
                            </div>
                        </a>
                    </cfoutput>
                </div>
            </section>
        </cfif>
    </cfif>
    
    <!--- Main Content --->
    <main class="main-content">
        <cfif url.page EQ 1>
            <div class="section-header">
                <h2 class="section-title">Latest Posts</h2>
                <p class="section-subtitle">Discover stories, thinking, and expertise from writers on any topic.</p>
            </div>
        </cfif>
        
        <!--- Posts Grid --->
        <div class="posts-masonry">
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
                                     loading="lazy">
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
                                <div class="post-author">
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
                                <span class="meta-divider">•</span>
                                <time datetime="#dateFormat(qPosts.published_at, 'yyyy-mm-dd')#">
                                    #dateFormat(qPosts.published_at, 'mmm dd')#
                                </time>
                                <span class="meta-divider">•</span>
                                <span>#readingTime# min</span>
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
                    <a href="?page=#url.page - 1#" rel="prev">← Previous</a>
                </cfif>
                
                <!--- Page numbers with ellipsis --->
                <cfset startPage = max(1, url.page - 2)>
                <cfset endPage = min(totalPages, url.page + 2)>
                
                <cfif startPage GT 1>
                    <a href="?page=1">1</a>
                    <cfif startPage GT 2>
                        <span class="pagination-ellipsis">...</span>
                    </cfif>
                </cfif>
                
                <cfloop from="#startPage#" to="#endPage#" index="i">
                    <cfif i EQ url.page>
                        <span class="current" aria-current="page">#i#</span>
                    <cfelse>
                        <a href="?page=#i#">#i#</a>
                    </cfif>
                </cfloop>
                
                <cfif endPage LT totalPages>
                    <cfif endPage LT totalPages - 1>
                        <span class="pagination-ellipsis">...</span>
                    </cfif>
                    <a href="?page=#totalPages#">#totalPages#</a>
                </cfif>
                
                <cfif url.page LT totalPages>
                    <a href="?page=#url.page + 1#" rel="next">Next →</a>
                </cfif>
            </nav>
        </cfif>
        
        <!--- Newsletter Section --->
        <section class="newsletter-section" id="subscribe">
            <h2 class="newsletter-title">Subscribe to our newsletter</h2>
            <p class="newsletter-description">Get the latest posts delivered right to your inbox</p>
            <form class="newsletter-form" action="/ghost/subscribe/" method="post">
                <input type="email" class="newsletter-input" placeholder="Your email address" required>
                <button type="submit" class="btn btn-primary">Subscribe</button>
            </form>
        </section>
    </main>
    
    <!--- Footer --->
    <footer class="site-footer">
        <div class="footer-container">
            <div class="footer-brand">
                <a href="/ghost/blog/" class="footer-logo">
                    <cfif len(siteLogo)>
                        <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>">
                    <cfelse>
                        <cfoutput>#siteTitle#</cfoutput>
                    </cfif>
                </a>
                <p class="footer-description"><cfoutput>#siteDescription#</cfoutput></p>
            </div>
            
            <cfif arrayLen(secondaryNav) GT 0>
                <div class="footer-section">
                    <h3>Links</h3>
                    <ul class="footer-links">
                        <cfloop array="#secondaryNav#" index="navItem">
                            <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                        </cfloop>
                    </ul>
                </div>
            </cfif>
            
            <div class="footer-section">
                <h3>Platform</h3>
                <ul class="footer-links">
                    <li><a href="/ghost/admin/">Admin Dashboard</a></li>
                    <li><a href="/ghost/api/">API Documentation</a></li>
                    <li><a href="/ghost/privacy/">Privacy Policy</a></li>
                    <li><a href="/ghost/terms/">Terms of Service</a></li>
                </ul>
            </div>
            
            <div class="footer-section">
                <h3>Connect</h3>
                <ul class="footer-links">
                    <li><a href="https://twitter.com">Twitter</a></li>
                    <li><a href="https://facebook.com">Facebook</a></li>
                    <li><a href="https://instagram.com">Instagram</a></li>
                    <li><a href="https://linkedin.com">LinkedIn</a></li>
                </ul>
            </div>
        </div>
        
        <div class="footer-bottom">
            &copy; <cfoutput>#year(now())# #siteTitle#</cfoutput> • Powered by Ghost CFML
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
            const menu = document.querySelector('.nav-menu');
            const cta = document.querySelector('.nav-cta');
            const isExpanded = this.getAttribute('aria-expanded') === 'true';
            
            this.setAttribute('aria-expanded', !isExpanded);
            
            if (!isExpanded) {
                // Create mobile menu container
                const mobileMenu = document.createElement('div');
                mobileMenu.className = 'mobile-menu';
                mobileMenu.style.cssText = `
                    position: absolute;
                    top: 100%;
                    left: 0;
                    right: 0;
                    background: var(--bg-primary);
                    border-bottom: 1px solid var(--border-color);
                    padding: 1rem 2rem 2rem;
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                `;
                
                // Clone menu items
                const menuClone = menu.cloneNode(true);
                menuClone.style.cssText = `
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                    margin-bottom: 1rem;
                `;
                
                const ctaClone = cta.cloneNode(true);
                ctaClone.style.cssText = `
                    display: flex;
                    flex-direction: column;
                    gap: 0.75rem;
                `;
                
                mobileMenu.appendChild(menuClone);
                mobileMenu.appendChild(ctaClone);
                document.querySelector('.site-header').appendChild(mobileMenu);
            } else {
                const mobileMenu = document.querySelector('.mobile-menu');
                if (mobileMenu) {
                    mobileMenu.remove();
                }
            }
        });
        
        // Theme toggle
        const themeToggle = document.querySelector('.theme-toggle');
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
        
        function setTheme(isDark) {
            document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
            localStorage.setItem('theme', isDark ? 'dark' : 'light');
        }
        
        // Check for saved theme preference
        const savedTheme = localStorage.getItem('theme');
        if (savedTheme) {
            setTheme(savedTheme === 'dark');
        }
        
        themeToggle.addEventListener('click', function() {
            const currentTheme = document.documentElement.getAttribute('data-theme');
            setTheme(currentTheme !== 'dark');
        });
        
        // Smooth scroll for anchor links
        document.querySelectorAll('a[href^="##"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
        
        // Lazy loading images
        if ('loading' in HTMLImageElement.prototype) {
            const images = document.querySelectorAll('img[loading="lazy"]');
            images.forEach(img => {
                img.src = img.src;
            });
        }
    </script>
</body>
</html>