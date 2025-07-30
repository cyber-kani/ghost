<cfsetting enablecfoutputonly="true"><!--- Tag Archive Page with Modern Design --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">
<cfparam name="url.page" default="1">

<!--- Get tag by slug --->
<cfquery name="qTag" datasource="#request.dsn#">
    SELECT * FROM tags
    WHERE slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
    LIMIT 1
</cfquery>

<!--- If tag not found, show 404 --->
<cfif qTag.recordCount EQ 0>
    <cfheader statuscode="404" statustext="Not Found">
    <cfcontent reset="true">
    <cfoutput><!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>404 - Tag not found</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; background: ##f5f5f7; }
            .error-container { text-align: center; }
            h1 { font-size: 4rem; margin: 0; color: ##1d1d1f; }
            p { font-size: 1.25rem; color: ##6e6e73; margin: 1rem 0 2rem; }
            a { color: ##0066cc; text-decoration: none; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="error-container">
            <h1>404</h1>
            <p>The tag you're looking for doesn't exist.</p>
            <a href="/ghost/">← Back to blog</a>
        </div>
    </body>
    </html>
    </cfoutput>
    <cfabort>
</cfif>

<!--- Pagination setup --->
<cfset postsPerPage = 12>
<cfset startRow = ((url.page - 1) * postsPerPage) + 1>

<!--- Get total post count for this tag --->
<cfquery name="qPostCount" datasource="#request.dsn#">
    SELECT COUNT(DISTINCT p.id) as total
    FROM posts p
    INNER JOIN posts_tags pt ON p.id = pt.post_id
    WHERE pt.tag_id = <cfqueryparam value="#qTag.id#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset totalPosts = qPostCount.total>
<cfset totalPages = ceiling(totalPosts / postsPerPage)>

<!--- Get posts for this tag --->
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
    INNER JOIN posts_tags pt ON p.id = pt.post_id
    LEFT JOIN users u ON p.created_by = u.id
    WHERE pt.tag_id = <cfqueryparam value="#qTag.id#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT #postsPerPage# OFFSET #startRow - 1#
</cfquery>

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
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<cfoutput><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <!--- SEO Meta Tags --->
    <title><cfoutput>#qTag.name# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>Posts tagged with #qTag.name# on #siteTitle#<cfif len(trim(qTag.description))> - #qTag.description#</cfif></cfoutput>">
    <link rel="canonical" href="<cfoutput>/ghost/tag/#qTag.slug#/<cfif url.page GT 1>?page=#url.page#</cfif></cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="website">
    <meta property="og:title" content="<cfoutput>#qTag.name# - #siteTitle#</cfoutput>">
    <meta property="og:description" content="<cfoutput>Posts tagged with #qTag.name#<cfif len(trim(qTag.description))> - #qTag.description#</cfif></cfoutput>">
    <meta property="og:url" content="<cfoutput>/ghost/tag/#qTag.slug#/</cfoutput>">
    <cfif len(qTag.feature_image)>
        <meta property="og:image" content="<cfoutput>#qTag.feature_image#</cfoutput>">
    </cfif>
    
    <!--- Twitter Card --->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<cfoutput>#qTag.name# - #siteTitle#</cfoutput>">
    <meta name="twitter:description" content="<cfoutput>Posts tagged with #qTag.name#<cfif len(trim(qTag.description))> - #qTag.description#</cfif></cfoutput>">
    <cfif len(qTag.feature_image)>
        <meta name="twitter:image" content="<cfoutput>#qTag.feature_image#</cfoutput>">
    </cfif>
    
    <!--- Favicon --->
    <cfif len(siteIcon)>
        <link rel="icon" href="<cfoutput>#siteIcon#</cfoutput>" type="image/png">
        <link rel="apple-touch-icon" href="<cfoutput>#siteIcon#</cfoutput>">
    </cfif>
    
    <!--- Fonts --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!--- Modern CSS --->
    <style>
        :root {
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --text-primary: ##1d1d1f;
            --text-secondary: ##6e6e73;
            --text-tertiary: ##86868b;
            --bg-primary: ##ffffff;
            --bg-secondary: ##f5f5f7;
            --bg-tertiary: ##fbfbfd;
            --border-color: ##d2d2d7;
            --border-light: ##e8e8ed;
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.04);
            --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
            --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1);
            --radius-sm: 0.5rem;
            --radius-md: 0.75rem;
            --radius-lg: 1rem;
            --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            --max-width-wide: 1200px;
        }
        
        <cfif colorScheme EQ "dark">
            /* Force dark mode */
            :root {
                --text-primary: ##f5f5f7;
                --text-secondary: ##a1a1a6;
                --text-tertiary: ##6e6e73;
                --bg-primary: ##000000;
                --bg-secondary: ##1d1d1f;
                --bg-tertiary: ##2d2d30;
                --border-color: ##38383d;
                --border-light: ##48484e;
            }
        <cfelseif colorScheme EQ "auto">
            @media (prefers-color-scheme: dark) {
                :root {
                    --text-primary: ##f5f5f7;
                    --text-secondary: ##a1a1a6;
                    --text-tertiary: ##6e6e73;
                    --bg-primary: ##000000;
                    --bg-secondary: ##1d1d1f;
                    --bg-tertiary: ##2d2d30;
                    --border-color: ##38383d;
                    --border-light: ##48484e;
                }
            }
        </cfif>
        
        * {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            font-family: var(--font-sans);
            font-size: 17px;
            line-height: 1.47059;
            font-weight: 400;
            letter-spacing: -0.022em;
            color: var(--text-primary);
            background-color: var(--bg-primary);
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Header */
        .site-header {
            backdrop-filter: saturate(180%) blur(20px);
            -webkit-backdrop-filter: saturate(180%) blur(20px);
            border-bottom: 1px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        <cfif colorScheme EQ "light">
            .site-header {
                background-color: rgba(255, 255, 255, 0.72);
            }
        <cfelseif colorScheme EQ "dark">
            .site-header {
                background-color: rgba(29, 29, 31, 0.72);
            }
        <cfelse>
            .site-header {
                background-color: rgba(255, 255, 255, 0.72);
            }
            @media (prefers-color-scheme: dark) {
                .site-header {
                    background-color: rgba(29, 29, 31, 0.72);
                }
            }
        </cfif>
        
        .header-inner {
            max-width: var(--max-width-wide);
            margin: 0 auto;
            padding: 0 22px;
            height: 70px;
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
            text-decoration: none !important;
            color: var(--text-primary);
            font-size: 21px;
            font-weight: 600;
            letter-spacing: 0.011em;
        }
        
        .site-logo:hover {
            text-decoration: none !important;
            opacity: 0.9;
        }
        
        .site-logo img {
            height: 30px;
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
            color: var(--text-primary);
            text-decoration: none;
            font-size: 17px;
            font-weight: 400;
            transition: var(--transition);
            opacity: 0.8;
        }
        
        .nav-menu a:hover {
            opacity: 1;
            color: var(--accent-color);
        }
        
        /* Tag Header */
        .tag-header {
            position: relative;
            text-align: center;
            <cfif len(coverImage) OR len(trim(qTag.feature_image))>
            background-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.6)), url('<cfoutput><cfif len(coverImage)>#coverImage#<cfelseif len(trim(qTag.feature_image))>#qTag.feature_image#</cfif></cfoutput>');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 120px 22px 80px !important;
            margin: 0;
            max-width: none;
            width: 100%;
            <cfelse>
            background-color: var(--bg-secondary);
            padding: 80px 22px 48px;
            max-width: var(--max-width-wide);
            margin: 0 auto;
            width: 100%;
            </cfif>
        }
        
        .tag-header-image {
            position: relative;
            height: 400px;
            overflow: hidden;
        }
        
        .tag-header-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .tag-header-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.6));
        }
        
        .tag-header-content {
            <cfif len(coverImage) OR len(trim(qTag.feature_image))>
            position: relative;
            z-index: 2;
            <cfelse>
            position: relative;
            </cfif>
        }
        
        .tag-accent {
            <cfif len(qTag.accent_color)>
            width: 80px;
            height: 80px;
            background-color: <cfoutput>#qTag.accent_color#</cfoutput>;
            border-radius: 50%;
            margin: 0 auto 24px;
            <cfelse>
            display: none;
            </cfif>
        }
        
        .tag-title {
            font-size: 48px;
            font-weight: 700;
            line-height: 1.0625;
            letter-spacing: -0.003em;
            margin: 0 0 16px;
            position: relative;
            display: inline-block;
            <cfif len(coverImage) OR len(trim(qTag.feature_image))>
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
            <cfelse>
            color: var(--text-primary);
            </cfif>
        }
        
        .tag-title .underline-wrap {
            position: relative;
            display: inline;
            background-image: linear-gradient(to right, var(--accent-color), var(--accent-color));
            background-repeat: no-repeat;
            background-position: 0 95%;
            background-size: 0% 5px;
            transition: background-size 1.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        .tag-title:hover .underline-wrap {
            background-size: 100% 5px;
        }
        
        .tag-description {
            font-size: 21px;
            line-height: 1.381;
            font-weight: 400;
            letter-spacing: 0.011em;
            margin: 0 0 24px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            <cfif len(coverImage) OR len(trim(qTag.feature_image))>
            color: rgba(255, 255, 255, 0.9);
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
            <cfelse>
            color: var(--text-secondary);
            </cfif>
        }
        
        .tag-meta {
            font-size: 17px;
            <cfif len(coverImage) OR len(trim(qTag.feature_image))>
            color: rgba(255, 255, 255, 0.8);
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
            <cfelse>
            color: var(--text-secondary);
            </cfif>
        }
        
        /* Main Content */
        .main-content {
            max-width: var(--max-width-wide);
            margin: 0 auto;
            padding: 64px 22px;
        }
        
        /* Posts Grid */
        .posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 32px;
            margin-bottom: 64px;
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
            padding-top: 56.25%;
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
            padding: 24px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .post-card-title {
            font-size: 24px;
            font-weight: 600;
            line-height: 1.3;
            margin: 0 0 12px;
            flex: 1;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            position: relative;
        }
        
        .post-card-title .underline-wrap {
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
            font-size: 17px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin: 0 0 16px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .post-card-meta {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 15px;
            color: var(--text-tertiary);
            margin-top: auto;
        }
        
        .post-author {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .author-avatar {
            width: 28px;
            height: 28px;
            min-width: 28px;
            min-height: 28px;
            max-width: 28px;
            max-height: 28px;
            border-radius: 50%;
            background-color: var(--accent-color);
            flex-shrink: 0;
            flex-grow: 0;
            overflow: hidden;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 600;
            color: white;
            text-transform: uppercase;
            line-height: 1;
            text-align: center;
            padding: 0;
            aspect-ratio: 1 / 1;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .meta-divider {
            color: var(--border-color);
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }
        
        .pagination a,
        .pagination span {
            padding: 10px 16px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 500;
            font-size: 15px;
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
            border-top: 1px solid var(--border-light);
            padding: 48px 0;
            text-align: center;
        }
        
        .footer-content {
            max-width: var(--max-width-wide);
            margin: 0 auto;
            padding: 0 22px;
        }
        
        .footer-copyright {
            color: var(--text-tertiary);
            font-size: 15px;
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
            color: var(--text-primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 1.125rem;
        }
        
        .mobile-menu-logo img {
            width: 32px;
            height: 32px;
            border-radius: 6px;
        }
        
        .mobile-menu-close {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-secondary);
            transition: var(--transition);
            border-radius: 8px;
        }
        
        .mobile-menu-close:hover {
            background-color: var(--bg-secondary);
            color: var(--text-primary);
        }
        
        /* Mobile Menu Navigation */
        .mobile-menu-nav {
            padding: 24px 0;
        }
        
        .mobile-menu-nav ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .mobile-menu-nav li {
            margin: 0;
        }
        
        .mobile-menu-nav a {
            display: block;
            padding: 16px 24px;
            color: var(--text-primary);
            text-decoration: none;
            font-size: 1.0625rem;
            font-weight: 500;
            transition: var(--transition);
            border-left: 3px solid transparent;
        }
        
        .mobile-menu-nav a:hover,
        .mobile-menu-nav a.active {
            background-color: var(--bg-secondary);
            border-left-color: var(--accent-color);
            color: var(--accent-color);
        }
        
        /* Mobile Menu Footer */
        .mobile-menu-footer {
            margin-top: auto;
            padding: 24px;
            border-top: 1px solid var(--border-light);
        }
        
        .mobile-menu-secondary {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 20px;
        }
        
        .secondary-link {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9375rem;
            transition: var(--transition);
        }
        
        .secondary-link:hover {
            color: var(--accent-color);
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .nav-menu {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .tag-header {
                padding: 48px 22px 32px;
            }
            
            .tag-title {
                font-size: 32px;
            }
            
            .tag-description {
                font-size: 18px;
            }
            
            .posts-grid {
                grid-template-columns: 1fr;
                gap: 24px;
            }
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 80px 22px;
        }
        
        .empty-state-icon {
            font-size: 64px;
            color: var(--text-tertiary);
            margin-bottom: 24px;
        }
        
        .empty-state-title {
            font-size: 28px;
            font-weight: 600;
            margin: 0 0 16px;
            color: var(--text-primary);
        }
        
        .empty-state-text {
            font-size: 18px;
            color: var(--text-secondary);
            margin: 0 0 32px;
        }
        
        .empty-state-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background-color: var(--accent-color);
            color: white;
            text-decoration: none;
            border-radius: 980px;
            font-weight: 500;
            transition: var(--transition);
        }
        
        .empty-state-link:hover {
            transform: scale(1.05);
            box-shadow: var(--shadow-md);
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
    
    <!--- Tag Header --->
    <section class="tag-header">
        <cfif len(trim(qTag.feature_image))>
            <div class="tag-header-image">
                <img src="<cfoutput>#qTag.feature_image#</cfoutput>" alt="<cfoutput>#qTag.name#</cfoutput>" loading="lazy">
                <div class="tag-header-overlay"></div>
            </div>
        </cfif>
        <div class="tag-header-content">
            <div class="tag-accent"></div>
            <h1 class="tag-title"><span class="underline-wrap"><cfoutput>#qTag.name#</cfoutput></span></h1>
            <cfif len(trim(qTag.description))>
                <p class="tag-description"><cfoutput>#qTag.description#</cfoutput></p>
            </cfif>
            <p class="tag-meta">
                <cfoutput>#totalPosts# post<cfif totalPosts NEQ 1>s</cfif></cfoutput>
            </p>
        </div>
    </section>
    
    <!--- Main Content --->
    <main class="main-content">
        <cfif qPosts.recordCount GT 0>
            <!--- Posts Grid --->
            <div class="posts-grid">
                <cfoutput query="qPosts">
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
                                         loading="lazy">
                                </div>
                            </cfif>
                            
                            <div class="post-card-content">
                                <h2 class="post-card-title"><span class="underline-wrap">#qPosts.title#</span></h2>
                                
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
                    
                    <cfset startPage = max(1, url.page - 2)>
                    <cfset endPage = min(totalPages, url.page + 2)>
                    
                    <cfif startPage GT 1>
                        <a href="?page=1">1</a>
                        <cfif startPage GT 2>
                            <span>...</span>
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
                            <span>...</span>
                        </cfif>
                        <a href="?page=#totalPages#">#totalPages#</a>
                    </cfif>
                    
                    <cfif url.page LT totalPages>
                        <a href="?page=#url.page + 1#" rel="next">Next →</a>
                    </cfif>
                </nav>
            </cfif>
        <cfelse>
            <!--- Empty State --->
            <div class="empty-state">
                <div class="empty-state-icon">📝</div>
                <h2 class="empty-state-title">No posts yet</h2>
                <p class="empty-state-text">No posts have been published with this tag.</p>
                <a href="/ghost/" class="empty-state-link">
                    ← Back to all posts
                </a>
            </div>
        </cfif>
    </main>
    
    <!--- Footer --->
    <footer class="site-footer">
        <div class="footer-content">
            <p class="footer-copyright">
                &copy; <cfoutput>#year(now())# #siteTitle#</cfoutput> • Powered by Ghost CFML
            </p>
        </div>
    </footer>
    
    <!--- Code Injection Foot --->
    <cfif len(codeInjectionFoot)>
        <cfoutput>#codeInjectionFoot#</cfoutput>
    </cfif>
    
    <!--- Scripts --->
    <script>
        // Mobile Menu Toggle
        const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
        const navMenu = document.querySelector('.nav-menu');
        
        mobileMenuToggle.addEventListener('click', function() {
            const isExpanded = this.getAttribute('aria-expanded') === 'true';
            this.setAttribute('aria-expanded', !isExpanded);
            
            navMenu.style.display = isExpanded ? 'none' : 'flex';
            navMenu.style.position = 'absolute';
            navMenu.style.top = '100%';
            navMenu.style.right = '0';
            navMenu.style.background = 'var(--bg-primary)';
            navMenu.style.flexDirection = 'column';
            navMenu.style.padding = '1rem';
            navMenu.style.border = '1px solid var(--border-color)';
            navMenu.style.borderRadius = 'var(--radius-md)';
            navMenu.style.boxShadow = 'var(--shadow-lg)';
        });
    </script>
</body>
</html>
</cfoutput>