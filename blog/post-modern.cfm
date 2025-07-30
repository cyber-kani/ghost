<cfsetting enablecfoutputonly="true"><!--- Modern Post Template with Apple HIG Design --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.slug" default="">

<!--- Get post by slug --->
<cfquery name="qPost" datasource="#request.dsn#">
    SELECT 
        p.*,
        u.id as author_id,
        u.name as author_name,
        u.email as author_email,
        u.profile_image as author_profile_image,
        u.bio as author_bio,
        u.website as author_website,
        u.location as author_location,
        u.facebook as author_facebook,
        u.twitter as author_twitter
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    WHERE p.slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
    AND p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- If post not found, show 404 --->
<cfif qPost.recordCount EQ 0>
    <cfheader statuscode="404" statustext="Not Found">
    <cfcontent reset="true">
    <cfoutput><!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>404 - Post not found</title>
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
            <p>The post you're looking for doesn't exist.</p>
            <a href="/ghost/">← Back to blog</a>
        </div>
    </body>
    </html>
    </cfoutput>
    <cfabort>
</cfif>

<!--- Get tags for this post --->
<cfquery name="qPostTags" datasource="#request.dsn#">
    SELECT t.id, t.name, t.slug
    FROM tags t
    INNER JOIN posts_tags pt ON t.id = pt.tag_id
    WHERE pt.post_id = <cfqueryparam value="#qPost.id#" cfsqltype="cf_sql_varchar">
    ORDER BY t.name
</cfquery>

<!--- Get related posts (same author or tags) --->
<cfquery name="qRelatedPosts" datasource="#request.dsn#">
    SELECT DISTINCT p.id, p.title, p.slug, p.feature_image, p.custom_excerpt, p.published_at, p.plaintext,
           u.name as author_name
    FROM posts p
    LEFT JOIN users u ON p.created_by = u.id
    LEFT JOIN posts_tags pt ON p.id = pt.post_id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    AND p.id != <cfqueryparam value="#qPost.id#" cfsqltype="cf_sql_varchar">
    AND p.type = <cfqueryparam value="#qPost.type#" cfsqltype="cf_sql_varchar">
    AND (
        p.created_by = <cfqueryparam value="#qPost.created_by#" cfsqltype="cf_sql_varchar">
        <cfif qPostTags.recordCount GT 0>
            OR pt.tag_id IN (
                <cfqueryparam value="#valueList(qPostTags.id)#" cfsqltype="cf_sql_varchar" list="true">
            )
        </cfif>
    )
    ORDER BY p.published_at DESC
    LIMIT 3
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
<cfset showAuthor = structKeyExists(siteSettings, "show_author") ? siteSettings.show_author : "true">
<cfset headingFont = structKeyExists(siteSettings, "heading_font") ? siteSettings.heading_font : "sans-serif">
<cfset bodyFont = structKeyExists(siteSettings, "body_font") ? siteSettings.body_font : "sans-serif">
<cfset colorScheme = structKeyExists(siteSettings, "color_scheme") ? siteSettings.color_scheme : "auto">
<cfset codeInjectionHead = structKeyExists(siteSettings, "codeinjection_head") ? siteSettings.codeinjection_head : "">
<cfset codeInjectionFoot = structKeyExists(siteSettings, "codeinjection_foot") ? siteSettings.codeinjection_foot : "">
<cfset siteUrl = structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "https://clitools.app">
<cfset navigationRight = structKeyExists(siteSettings, "navigation_right") ? siteSettings.navigation_right : "false">

<!--- Get navigation --->
<cfset primaryNav = structKeyExists(siteSettings, "navigation") ? deserializeJSON(siteSettings.navigation) : []>
<cfset secondaryNav = structKeyExists(siteSettings, "secondary_navigation") ? deserializeJSON(siteSettings.secondary_navigation) : []>

<!--- Process content --->
<cfset postContent = qPost.html>
<cfset postContent = replace(postContent, "__GHOST_URL__", "/ghost", "all")>

<!--- Calculate reading time --->
<cfset wordCount = listLen(qPost.plaintext, " ")>
<cfset readingTime = ceiling(wordCount / 200)>
<cfif readingTime EQ 0>
    <cfset readingTime = 1>
</cfif>

<!--- Create excerpt for meta description --->
<cfset metaDescription = "">
<cfif len(trim(qPost.custom_excerpt))>
    <cfset metaDescription = qPost.custom_excerpt>
<cfelse>
    <cfset plainExcerpt = left(qPost.plaintext, 160)>
    <cfif len(qPost.plaintext) GT 160>
        <cfset plainExcerpt = plainExcerpt & "...">
    </cfif>
    <cfset metaDescription = plainExcerpt>
</cfif>

<!--- Structured data for article --->
<cfset structuredData = {
    "@context": "https://schema.org",
    "@type": "Article",
    "headline": qPost.title,
    "description": metaDescription,
    "image": len(qPost.feature_image) ? qPost.feature_image : "",
    "datePublished": dateFormat(qPost.published_at, "yyyy-mm-dd") & "T" & timeFormat(qPost.published_at, "HH:mm:ss") & "Z",
    "dateModified": dateFormat(qPost.updated_at, "yyyy-mm-dd") & "T" & timeFormat(qPost.updated_at, "HH:mm:ss") & "Z",
    "author": {
        "@type": "Person",
        "name": qPost.author_name,
        "url": "/ghost/author/" & qPost.author_id
    },
    "publisher": {
        "@type": "Organization",
        "name": siteTitle,
        "logo": {
            "@type": "ImageObject",
            "url": siteUrl & siteLogo
        }
    },
    "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": siteUrl & "/ghost/" & qPost.slug & "/"
    }
}>

<cfoutput><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    
    <!--- SEO Meta Tags --->
    <title><cfoutput>#qPost.title# - #siteTitle#</cfoutput></title>
    <meta name="description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <meta name="author" content="<cfoutput>#qPost.author_name#</cfoutput>">
    <link rel="canonical" href="<cfoutput>/ghost/#qPost.slug#/</cfoutput>">
    
    <!--- Open Graph --->
    <meta property="og:site_name" content="<cfoutput>#siteTitle#</cfoutput>">
    <meta property="og:type" content="article">
    <meta property="og:title" content="<cfoutput>#qPost.title#</cfoutput>">
    <meta property="og:description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <meta property="og:url" content="<cfoutput>/ghost/#qPost.slug#/</cfoutput>">
    <cfif len(qPost.feature_image)>
        <meta property="og:image" content="<cfoutput>#qPost.feature_image#</cfoutput>">
    </cfif>
    <meta property="article:published_time" content="<cfoutput>#dateFormat(qPost.published_at, 'yyyy-mm-dd')#T#timeFormat(qPost.published_at, 'HH:mm:ss')#Z</cfoutput>">
    <meta property="article:modified_time" content="<cfoutput>#dateFormat(qPost.updated_at, 'yyyy-mm-dd')#T#timeFormat(qPost.updated_at, 'HH:mm:ss')#Z</cfoutput>">
    <meta property="article:author" content="<cfoutput>#qPost.author_name#</cfoutput>">
    <cfloop query="qPostTags">
        <meta property="article:tag" content="<cfoutput>#qPostTags.name#</cfoutput>">
    </cfloop>
    
    <!--- Twitter Card --->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<cfoutput>#qPost.title#</cfoutput>">
    <meta name="twitter:description" content="<cfoutput>#htmlEditFormat(metaDescription)#</cfoutput>">
    <cfif len(qPost.feature_image)>
        <meta name="twitter:image" content="<cfoutput>#qPost.feature_image#</cfoutput>">
    </cfif>
    <cfif len(qPost.author_twitter)>
        <meta name="twitter:creator" content="@<cfoutput>#qPost.author_twitter#</cfoutput>">
    </cfif>
    
    <!--- Favicon --->
    <cfif len(siteIcon)>
        <link rel="icon" href="<cfoutput>#siteIcon#</cfoutput>" type="image/png">
        <link rel="apple-touch-icon" href="<cfoutput>#siteIcon#</cfoutput>">
    </cfif>
    
    <!--- Structured Data --->
    <script type="application/ld+json">
        <cfoutput>#serializeJSON(structuredData)#</cfoutput>
    </script>
    
    <!--- Fonts --->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Merriweather:wght@300;400;700&display=swap" rel="stylesheet">
    
    <!--- Modern CSS following Apple HIG --->
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
            --font-heading: <cfoutput>#headingFontFamily#</cfoutput>;
            --font-body: <cfoutput>#bodyFontFamily#</cfoutput>;
            --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            --font-serif: 'Merriweather', Georgia, serif;
            --transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            --max-width-content: 680px;
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
        }
        
        a {
            color: var(--accent-color);
            text-decoration: none;
            transition: var(--transition);
        }
        
        a:hover {
            opacity: 0.8;
            text-decoration: underline;
        }
        
        /* Typography for headings */
        h1, h2, h3, h4, h5, h6 {
            font-family: var(--font-heading);
            font-weight: 700;
            line-height: 1.2;
            color: var(--text-primary);
            margin: 2em 0 0.5em;
        }
        
        h1:first-child, h2:first-child, h3:first-child,
        h4:first-child, h5:first-child, h6:first-child {
            margin-top: 0;
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
                background-color: rgba(255, 255, 255, 0.9);
            }
        <cfelseif colorScheme EQ "dark">
            .site-header {
                background-color: rgba(29, 29, 31, 0.9);
            }
        <cfelse>
            .site-header {
                background-color: rgba(255, 255, 255, 0.9);
            }
            @media (prefers-color-scheme: dark) {
                .site-header {
                    background-color: rgba(29, 29, 31, 0.9);
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
        
        /* Reading Progress */
        .reading-progress {
            position: fixed;
            top: 52px;
            left: 0;
            width: 100%;
            height: 3px;
            background-color: var(--border-light);
            z-index: 999;
        }
        
        .reading-progress-bar {
            height: 100%;
            background-color: var(--accent-color);
            width: 0%;
            transition: width 0.2s ease;
        }
        
        /* Article Header */
        .article-header {
            padding: 80px 22px 48px;
            text-align: center;
            max-width: var(--max-width-content);
            margin: 0 auto;
        }
        
        .article-meta-top {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            margin-bottom: 24px;
            font-size: 15px;
            color: var(--text-secondary);
        }
        
        .article-tags {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            justify-content: center;
        }
        
        .article-tag {
            display: inline-flex;
            align-items: center;
            padding: 4px 12px;
            background-color: var(--bg-secondary);
            color: var(--text-primary);
            border-radius: 980px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: var(--transition);
        }
        
        .article-tag:hover {
            background-color: var(--accent-color);
            color: white;
            transform: scale(1.05);
        }
        
        .article-title {
            font-size: 48px;
            font-weight: 700;
            line-height: 1.0625;
            letter-spacing: -0.003em;
            margin: 0 0 16px;
            color: var(--text-primary);
            position: relative;
            display: inline-block;
        }
        
        .article-title .underline-wrap {
            position: relative;
            display: inline;
            background-image: linear-gradient(to right, var(--accent-color), var(--accent-color));
            background-repeat: no-repeat;
            background-position: 0 95%;
            background-size: 0% 5px;
            transition: background-size 1.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        .article-title:hover .underline-wrap {
            background-size: 100% 5px;
        }
        
        @media (max-width: 768px) {
            .article-title {
                font-size: 32px;
                line-height: 1.125;
            }
        }
        
        .article-excerpt {
            font-size: 21px;
            line-height: 1.381;
            font-weight: 400;
            letter-spacing: 0.011em;
            color: var(--text-secondary);
            margin: 0 0 32px;
        }
        
        .article-meta-bottom {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 24px;
            font-size: 17px;
            color: var(--text-secondary);
        }
        
        .article-author {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none !important;
            color: inherit;
            transition: var(--transition);
        }
        
        .article-author:hover {
            color: var(--text-primary);
            text-decoration: none !important;
        }
        
        .author-avatar {
            width: 48px;
            height: 48px;
            min-width: 48px;
            min-height: 48px;
            max-width: 48px;
            max-height: 48px;
            border-radius: 50%;
            overflow: hidden;
            background-color: var(--accent-color);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 600;
            color: white;
            line-height: 1;
            text-align: center;
            text-transform: uppercase;
            padding: 0;
            flex-shrink: 0;
            flex-grow: 0;
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
        
        /* Feature Image */
        .article-feature-image {
            margin: 0 auto 64px;
            max-width: var(--max-width-wide);
            padding: 0 22px;
        }
        
        .article-feature-image img {
            width: 100%;
            height: auto;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
        }
        
        /* Article Content */
        .article-content {
            max-width: var(--max-width-content);
            margin: 0 auto;
            padding: 0 22px;
            font-family: var(--font-serif);
            font-size: 19px;
            line-height: 1.5263;
            letter-spacing: -0.011em;
            color: var(--text-primary);
        }
        
        .article-content h1,
        .article-content h2,
        .article-content h3,
        .article-content h4,
        .article-content h5,
        .article-content h6 {
            font-family: var(--font-sans);
            font-weight: 600;
            line-height: 1.2;
            margin: 48px 0 24px;
            color: var(--text-primary);
        }
        
        .article-content h2 {
            font-size: 32px;
            letter-spacing: 0.009em;
        }
        
        .article-content h3 {
            font-size: 28px;
            letter-spacing: 0.012em;
        }
        
        .article-content h4 {
            font-size: 24px;
            letter-spacing: 0.015em;
        }
        
        .article-content p {
            margin: 0 0 28px;
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
            margin: 32px 0;
            border-radius: var(--radius-md);
        }
        
        .article-content blockquote {
            border-left: 4px solid var(--accent-color);
            padding-left: 24px;
            margin: 32px 0;
            font-style: italic;
            color: var(--text-secondary);
        }
        
        .article-content pre {
            background-color: var(--bg-secondary);
            border-radius: var(--radius-md);
            padding: 24px;
            overflow-x: auto;
            margin: 32px 0;
            font-size: 16px;
            line-height: 1.5;
        }
        
        .article-content code {
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
            font-size: 0.9em;
            background-color: var(--bg-secondary);
            padding: 2px 6px;
            border-radius: 4px;
        }
        
        .article-content pre code {
            background: none;
            padding: 0;
            font-size: inherit;
        }
        
        .article-content ul,
        .article-content ol {
            margin: 0 0 28px;
            padding-left: 32px;
        }
        
        .article-content li {
            margin-bottom: 8px;
        }
        
        .article-content hr {
            border: none;
            border-top: 1px solid var(--border-light);
            margin: 48px 0;
        }
        
        /* Share Section */
        .share-section {
            max-width: var(--max-width-content);
            margin: 64px auto;
            padding: 48px 22px;
            text-align: center;
            border-top: 1px solid var(--border-light);
            border-bottom: 1px solid var(--border-light);
        }
        
        .share-title {
            font-size: 24px;
            font-weight: 600;
            margin: 0 0 24px;
            color: var(--text-primary);
        }
        
        .share-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .share-button {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            background-color: var(--bg-secondary);
            color: var(--text-primary);
            text-decoration: none;
            border-radius: 980px;
            font-size: 16px;
            font-weight: 500;
            transition: var(--transition);
        }
        
        .share-button:hover {
            background-color: var(--accent-color);
            color: white;
            transform: translateY(-2px);
        }
        
        .share-button svg {
            width: 20px;
            height: 20px;
        }
        
        /* Author Bio */
        .author-bio-section {
            max-width: var(--max-width-content);
            margin: 64px auto;
            padding: 0 22px;
        }
        
        .author-bio-card {
            background-color: var(--bg-secondary);
            border-radius: var(--radius-xl);
            padding: 48px;
            display: flex;
            gap: 32px;
            align-items: flex-start;
        }
        
        @media (max-width: 768px) {
            .author-bio-card {
                flex-direction: column;
                text-align: center;
                align-items: center;
                padding: 32px;
            }
        }
        
        .author-bio-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            overflow: hidden;
            flex-shrink: 0;
            background-color: var(--accent-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: 600;
            color: white;
        }
        
        .author-bio-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .author-bio-content {
            flex: 1;
        }
        
        .author-bio-name {
            font-size: 28px;
            font-weight: 600;
            margin: 0 0 8px;
            color: var(--text-primary);
        }
        
        .author-bio-meta {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;
            font-size: 15px;
            color: var(--text-secondary);
            flex-wrap: wrap;
        }
        
        @media (max-width: 768px) {
            .author-bio-meta {
                justify-content: center;
            }
        }
        
        .author-bio-meta-item {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .author-bio-text {
            font-size: 17px;
            line-height: 1.5;
            color: var(--text-primary);
            margin: 0 0 24px;
        }
        
        .author-bio-links {
            display: flex;
            gap: 12px;
        }
        
        @media (max-width: 768px) {
            .author-bio-links {
                justify-content: center;
            }
        }
        
        .author-bio-link {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 44px;
            height: 44px;
            background-color: var(--bg-primary);
            color: var(--text-primary);
            border-radius: 50%;
            text-decoration: none;
            transition: var(--transition);
        }
        
        .author-bio-link:hover {
            background-color: var(--accent-color);
            color: white;
            transform: scale(1.1);
        }
        
        .author-bio-link svg {
            width: 20px;
            height: 20px;
        }
        
        /* Related Posts */
        .related-posts-section {
            background-color: var(--bg-secondary);
            padding: 80px 0;
            margin-top: 80px;
        }
        
        .related-posts-container {
            max-width: var(--max-width-wide);
            margin: 0 auto;
            padding: 0 22px;
        }
        
        .related-posts-header {
            text-align: center;
            margin-bottom: 48px;
        }
        
        .related-posts-title {
            font-size: 40px;
            font-weight: 600;
            margin: 0 0 16px;
            color: var(--text-primary);
        }
        
        .related-posts-subtitle {
            font-size: 21px;
            color: var(--text-secondary);
            margin: 0;
        }
        
        .related-posts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 32px;
        }
        
        .related-post-card {
            background-color: var(--bg-primary);
            border-radius: var(--radius-lg);
            overflow: hidden;
            text-decoration: none;
            color: inherit;
            transition: var(--transition);
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow-sm);
        }
        
        .related-post-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }
        
        .related-post-image {
            position: relative;
            padding-top: 56.25%;
            background-color: var(--bg-tertiary);
            overflow: hidden;
        }
        
        .related-post-image img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: var(--transition);
        }
        
        .related-post-card:hover .related-post-image img {
            transform: scale(1.05);
        }
        
        .related-post-content {
            padding: 32px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .related-post-title {
            font-size: 24px;
            font-weight: 600;
            line-height: 1.2;
            margin: 0 0 12px;
            color: var(--text-primary);
            position: relative;
        }
        
        .related-post-title .underline-wrap {
            position: relative;
            display: inline;
            background-image: linear-gradient(to right, var(--accent-color), var(--accent-color));
            background-repeat: no-repeat;
            background-position: 0 95%;
            background-size: 0% 5px;
            transition: background-size 1.2s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        
        .related-post:hover .underline-wrap {
            background-size: 100% 5px;
        }
        
        .related-post-excerpt {
            font-size: 17px;
            line-height: 1.5;
            color: var(--text-secondary);
            margin: 0 0 16px;
            flex: 1;
        }
        
        .related-post-meta {
            font-size: 15px;
            color: var(--text-tertiary);
        }
        
        /* Footer */
        .site-footer {
            background-color: var(--bg-primary);
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
            color: var(--text-secondary);
            font-size: 15px;
            margin: 0;
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
            
            .article-header {
                padding: 48px 22px 32px;
            }
            
            .article-meta-top {
                flex-direction: column;
                gap: 0.5rem;
            }
            
            .article-meta-bottom {
                flex-direction: column;
                gap: 16px;
            }
            
            .article-content {
                font-size: 17px;
            }
            
            .share-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .share-button {
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
    
    <!--- Reading Progress Bar --->
    <div class="reading-progress">
        <div class="reading-progress-bar" id="readingProgress"></div>
    </div>
    
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
    
    <!--- Article Header --->
    <article class="fade-in-up">
        <header class="article-header">
            <cfif qPostTags.recordCount GT 0>
                <div class="article-meta-top">
                    <div class="article-tags">
                        <cfoutput query="qPostTags">
                            <cfset cleanTagSlug = replace(trim(qPostTags.slug), "\", "", "all")>
                            <a href="/ghost/tag/<cfoutput>#cleanTagSlug#</cfoutput>/" class="article-tag">#qPostTags.name#</a>
                        </cfoutput>
                    </div>
                </div>
            </cfif>
            
            <h1 class="article-title"><span class="underline-wrap"><cfoutput>#qPost.title#</cfoutput></span></h1>
            
            <cfif len(trim(qPost.custom_excerpt))>
                <p class="article-excerpt"><cfoutput>#qPost.custom_excerpt#</cfoutput></p>
            </cfif>
            
            <div class="article-meta-bottom">
                <cfif showAuthor EQ "true">
                    <a href="/ghost/author/<cfoutput>#qPost.author_id#</cfoutput>/" class="article-author">
                        <div class="author-avatar">
                            <cfif len(trim(qPost.author_profile_image))>
                                <img src="<cfoutput>#qPost.author_profile_image#</cfoutput>" alt="<cfoutput>#qPost.author_name#</cfoutput>">
                            <cfelse>
                                <cfoutput>#left(qPost.author_name, 1)#</cfoutput>
                            </cfif>
                        </div>
                        <span><cfoutput>#qPost.author_name#</cfoutput></span>
                    </a>
                    <span class="meta-divider">•</span>
                </cfif>
                <time datetime="<cfoutput>#dateFormat(qPost.published_at, 'yyyy-mm-dd')#</cfoutput>">
                    <cfoutput>#dateFormat(qPost.published_at, 'mmmm d, yyyy')#</cfoutput>
                </time>
                <span class="meta-divider">•</span>
                <span><cfoutput>#readingTime#</cfoutput> min read</span>
            </div>
        </header>
        
        <cfif len(trim(qPost.feature_image))>
            <div class="article-feature-image">
                <img src="<cfoutput>#qPost.feature_image#</cfoutput>" 
                     alt="<cfoutput>#htmlEditFormat(qPost.title)#</cfoutput>" 
                     loading="eager">
            </div>
        </cfif>
        
        <div class="article-content">
            <cfoutput>#postContent#</cfoutput>
        </div>
    </article>
    
    <!--- Share Section --->
    <section class="share-section">
        <h2 class="share-title">Share this article</h2>
        <div class="share-buttons">
            <a href="https://twitter.com/intent/tweet?text=<cfoutput>#urlEncodedFormat(qPost.title)#&url=#urlEncodedFormat(siteUrl & '/ghost/' & qPost.slug & '/')#</cfoutput>" 
               class="share-button" 
               target="_blank" 
               rel="noopener noreferrer">
                <svg fill="currentColor" viewBox="0 0 24 24">
                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                </svg>
                <span>Twitter</span>
            </a>
            
            <a href="https://www.facebook.com/sharer/sharer.php?u=<cfoutput>#urlEncodedFormat(siteUrl & '/ghost/' & qPost.slug & '/')#</cfoutput>" 
               class="share-button" 
               target="_blank" 
               rel="noopener noreferrer">
                <svg fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
                <span>Facebook</span>
            </a>
            
            <a href="https://www.linkedin.com/sharing/share-offsite/?url=<cfoutput>#urlEncodedFormat(siteUrl & '/ghost/' & qPost.slug & '/')#</cfoutput>" 
               class="share-button" 
               target="_blank" 
               rel="noopener noreferrer">
                <svg fill="currentColor" viewBox="0 0 24 24">
                    <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
                <span>LinkedIn</span>
            </a>
            
            <button class="share-button" onclick="copyToClipboard()">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                </svg>
                <span>Copy link</span>
            </button>
        </div>
    </section>
    
    <!--- Author Bio --->
    <cfif showAuthor EQ "true" AND len(trim(qPost.author_bio))>
        <section class="author-bio-section">
            <div class="author-bio-card">
                <div class="author-bio-avatar">
                    <cfif len(trim(qPost.author_profile_image))>
                        <img src="<cfoutput>#qPost.author_profile_image#</cfoutput>" alt="<cfoutput>#qPost.author_name#</cfoutput>">
                    <cfelse>
                        <cfoutput>#left(qPost.author_name, 1)#</cfoutput>
                    </cfif>
                </div>
                <div class="author-bio-content">
                    <h3 class="author-bio-name"><cfoutput>#qPost.author_name#</cfoutput></h3>
                    <div class="author-bio-meta">
                        <cfif len(trim(qPost.author_location))>
                            <div class="author-bio-meta-item">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                </svg>
                                <span><cfoutput>#qPost.author_location#</cfoutput></span>
                            </div>
                        </cfif>
                        <cfif len(trim(qPost.author_website))>
                            <div class="author-bio-meta-item">
                                <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                                </svg>
                                <a href="<cfoutput>#qPost.author_website#</cfoutput>" target="_blank" rel="noopener noreferrer">Website</a>
                            </div>
                        </cfif>
                    </div>
                    <p class="author-bio-text"><cfoutput>#qPost.author_bio#</cfoutput></p>
                    <div class="author-bio-links">
                        <cfif len(trim(qPost.author_twitter))>
                            <a href="https://twitter.com/<cfoutput>#qPost.author_twitter#</cfoutput>" 
                               class="author-bio-link" 
                               target="_blank" 
                               rel="noopener noreferrer"
                               aria-label="Twitter">
                                <svg fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                                </svg>
                            </a>
                        </cfif>
                        <cfif len(trim(qPost.author_facebook))>
                            <a href="https://facebook.com/<cfoutput>#qPost.author_facebook#</cfoutput>" 
                               class="author-bio-link" 
                               target="_blank" 
                               rel="noopener noreferrer"
                               aria-label="Facebook">
                                <svg fill="currentColor" viewBox="0 0 24 24">
                                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                                </svg>
                            </a>
                        </cfif>
                        <cfif len(trim(qPost.author_website))>
                            <a href="<cfoutput>#qPost.author_website#</cfoutput>" 
                               class="author-bio-link" 
                               target="_blank" 
                               rel="noopener noreferrer"
                               aria-label="Website">
                                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path>
                                </svg>
                            </a>
                        </cfif>
                    </div>
                </div>
            </div>
        </section>
    </cfif>
    
    <!--- Related Posts --->
    <cfif qRelatedPosts.recordCount GT 0>
        <section class="related-posts-section">
            <div class="related-posts-container">
                <div class="related-posts-header">
                    <h2 class="related-posts-title">More to explore</h2>
                    <p class="related-posts-subtitle">Continue reading from our collection</p>
                </div>
                
                <div class="related-posts-grid">
                    <cfoutput query="qRelatedPosts">
                        <!--- Create excerpt --->
                        <cfset relatedExcerpt = "">
                        <cfif len(trim(qRelatedPosts.custom_excerpt))>
                            <cfset relatedExcerpt = qRelatedPosts.custom_excerpt>
                        <cfelseif len(trim(qRelatedPosts.plaintext))>
                            <cfset relatedExcerpt = left(qRelatedPosts.plaintext, 120)>
                            <cfif len(qRelatedPosts.plaintext) GT 120>
                                <cfset relatedExcerpt = relatedExcerpt & "...">
                            </cfif>
                        </cfif>
                        
                        <cfset cleanRelatedSlug = replace(trim(qRelatedPosts.slug), "\", "", "all")>
                        <a href="/ghost/<cfoutput>#cleanRelatedSlug#</cfoutput>/" class="related-post-card">
                            <cfif len(trim(qRelatedPosts.feature_image))>
                                <div class="related-post-image">
                                    <img src="#qRelatedPosts.feature_image#" 
                                         alt="#htmlEditFormat(qRelatedPosts.title)#" 
                                         loading="lazy">
                                </div>
                            </cfif>
                            <div class="related-post-content">
                                <h3 class="related-post-title"><span class="underline-wrap">#qRelatedPosts.title#</span></h3>
                                <cfif len(relatedExcerpt)>
                                    <p class="related-post-excerpt">#relatedExcerpt#</p>
                                </cfif>
                                <p class="related-post-meta">
                                    By #qRelatedPosts.author_name# • 
                                    #dateFormat(qRelatedPosts.published_at, 'mmm d, yyyy')#
                                </p>
                            </div>
                        </a>
                    </cfoutput>
                </div>
            </div>
        </section>
    </cfif>
    
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
        // Reading Progress Bar
        const readingProgress = document.getElementById('readingProgress');
        const article = document.querySelector('article');
        
        function updateReadingProgress() {
            if (!article) return;
            
            const articleTop = article.offsetTop;
            const articleHeight = article.offsetHeight;
            const windowHeight = window.innerHeight;
            const scrollY = window.scrollY;
            
            const progress = Math.max(0, Math.min(100, 
                ((scrollY - articleTop + windowHeight) / articleHeight) * 100
            ));
            
            readingProgress.style.width = progress + '%';
        }
        
        window.addEventListener('scroll', updateReadingProgress);
        window.addEventListener('resize', updateReadingProgress);
        updateReadingProgress();
        
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
        
        // Copy to Clipboard
        function copyToClipboard() {
            const url = window.location.href;
            
            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(url).then(function() {
                    showCopySuccess();
                });
            } else {
                // Fallback for older browsers
                const textArea = document.createElement('textarea');
                textArea.value = url;
                textArea.style.position = 'fixed';
                textArea.style.left = '-999999px';
                document.body.appendChild(textArea);
                textArea.focus();
                textArea.select();
                
                try {
                    document.execCommand('copy');
                    showCopySuccess();
                } catch (err) {
                    console.error('Failed to copy:', err);
                }
                
                document.body.removeChild(textArea);
            }
        }
        
        function showCopySuccess() {
            const button = event.currentTarget;
            const originalText = button.querySelector('span').textContent;
            button.querySelector('span').textContent = 'Copied!';
            button.style.backgroundColor = 'var(--accent-color)';
            button.style.color = 'white';
            
            setTimeout(() => {
                button.querySelector('span').textContent = originalText;
                button.style.backgroundColor = '';
                button.style.color = '';
            }, 2000);
        }
        
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
        
        // Lazy loading for images
        if ('loading' in HTMLImageElement.prototype) {
            const images = document.querySelectorAll('img[loading="lazy"]');
            images.forEach(img => {
                img.src = img.src;
            });
        }
    </script>
</body>
</html>
</cfoutput>