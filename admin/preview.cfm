<!--- Ghost-style Preview Page --->
<cfparam name="url.id" default="0">
<cfparam name="url.member_status" default="public">

<!--- For preview in iframe, skip session check for now --->
<cfset isLoggedIn = false>
<cfset userRole = "Guest">
<cfset userId = 0>

<cftry>
    <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
        <cfset isLoggedIn = true>
        <cfset userId = session.USERID>
        <cfif structKeyExists(session, "ROLE")>
            <cfset userRole = session.ROLE>
        </cfif>
    </cfif>
    <cfcatch>
        <!--- Session might not exist in iframe context --->
    </cfcatch>
</cftry>

<!--- Get post data --->
<cftry>
    <cfquery name="postData" datasource="#request.dsn#">
        SELECT 
            p.id,
            p.title,
            p.slug,
            p.html as content,
            p.custom_excerpt as excerpt,
            p.feature_image,
            p.status,
            p.visibility,
            pm.meta_title,
            pm.meta_description,
            p.published_at,
            p.created_at,
            p.updated_at,
            u.name as author_name,
            u.slug as author_slug,
            u.bio as author_bio,
            u.profile_image as author_image
        FROM posts p
        INNER JOIN users u ON p.created_by = u.id
        LEFT JOIN posts_meta pm ON p.id = pm.post_id
        WHERE p.id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
        <!--- Only allow preview of posts created by current user if not admin --->
        <cfif isLoggedIn AND NOT (structKeyExists(session, "ROLE") AND (session.ROLE eq "Administrator" OR session.ROLE eq "Owner"))>
            AND p.created_by = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
        </cfif>
    </cfquery>
    
    <cfif postData.recordCount eq 0>
        <cfheader statuscode="404" statustext="Not Found">
        <h1>404 - Post not found</h1>
        <cfabort>
    </cfif>
    
    <cfcatch>
        <cfheader statuscode="500" statustext="Internal Server Error">
        <cfoutput>
        <h1>500 - Error loading post</h1>
        <cfif structKeyExists(application, "debugMode") AND application.debugMode>
            <p>Error: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfif>
        </cfoutput>
        <cfabort>
    </cfcatch>
</cftry>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#postData.title# - Preview</cfoutput></title>
    
    <!-- Ghost-style preview CSS -->
    <style>
        /* Ghost preview styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
            color: #15171a;
            background: #ffffff;
            line-height: 1.6;
        }
        
        /* Container */
        .gh-viewport {
            position: relative;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        /* Preview banner */
        .gh-preview-banner {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 44px;
            background: #15171a;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            font-size: 14px;
        }
        
        .gh-preview-banner-content {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .gh-preview-status {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .gh-preview-status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #30cf43;
        }
        
        .gh-preview-close {
            position: absolute;
            right: 20px;
            color: #fff;
            text-decoration: none;
            font-weight: 500;
        }
        
        /* Main content */
        .gh-main {
            flex: 1;
            margin-top: 44px;
        }
        
        /* Article container */
        .gh-article {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 4vw;
        }
        
        /* Feature image */
        .gh-article-image {
            margin: 40px 0;
        }
        
        .gh-article-image img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        /* Article header */
        .gh-article-header {
            margin: 40px 0;
        }
        
        .gh-article-tag {
            display: inline-block;
            color: #ff0095;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: .02em;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        
        .gh-article-title {
            font-size: 48px;
            font-weight: 700;
            line-height: 1.1;
            margin: 16px 0;
        }
        
        .gh-article-excerpt {
            font-size: 20px;
            line-height: 1.4;
            color: #626d79;
            margin: 16px 0;
        }
        
        .gh-article-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-top: 24px;
            font-size: 14px;
            color: #626d79;
        }
        
        .gh-article-author {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .gh-article-author-image {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            overflow: hidden;
        }
        
        .gh-article-author-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .gh-article-author-name {
            font-weight: 600;
            color: #15171a;
        }
        
        /* Content styles */
        .gh-content {
            font-size: 18px;
            line-height: 1.7;
            margin: 40px 0;
        }
        
        /* Ghost card styles */
        .kg-card {
            margin: 1.5em 0 3em;
        }
        
        .kg-card:first-child {
            margin-top: 0;
        }
        
        .kg-card + .kg-card {
            margin-top: 2em;
        }
        
        /* Image card */
        .kg-image-card {
            margin: 1.5em 0;
        }
        
        .kg-image-card img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        .kg-image-card figcaption {
            text-align: center;
            font-size: 14px;
            color: #626d79;
            margin-top: 8px;
        }
        
        .kg-width-wide {
            position: relative;
            width: 85vw;
            max-width: 1200px;
            margin-left: calc(50% - 50vw);
            margin-right: calc(50% - 50vw);
            transform: translateX(calc(50vw - 50%));
        }
        
        .kg-width-full {
            position: relative;
            width: 100vw;
            margin-left: calc(50% - 50vw);
            margin-right: calc(50% - 50vw);
        }
        
        /* Gallery card */
        .kg-gallery-card {
            margin: 1.5em 0;
        }
        
        .kg-gallery-container {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        
        .kg-gallery-row {
            display: flex;
            gap: 8px;
        }
        
        .kg-gallery-image {
            flex: 1;
        }
        
        .kg-gallery-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }
        
        /* Video card */
        .kg-video-card {
            margin: 1.5em 0;
            position: relative;
            padding-top: 56.25%;
        }
        
        .kg-video-card iframe,
        .kg-video-card video {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
        }
        
        /* Audio card */
        .kg-audio-card {
            margin: 1.5em 0;
        }
        
        /* Callout card */
        .kg-callout-card {
            padding: 20px 28px;
            border-radius: 3px;
            margin: 1.5em 0;
        }
        
        .kg-callout-card.kg-callout-card-blue {
            background: rgba(33, 172, 232, 0.12);
            border-left: 3px solid #21ace8;
        }
        
        .kg-callout-card.kg-callout-card-green {
            background: rgba(52, 183, 67, 0.12);
            border-left: 3px solid #34b743;
        }
        
        .kg-callout-card.kg-callout-card-yellow {
            background: rgba(255, 193, 7, 0.12);
            border-left: 3px solid #ffc107;
        }
        
        .kg-callout-card.kg-callout-card-red {
            background: rgba(244, 67, 54, 0.12);
            border-left: 3px solid #f44336;
        }
        
        .kg-callout-card.kg-callout-card-pink {
            background: rgba(233, 30, 99, 0.12);
            border-left: 3px solid #e91e63;
        }
        
        .kg-callout-card.kg-callout-card-purple {
            background: rgba(156, 39, 176, 0.12);
            border-left: 3px solid #9c27b0;
        }
        
        .kg-callout-card.kg-callout-card-accent {
            background: rgba(255, 0, 149, 0.12);
            border-left: 3px solid #ff0095;
        }
        
        /* Button card */
        .kg-button-card {
            margin: 1.5em 0;
            text-align: center;
        }
        
        .kg-btn {
            display: inline-block;
            padding: 8px 16px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            border-radius: 5px;
            transition: all 0.2s ease;
        }
        
        .kg-btn-primary {
            background: #14b8ff;
            color: #fff;
        }
        
        .kg-btn-primary:hover {
            background: #0ea5e9;
        }
        
        /* Toggle card */
        .kg-toggle-card {
            margin: 1.5em 0;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
        }
        
        .kg-toggle-heading {
            padding: 16px 20px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 600;
        }
        
        .kg-toggle-content {
            padding: 0 20px 16px;
            display: none;
        }
        
        .kg-toggle-card.kg-toggle-card-open .kg-toggle-content {
            display: block;
        }
        
        /* Bookmark card */
        .kg-bookmark-card {
            margin: 1.5em 0;
            border: 1px solid #e5e7eb;
            border-radius: 3px;
            display: flex;
            text-decoration: none;
            color: inherit;
            overflow: hidden;
        }
        
        .kg-bookmark-container {
            display: flex;
            width: 100%;
            min-height: 148px;
        }
        
        .kg-bookmark-content {
            flex: 1;
            padding: 20px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        
        .kg-bookmark-title {
            font-size: 18px;
            font-weight: 600;
            line-height: 1.3;
            margin-bottom: 8px;
        }
        
        .kg-bookmark-description {
            font-size: 14px;
            line-height: 1.5;
            color: #626d79;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        
        .kg-bookmark-metadata {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 12px;
            font-size: 14px;
            color: #626d79;
        }
        
        .kg-bookmark-icon {
            width: 20px;
            height: 20px;
        }
        
        .kg-bookmark-author {
            font-weight: 500;
        }
        
        .kg-bookmark-thumbnail {
            width: 280px;
            flex-shrink: 0;
        }
        
        .kg-bookmark-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        /* Product card */
        .kg-product-card {
            margin: 1.5em 0;
            border: 1px solid #e5e7eb;
            border-radius: 3px;
            padding: 20px;
        }
        
        /* Divider */
        hr.kg-divider-card {
            margin: 3em 0;
            border: 0;
            height: 1px;
            background: #e5e7eb;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .gh-article-title {
                font-size: 32px;
            }
            
            .gh-article-excerpt {
                font-size: 18px;
            }
            
            .gh-content {
                font-size: 16px;
            }
            
            .kg-bookmark-container {
                flex-direction: column;
            }
            
            .kg-bookmark-thumbnail {
                width: 100%;
                max-height: 200px;
            }
        }
        
        /* Member visibility styles */
        .gh-members-cta {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 48px 32px;
            text-align: center;
            margin: 3em 0;
        }
        
        .gh-members-cta h2 {
            font-size: 28px;
            margin-bottom: 16px;
        }
        
        .gh-members-cta p {
            font-size: 18px;
            color: #626d79;
            margin-bottom: 24px;
        }
        
        .gh-members-cta .kg-btn {
            margin: 0 8px;
        }
    </style>
</head>
<body>
    <div class="gh-viewport">
        <!-- Main content -->
        <main class="gh-main" style="margin-top: 0;">
            <article class="gh-article">
                <cfoutput>
                <!-- Feature image -->
                <cfif len(postData.feature_image)>
                    <figure class="gh-article-image">
                        <cfset imageUrl = postData.feature_image>
                        <cfif findNoCase("__GHOST_URL__", imageUrl)>
                            <cfset imageUrl = replace(imageUrl, "__GHOST_URL__", "", "all")>
                        </cfif>
                        <cfif left(imageUrl, 1) eq "/" AND NOT findNoCase("/ghost", imageUrl)>
                            <cfset imageUrl = "/ghost" & imageUrl>
                        </cfif>
                        <img src="#imageUrl#" alt="#postData.title#">
                    </figure>
                </cfif>
                
                <!-- Article header -->
                <header class="gh-article-header">
                    <h1 class="gh-article-title">#postData.title#</h1>
                    
                    <cfif len(postData.excerpt)>
                        <p class="gh-article-excerpt">#postData.excerpt#</p>
                    </cfif>
                    
                    <div class="gh-article-meta">
                        <div class="gh-article-author">
                            <cfif len(postData.author_image)>
                                <div class="gh-article-author-image">
                                    <img src="#postData.author_image#" alt="#postData.author_name#">
                                </div>
                            </cfif>
                            <span class="gh-article-author-name">#postData.author_name#</span>
                        </div>
                        <span>&bull;</span>
                        <time>#dateFormat(postData.published_at ?: postData.created_at, "mmm dd, yyyy")#</time>
                    </div>
                </header>
                
                <!-- Content -->
                <section class="gh-content">
                    <!-- Check for member-only content -->
                    <cfif postData.visibility eq "members" AND url.member_status eq "public">
                        <div class="gh-members-cta">
                            <h2>This post is for subscribers only</h2>
                            <p>Subscribe now to unlock this post and get access to the full library of posts for subscribers only.</p>
                            <a href="##" class="kg-btn kg-btn-primary">Subscribe now</a>
                            <a href="##" class="kg-btn">Already have an account? Sign in</a>
                        </div>
                    <cfelseif postData.visibility eq "paid" AND url.member_status neq "paid">
                        <div class="gh-members-cta">
                            <h2>This post is for paying subscribers only</h2>
                            <p>Upgrade your account to get access to the full library of posts for paying subscribers only.</p>
                            <a href="##" class="kg-btn kg-btn-primary">Upgrade now</a>
                            <a href="##" class="kg-btn">Already have an account? Sign in</a>
                        </div>
                    <cfelse>
                        #postData.content#
                    </cfif>
                </section>
                </cfoutput>
            </article>
        </main>
    </div>
    
    <!-- JavaScript for interactive elements -->
    <script>
        // Toggle card functionality
        document.addEventListener('click', function(e) {
            const toggleHeading = e.target.closest('.kg-toggle-heading');
            if (toggleHeading) {
                const card = toggleHeading.closest('.kg-toggle-card');
                card.classList.toggle('kg-toggle-card-open');
            }
        });
    </script>
</body>
</html>