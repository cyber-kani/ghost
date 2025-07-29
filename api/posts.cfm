<!--- Posts API Endpoint --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">
<cfparam name="request.dsn" default="blog">
<cfparam name="url.page" default="1">
<cfparam name="url.format" default="json">

<cftry>
    <!--- Pagination setup --->
    <cfset postsPerPage = 12>
    <cfset startRow = ((url.page - 1) * postsPerPage) + 1>
    
    <!--- Get total post count --->
    <cfquery name="qPostCount" datasource="#request.dsn#">
        SELECT COUNT(*) as total
        FROM posts
        WHERE status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
        AND type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfset totalPosts = qPostCount.total>
    <cfset totalPages = ceiling(totalPosts / postsPerPage)>
    
    <!--- Get posts for current page --->
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
            u.profile_image as author_profile_image,
            u.bio as author_bio
        FROM posts p
        LEFT JOIN users u ON p.created_by = u.id
        WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
        AND p.type = <cfqueryparam value="post" cfsqltype="cf_sql_varchar">
        ORDER BY p.published_at DESC
        LIMIT #postsPerPage# OFFSET #startRow - 1#
    </cfquery>
    
    <!--- Build response array --->
    <cfset postsArray = []>
    <cfloop query="qPosts">
        <!--- Get tags for this post --->
        <cfquery name="qPostTags" datasource="#request.dsn#">
            SELECT t.id, t.name, t.slug
            FROM tags t
            INNER JOIN posts_tags pt ON t.id = pt.tag_id
            WHERE pt.post_id = <cfqueryparam value="#qPosts.id#" cfsqltype="cf_sql_varchar">
            ORDER BY t.name
            LIMIT 3
        </cfquery>
        
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
        
        <!--- Build tags array --->
        <cfset tagsArray = []>
        <cfloop query="qPostTags">
            <cfset arrayAppend(tagsArray, {
                "id": qPostTags.id,
                "name": qPostTags.name,
                "slug": qPostTags.slug
            })>
        </cfloop>
        
        <!--- Add post to array --->
        <cfset arrayAppend(postsArray, {
            "id": qPosts.id,
            "title": qPosts.title,
            "slug": qPosts.slug,
            "excerpt": excerpt,
            "feature_image": qPosts.feature_image,
            "published_at": dateFormat(qPosts.published_at, "yyyy-mm-dd") & "T" & timeFormat(qPosts.published_at, "HH:mm:ss") & "Z",
            "reading_time": readingTime,
            "author": {
                "id": qPosts.author_id,
                "name": qPosts.author_name,
                "profile_image": qPosts.author_profile_image
            },
            "tags": tagsArray,
            "url": "/ghost/" & replace(trim(qPosts.slug), "\", "", "all") & "/"
        })>
    </cfloop>
    
    <!--- Return HTML format if requested --->
    <cfif url.format EQ "html">
        <cfcontent reset="true" type="text/html">
        <cfloop array="#postsArray#" index="post">
            <article class="post-card">
                <a href="#post.url#" class="post-card-link">
                    <cfif len(trim(post.feature_image))>
                        <div class="post-card-image">
                            <img src="#post.feature_image#" 
                                 alt="#htmlEditFormat(post.title)#" 
                                 loading="lazy"
                                 width="680"
                                 height="383">
                        </div>
                    </cfif>
                    
                    <div class="post-card-content">
                        <cfif arrayLen(post.tags) GT 0>
                            <div class="post-card-tags">
                                <cfloop array="#post.tags#" index="tag">
                                    <span class="post-tag">#tag.name#</span>
                                </cfloop>
                            </div>
                        </cfif>
                        
                        <h3 class="post-card-title"><span class="underline-wrap">#post.title#</span></h3>
                        
                        <cfif len(post.excerpt)>
                            <p class="post-card-excerpt">#post.excerpt#</p>
                        </cfif>
                        
                        <div class="post-card-meta">
                            <div class="post-author">
                                <div class="author-avatar">
                                    <cfif len(trim(post.author.profile_image))>
                                        <img src="#post.author.profile_image#" 
                                             alt="#post.author.name#" 
                                             loading="lazy">
                                    <cfelse>
                                        #left(post.author.name, 1)#
                                    </cfif>
                                </div>
                                <span>#post.author.name#</span>
                            </div>
                            <div class="post-meta-info">
                                <time datetime="#dateFormat(post.published_at, 'yyyy-mm-dd')#">
                                    #dateFormat(post.published_at, 'mmm dd')#
                                </time>
                                <span class="post-meta-divider">•</span>
                                <span class="reading-time">
                                    <svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16">
                                        <path d="M8 3.5a.5.5 0 0 0-1 0V9a.5.5 0 0 0 .252.434l3.5 2a.5.5 0 0 0 .496-.868L8 8.71V3.5z"/>
                                        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm7-8A7 7 0 1 1 1 8a7 7 0 0 1 14 0z"/>
                                    </svg>
                                    #post.reading_time# min
                                </span>
                            </div>
                        </div>
                    </div>
                </a>
            </article>
        </cfloop>
        <cfabort>
    </cfif>
    
    <!--- Build JSON response --->
    <cfset response = {
        "posts": postsArray,
        "meta": {
            "page": url.page,
            "total_pages": totalPages,
            "total_posts": totalPosts,
            "posts_per_page": postsPerPage,
            "has_next": url.page LT totalPages,
            "has_previous": url.page GT 1
        }
    }>
    
<cfcatch>
    <cfset response = {
        "error": true,
        "message": cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>