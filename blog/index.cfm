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
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">
<cfset showAuthorsWidget = structKeyExists(siteSettings, "show_authors_widget") ? siteSettings.show_authors_widget : "false">
<cfset showTagsWidget = structKeyExists(siteSettings, "show_tags_widget") ? siteSettings.show_tags_widget : "false">
<cfset standardLoadMore = structKeyExists(siteSettings, "standard_load_more") ? siteSettings.standard_load_more : "false">

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
    <link rel="canonical" href="<cfoutput>/ghost/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="website">
    <meta property="og:title" content="<cfoutput>#siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput>">
    <meta property="og:description" content="<cfoutput>#siteDescription#</cfoutput>">
    <meta property="og:url" content="<cfoutput>/ghost/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
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
        "url": "<cfoutput>/ghost/</cfoutput>",
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
            <cfif navigationRight EQ "true">
            justify-content: space-between;
            <cfelse>
            gap: 2rem;
            </cfif>
            align-items: center;
        }
        
        <cfif navigationRight NEQ "true">
        .site-nav {
            flex: 1;
            justify-content: flex-start;
        }
        </cfif>
        
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
            position: relative;
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
            position: relative;
        }
        
        .underline-wrap {
            position: relative;
            display: inline;
            background-image: linear-gradient(to right, var(--accent-color), var(--accent-color));
            background-repeat: no-repeat;
            background-position: 0 95%;
            background-size: 0% 5px;
            transition: background-size 1.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        .post-card:hover .underline-wrap {
            background-size: 100% 5px;
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
        
        /* Load More Button */
        .load-more-container {
            text-align: center;
            padding: 2rem 0;
        }
        
        .load-more-button {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.875rem 2rem;
            background-color: var(--accent-color);
            color: white;
            border: none;
            border-radius: 9999px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            position: relative;
        }
        
        .load-more-button:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }
        
        .load-more-button:active {
            transform: translateY(0);
        }
        
        .load-more-button.loading {
            pointer-events: none;
            opacity: 0.8;
        }
        
        .load-more-button.loading .load-more-text {
            visibility: hidden;
        }
        
        .load-more-button.loading .load-more-spinner {
            display: inline-flex !important;
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
        }
        
        .load-more-spinner svg {
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        .load-more-info {
            margin-top: 1rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
        }
        
        /* Widgets Section */
        .widgets-section {
            background-color: var(--bg-secondary);
            border-top: 1px solid var(--border-color);
            padding: 4rem 1.5rem;
        }
        
        .widgets-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 3rem;
        }
        
        .widget {
            background-color: var(--bg-primary);
            border-radius: var(--radius-lg);
            padding: 2rem;
            box-shadow: var(--shadow-sm);
        }
        
        .widget-title {
            font-size: 1.25rem;
            font-weight: 700;
            margin: 0 0 1.5rem;
            color: var(--text-primary);
        }
        
        /* Authors Widget */
        .authors-list {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        
        .author-item {
            display: flex;
            align-items: center;
            gap: 1rem;
            text-decoration: none;
            color: var(--text-primary);
            padding: 0.75rem;
            border-radius: var(--radius-md);
            transition: var(--transition);
        }
        
        .author-item:hover {
            background-color: var(--bg-secondary);
        }
        
        .author-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            overflow: hidden;
            background-color: var(--accent-color);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .author-avatar span {
            color: white;
            font-weight: 600;
            font-size: 1.125rem;
            text-transform: uppercase;
        }
        
        .author-info {
            flex: 1;
        }
        
        .author-name {
            font-size: 1rem;
            font-weight: 600;
            margin: 0 0 0.25rem;
        }
        
        .author-posts {
            font-size: 0.875rem;
            color: var(--text-secondary);
        }
        
        /* Tags Widget */
        .tags-cloud {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
        }
        
        .tag-item {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background-color: var(--bg-secondary);
            color: var(--text-primary);
            text-decoration: none;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 500;
            transition: var(--transition);
        }
        
        .tag-item:hover {
            background-color: var(--accent-color);
            color: white;
            transform: translateY(-2px);
        }
        
        .tag-name {
            font-weight: 500;
        }
        
        .tag-count {
            font-size: 0.75rem;
            opacity: 0.7;
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-primary);
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
            position: relative;
            width: 44px;
            height: 44px;
            background: none;
            border: none;
            cursor: pointer;
            padding: 0;
            color: var(--text-primary);
            transition: var(--transition);
            -webkit-tap-highlight-color: transparent;
        }
        
        .mobile-menu-toggle:hover {
            opacity: 0.7;
        }
        
        .mobile-menu-toggle:focus {
            outline: none;
        }
        
        .mobile-menu-toggle:focus-visible {
            outline: 2px solid var(--accent-color);
            outline-offset: 2px;
            border-radius: 8px;
        }
        
        /* Animated Hamburger Icon */
        .hamburger {
            position: relative;
            width: 24px;
            height: 24px;
            margin: auto;
        }
        
        .hamburger span {
            position: absolute;
            left: 0;
            width: 100%;
            height: 2px;
            background-color: currentColor;
            border-radius: 2px;
            transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }
        
        .hamburger span:nth-child(1) {
            top: 6px;
        }
        
        .hamburger span:nth-child(2) {
            top: 11px;
        }
        
        .hamburger span:nth-child(3) {
            top: 16px;
        }
        
        /* Hamburger Animation to X */
        .mobile-menu-toggle.active .hamburger span:nth-child(1) {
            transform: rotate(45deg);
            top: 11px;
        }
        
        .mobile-menu-toggle.active .hamburger span:nth-child(2) {
            opacity: 0;
            transform: translateX(-20px);
        }
        
        .mobile-menu-toggle.active .hamburger span:nth-child(3) {
            transform: rotate(-45deg);
            top: 11px;
        }
        
        /* Mobile Menu Overlay */
        .mobile-menu-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.4);
            opacity: 0;
            z-index: 998;
            transition: opacity 0.3s ease;
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
        }
        
        .mobile-menu-overlay.active {
            opacity: 1;
        }
        
        /* Mobile Menu Container */
        .mobile-menu {
            position: fixed;
            top: 0;
            right: -100%;
            width: min(85vw, 320px);
            height: 100%;
            background-color: var(--bg-primary);
            z-index: 999;
            transition: right 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
            box-shadow: -4px 0 30px rgba(0, 0, 0, 0.1);
        }
        
        .mobile-menu.active {
            right: 0;
        }
        
        /* Mobile Menu Header */
        .mobile-menu-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 24px;
            border-bottom: 1px solid var(--border-light);
        }
        
        .mobile-menu-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 600;
            font-size: 18px;
        }
        
        .mobile-menu-logo img {
            height: 28px;
            width: auto;
        }
        
        .mobile-menu-close {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--bg-secondary);
            border: none;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.2s ease;
            color: var(--text-secondary);
        }
        
        .mobile-menu-close:hover {
            background: var(--bg-tertiary);
            transform: scale(1.05);
        }
        
        /* Mobile Menu Navigation */
        .mobile-menu-nav {
            padding: 24px;
        }
        
        .mobile-menu-nav ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .mobile-menu-nav li {
            margin-bottom: 4px;
        }
        
        .mobile-menu-nav a {
            display: flex;
            align-items: center;
            padding: 14px 16px;
            color: var(--text-primary);
            text-decoration: none;
            font-size: 17px;
            font-weight: 500;
            border-radius: 12px;
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
        }
        
        .mobile-menu-nav a::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: var(--accent-color);
            opacity: 0.1;
            transition: left 0.3s ease;
        }
        
        .mobile-menu-nav a:hover::before,
        .mobile-menu-nav a.active::before {
            left: 0;
        }
        
        .mobile-menu-nav a:hover {
            color: var(--accent-color);
            transform: translateX(4px);
        }
        
        .mobile-menu-nav a.active {
            color: var(--accent-color);
            font-weight: 600;
        }
        
        /* Mobile Menu Footer */
        .mobile-menu-footer {
            padding: 24px;
            border-top: 1px solid var(--border-light);
            margin-top: auto;
        }
        
        .mobile-menu-secondary {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        
        .mobile-menu-secondary a {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 15px;
            padding: 8px 0;
            transition: color 0.2s ease;
        }
        
        .mobile-menu-secondary a:hover {
            color: var(--accent-color);
        }
        
        .mobile-menu-social {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-top: 16px;
        }
        
        .mobile-menu-social a {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--bg-secondary);
            border-radius: 50%;
            color: var(--text-secondary);
            transition: all 0.2s ease;
        }
        
        .mobile-menu-social a:hover {
            background: var(--accent-color);
            color: white;
            transform: translateY(-2px);
        }
        
        /* Prevent body scroll when menu is open */
        body.menu-open {
            overflow: hidden;
            position: fixed;
            width: 100%;
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .nav-menu {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .header-inner {
                padding: 1rem 1.5rem;
            }
            
            .hero-inner {
                padding: 4rem 1.5rem 3rem;
            }
            
            .main-content {
                padding: 3rem 1.5rem;
            }
            
            .posts-grid {
                grid-template-columns: 1fr;
                gap: 2rem;
            }
            
            .posts-grid .post-card:first-child {
                padding: 1.5rem;
            }
            
            .widgets-container {
                grid-template-columns: 1fr;
                gap: 2rem;
            }
            
            .widget {
                padding: 1.5rem;
            }
        }
        
        /* Smooth Scrolling */
        @media (prefers-reduced-motion: no-preference) {
            html {
                scroll-behavior: smooth;
            }
        }
        
        /* Focus Visible */
        :focus {
            outline: none;
        }
        
        :focus-visible {
            outline: 2px solid var(--accent-color);
            outline-offset: 2px;
        }
        
        /* Loading States */
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }
        
        /* Hover Effect for Touch Devices */
        @media (hover: none) {
            .post-card:hover {
                transform: none;
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
            border-radius: var(--radius-lg);
        }
        
        .skeleton::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            animation: shimmer 1.5s infinite;
        }
        
        /* Post Card Loading State */
        .post-card-skeleton {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-xl);
            overflow: hidden;
        }
        
        .post-card-skeleton .skeleton-image {
            height: 200px;
            background: var(--bg-secondary);
        }
        
        .post-card-skeleton .skeleton-content {
            padding: 1.75rem;
        }
        
        .post-card-skeleton .skeleton-tag {
            width: 60px;
            height: 24px;
            background: var(--bg-secondary);
            border-radius: 9999px;
            margin-bottom: 1rem;
        }
        
        .post-card-skeleton .skeleton-title {
            width: 80%;
            height: 28px;
            background: var(--bg-secondary);
            border-radius: var(--radius-sm);
            margin-bottom: 1rem;
        }
        
        .post-card-skeleton .skeleton-excerpt {
            width: 100%;
            height: 60px;
            background: var(--bg-secondary);
            border-radius: var(--radius-sm);
            margin-bottom: 1rem;
        }
        
        .post-card-skeleton .skeleton-meta {
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        
        .post-card-skeleton .skeleton-avatar {
            width: 36px;
            height: 36px;
            background: var(--bg-secondary);
            border-radius: 50%;
        }
        
        .post-card-skeleton .skeleton-text {
            width: 100px;
            height: 16px;
            background: var(--bg-secondary);
            border-radius: var(--radius-sm);
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
            <a href="/ghost/" class="site-logo">
                <cfif len(siteLogo)>
                    <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>" loading="lazy">
                </cfif>
                <span class="site-name"><cfoutput>#siteTitle#</cfoutput></span>
            </a>
            
            <nav class="site-nav" role="navigation">
                <ul class="nav-menu">
                    <cfloop array="#primaryNav#" index="navItem">
                        <li><a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a></li>
                    </cfloop>
                </ul>
                
                <button class="mobile-menu-toggle" aria-label="Menu" aria-expanded="false">
                    <div class="hamburger">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                </button>
            </nav>
        </div>
    </header>
    
    <!--- Mobile Menu Overlay --->
    <div class="mobile-menu-overlay"></div>
    
    <!--- Mobile Menu --->
    <div class="mobile-menu">
        <div class="mobile-menu-header">
            <a href="/ghost/" class="mobile-menu-logo">
                <cfif len(siteLogo)>
                    <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>">
                </cfif>
                <span><cfoutput>#siteTitle#</cfoutput></span>
            </a>
            <button class="mobile-menu-close" aria-label="Close menu">
                <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M18 6L6 18M6 6l12 12"/>
                </svg>
            </button>
        </div>
        
        <nav class="mobile-menu-nav">
            <ul>
                <cfloop array="#primaryNav#" index="navItem">
                    <li>
                        <a href="<cfoutput>#navItem.url#</cfoutput>">
                            <cfoutput>#navItem.label#</cfoutput>
                        </a>
                    </li>
                </cfloop>
            </ul>
        </nav>
        
        <cfif arrayLen(secondaryNav) GT 0>
            <div class="mobile-menu-footer">
                <nav class="mobile-menu-secondary">
                    <cfloop array="#secondaryNav#" index="navItem">
                        <a href="<cfoutput>#navItem.url#</cfoutput>" class="secondary-link">
                            <cfoutput>#navItem.label#</cfoutput>
                        </a>
                    </cfloop>
                </nav>
                
                <div class="mobile-menu-social">
                    <!--- Social icons can be added here based on settings --->
                </div>
            </div>
        </cfif>
    </div>
    
    <!--- Hero Section --->
    <cfif url.page EQ 1>
        <section class="hero-section">
            <div class="hero-bg-animation"></div>
            <div class="hero-inner">
                <div class="hero-content">
                    <h1 class="hero-title"><cfoutput>#siteTitle#</cfoutput></h1>
                    <p class="hero-description"><cfoutput>#siteDescription#</cfoutput></p>
                    <div class="hero-meta">
                        <span>
                            <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M3.5 0a.5.5 0 0 1 .5.5V1h8V.5a.5.5 0 0 1 1 0V1h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h1V.5a.5.5 0 0 1 .5-.5zM1 4v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V4H1z"/>
                            </svg>
                            <cfoutput>#totalPosts# posts</cfoutput>
                        </span>
                        <cfquery name="qAuthors" datasource="#request.dsn#">
                            SELECT COUNT(DISTINCT created_by) as author_count
                            FROM posts
                            WHERE status = 'published'
                        </cfquery>
                        <span>
                            <svg width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                                <path d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
                            </svg>
                            <cfoutput>#qAuthors.author_count# authors</cfoutput>
                        </span>
                    </div>
                </div>
            </div>
        </section>
    </cfif>
    
    <!--- Main Content --->
    <main class="main-content" role="main">
        <cfif url.page GT 1>
            <div class="section-header">
                <h1 class="section-title">Page <cfoutput>#url.page#</cfoutput></h1>
                <p class="section-subtitle">Exploring more stories from our collection</p>
            </div>
        </cfif>
        
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
                    <cfset cleanSlug = replace(trim(qPosts.slug), "\", "", "all")>
                    <cfset postUrl = "/ghost/" & cleanSlug & "/">
                    <a href="#postUrl#" class="post-card-link">
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
                            
                            <h3 class="post-card-title"><span class="underline-wrap">#qPosts.title#</span></h3>
                            
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
                                </cfif>
                                <div class="post-meta-info">
                                    <time datetime="#dateFormat(qPosts.published_at, 'yyyy-mm-dd')#">
                                        #dateFormat(qPosts.published_at, 'mmm dd')#
                                    </time>
                                    <span class="post-meta-divider"></span>
                                    <span class="reading-time">
                                        <svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16">
                                            <path d="M8 3.5a.5.5 0 0 0-1 0V9a.5.5 0 0 0 .252.434l3.5 2a.5.5 0 0 0 .496-.868L8 8.71V3.5z"/>
                                            <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm7-8A7 7 0 1 1 1 8a7 7 0 0 1 14 0z"/>
                                        </svg>
                                        #readingTime# min
                                    </span>
                                </div>
                            </div>
                        </div>
                    </a>
                </article>
            </cfoutput>
        </div>
        
        <!--- Pagination or Load More --->
        <cfif totalPages GT 1>
            <cfif standardLoadMore EQ "true">
                <!--- Load More Button --->
                <cfif url.page LT totalPages>
                    <div class="load-more-container">
                        <button class="load-more-button" data-page="#url.page + 1#" onclick="loadMorePosts(this)">
                            <span class="load-more-text">Load more posts</span>
                            <span class="load-more-spinner" style="display: none;">
                                <svg class="spinner" width="20" height="20" viewBox="0 0 20 20">
                                    <circle cx="10" cy="10" r="8" stroke="currentColor" stroke-width="2" fill="none" stroke-dasharray="40" stroke-dashoffset="10">
                                        <animateTransform attributeName="transform" type="rotate" from="0 10 10" to="360 10 10" dur="1s" repeatCount="indefinite"/>
                                    </circle>
                                </svg>
                            </span>
                        </button>
                        <p class="load-more-info">Page #url.page# of #totalPages#</p>
                    </div>
                </cfif>
            <cfelse>
                <!--- Standard Pagination --->
                <nav class="pagination" role="navigation" aria-label="Pagination">
                    <cfif url.page GT 1>
                        <a href="?page=#url.page - 1#" rel="prev"><span>← Previous</span></a>
                    </cfif>
                    
                    <!--- Show limited page numbers for better UX --->
                    <cfset startPage = max(1, url.page - 2)>
                    <cfset endPage = min(totalPages, url.page + 2)>
                    
                    <cfif startPage GT 1>
                        <a href="?page=1"><span>1</span></a>
                        <cfif startPage GT 2>
                            <span>...</span>
                        </cfif>
                    </cfif>
                    
                    <cfloop from="#startPage#" to="#endPage#" index="i">
                        <cfif i EQ url.page>
                            <span class="current" aria-current="page">#i#</span>
                        <cfelse>
                            <a href="?page=#i#"><span>#i#</span></a>
                        </cfif>
                    </cfloop>
                    
                    <cfif endPage LT totalPages>
                        <cfif endPage LT totalPages - 1>
                            <span>...</span>
                        </cfif>
                        <a href="?page=#totalPages#"><span>#totalPages#</span></a>
                    </cfif>
                    
                    <cfif url.page LT totalPages>
                        <a href="?page=#url.page + 1#" rel="next"><span>Next →</span></a>
                    </cfif>
                </nav>
            </cfif>
        </cfif>
    </main>
    
    <!--- Widgets Section --->
    <cfif showAuthorsWidget EQ "true" OR showTagsWidget EQ "true">
        <section class="widgets-section">
            <div class="widgets-container">
                <!--- Authors Widget --->
                <cfif showAuthorsWidget EQ "true">
                    <cfquery name="qAuthorsWidget" datasource="#request.dsn#">
                        SELECT u.id, u.name, u.bio, u.profile_image, 
                               COUNT(p.id) as post_count
                        FROM users u
                        LEFT JOIN posts p ON u.id = p.created_by AND p.status = 'published'
                        GROUP BY u.id
                        HAVING post_count > 0
                        ORDER BY post_count DESC
                        LIMIT 5
                    </cfquery>
                    
                    <div class="widget authors-widget">
                        <h3 class="widget-title">Authors</h3>
                        <div class="authors-list">
                            <cfoutput query="qAuthorsWidget">
                                <cfset authorUrl = "/ghost/author/" & trim(qAuthorsWidget.id) & "/">
                                <a href="#authorUrl#" class="author-item">
                                    <div class="author-avatar">
                                        <cfif len(trim(qAuthorsWidget.profile_image))>
                                            <img src="#qAuthorsWidget.profile_image#" alt="#qAuthorsWidget.name#">
                                        <cfelse>
                                            <span>#left(qAuthorsWidget.name, 1)#</span>
                                        </cfif>
                                    </div>
                                    <div class="author-info">
                                        <h4 class="author-name">#qAuthorsWidget.name#</h4>
                                        <span class="author-posts">#qAuthorsWidget.post_count# post<cfif qAuthorsWidget.post_count NEQ 1>s</cfif></span>
                                    </div>
                                </a>
                            </cfoutput>
                        </div>
                    </div>
                </cfif>
                
                <!--- Tags Widget --->
                <cfif showTagsWidget EQ "true">
                    <cfquery name="qTagsWidget" datasource="#request.dsn#">
                        SELECT t.id, t.name, t.slug, 
                               COUNT(pt.post_id) as post_count
                        FROM tags t
                        LEFT JOIN posts_tags pt ON t.id = pt.tag_id
                        LEFT JOIN posts p ON pt.post_id = p.id AND p.status = 'published'
                        WHERE t.visibility = 'public'
                        GROUP BY t.id
                        HAVING post_count > 0
                        ORDER BY post_count DESC
                        LIMIT 10
                    </cfquery>
                    
                    <div class="widget tags-widget">
                        <h3 class="widget-title">Tags</h3>
                        <div class="tags-cloud">
                            <cfoutput query="qTagsWidget">
                                <cfset cleanTagSlug = replace(trim(qTagsWidget.slug), "\", "", "all")>
                                <cfset tagUrl = "/ghost/tag/" & cleanTagSlug & "/">
                                <a href="#tagUrl#" class="tag-item">
                                    <span class="tag-name">#qTagsWidget.name#</span>
                                    <span class="tag-count">#qTagsWidget.post_count#</span>
                                </a>
                            </cfoutput>
                        </div>
                    </div>
                </cfif>
            </div>
        </section>
    </cfif>
    
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
                &copy; <cfoutput>#year(now())# #siteTitle#</cfoutput> • Powered by <a href="https://ghost.org" target="_blank" rel="noopener">Ghost</a> CFML
            </div>
        </div>
    </footer>
    
    <!--- Code Injection Foot --->
    <cfif len(codeInjectionFoot)>
        <cfoutput>#codeInjectionFoot#</cfoutput>
    </cfif>
    
    <!--- Enhanced Scripts --->
    <script>
        // Header scroll effect
        let lastScroll = 0;
        const header = document.querySelector('.site-header');
        
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > 50) {
                header.classList.add('scrolled');
            } else {
                header.classList.remove('scrolled');
            }
            
            lastScroll = currentScroll;
        });
        
        // Modern Mobile Menu Implementation
        const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
        const mobileMenu = document.querySelector('.mobile-menu');
        const mobileMenuOverlay = document.querySelector('.mobile-menu-overlay');
        const mobileMenuClose = document.querySelector('.mobile-menu-close');
        const body = document.body;
        let menuOpen = false;
        
        // Toggle menu function
        function toggleMenu() {
            menuOpen = !menuOpen;
            
            if (menuOpen) {
                // Show overlay
                mobileMenuOverlay.style.display = 'block';
                requestAnimationFrame(() => {
                    mobileMenuOverlay.classList.add('active');
                });
                
                // Show menu
                mobileMenu.classList.add('active');
                mobileMenuToggle.classList.add('active');
                mobileMenuToggle.setAttribute('aria-expanded', 'true');
                
                // Prevent body scroll
                body.classList.add('menu-open');
                
                // Trap focus
                mobileMenuClose.focus();
            } else {
                // Hide menu
                mobileMenu.classList.remove('active');
                mobileMenuToggle.classList.remove('active');
                mobileMenuToggle.setAttribute('aria-expanded', 'false');
                
                // Hide overlay
                mobileMenuOverlay.classList.remove('active');
                setTimeout(() => {
                    mobileMenuOverlay.style.display = 'none';
                }, 300);
                
                // Restore body scroll
                body.classList.remove('menu-open');
                
                // Return focus to toggle button
                mobileMenuToggle.focus();
            }
        }
        
        // Event listeners
        mobileMenuToggle.addEventListener('click', toggleMenu);
        mobileMenuClose.addEventListener('click', toggleMenu);
        mobileMenuOverlay.addEventListener('click', toggleMenu);
        
        // Close menu on ESC key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && menuOpen) {
                toggleMenu();
            }
        });
        
        // Mark active menu item
        const currentPath = window.location.pathname;
        const mobileMenuLinks = document.querySelectorAll('.mobile-menu-nav a');
        
        mobileMenuLinks.forEach(link => {
            if (link.getAttribute('href') === currentPath) {
                link.classList.add('active');
            }
        });
        
        // Handle menu link clicks
        mobileMenuLinks.forEach(link => {
            link.addEventListener('click', function(e) {
                // If it's an internal link, close the menu
                if (this.hostname === window.location.hostname) {
                    setTimeout(() => {
                        toggleMenu();
                    }, 100);
                }
            });
        });
        
        // Intersection Observer for fade-in animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);
        
        // Observe post cards
        document.querySelectorAll('.post-card').forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            card.style.transition = `all 0.6s ease ${index * 0.1}s`;
            observer.observe(card);
        });
        
        // Add animations
        const style = document.createElement('style');
        style.innerHTML = `
            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateX(20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }
            
            @keyframes slideOut {
                from {
                    opacity: 1;
                    transform: translateX(0);
                }
                to {
                    opacity: 0;
                    transform: translateX(20px);
                }
            }
        `;
        document.head.appendChild(style);
        
        // Load More Posts Function
        async function loadMorePosts(button) {
            const nextPage = button.getAttribute('data-page');
            const container = document.querySelector('.posts-grid');
            const loadMoreContainer = document.querySelector('.load-more-container');
            
            // Show loading state
            button.classList.add('loading');
            
            try {
                // Fetch next page
                const response = await fetch(`/ghost/?page=${nextPage}`);
                const html = await response.text();
                
                // Parse the HTML
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                
                // Get new posts
                const newPosts = doc.querySelectorAll('.posts-grid .post-card');
                const newLoadMore = doc.querySelector('.load-more-container');
                
                // Add new posts with animation
                newPosts.forEach((post, index) => {
                    post.style.opacity = '0';
                    post.style.transform = 'translateY(20px)';
                    container.appendChild(post);
                    
                    // Animate in
                    setTimeout(() => {
                        post.style.transition = 'all 0.6s ease';
                        post.style.opacity = '1';
                        post.style.transform = 'translateY(0)';
                    }, index * 100);
                });
                
                // Update or remove load more button
                if (newLoadMore) {
                    loadMoreContainer.innerHTML = newLoadMore.innerHTML;
                } else {
                    // No more posts
                    loadMoreContainer.innerHTML = '<p class="load-more-info">No more posts to load</p>';
                }
            } catch (error) {
                console.error('Error loading more posts:', error);
                button.classList.remove('loading');
                alert('Failed to load more posts. Please try again.');
            }
        }
    </script>
</body>
</html>