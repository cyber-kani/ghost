<!--- Modern Page Template with Apple HIG Design --->\
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
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>404 - Page not found</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; background: #f5f5f7; }
            .error-container { text-align: center; }
            h1 { font-size: 4rem; margin: 0; color: #1d1d1f; }
            p { font-size: 1.25rem; color: #6e6e73; margin: 1rem 0 2rem; }
            a { color: #0066cc; text-decoration: none; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="error-container">
            <h1>404</h1>
            <p>The page you're looking for doesn't exist.</p>
            <a href="/ghost/blog/">← Back to home</a>
        </div>
    </body>
    </html>
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
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "https://clitools.app">

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

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <!--- SEO Meta Tags --->
    <title><cfoutput>#qPage.title# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <link rel="canonical" href="<cfoutput>/ghost/#qPage.slug#/</cfoutput>">
    
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
            --text-primary: #1d1d1f;
            --text-secondary: #6e6e73;
            --text-tertiary: #86868b;
            --bg-primary: #ffffff;
            --bg-secondary: #f5f5f7;
            --bg-tertiary: #fbfbfd;
            --border-color: #d2d2d7;
            --border-light: #e8e8ed;
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
        
        @media (prefers-color-scheme: dark) {
            :root {
                --text-primary: #f5f5f7;
                --text-secondary: #a1a1a6;
                --text-tertiary: #6e6e73;
                --bg-primary: #000000;
                --bg-secondary: #1d1d1f;
                --bg-tertiary: #2d2d30;
                --border-color: #38383d;
                --border-light: #48484e;
            }
        }
        
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
            background-color: rgba(255, 255, 255, 0.72);
            backdrop-filter: saturate(180%) blur(20px);
            -webkit-backdrop-filter: saturate(180%) blur(20px);
            border-bottom: 1px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 1000;
            transition: var(--transition);
        }
        
        @media (prefers-color-scheme: dark) {
            .site-header {
                background-color: rgba(29, 29, 31, 0.72);
            }
        }
        
        .header-inner {
            max-width: var(--max-width-wide);
            margin: 0 auto;
            padding: 0 22px;
            height: 52px;
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
            font-size: 21px;
            font-weight: 600;
            letter-spacing: 0.011em;
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
            padding: 80px 22px 48px;
            text-align: center;
            max-width: var(--max-width-content);
            margin: 0 auto;
            width: 100%;
        }
        
        .page-title {
            font-size: 48px;
            font-weight: 700;
            line-height: 1.0625;
            letter-spacing: -0.003em;
            margin: 0 0 16px;
            color: var(--text-primary);
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
            color: var(--text-secondary);
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
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                    </svg>
                </button>
            </nav>
        </div>
    </header>
    
    <!--- Page Container --->
    <div class="page-container">
        <!--- Page Header --->
        <header class="page-header fade-in-up">
            <h1 class="page-title"><cfoutput>#qPage.title#</cfoutput></h1>
            <cfif len(trim(qPage.custom_excerpt))>
                <p class="page-subtitle"><cfoutput>#qPage.custom_excerpt#</cfoutput></p>
            </cfif>
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