<!--- CloudCoder Theme Post Template --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">
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

<!--- Use brand colors from design settings --->
<cfset primaryColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : (structKeyExists(themeSettings, "primaryColor") ? themeSettings.primaryColor : "##000000")>
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : (structKeyExists(themeSettings, "accentColor") ? themeSettings.accentColor : "##0066CC")>

<!--- Use typography settings from design --->
<cfset headingFont = structKeyExists(siteSettings, "heading_font") ? siteSettings.heading_font : "sans-serif">
<cfset bodyFont = structKeyExists(siteSettings, "body_font") ? siteSettings.body_font : "sans-serif">

<!--- Theme-specific settings --->
<cfset showAuthorInfo = structKeyExists(siteSettings, "show_author") ? siteSettings.show_author : (structKeyExists(themeSettings, "showAuthorInfo") ? themeSettings.showAuthorInfo : "false")>
<cfset showReadingTime = structKeyExists(themeSettings, "showReadingTime") ? themeSettings.showReadingTime : "true">

<!--- Use color scheme from design settings --->
<cfset colorScheme = structKeyExists(siteSettings, "color_scheme") ? siteSettings.color_scheme : "auto">
<cfset darkMode = colorScheme>

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Additional settings --->
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">
<cfset footerCopyright = structKeyExists(siteSettings, "footer_copyright") ? siteSettings.footer_copyright : "">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "">

<!--- Get post --->
<cfquery name="qPost" datasource="#request.dsn#">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.html,
        p.plaintext,
        p.feature_image,
        p.published_at,
        p.updated_at,
        p.created_by as author_id,
        p.custom_excerpt,
        u.name as author_name,
        u.bio as author_bio,
        u.profile_image as author_profile_image,
        u.website as author_website
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- 404 if post not found --->
<cfif qPost.recordCount EQ 0>
    <cfheader statuscode="404" statustext="Not Found">
    <cfabort>
</cfif>

<!--- Calculate reading time --->
<cfset wordCount = listLen(qPost.plaintext, " ")>
<cfset readingTime = ceiling(wordCount / 200)>
<cfif readingTime EQ 0>
    <cfset readingTime = 1>
</cfif>

<!--- Get related posts --->
<cfquery name="qRelatedPosts" datasource="#request.dsn#">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.custom_excerpt,
        p.plaintext,
        p.feature_image,
        p.published_at
    FROM posts p
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    AND p.id != <cfqueryparam value="#qPost.id#" cfsqltype="cf_sql_varchar">
    ORDER BY p.published_at DESC
    LIMIT 3
</cfquery>

<!DOCTYPE html>
<html lang="en" <cfif darkMode EQ "dark">class="dark"<cfelseif darkMode EQ "auto">class="auto"</cfif>>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title><cfoutput>#qPost.title# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#len(trim(qPost.custom_excerpt)) ? qPost.custom_excerpt : left(qPost.plaintext, 160)#</cfoutput>">
    
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
        
        /* Article */
        .article {
            max-width: 800px;
            margin: 0 auto;
            padding: 4rem 2rem;
        }
        
        .article-header {
            margin-bottom: 3rem;
            text-align: center;
        }
        
        .article-meta {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 2rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
        }
        
        /* Typography */
        h1, h2, h3, h4, h5, h6,
        .article-title {
            font-family: var(--heading-font);
        }
        
        .article-title {
            font-size: 3rem;
            font-weight: 800;
            line-height: 1.2;
            margin-bottom: 1rem;
            letter-spacing: -0.03em;
        }
        
        .article-excerpt {
            font-size: 1.25rem;
            color: var(--text-secondary);
            line-height: 1.5;
        }
        
        /* Feature Image */
        .feature-image {
            margin: 3rem -2rem;
            border-radius: var(--radius);
            overflow: hidden;
        }
        
        .feature-image img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        /* Article Content */
        .article-content {
            font-size: 1.125rem;
            line-height: 1.8;
            color: var(--text-primary);
        }
        
        .article-content h1,
        .article-content h2,
        .article-content h3,
        .article-content h4,
        .article-content h5,
        .article-content h6 {
            font-weight: 700;
            margin: 2rem 0 1rem;
            line-height: 1.3;
            letter-spacing: -0.02em;
        }
        
        .article-content h2 {
            font-size: 2rem;
        }
        
        .article-content h3 {
            font-size: 1.5rem;
        }
        
        .article-content p {
            margin-bottom: 1.5rem;
        }
        
        .article-content a {
            color: var(--accent-color);
            text-decoration: none;
            border-bottom: 1px solid transparent;
            transition: var(--transition);
        }
        
        .article-content a:hover {
            border-bottom-color: var(--accent-color);
        }
        
        .article-content img {
            max-width: 100%;
            height: auto;
            margin: 2rem 0;
            border-radius: var(--radius);
        }
        
        .article-content blockquote {
            margin: 2rem 0;
            padding: 1rem 2rem;
            border-left: 4px solid var(--accent-color);
            background: var(--bg-secondary);
            font-style: italic;
            color: var(--text-secondary);
            border-radius: 0 var(--radius) var(--radius) 0;
        }
        
        .article-content code {
            background: var(--bg-secondary);
            padding: 0.2rem 0.4rem;
            border-radius: 4px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 0.9em;
        }
        
        .article-content pre {
            background: var(--bg-secondary);
            padding: 1.5rem;
            border-radius: var(--radius);
            overflow-x: auto;
            margin: 2rem 0;
        }
        
        .article-content pre code {
            background: none;
            padding: 0;
        }
        
        .article-content ul,
        .article-content ol {
            margin: 1.5rem 0;
            padding-left: 2rem;
        }
        
        .article-content li {
            margin-bottom: 0.5rem;
        }
        
        /* Author Info */
        .author-info {
            margin-top: 4rem;
            padding: 2rem;
            background: var(--bg-secondary);
            border-radius: var(--radius);
            display: flex;
            gap: 1.5rem;
            align-items: center;
        }
        
        .author-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            overflow: hidden;
            flex-shrink: 0;
        }
        
        .author-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .author-avatar-placeholder {
            width: 100%;
            height: 100%;
            background: var(--accent-color);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 600;
        }
        
        .author-details h3 {
            font-size: 1.25rem;
            margin-bottom: 0.5rem;
        }
        
        .author-details p {
            color: var(--text-secondary);
            margin: 0;
        }
        
        /* Related Posts */
        .related-posts {
            max-width: 1200px;
            margin: 0 auto;
            padding: 4rem 2rem;
        }
        
        .related-posts h2 {
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 2rem;
            letter-spacing: -0.02em;
        }
        
        .related-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 2rem;
        }
        
        .related-card {
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            overflow: hidden;
            transition: var(--transition);
            text-decoration: none;
            color: inherit;
        }
        
        .related-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-hover);
        }
        
        .related-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        
        .related-content {
            padding: 1.5rem;
        }
        
        .related-title {
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            line-height: 1.3;
        }
        
        .related-excerpt {
            color: var(--text-secondary);
            font-size: 0.875rem;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
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
            .article {
                padding: 2rem 1rem;
            }
            
            .article-title {
                font-size: 2rem;
            }
            
            .article-excerpt {
                font-size: 1rem;
            }
            
            .feature-image {
                margin: 2rem -1rem;
                border-radius: 0;
            }
            
            .article-content {
                font-size: 1rem;
            }
            
            .article-content h2 {
                font-size: 1.5rem;
            }
            
            .article-content h3 {
                font-size: 1.25rem;
            }
            
            .nav {
                display: none;
            }
            
            .mobile-menu-toggle {
                display: block;
            }
            
            .author-info {
                flex-direction: column;
                text-align: center;
            }
            
            .related-grid {
                grid-template-columns: 1fr;
            }
        }
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
                    <a href="<cfoutput>#navItem.url#</cfoutput>" class="nav-link"><cfoutput>#navItem.label#</cfoutput></a>
                </cfloop>
            </nav>
            
            <button class="mobile-menu-toggle">☰</button>
        </div>
    </header>
    
    <article class="article">
        <header class="article-header">
            <div class="article-meta">
                <cfif showAuthorInfo EQ "true">
                    <span><cfoutput>#qPost.author_name#</cfoutput></span>
                    <span>•</span>
                </cfif>
                <time datetime="<cfoutput>#dateFormat(qPost.published_at, 'yyyy-mm-dd')#</cfoutput>">
                    <cfoutput>#dateFormat(qPost.published_at, 'mmmm dd, yyyy')#</cfoutput>
                </time>
                <cfif showReadingTime EQ "true">
                    <span>•</span>
                    <span><cfoutput>#readingTime#</cfoutput> min read</span>
                </cfif>
            </div>
            
            <h1 class="article-title"><cfoutput>#qPost.title#</cfoutput></h1>
            
            <cfif len(trim(qPost.custom_excerpt))>
                <p class="article-excerpt"><cfoutput>#qPost.custom_excerpt#</cfoutput></p>
            </cfif>
        </header>
        
        <cfif len(trim(qPost.feature_image))>
            <div class="feature-image">
                <img src="<cfoutput>#qPost.feature_image#</cfoutput>" alt="<cfoutput>#htmlEditFormat(qPost.title)#</cfoutput>" loading="lazy">
            </div>
        </cfif>
        
        <div class="article-content">
            <cfoutput>#qPost.html#</cfoutput>
        </div>
        
        <cfif showAuthorInfo EQ "true">
            <section class="author-info">
                <div class="author-avatar">
                    <cfif len(trim(qPost.author_profile_image))>
                        <img src="<cfoutput>#qPost.author_profile_image#</cfoutput>" alt="<cfoutput>#qPost.author_name#</cfoutput>">
                    <cfelse>
                        <div class="author-avatar-placeholder">
                            <cfoutput>#left(qPost.author_name, 1)#</cfoutput>
                        </div>
                    </cfif>
                </div>
                <div class="author-details">
                    <h3><cfoutput>#qPost.author_name#</cfoutput></h3>
                    <cfif len(trim(qPost.author_bio))>
                        <p><cfoutput>#qPost.author_bio#</cfoutput></p>
                    </cfif>
                </div>
            </section>
        </cfif>
    </article>
    
    <cfif qRelatedPosts.recordCount GT 0>
        <section class="related-posts">
            <h2>More from <cfoutput>#siteTitle#</cfoutput></h2>
            <div class="related-grid">
                <cfoutput query="qRelatedPosts">
                    <!--- Create excerpt --->
                    <cfset excerpt = "">
                    <cfif len(trim(qRelatedPosts.custom_excerpt))>
                        <cfset excerpt = qRelatedPosts.custom_excerpt>
                    <cfelseif len(trim(qRelatedPosts.plaintext))>
                        <cfset excerpt = left(qRelatedPosts.plaintext, 120)>
                        <cfif len(qRelatedPosts.plaintext) GT 120>
                            <cfset excerpt = excerpt & "...">
                        </cfif>
                    </cfif>
                    
                    <a href="/ghost/#qRelatedPosts.slug#/" class="related-card">
                        <cfif len(trim(qRelatedPosts.feature_image))>
                            <img src="#qRelatedPosts.feature_image#" alt="#htmlEditFormat(qRelatedPosts.title)#" class="related-image" loading="lazy">
                        </cfif>
                        <div class="related-content">
                            <h3 class="related-title">#qRelatedPosts.title#</h3>
                            <cfif len(excerpt)>
                                <p class="related-excerpt">#excerpt#</p>
                            </cfif>
                        </div>
                    </a>
                </cfoutput>
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