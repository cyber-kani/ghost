<!--- CloudCoder Theme Index Template --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">
<cfparam name="theme" default="#structNew()#">

<!--- Get theme settings --->
<cfquery name="qThemeSettings" datasource="#request.dsn#">
    SELECT `key`, value FROM settings WHERE `key` LIKE 'theme_%'
</cfquery>

<cfset themeSettings = {}>
<cfloop query="qThemeSettings">
    <cfset cleanKey = replace(qThemeSettings.key, "theme_", "")>
    <cfset themeSettings[cleanKey] = qThemeSettings.value>
</cfloop>

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value FROM settings
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Set defaults - Use design settings first, then theme settings as fallback --->
<cfset siteTitle = structKeyExists(siteSettings, "title") ? siteSettings.title : "Blog">
<cfset siteDescription = structKeyExists(siteSettings, "description") ? siteSettings.description : "A modern blog">
<cfset siteLogo = structKeyExists(siteSettings, "logo") ? siteSettings.logo : "">
<cfset siteIcon = structKeyExists(siteSettings, "icon") ? siteSettings.icon : "">

<!--- Use brand colors from design settings --->
<cfset primaryColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : (structKeyExists(themeSettings, "primaryColor") ? themeSettings.primaryColor : "##000000")>
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : (structKeyExists(themeSettings, "accentColor") ? themeSettings.accentColor : "##0066CC")>

<!--- Use typography settings from design --->
<cfset headingFont = structKeyExists(siteSettings, "heading_font") ? siteSettings.heading_font : "inter">
<cfset bodyFont = structKeyExists(siteSettings, "body_font") ? siteSettings.body_font : "inter">
<cfset fontFamily = bodyFont>

<!--- Theme-specific settings --->
<cfset layoutStyle = structKeyExists(themeSettings, "layoutStyle") ? themeSettings.layoutStyle : "cards">
<cfset showAuthorInfo = structKeyExists(siteSettings, "show_author") ? siteSettings.show_author : (structKeyExists(themeSettings, "showAuthorInfo") ? themeSettings.showAuthorInfo : "false")>
<cfset showReadingTime = structKeyExists(themeSettings, "showReadingTime") ? themeSettings.showReadingTime : "true">

<!--- Use color scheme from design settings --->
<cfset colorScheme = structKeyExists(siteSettings, "color_scheme") ? siteSettings.color_scheme : "auto">
<cfset darkMode = colorScheme>

<!--- Additional settings --->
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">
<cfset showAuthorsWidget = structKeyExists(siteSettings, "show_authors_widget") ? siteSettings.show_authors_widget : "false">
<cfset showTagsWidget = structKeyExists(siteSettings, "show_tags_widget") ? siteSettings.show_tags_widget : "false">
<cfset standardLoadMore = structKeyExists(siteSettings, "standard_load_more") ? siteSettings.standard_load_more : "false">
<cfset footerCopyright = structKeyExists(siteSettings, "footer_copyright") ? siteSettings.footer_copyright : "">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Pagination setup --->
<cfset postsPerPage = 12>
<cfset startRow = ((url.page - 1) * postsPerPage) + 1>

<!--- Get featured posts (posts with featured = true) --->
<cfquery name="qFeaturedPosts" datasource="#request.dsn#">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.custom_excerpt,
        p.plaintext,
        p.feature_image,
        p.featured,
        p.published_at,
        p.created_by as author_id,
        u.name as author_name,
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    AND p.featured = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
    ORDER BY p.published_at DESC
    LIMIT 4
</cfquery>

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
        p.created_at,
        p.created_by as author_id,
        u.name as author_name,
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    <cfif url.page EQ 1 AND qFeaturedPosts.recordCount GT 0>
    AND p.featured != <cfqueryparam value="1" cfsqltype="cf_sql_integer">
    </cfif>
    ORDER BY p.published_at DESC
    LIMIT #postsPerPage# OFFSET #startRow - 1#
</cfquery>

<!--- Get total post count --->
<cfquery name="qPostCount" datasource="#request.dsn#">
    SELECT COUNT(*) as total
    FROM posts
    WHERE status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset totalPosts = qPostCount.total>
<cfset totalPages = ceiling(totalPosts / postsPerPage)>

<!DOCTYPE html>
<html lang="en" <cfif darkMode EQ "dark">class="dark"<cfelseif darkMode EQ "auto">class="auto"</cfif>>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title><cfoutput>#siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput></title>
    <meta name="description" content="<cfoutput>#siteDescription#</cfoutput>">
    
    <!--- Fonts --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <cfif fontFamily EQ "inter">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <cfelseif fontFamily EQ "roboto">
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    </cfif>
    
    <!--- Code Injection Head --->
    <cfif len(codeInjectionHead)>
        <cfoutput>#codeInjectionHead#</cfoutput>
    </cfif>
    
    <style>
        :root {
            --primary-color: <cfoutput>#primaryColor#</cfoutput>;
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --text-primary: #000000;
            --text-secondary: #666666;
            --bg-primary: #ffffff;
            --bg-secondary: #f5f5f5;
            --border-color: #e0e0e0;
            --shadow: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-hover: 0 4px 12px rgba(0,0,0,0.15);
            --radius: 12px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            
            <cfif bodyFont EQ "serif">
            --font-family: Georgia, 'Times New Roman', serif;
            <cfelse>
            --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            </cfif>
            
            <cfif headingFont EQ "serif">
            --heading-font: Georgia, 'Times New Roman', serif;
            <cfelseif headingFont EQ "slab">
            --heading-font: 'Roboto Slab', Georgia, serif;
            <cfelse>
            --heading-font: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            </cfif>
        }
        
        <cfif darkMode EQ "dark" OR darkMode EQ "auto">
        @media (prefers-color-scheme: dark) {
            <cfif darkMode EQ "auto">:root {<cfelse>.dark {</cfif>
                --text-primary: #ffffff;
                --text-secondary: #a0a0a0;
                --bg-primary: #000000;
                --bg-secondary: #1a1a1a;
                --border-color: #333333;
            }
        }
        </cfif>
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: var(--font-family);
            color: var(--text-primary);
            background-color: var(--bg-primary);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Header */
        .header {
            position: sticky;
            top: 0;
            background: var(--bg-primary);
            border-bottom: 1px solid var(--border-color);
            z-index: 100;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }
        
        .header-inner {
            max-width: 1200px;
            margin: 0 auto;
            padding: 1rem 2rem;
            display: flex;
            <cfif navigationRight EQ "true">
            justify-content: space-between;
            <cfelse>
            gap: 2rem;
            </cfif>
            align-items: center;
        }
        
        <cfif navigationRight NEQ "true">
        .nav {
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
            font-weight: 700;
            font-size: 1.25rem;
        }
        
        .site-logo img {
            height: 32px;
        }
        
        /* Navigation */
        .nav {
            display: flex;
            gap: 1rem;
        }
        
        .nav-link {
            padding: 0.75rem 1.5rem;
            text-decoration: none;
            color: var(--text-primary);
            background: transparent;
            border-radius: 30px;
            transition: var(--transition);
            font-weight: 500;
            font-size: 0.875rem;
            border: 1px solid transparent;
        }
        
        .nav-link:hover {
            background: var(--bg-secondary);
            transform: translateY(-1px);
        }
        
        .nav-link.active {
            background: #000000;
            color: white;
        }
        
        /* Dark mode navigation */
        <cfif darkMode EQ "dark">
        .dark .nav-link.active {
            background: #ffffff;
            color: #000000;
        }
        
        .dark .nav-link.active:hover {
            background: #e5e5e5;
        }
        <cfelseif darkMode EQ "auto">
        @media (prefers-color-scheme: dark) {
            .nav-link {
                color: #ffffff;
            }
            
            .nav-link.active {
                background: #ffffff;
                color: #000000;
            }
            
            .nav-link.active:hover {
                background: #e5e5e5;
            }
        }
        </cfif>
        
        /* Hero Section */
        .hero {
            position: relative;
            padding: 4rem 2rem;
            text-align: center;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            <cfif len(coverImage)>
            min-height: 300px;
            display: flex;
            align-items: center;
            justify-content: center;
            </cfif>
        }
        
        .hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.4);
            <cfif NOT len(coverImage)>
            display: none;
            </cfif>
        }
        
        .hero-content {
            position: relative;
            z-index: 1;
            max-width: 800px;
            margin: 0 auto;
            <cfif len(coverImage)>
            color: white;
            </cfif>
        }
        
        h1, h2, h3, h4, h5, h6,
        .hero h1,
        .post-title {
            font-family: var(--heading-font);
        }
        
        .hero h1 {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1rem;
            line-height: 1.2;
        }
        
        .hero p {
            font-size: 1.25rem;
            color: var(--text-secondary);
        }
        
        /* Main Content */
        .main {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        /* Featured Posts Section */
        .featured-section {
            margin-bottom: 4rem;
        }
        
        .featured-header {
            margin-bottom: 2rem;
        }
        
        .featured-label {
            display: inline-block;
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.5rem;
        }
        
        .featured-title {
            font-size: 2rem;
            font-weight: 800;
            margin: 0;
            color: var(--text-primary);
        }
        
        /* Featured Grid */
        .featured-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 3rem;
        }
        
        @media (min-width: 768px) {
            .featured-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        /* Featured Card */
        .featured-card {
            position: relative;
            display: block;
            height: 400px;
            background: var(--bg-secondary);
            border-radius: var(--radius);
            overflow: hidden;
            text-decoration: none;
            color: white;
            transition: var(--transition);
        }
        
        .featured-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0,0,0,0.2);
        }
        
        .featured-card-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        
        .featured-card-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition);
        }
        
        .featured-card:hover .featured-card-image img {
            transform: scale(1.05);
        }
        
        .featured-card-gradient {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(180deg, 
                rgba(0,0,0,0) 0%, 
                rgba(0,0,0,0.1) 30%, 
                rgba(0,0,0,0.8) 100%);
            z-index: 1;
        }
        
        .featured-card-content {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            padding: 2rem;
            z-index: 2;
        }
        
        .featured-card-tag {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.75rem;
            border: 1px solid rgba(255,255,255,0.2);
        }
        
        .featured-card-title {
            font-size: 1.5rem;
            font-weight: 700;
            line-height: 1.3;
            margin: 0 0 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .featured-card-excerpt {
            font-size: 0.875rem;
            line-height: 1.5;
            opacity: 0.9;
            margin-bottom: 1rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .featured-card-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.75rem;
            opacity: 0.8;
        }
        
        .featured-author {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .featured-author-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            overflow: hidden;
            background: rgba(255,255,255,0.2);
        }
        
        .featured-author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        /* Posts Grid */
        .posts-grid {
            display: grid;
            <cfif layoutStyle EQ "cards">
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            <cfelseif layoutStyle EQ "list">
            grid-template-columns: 1fr;
            <cfelse>
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            </cfif>
            gap: 2rem;
            margin-bottom: 4rem;
        }
        
        /* Post Card */
        .post-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            overflow: hidden;
            transition: var(--transition);
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
        }
        
        .post-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-hover);
        }
        
        .post-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            transition: var(--transition);
        }
        
        .post-card:hover .post-image {
            transform: scale(1.05);
        }
        
        .post-content {
            padding: 1.5rem;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .post-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            line-height: 1.3;
        }
        
        .post-excerpt {
            color: var(--text-secondary);
            margin-bottom: 1rem;
            flex: 1;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
        }
        
        .post-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
        }
        
        .post-author {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .author-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: var(--accent-color);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }
        
        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 1rem;
            margin-top: 4rem;
        }
        
        .pagination a,
        .pagination span {
            padding: 0.5rem 1rem;
            border-radius: 8px;
            text-decoration: none;
            color: var(--text-primary);
            border: 1px solid var(--border-color);
            transition: var(--transition);
        }
        
        .pagination a:hover {
            background: var(--bg-secondary);
        }
        
        .pagination .current {
            background: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }
        
        /* Load More Button */
        .load-more-container {
            text-align: center;
            margin-top: 4rem;
        }
        
        .load-more-button {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 2rem;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 30px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
        }
        
        .load-more-button:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
        }
        
        .load-more-button.loading {
            opacity: 0.7;
            cursor: not-allowed;
        }
        
        .load-more-button.loading .load-more-text {
            display: none;
        }
        
        .load-more-button.loading .load-more-spinner {
            display: inline-flex !important;
        }
        
        .load-more-info {
            margin-top: 1rem;
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        
        /* Mobile Menu */
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--text-primary);
        }
        
        /* Widgets Section */
        .widgets-section {
            background: var(--bg-secondary);
            padding: 4rem 2rem;
            border-top: 1px solid var(--border-color);
        }
        
        .widgets-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 3rem;
        }
        
        .widget {
            background: var(--bg-primary);
            border-radius: var(--radius);
            padding: 2rem;
            box-shadow: var(--shadow);
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
            border-radius: 8px;
            transition: var(--transition);
        }
        
        .author-item:hover {
            background: var(--bg-secondary);
        }
        
        .author-info h4 {
            margin: 0;
            font-size: 1rem;
            font-weight: 600;
        }
        
        .author-info p {
            margin: 0.25rem 0 0;
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
            gap: 0.25rem;
            padding: 0.5rem 1rem;
            background: var(--bg-secondary);
            border-radius: 20px;
            text-decoration: none;
            color: var(--text-primary);
            font-size: 0.875rem;
            transition: var(--transition);
        }
        
        .tag-item:hover {
            background: var(--accent-color);
            color: white;
            transform: translateY(-1px);
        }
        
        .tag-count {
            opacity: 0.7;
            font-size: 0.75rem;
        }
        
        /* Footer */
        .site-footer {
            background: var(--bg-secondary);
            padding: 3rem 2rem;
            border-top: 1px solid var(--border-color);
        }
        
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
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
            transition: var(--transition);
        }
        
        .footer-nav a:hover {
            color: var(--accent-color);
        }
        
        .footer-copyright {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        
        .footer-copyright a {
            color: var(--text-secondary);
            text-decoration: none;
            border-bottom: 1px solid transparent;
            transition: var(--transition);
        }
        
        .footer-copyright a:hover {
            color: var(--accent-color);
            border-bottom-color: var(--accent-color);
        }
        
        @media (max-width: 768px) {
            .hero h1 {
                font-size: 2rem;
            }
            
            .hero p {
                font-size: 1rem;
            }
            
            .nav {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .posts-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .main {
                padding: 1rem;
            }
            
            .featured-title {
                font-size: 1.5rem;
            }
            
            .featured-grid {
                grid-template-columns: 1fr;
            }
            
            .featured-card {
                height: 300px;
            }
            
            .featured-card-title {
                font-size: 1.25rem;
            }
        }
        
        /* List Layout Specific */
        <cfif layoutStyle EQ "list">
        .post-card {
            flex-direction: row;
            max-height: 200px;
        }
        
        .post-image {
            width: 300px;
            height: 100%;
        }
        
        @media (max-width: 768px) {
            .post-card {
                flex-direction: column;
                max-height: none;
            }
            
            .post-image {
                width: 100%;
                height: 200px;
            }
        }
        </cfif>
    </style>
</head>
<body>
    <!--- Announcement Bar --->
    <cfinclude template="/ghost/includes/announcement-bar.cfm">
    
    <header class="header">
        <div class="header-inner">
            <a href="/ghost/" class="site-logo">
                <cfif len(siteLogo)>
                    <img src="<cfoutput>#siteLogo#</cfoutput>" alt="<cfoutput>#siteTitle#</cfoutput>">
                </cfif>
                <span><cfoutput>#siteTitle#</cfoutput></span>
            </a>
            
            <nav class="nav">
                <cfloop array="#primaryNav#" index="navItem">
                    <cfset isActive = (url.page EQ 1 AND (navItem.url EQ "/" OR navItem.url EQ "/ghost/" OR navItem.url EQ "/ghost"))>
                    <a href="<cfoutput>#navItem.url#</cfoutput>" class="nav-link<cfif isActive> active</cfif>"><cfoutput>#navItem.label#</cfoutput></a>
                </cfloop>
            </nav>
            
            <button class="mobile-menu-toggle">☰</button>
        </div>
    </header>
    
    <!--- Hero Section with Publication Cover --->
    <section class="hero" <cfif len(coverImage)>style="background-image: url('<cfoutput>#coverImage#</cfoutput>');"</cfif>>
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <h1><cfoutput>#siteTitle#</cfoutput></h1>
            <p><cfoutput>#siteDescription#</cfoutput></p>
        </div>
    </section>
    
    <main class="main">
        <!--- Featured Posts Section --->
        <cfif qFeaturedPosts.recordCount GT 0 AND url.page EQ 1>
            <section class="featured-section">
                <div class="featured-header">
                    <div class="featured-label">Featured</div>
                    <h2 class="featured-title">Editor's Picks</h2>
                </div>
                
                <div class="featured-grid">
                    <cfoutput query="qFeaturedPosts">
                        <!--- Get primary tag --->
                        <cfquery name="qPrimaryTag" datasource="#request.dsn#">
                            SELECT t.name, t.slug 
                            FROM tags t
                            INNER JOIN posts_tags pt ON t.id = pt.tag_id
                            WHERE pt.post_id = <cfqueryparam value="#qFeaturedPosts.id#" cfsqltype="cf_sql_varchar">
                            ORDER BY pt.sort_order
                            LIMIT 1
                        </cfquery>
                        
                        <a href="/ghost/#qFeaturedPosts.slug#/" class="featured-card">
                            <cfif len(trim(qFeaturedPosts.feature_image))>
                                <div class="featured-card-image">
                                    <img src="#qFeaturedPosts.feature_image#" 
                                         alt="#htmlEditFormat(qFeaturedPosts.title)#" 
                                         loading="lazy">
                                </div>
                            </cfif>
                            
                            <div class="featured-card-gradient"></div>
                            
                            <div class="featured-card-content">
                                <cfif qPrimaryTag.recordCount>
                                    <span class="featured-card-tag">#qPrimaryTag.name#</span>
                                </cfif>
                                
                                <h3 class="featured-card-title">#qFeaturedPosts.title#</h3>
                                
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
                                <cfif len(excerpt)>
                                    <p class="featured-card-excerpt">#excerpt#</p>
                                </cfif>
                                
                                <div class="featured-card-meta">
                                    <cfif showAuthorInfo EQ "true">
                                        <div class="featured-author">
                                            <cfif len(trim(qFeaturedPosts.author_profile_image))>
                                                <div class="featured-author-avatar">
                                                    <img src="#qFeaturedPosts.author_profile_image#" 
                                                         alt="#qFeaturedPosts.author_name#">
                                                </div>
                                            </cfif>
                                            <span>#qFeaturedPosts.author_name#</span>
                                        </div>
                                    </cfif>
                                    
                                    <time datetime="#dateFormat(qFeaturedPosts.published_at, 'yyyy-mm-dd')#">
                                        #dateFormat(qFeaturedPosts.published_at, 'mmm d, yyyy')#
                                    </time>
                                </div>
                            </div>
                        </a>
                    </cfoutput>
                </div>
            </section>
        </cfif>
        
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
                
                <a href="/ghost/#qPosts.slug#/" class="post-card">
                    <cfif len(trim(qPosts.feature_image))>
                        <img src="#qPosts.feature_image#" alt="#htmlEditFormat(qPosts.title)#" class="post-image" loading="lazy">
                    </cfif>
                    
                    <div class="post-content">
                        <h2 class="post-title">#qPosts.title#</h2>
                        
                        <cfif len(excerpt)>
                            <p class="post-excerpt">#excerpt#</p>
                        </cfif>
                        
                        <div class="post-meta">
                            <cfif showAuthorInfo EQ "true">
                                <div class="post-author">
                                    <div class="author-avatar">
                                        <cfif len(trim(qPosts.author_profile_image))>
                                            <img src="#qPosts.author_profile_image#" alt="#qPosts.author_name#">
                                        <cfelse>
                                            #left(qPosts.author_name, 1)#
                                        </cfif>
                                    </div>
                                    <span>#qPosts.author_name#</span>
                                </div>
                            </cfif>
                            
                            <time datetime="#dateFormat(qPosts.published_at, 'yyyy-mm-dd')#">
                                #dateFormat(qPosts.published_at, 'mmm dd, yyyy')#
                            </time>
                            
                            <cfif showReadingTime EQ "true">
                                <span>#readingTime# min read</span>
                            </cfif>
                        </div>
                    </div>
                </a>
            </cfoutput>
        </div>
        
        <!--- Pagination or Load More --->
        <cfif totalPages GT 1>
            <cfif standardLoadMore EQ "true">
                <!--- Load More Button --->
                <cfif url.page LT totalPages>
                    <div class="load-more-container">
                        <button class="load-more-button" onclick="loadMorePosts()">
                            <span class="load-more-text">Load More</span>
                            <span class="load-more-spinner" style="display: none;">
                                <svg width="20" height="20" viewBox="0 0 20 20">
                                    <circle cx="10" cy="10" r="8" stroke="currentColor" stroke-width="2" fill="none" stroke-dasharray="25.12" stroke-dashoffset="25.12" stroke-linecap="round">
                                        <animateTransform attributeName="transform" type="rotate" dur="1s" repeatCount="indefinite" from="0 10 10" to="360 10 10"/>
                                    </circle>
                                </svg>
                            </span>
                        </button>
                        <p class="load-more-info">Page #url.page# of #totalPages#</p>
                    </div>
                    
                    <script>
                    let currentPage = <cfoutput>#url.page#</cfoutput>;
                    const totalPages = <cfoutput>#totalPages#</cfoutput>;
                    let isLoading = false;
                    
                    function loadMorePosts() {
                        if (isLoading || currentPage >= totalPages) return;
                        
                        isLoading = true;
                        const button = document.querySelector('.load-more-button');
                        button.classList.add('loading');
                        
                        currentPage++;
                        
                        fetch(`?page=${currentPage}`)
                            .then(response => response.text())
                            .then(html => {
                                const parser = new DOMParser();
                                const doc = parser.parseFromString(html, 'text/html');
                                const newPosts = doc.querySelectorAll('.post-card');
                                const grid = document.querySelector('.posts-grid');
                                
                                newPosts.forEach(post => {
                                    grid.appendChild(post.cloneNode(true));
                                });
                                
                                button.classList.remove('loading');
                                isLoading = false;
                                
                                document.querySelector('.load-more-info').textContent = `Page ${currentPage} of ${totalPages}`;
                                
                                if (currentPage >= totalPages) {
                                    document.querySelector('.load-more-container').style.display = 'none';
                                }
                            })
                            .catch(error => {
                                console.error('Error loading more posts:', error);
                                button.classList.remove('loading');
                                isLoading = false;
                            });
                    }
                    </script>
                </cfif>
            <cfelse>
                <!--- Standard Pagination --->
                <nav class="pagination">
                    <cfif url.page GT 1>
                        <a href="?page=#url.page - 1#">← Previous</a>
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
                            <span class="current">#i#</span>
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
                        <a href="?page=#url.page + 1#">Next →</a>
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
                    <cfquery name="qAuthors" datasource="#request.dsn#">
                        SELECT id, name, bio, profile_image
                        FROM users
                        WHERE status = 'active'
                        ORDER BY name
                    </cfquery>
                    
                    <cfif qAuthors.recordCount>
                        <div class="widget">
                            <h3 class="widget-title">Authors</h3>
                            <div class="authors-list">
                                <cfoutput query="qAuthors">
                                    <a href="/ghost/author/#qAuthors.id#/" class="author-item">
                                        <div class="author-avatar">
                                            <cfif len(trim(qAuthors.profile_image))>
                                                <img src="#qAuthors.profile_image#" alt="#qAuthors.name#">
                                            <cfelse>
                                                <span>#left(qAuthors.name, 1)#</span>
                                            </cfif>
                                        </div>
                                        <div class="author-info">
                                            <h4>#qAuthors.name#</h4>
                                            <cfif len(trim(qAuthors.bio))>
                                                <p>#left(qAuthors.bio, 100)#<cfif len(qAuthors.bio) GT 100>...</cfif></p>
                                            </cfif>
                                        </div>
                                    </a>
                                </cfoutput>
                            </div>
                        </div>
                    </cfif>
                </cfif>
                
                <!--- Tags Widget --->
                <cfif showTagsWidget EQ "true">
                    <cfquery name="qTags" datasource="#request.dsn#">
                        SELECT t.id, t.name, t.slug, COUNT(pt.post_id) as post_count
                        FROM tags t
                        LEFT JOIN posts_tags pt ON t.id = pt.tag_id
                        LEFT JOIN posts p ON pt.post_id = p.id AND p.status = 'published'
                        WHERE t.visibility = 'public'
                        GROUP BY t.id, t.name, t.slug
                        HAVING post_count > 0
                        ORDER BY post_count DESC, t.name
                        LIMIT 20
                    </cfquery>
                    
                    <cfif qTags.recordCount>
                        <div class="widget">
                            <h3 class="widget-title">Tags</h3>
                            <div class="tags-cloud">
                                <cfoutput query="qTags">
                                    <a href="/ghost/tag/#qTags.slug#/" class="tag-item">
                                        #qTags.name# <span class="tag-count">(#qTags.post_count#)</span>
                                    </a>
                                </cfoutput>
                            </div>
                        </div>
                    </cfif>
                </cfif>
            </div>
        </section>
    </cfif>
    
    <!--- Footer --->
    <footer class="site-footer">
        <div class="footer-content">
            <cfif arrayLen(secondaryNav) GT 0>
                <nav class="footer-nav">
                    <cfloop array="#secondaryNav#" index="navItem">
                        <a href="#navItem.url#">#navItem.label#</a>
                    </cfloop>
                </nav>
            </cfif>
            
            <div class="footer-copyright">
                <cfif len(footerCopyright)>
                    <cfoutput>#footerCopyright#</cfoutput>
                <cfelse>
                    &copy; <cfoutput>#year(now())# #siteTitle#</cfoutput> • Powered by <a href="https://ghost.org" target="_blank" rel="noopener">Ghost</a> CFML
                </cfif>
            </div>
        </div>
    </footer>
    
    <!--- Code Injection Foot --->
    <cfif len(codeInjectionFoot)>
        <cfoutput>#codeInjectionFoot#</cfoutput>
    </cfif>
</body>
</html>