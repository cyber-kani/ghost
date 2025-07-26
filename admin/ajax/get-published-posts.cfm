<cfcontent type="application/json" reset="true">
<cfheader name="X-Content-Type-Options" value="nosniff">

<cfset response = {
    "success": false,
    "message": "",
    "posts": []
}>

<cftry>
    <!--- Get published posts --->
    <cfquery name="qPosts" datasource="blog">
        SELECT 
            p.id,
            p.slug,
            p.title,
            p.custom_excerpt as excerpt,
            p.feature_image,
            p.published_at,
            u.name as author_name
        FROM posts p
        LEFT JOIN users u ON p.author_id = u.id
        WHERE p.status = 'published'
        AND p.type = 'post'
        ORDER BY p.published_at DESC
        LIMIT 50
    </cfquery>
    
    <!--- Build posts array --->
    <cfset postsArray = []>
    
    <cfloop query="qPosts">
        <cfset post = {
            "id": qPosts.id,
            "slug": qPosts.slug,
            "title": qPosts.title,
            "excerpt": qPosts.excerpt ?: "",
            "feature_image": qPosts.feature_image ?: "",
            "published_at": dateFormat(qPosts.published_at, "yyyy-mm-dd") & " " & timeFormat(qPosts.published_at, "HH:mm:ss"),
            "author": qPosts.author_name ?: ""
        }>
        
        <cfset arrayAppend(postsArray, post)>
    </cfloop>
    
    <cfset response.success = true>
    <cfset response.posts = postsArray>
    <cfset response.message = "Posts loaded successfully">
    
    <cfcatch>
        <cfset response.success = false>
        <cfset response.message = "Failed to load posts: #cfcatch.message#">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>