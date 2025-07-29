<!--- Static Page Template --->\
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">

<!--- Get page by slug --->
<cfquery name="qPage" datasource="#request.dsn#">
    SELECT 
        p.*,
        u.id as author_id,
        u.name as author_name,
        u.email as author_email,
        u.profile_image as author_profile_image,
        u.bio as author_bio
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
    <h1>Page not found</h1>
    <p>The page you're looking for doesn't exist.</p>
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
<cfset accentColor = structKeyExists(siteSettings, "accent_color") ? siteSettings.accent_color : "##5A67D8">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Process content to replace Ghost image URLs --->
<cfset pageContent = qPage.html>
<cfset pageContent = replace(pageContent, "__GHOST_URL__", "/ghost", "all")>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <title><cfoutput>#qPage.title# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#len(qPage.custom_excerpt) ? qPage.custom_excerpt : left(reReplace(qPage.html, "<[^>]*>", "", "all"), 160)#</cfoutput>">
    <link rel="canonical" href="<cfoutput>/ghost/#qPage.slug#/</cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="article">
    <meta property="og:title" content="<cfoutput>#qPage.title#</cfoutput>">
    <meta property="og:description" content="<cfoutput>#len(qPage.custom_excerpt) ? qPage.custom_excerpt : left(reReplace(qPage.html, "<[^>]*>", "", "all"), 160)#</cfoutput>">
    <meta property="og:url" content="<cfoutput>/ghost/#qPage.slug#/</cfoutput>">
    <cfif len(qPage.feature_image)>
        <meta property="og:image" content="<cfoutput>#qPage.feature_image#</cfoutput>">
    </cfif>
    
    <!--- Twitter Card --->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<cfoutput>#qPage.title#</cfoutput>">
    <meta name="twitter:description" content="<cfoutput>#len(qPage.custom_excerpt) ? qPage.custom_excerpt : left(reReplace(qPage.html, "<[^>]*>", "", "all"), 160)#</cfoutput>">
    <cfif len(qPage.feature_image)>
        <meta name="twitter:image" content="<cfoutput>#qPage.feature_image#</cfoutput>">
    </cfif>
    
    <!--- Favicon --->
    <cfif len(siteIcon)>
        <link rel="icon" href="<cfoutput>#siteIcon#</cfoutput>" type="image/png">
        <link rel="apple-touch-icon" href="<cfoutput>#siteIcon#</cfoutput>">
    </cfif>
    
    <!--- Modern CSS --->
    <style>
        :root {
            --accent-color: <cfoutput>#accentColor#</cfoutput>;
            --text-primary: #1a1a1a;
            --text-secondary: #6b7280;
            --bg-primary: #ffffff;
            --bg-secondary: #f9fafb;
            --border-color: #e5e7eb;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --radius-md: 0.5rem;
            --transition: all 0.2s ease;
        }
        
        @media (prefers-color-scheme: dark) {
            :root {
                --text-primary: #f3f4f6;
                --text-secondary: #9ca3af;
                --bg-primary: #111827;
                --bg-secondary: #1f2937;
                --border-color: #374151;
            }
        }
        
        * {
            box-sizing: border-box;
        }
        
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            font-size: 16px;
            line-height: 1.6;
            color: var(--text-primary);
            background-color: var(--bg-primary);
            -webkit-font-smoothing: antialiased;
        }
        
        /* Header */
        .site-header {
            background-color: var(--bg-primary);
            border-bottom: 1px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 40;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            background-color: rgba(255, 255, 255, 0.8);
        }
        
        @media (prefers-color-scheme: dark) {
            .site-header {
                background-color: rgba(17, 24, 39, 0.8);
            }
        }
        
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
        
        /* Page Content */
        .page-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 4rem 1.5rem;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 3rem;
            padding-bottom: 2rem;
            border-bottom: 1px solid var(--border-color);
        }
        
        .page-title {
            font-size: 3rem;
            font-weight: 800;
            margin: 0 0 1rem;
            line-height: 1.2;
        }
        
        .page-feature-image {
            margin: -4rem -1.5rem 3rem;
            overflow: hidden;
            border-radius: 0;
        }
        
        @media (min-width: 800px) {
            .page-feature-image {
                margin-left: -4rem;
                margin-right: -4rem;
                border-radius: 0.75rem;
            }
        }
        
        .page-feature-image img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        .page-content {
            font-size: 1.125rem;
            line-height: 1.8;
            color: var(--text-primary);
        }
        
        .page-content h1,
        .page-content h2,
        .page-content h3,
        .page-content h4,
        .page-content h5,
        .page-content h6 {
            margin: 2.5rem 0 1rem;
            font-weight: 700;
            line-height: 1.3;
        }
        
        .page-content h2 {
            font-size: 2rem;
        }
        
        .page-content h3 {
            font-size: 1.5rem;
        }
        
        .page-content p {
            margin: 0 0 1.5rem;
        }
        
        .page-content img {
            max-width: 100%;
            height: auto;
            margin: 2rem 0;
            border-radius: 0.5rem;
        }
        
        .page-content blockquote {
            border-left: 4px solid var(--accent-color);
            padding-left: 1.5rem;
            margin: 2rem 0;
            font-style: italic;
            color: var(--text-secondary);
        }
        
        .page-content pre {
            background-color: var(--bg-secondary);
            padding: 1.5rem;
            border-radius: 0.5rem;
            overflow-x: auto;
            margin: 2rem 0;
        }
        
        .page-content code {
            background-color: var(--bg-secondary);
            padding: 0.125rem 0.375rem;
            border-radius: 0.25rem;
            font-size: 0.875em;
            font-family: 'Courier New', Courier, monospace;
        }
        
        .page-content pre code {
            background: none;
            padding: 0;
        }
        
        .page-content a {
            color: var(--accent-color);
            text-decoration: underline;
        }
        
        .page-content a:hover {
            text-decoration: none;
        }
        
        .page-content ul,
        .page-content ol {
            margin: 0 0 1.5rem;
            padding-left: 2rem;
        }
        
        .page-content li {
            margin-bottom: 0.5rem;
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-secondary);
            border-top: 1px solid var(--border-color);
            padding: 3rem 1.5rem;
            text-align: center;
            margin-top: 5rem;
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
            
            .page-title {
                font-size: 2rem;
            }
            
            .page-container {
                padding: 2rem 1.5rem;
            }
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
                
                <button class="mobile-menu-toggle" aria-label="Menu">
                    <svg width="24" height="24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M3 12h18M3 6h18M3 18h18"/>
                    </svg>
                </button>
            </nav>
        </div>
    </header>
    
    <!--- Page Content --->
    <div class="page-container">
        <cfif len(trim(qPage.feature_image))>
            <cfset featureImageUrl = replace(qPage.feature_image, "__GHOST_URL__", "/ghost", "all")>
            <div class="page-feature-image">
                <img src="<cfoutput>#featureImageUrl#</cfoutput>" alt="<cfoutput>#qPage.title#</cfoutput>" loading="lazy">
            </div>
        </cfif>
        
        <header class="page-header">
            <h1 class="page-title"><cfoutput>#qPage.title#</cfoutput></h1>
        </header>
        
        <div class="page-content">
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
            menu.style.boxShadow = 'var(--shadow-md)';
        });
    </script>
</body>
</html>