<!--- Find posts by partial ID match --->
<cfparam name="request.dsn" default="ghost_prod">
<cfparam name="url.search" default="688a02858edd034b578322f0">

<!--- Query posts with LIKE search --->
<cfquery name="qPosts" datasource="#request.dsn#">
    SELECT 
        id,
        title,
        slug,
        status,
        type,
        html,
        published_at,
        created_at
    FROM posts
    WHERE id LIKE <cfqueryparam value="%#url.search#%" cfsqltype="cf_sql_varchar">
    OR id = <cfqueryparam value="#url.search#" cfsqltype="cf_sql_varchar">
    OR title LIKE <cfqueryparam value="%688a02858edd034b578322f0%" cfsqltype="cf_sql_varchar">
    ORDER BY created_at DESC
</cfquery>

<cfoutput>
    <h1>Search Results for: #url.search#</h1>
    <p>Found: #qPosts.recordCount# posts</p>
    
    <cfif qPosts.recordCount GT 0>
        <cfloop query="qPosts">
            <div style="border: 1px solid ##ccc; padding: 10px; margin: 10px 0;">
                <h2>#title#</h2>
                <p><strong>ID:</strong> #id#</p>
                <p><strong>Slug:</strong> #slug#</p>
                <p><strong>Type:</strong> #type# | <strong>Status:</strong> #status#</p>
                <p><strong>Published:</strong> #dateFormat(published_at, "yyyy-mm-dd")#</p>
                
                <!--- Save HTML to file --->
                <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ghost_prod_post_#id#.html">
                <cffile action="write" file="#fileName#" output="#html#" charset="utf-8">
                <p><strong>HTML saved to:</strong> #fileName#</p>
            </div>
        </cfloop>
    <cfelse>
        <p>No posts found matching the search criteria.</p>
    </cfif>
</cfoutput>