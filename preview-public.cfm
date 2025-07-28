<!--- Public Preview Page (No Auth Required) --->
<cfparam name="url.id" default="0">
<cfparam name="url.member_status" default="public">

<!--- Include site configuration --->
<cfinclude template="/ghost/config/site.cfm">

<!--- Get post data --->
<cftry>
    <cfquery name="postData" datasource="blog">
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
    </cfquery>
    
    <cfif postData.recordCount eq 0>
        <h1>404 - Post not found</h1>
        <cfabort>
    </cfif>
    
    <cfcatch>
        <h1>500 - Error loading post</h1>
        <cfif structKeyExists(application, "debugMode") AND application.debugMode>
            <cfoutput>
            <p>Error: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
            </cfoutput>
        </cfif>
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
        
        /* Main content */
        .gh-main {
            flex: 1;
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
    </style>
</head>
<body>
    <div class="gh-viewport">
        <main class="gh-main">
            <article class="gh-article">
                <cfoutput>
                <!-- Feature image -->
                <cfif len(postData.feature_image)>
                    <figure class="gh-article-image">
                        <cfset imageUrl = getImageUrl(postData.feature_image)>
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
                    #replaceGhostUrl(postData.content)#
                </section>
                </cfoutput>
            </article>
        </main>
    </div>
</body>
</html>