<cfsetting enablecfoutputonly="true"><!--- Modern Page Template with Apple HIG Design --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">

<!--- Get page by slug --->
<cfquery name="qPage" datasource="#request.dsn#">
    SELECT 
        p.*,
        u.id as author_id,
        u.name as author_name,
        u.email as author_email,
        u.profile_image as author_profile_image
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="page" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- If page not found, show 404 --->
<cfif qPage.recordCount EQ 0>
    <cfheader statuscode="404" statustext="Not Found">
    <cfcontent reset="true">
    <cfoutput><!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>404 - Page not found</title>
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
            <p>The page you're looking for doesn't exist.</p>
            <a href="/ghost/">← Back to home</a>
        </div>
    </body>
    </html>
    </cfoutput>
    <cfabort>
</cfif>

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
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "https://clitools.app">
<cfset coverImage = structKeyExists(siteSettings, "cover_image") ? siteSettings.cover_image : "">
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Process content --->
<cfset pageContent = qPage.html>
<cfset pageContent = replace(pageContent, "__GHOST_URL__", "/ghost", "all")>

<!--- Create excerpt for meta description --->
<cfset metaDescription = "">
<cfif len(trim(qPage.custom_excerpt))>
    <cfset metaDescription = qPage.custom_excerpt>
<cfelse>
    <cfset plainExcerpt = reReplace(qPage.html, "<[^>]*>", "", "all")>
    <cfset plainExcerpt = left(plainExcerpt, 160)>
    <cfif len(plainExcerpt) GT 160>
        <cfset plainExcerpt = plainExcerpt & "...">
    </cfif>
    <cfset metaDescription = plainExcerpt>
</cfif>

<cfoutput><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <!--- SEO Meta Tags --->
    <title><cfoutput>#qPage.title# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <cfset cleanPageSlug = replace(trim(qPage.slug), "\", "", "all")>
    <link rel="canonical" href="<cfoutput>/ghost/#cleanPageSlug#/</cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="website">
    <meta property="og:title" content="<cfoutput>#qPage.title#</cfoutput>">
    <meta property="og:description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <meta property="og:url" content="<cfoutput>/ghost/#qPage.slug#/</cfoutput>">
    <cfif len(qPage.feature_image)>
        <meta property="og:image" content="<cfoutput>#qPage.feature_image#</cfoutput>">
    </cfif>
    
    <!--- Twitter Card --->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<cfoutput>#qPage.title#</cfoutput>">
    <meta name="twitter:description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <cfif len(qPage.feature_image)>
        <meta name="twitter:image" content="<cfoutput>#qPage.feature_image#</cfoutput>">
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
    
    <!--- Modern CSS following Apple HIG --->
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
            --radius-xl: 1.25rem;
            --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            --max-width-content: 800px;
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
        
        ::selection {
            background-color: var(--accent-color);
            color: white;
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
            text-rendering: optimizeLegibility;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        /* Header */
        .site-header {
            backdrop-filter: saturate(180%) blur(20px);
            -webkit-backdrop-filter: saturate(180%) blur(20px);
            border-bottom: 1px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: var(--transition);
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
        
        /* Page Container */
        .page-container {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        /* Page Header */
        .page-header {
            position: relative;
            <cfif len(coverImage)>
            background-image: linear-gradient(to bottom, rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.6)), url('<cfoutput>#coverImage#</cfoutput>');
            background-size: cover;
            background-position: center;
            color: white;
            padding: 120px 22px 80px;
            margin: 0;
            max-width: none;
            width: 100%;
            min-height: 400px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            <cfelse>
            padding: 80px 22px 48px;
            max-width: var(--max-width-content);
            margin: 0 auto;
            width: 100%;
            </cfif>
            text-align: center;
        }
        
        .page-header-content {
            <cfif len(coverImage)>
            position: relative;
            z-index: 2;
            width: 100%;
            <cfelse>
            position: relative;
            </cfif>
        }
        
        .page-title {
            font-size: 48px;
            font-weight: 700;
            line-height: 1.0625;
            letter-spacing: -0.003em;
            margin: 0 0 16px;
            <cfif len(coverImage)>
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
            <cfelse>
            color: var(--text-primary);
            </cfif>
            position: relative;
            display: inline-block;
        }
        
        .page-title .underline-wrap {
            position: relative;
            display: inline;
            background-image: linear-gradient(to right, var(--accent-color), var(--accent-color));
            background-repeat: no-repeat;
            background-position: 0 95%;
            background-size: 0% 5px;
            transition: background-size 1.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        .page-title:hover .underline-wrap {
            background-size: 100% 5px;
        }
        
        @media (max-width: 768px) {
            .page-title {
                font-size: 32px;
                line-height: 1.125;
            }
        }
        
        .page-subtitle {
            font-size: 21px;
            line-height: 1.381;
            font-weight: 400;
            letter-spacing: 0.011em;
            <cfif len(coverImage)>
            color: rgba(255, 255, 255, 0.9);
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
            <cfelse>
            color: var(--text-secondary);
            </cfif>
            margin: 0;
        }
        
        /* Feature Image */
        .page-feature-image {
            margin: 0 auto 64px;
            max-width: var(--max-width-wide);
            padding: 0 22px;
        }
        
        .page-feature-image img {
            width: 100%;
            height: auto;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
        }
        
        /* Page Content */
        .page-content {
            max-width: var(--max-width-content);
            margin: 0 auto;
            padding: 0 22px 80px;
            font-size: 19px;
            line-height: 1.5263;
            letter-spacing: -0.011em;
            color: var(--text-primary);
        }
        
        .page-content h1,
        .page-content h2,
        .page-content h3,
        .page-content h4,
        .page-content h5,
        .page-content h6 {
            font-weight: 600;
            line-height: 1.2;
            margin: 48px 0 24px;
            color: var(--text-primary);
        }
        
        .page-content h1 {
            font-size: 40px;
            letter-spacing: 0.008em;
        }
        
        .page-content h2 {
            font-size: 32px;
            letter-spacing: 0.009em;
        }
        
        .page-content h3 {
            font-size: 28px;
            letter-spacing: 0.012em;
        }
        
        .page-content h4 {
            font-size: 24px;
            letter-spacing: 0.015em;
        }
        
        .page-content p {
            margin: 0 0 28px;
        }
        
        .page-content a {
            color: var(--accent-color);
            text-decoration: none;
            border-bottom: 1px solid transparent;
            transition: var(--transition);
        }
        
        .page-content a:hover {
            border-bottom-color: var(--accent-color);
        }
        
        .page-content img {
            max-width: 100%;
            height: auto;
            margin: 32px 0;
            border-radius: var(--radius-md);
        }
        
        .page-content blockquote {
            border-left: 4px solid var(--accent-color);
            padding-left: 24px;
            margin: 32px 0;
            font-style: italic;
            color: var(--text-secondary);
        }
        
        .page-content pre {
            background-color: var(--bg-secondary);
            border-radius: var(--radius-md);
            padding: 24px;
            overflow-x: auto;
            margin: 32px 0;
            font-size: 16px;
            line-height: 1.5;
        }
        
        .page-content code {
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
            font-size: 0.9em;
            background-color: var(--bg-secondary);
            padding: 2px 6px;
            border-radius: 4px;
        }
        
        .page-content pre code {
            background: none;
            padding: 0;
            font-size: inherit;
        }
        
        .page-content ul,
        .page-content ol {
            margin: 0 0 28px;
            padding-left: 32px;
        }
        
        .page-content li {
            margin-bottom: 8px;
        }
        
        .page-content hr {
            border: none;
            border-top: 1px solid var(--border-light);
            margin: 48px 0;
        }
        
        /* Contact Form (for contact pages) */
        .contact-form {
            max-width: 600px;
            margin: 48px auto;
            padding: 48px;
            background-color: var(--bg-secondary);
            border-radius: var(--radius-xl);
        }
        
        .form-group {
            margin-bottom: 24px;
        }
        
        .form-label {
            display: block;
            font-size: 15px;
            font-weight: 500;
            color: var(--text-primary);
            margin-bottom: 8px;
            letter-spacing: -0.015em;
        }
        
        .form-input,
        .form-textarea {
            width: 100%;
            padding: 12px 16px;
            background-color: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 17px;
            color: var(--text-primary);
            font-family: inherit;
            transition: var(--transition);
        }
        
        .form-input:focus,
        .form-textarea:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.1);
        }
        
        .form-textarea {
            min-height: 120px;
            resize: vertical;
        }
        
        .form-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 32px;
            background-color: var(--accent-color);
            color: white;
            border: none;
            border-radius: 980px;
            font-size: 17px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            letter-spacing: -0.015em;
        }
        
        .form-button:hover {
            transform: scale(1.05);
            box-shadow: var(--shadow-md);
        }
        
        .form-button:active {
            transform: scale(0.98);
        }
        
        /* Call to Action Section */
        .cta-section {
            background-color: var(--bg-secondary);
            border-radius: var(--radius-xl);
            padding: 64px 48px;
            margin: 64px 0;
            text-align: center;
        }
        
        .cta-title {
            font-size: 32px;
            font-weight: 600;
            margin: 0 0 16px;
            color: var(--text-primary);
        }
        
        .cta-description {
            font-size: 19px;
            color: var(--text-secondary);
            margin: 0 0 32px;
        }
        
        .cta-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .cta-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 32px;
            background-color: var(--accent-color);
            color: white;
            text-decoration: none;
            border-radius: 980px;
            font-size: 17px;
            font-weight: 500;
            transition: var(--transition);
        }
        
        .cta-button:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        .cta-button-secondary {
            background-color: transparent;
            color: var(--accent-color);
            border: 2px solid var(--accent-color);
        }
        
        .cta-button-secondary:hover {
            background-color: var(--accent-color);
            color: white;
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-secondary);
            border-top: 1px solid var(--border-light);
            padding: 48px 0;
            text-align: center;
            margin-top: auto;
        }
        
        .footer-content {
            max-width: var(--max-width-wide);
            margin: 0 auto;
            padding: 0 22px;
        }
        
        .footer-nav {
            display: flex;
            justify-content: center;
            gap: 32px;
            margin-bottom: 32px;
            flex-wrap: wrap;
        }
        
        .footer-nav a {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 15px;
            transition: var(--transition);
        }
        
        .footer-nav a:hover {
            color: var(--accent-color);
        }
        
        .footer-copyright {
            color: var(--text-tertiary);
            font-size: 15px;
            margin: 0;
        }
        
        /* Mobile Menu */
        .mobile-menu-toggle {
            display: none;
            background: none;
            border: none;
            cursor: pointer;
            padding: 8px;
            color: var(--text-primary);
        }
        
        .mobile-menu-toggle svg {
            width: 24px;
            height: 24px;
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
            
            .page-header {
                padding: 48px 22px 32px;
            }
            
            .page-content {
                font-size: 17px;
                padding: 0 22px 48px;
            }
            
            .contact-form {
                padding: 32px 24px;
            }
            
            .cta-section {
                padding: 48px 32px;
            }
            
            .cta-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .cta-button {
                width: 100%;
                max-width: 280px;
                justify-content: center;
            }
        }
        
        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .fade-in-up {
            animation: fadeInUp 0.6s ease-out;
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
        
        /* Focus styles */
        :focus-visible {
            outline: 2px solid var(--accent-color);
            outline-offset: 2px;
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
    
    <!--- Page Container --->
    <div class="page-container">
        <!--- Page Header --->
        <header class="page-header fade-in-up">
            <div class="page-header-content">
                <h1 class="page-title"><span class="underline-wrap"><cfoutput>#qPage.title#</cfoutput></span></h1>
                <cfif len(trim(qPage.custom_excerpt))>
                    <p class="page-subtitle"><cfoutput>#qPage.custom_excerpt#</cfoutput></p>
                </cfif>
            </div>
        </header>
        
        <cfif len(trim(qPage.feature_image))>
            <div class="page-feature-image fade-in-up">
                <img src="<cfoutput>#qPage.feature_image#</cfoutput>" 
                     alt="<cfoutput>#htmlEditFormat(qPage.title)#</cfoutput>" 
                     loading="eager">
            </div>
        </cfif>
        
        <div class="page-content fade-in-up">
            <cfoutput>#pageContent#</cfoutput>
        </div>
    </div>
    
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
        
        // Add fade-in animation on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);
        
        document.querySelectorAll('.fade-in-up').forEach(el => {
            el.style.opacity = '0';
            el.style.transform = 'translateY(20px)';
            el.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
            observer.observe(el);
        });
    </script>
</body>
</html>
</cfoutput>