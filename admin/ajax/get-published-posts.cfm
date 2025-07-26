<cfcontent type="application/json" reset="true">
<cfheader name="X-Content-Type-Options" value="nosniff">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "user") OR NOT structKeyExists(session.user, "id")>
    <cfset response = {
        "success": false,
        "message": "Unauthorized access",
        "posts": []
    }>
    <cfoutput>#serializeJSON(response)#</cfoutput>
    <cfabort>
</cfif>

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
            p.feature_image,
            p.published_at
        FROM posts p
        WHERE p.status = 'published'
        ORDER BY p.created_at DESC
        LIMIT 50
    </cfquery>
    
    <!--- Build posts array --->
    <cfset postsArray = []>
    
    <cfloop query="qPosts">
        <cfset publishedDate = "">
        <cfif NOT isNull(qPosts.published_at) AND isDate(qPosts.published_at)>
            <cfset publishedDate = dateFormat(qPosts.published_at, "yyyy-mm-dd") & " " & timeFormat(qPosts.published_at, "HH:mm:ss")>
        </cfif>
        
        <cfset post = {
            "id": qPosts.id,
            "slug": qPosts.slug ?: "",
            "title": qPosts.title ?: "Untitled",
            "excerpt": "",
            "feature_image": qPosts.feature_image ?: "",
            "published_at": publishedDate,
            "author": ""
        }>
        
        <cfset arrayAppend(postsArray, post)>
    </cfloop>
    
    <cfset response.success = true>
    <cfset response.posts = postsArray>
    <cfset response.message = "Posts loaded successfully">
    <cfset response.count = qPosts.recordCount>
    
    <cfcatch>
        <cfset response.success = false>
        <cfset response.message = "Failed to load posts: #cfcatch.message#">
        <cfset response.error = {
            "type": cfcatch.type,
            "message": cfcatch.message,
            "detail": cfcatch.detail
        }>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>