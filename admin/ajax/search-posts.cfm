<!--- Search Posts AJAX Handler --->
<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">
<cfcontent reset="true">

<cfparam name="url.q" default="">
<cfparam name="url.type" default="post">

<!--- Use the application datasource --->
<cfif not structKeyExists(request, "dsn")>
    <cfset request.dsn = application.datasource ?: "blog">
</cfif>

<cfset response = {success: false, posts: [], query: url.q, type: url.type, datasource: request.dsn}>

<cftry>
    <!--- Check if user is logged in --->
    <cfif not structKeyExists(session, "ISLOGGEDIN") or not session.ISLOGGEDIN>
        <cfset response.message = "User not logged in">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Search for posts if query length is at least 2 characters --->
    <cfif len(trim(url.q)) gte 2>
        <cfquery name="searchResults" datasource="#request.dsn#">
            SELECT 
                p.id,
                p.title,
                p.slug,
                p.status,
                p.published_at,
                p.created_at,
                u.name as author_name
            FROM posts p
            LEFT JOIN users u ON p.created_by = u.id
            WHERE p.type = <cfqueryparam value="#url.type#" cfsqltype="cf_sql_varchar">
            AND (
                p.title LIKE <cfqueryparam value="%#url.q#%" cfsqltype="cf_sql_varchar">
                OR p.plaintext LIKE <cfqueryparam value="%#url.q#%" cfsqltype="cf_sql_varchar">
                OR p.slug LIKE <cfqueryparam value="%#url.q#%" cfsqltype="cf_sql_varchar">
            )
            ORDER BY 
                CASE 
                    WHEN p.title LIKE <cfqueryparam value="#url.q#%" cfsqltype="cf_sql_varchar"> THEN 1
                    WHEN p.title LIKE <cfqueryparam value="%#url.q#%" cfsqltype="cf_sql_varchar"> THEN 2
                    ELSE 3
                END,
                p.published_at DESC
            LIMIT 10
        </cfquery>
        
        <!--- Format results --->
        <cfloop query="searchResults">
            <cfset postItem = {
                id: searchResults.id,
                title: searchResults.title,
                slug: searchResults.slug,
                status: searchResults.status,
                author: searchResults.author_name ?: "Unknown",
                published_at: isDate(searchResults.published_at) ? dateFormat(searchResults.published_at, "mmm d, yyyy") : "",
                created_at: dateFormat(searchResults.created_at, "mmm d, yyyy"),
                url: "/ghost/admin/#url.type eq 'page' ? 'page' : 'post'#/edit/#searchResults.id#"
            }>
            <cfset arrayAppend(response.posts, postItem)>
        </cfloop>
    </cfif>
    
    <cfset response.success = true>
    <cfset response.count = arrayLen(response.posts)>
    
    <cfcatch>
        <cfset response.message = "Error searching posts: " & cfcatch.message>
        <cfset response.error = cfcatch.detail>
        <cfset response.errorType = cfcatch.type>
    </cfcatch>
</cftry>

<!--- Output JSON response --->
<cfoutput>#serializeJSON(response)#</cfoutput>