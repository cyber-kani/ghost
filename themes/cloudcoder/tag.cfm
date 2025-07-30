<!--- CloudCoder Theme Tag Template --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">
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

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Additional settings --->
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">
<cfset footerCopyright = structKeyExists(siteSettings, "footer_copyright") ? siteSettings.footer_copyright : "">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "">

<!--- Get tag --->
<cfquery name="qTag" datasource="#request.dsn#">
    SELECT * FROM tags 
    WHERE slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- 404 if tag not found --->
<cfif qTag.recordCount EQ 0>
    <cfheader statuscode="404" statustext="Not Found">
    <cfabort>
</cfif>

<!--- Pagination setup --->
<cfset postsPerPage = 12>
<cfset startRow = ((url.page - 1) * postsPerPage) + 1>

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
    LEFT JOIN users u ON p.created_by = u.id
    INNER JOIN posts_tags pt ON p.id = pt.post_id
    WHERE pt.tag_id = <cfqueryparam value="#qTag.id#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT #postsPerPage# OFFSET #startRow - 1#
</cfquery>

<!--- Get total post count for tag --->
<cfquery name="qPostCount" datasource="#request.dsn#">
    SELECT COUNT(*) as total
    FROM posts p
    INNER JOIN posts_tags pt ON p.id = pt.post_id
    WHERE pt.tag_id = <cfqueryparam value="#qTag.id#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset totalPosts = qPostCount.total>
<cfset totalPages = ceiling(totalPosts / postsPerPage)>

<!DOCTYPE html>
<html lang="en" <cfif darkMode EQ "dark">class="dark"<cfelseif darkMode EQ "auto">class="auto"</cfif>>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title><cfoutput>#qTag.name# - #siteTitle#<cfif url.page GT 1> - Page #url.page#</cfif></cfoutput></title>
    <meta name="description" content="<cfoutput>#len(trim(qTag.description)) ? qTag.description : 'Posts tagged with ' & qTag.name#</cfoutput>">
    
    <!--- Fonts --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    
    <!--- Load heading font --->
    <cfif headingFont EQ "inter">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "roboto">
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "poppins">
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "playfair">
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "merriweather">
        <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@300;400;700;900&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "montserrat">
        <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "raleway">
        <link href="https://fonts.googleapis.com/css2?family=Raleway:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "lora">
        <link href="https://fonts.googleapis.com/css2?family=Lora:wght@400;500;600;700&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "bebas">
        <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "opensans">
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "crimson">
        <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:wght@400;600;700&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "bitter">
        <link href="https://fonts.googleapis.com/css2?family=Bitter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "libre">
        <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:wght@400;700&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "oswald">
        <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "dm-serif">
        <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&display=swap" rel="stylesheet">
    <cfelseif headingFont EQ "abril">
        <link href="https://fonts.googleapis.com/css2?family=Abril+Fatface&display=swap" rel="stylesheet">
    </cfif>
    
    <!--- Load body font if different from heading --->
    <cfif bodyFont NEQ headingFont>
        <cfif bodyFont EQ "inter">
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "roboto">
            <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700;900&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "opensans">
            <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "lato">
            <link href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700;900&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "merriweather">
            <link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@300;400;700;900&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "nunito">
            <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700;800&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "sourcesans">
            <link href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300;400;600;700;900&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "crimson">
            <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:wght@400;600;700&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "libre">
            <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:wght@400;700&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "noto-serif">
            <link href="https://fonts.googleapis.com/css2?family=Noto+Serif:wght@400;700&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "pt-serif">
            <link href="https://fonts.googleapis.com/css2?family=PT+Serif:wght@400;700&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "work-sans">
            <link href="https://fonts.googleapis.com/css2?family=Work+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "karla">
            <link href="https://fonts.googleapis.com/css2?family=Karla:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <cfelseif bodyFont EQ "dm-sans">
            <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
        </cfif>
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
            
            <!--- Body font family --->
            <cfif bodyFont EQ "inter">
            --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            <cfelseif bodyFont EQ "roboto">
            --font-family: 'Roboto', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "opensans">
            --font-family: 'Open Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "lato">
            --font-family: 'Lato', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "merriweather">
            --font-family: 'Merriweather', Georgia, serif;
            <cfelseif bodyFont EQ "georgia">
            --font-family: Georgia, 'Times New Roman', serif;
            <cfelseif bodyFont EQ "nunito">
            --font-family: 'Nunito', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "sourcesans">
            --font-family: 'Source Sans Pro', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "crimson">
            --font-family: 'Crimson Text', Georgia, serif;
            <cfelseif bodyFont EQ "libre">
            --font-family: 'Libre Baskerville', Georgia, serif;
            <cfelseif bodyFont EQ "noto-serif">
            --font-family: 'Noto Serif', Georgia, serif;
            <cfelseif bodyFont EQ "pt-serif">
            --font-family: 'PT Serif', Georgia, serif;
            <cfelseif bodyFont EQ "work-sans">
            --font-family: 'Work Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "karla">
            --font-family: 'Karla', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "dm-sans">
            --font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif bodyFont EQ "helvetica">
            --font-family: Helvetica, Arial, sans-serif;
            <cfelseif bodyFont EQ "arial">
            --font-family: Arial, Helvetica, sans-serif;
            <cfelse>
            --font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            </cfif>
            
            <!--- Heading font family --->
            <cfif headingFont EQ "inter">
            --heading-font: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            <cfelseif headingFont EQ "roboto">
            --heading-font: 'Roboto', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif headingFont EQ "poppins">
            --heading-font: 'Poppins', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif headingFont EQ "playfair">
            --heading-font: 'Playfair Display', Georgia, serif;
            <cfelseif headingFont EQ "merriweather">
            --heading-font: 'Merriweather', Georgia, serif;
            <cfelseif headingFont EQ "montserrat">
            --heading-font: 'Montserrat', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif headingFont EQ "raleway">
            --heading-font: 'Raleway', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif headingFont EQ "lora">
            --heading-font: 'Lora', Georgia, serif;
            <cfelseif headingFont EQ "bebas">
            --heading-font: 'Bebas Neue', Impact, sans-serif;
            <cfelseif headingFont EQ "opensans">
            --heading-font: 'Open Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif headingFont EQ "crimson">
            --heading-font: 'Crimson Text', Georgia, serif;
            <cfelseif headingFont EQ "bitter">
            --heading-font: 'Bitter', Georgia, serif;
            <cfelseif headingFont EQ "libre">
            --heading-font: 'Libre Baskerville', Georgia, serif;
            <cfelseif headingFont EQ "oswald">
            --heading-font: 'Oswald', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            <cfelseif headingFont EQ "dm-serif">
            --heading-font: 'DM Serif Display', Georgia, serif;
            <cfelseif headingFont EQ "abril">
            --heading-font: 'Abril Fatface', Georgia, serif;
            <cfelseif headingFont EQ "georgia">
            --heading-font: Georgia, 'Times New Roman', serif;
            <cfelseif headingFont EQ "helvetica">
            --heading-font: Helvetica, Arial, sans-serif;
            <cfelse>
            --heading-font: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
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
        
        /* Typography */
        h1, h2, h3, h4, h5, h6,
        .tag-hero h1,
        .post-title {
            font-family: var(--heading-font);
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
            padding: 0.5rem 0.75rem;
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
            color: var(--accent-color);
        }
        
        .nav-link.active {
            padding: 0.75rem 1.5rem;
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
        
        /* Tag Hero */
        .tag-hero {
            position: relative;
            padding: 4rem 2rem;
            text-align: center;
            background: linear-gradient(135deg, var(--bg-secondary), var(--bg-primary));
            border-bottom: 1px solid var(--border-color);
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
        
        .tag-hero-overlay {
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
        
        .tag-hero-inner {
            position: relative;
            z-index: 1;
            max-width: 800px;
            margin: 0 auto;
            <cfif len(coverImage)>
            color: white;
            </cfif>
        }
        
        .tag-badge {
            display: inline-block;
            padding: 0.5rem 1.5rem;
            background: var(--accent-color);
            color: white;
            border-radius: 30px;
            font-weight: 600;
            font-size: 0.875rem;
            margin-bottom: 1rem;
        }
        
        .tag-title {
            font-size: 3rem;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 1rem;
            letter-spacing: -0.03em;
        }
        
        .tag-description {
            font-size: 1.25rem;
            color: var(--text-secondary);
            line-height: 1.5;
        }
        
        .tag-count {
            margin-top: 1rem;
            font-size: 1rem;
            color: var(--text-secondary);
        }
        
        /* Main Content */
        .main {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        /* Posts Grid - Same as index */
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
        
        /* Post Card - Same as index */
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
        
        /* Pagination - Same as index */
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
        
        /* Mobile Menu */
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: var(--text-primary);
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: var(--text-secondary);
        }
        
        .empty-state h2 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: var(--text-primary);
        }
        
        /* Footer */
        .site-footer {
            background: var(--bg-secondary);
            padding: 3rem 2rem;
            border-top: 1px solid var(--border-color);
            margin-top: 4rem;
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
            .tag-hero {
                padding: 2rem 1rem;
            }
            
            .tag-title {
                font-size: 2rem;
            }
            
            .tag-description {
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
    
    <!--- Code Injection Head --->
    <cfif len(codeInjectionHead)>
        <cfoutput>#codeInjectionHead#</cfoutput>
    </cfif>
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
                    <cfset isActive = false>
                    <!--- Check if this is the active page/tag --->
                    <cfif navItem.url EQ "/ghost/tag/#url.slug#/">
                        <cfset isActive = true>
                    </cfif>
                    <a href="<cfoutput>#navItem.url#</cfoutput>" class="nav-link<cfif isActive> active</cfif>"><cfoutput>#navItem.label#</cfoutput></a>
                </cfloop>
            </nav>
            
            <button class="mobile-menu-toggle">☰</button>
        </div>
    </header>
    
    <section class="tag-hero" <cfif len(coverImage)>style="background-image: url('<cfoutput>#coverImage#</cfoutput>');"</cfif>>
        <div class="tag-hero-overlay"></div>
        <div class="tag-hero-inner">
            <span class="tag-badge">Tag</span>
            <h1 class="tag-title"><cfoutput>#qTag.name#</cfoutput></h1>
            <cfif len(trim(qTag.description))>
                <p class="tag-description"><cfoutput>#qTag.description#</cfoutput></p>
            </cfif>
            <p class="tag-count"><cfoutput>#totalPosts# post<cfif totalPosts NEQ 1>s</cfif></cfoutput></p>
        </div>
    </section>
    
    <main class="main">
        <cfif qPosts.recordCount GT 0>
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
            
            <!--- Pagination --->
            <cfif totalPages GT 1>
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
        <cfelse>
            <div class="empty-state">
                <h2>No posts yet</h2>
                <p>There are no posts with this tag yet.</p>
            </div>
        </cfif>
    </main>
    
    <!--- Footer --->
    <footer class="site-footer">
        <div class="footer-content">
            <cfif arrayLen(secondaryNav) GT 0>
                <nav class="footer-nav">
                    <cfloop array="#secondaryNav#" index="navItem">
                        <a href="<cfoutput>#navItem.url#</cfoutput>"><cfoutput>#navItem.label#</cfoutput></a>
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