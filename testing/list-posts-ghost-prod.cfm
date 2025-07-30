<!--- List posts from ghost_prod database --->
<cfparam name="request.dsn" default="ghost_prod">

<!--- Query posts --->
<cfquery name="qPosts" datasource="#request.dsn#">
    SELECT 
        id,
        title,
        slug,
        status,
        type,
        published_at,
        created_at
    FROM posts
    ORDER BY created_at DESC
    LIMIT 20
</cfquery>

<cfoutput>
    <h1>Posts in ghost_prod database</h1>
    <p>Total posts shown: #qPosts.recordCount# (limited to 20)</p>
    
    <table border="1" cellpadding="5" cellspacing="0">
        <thead>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Slug</th>
                <th>Type</th>
                <th>Status</th>
                <th>Published</th>
            </tr>
        </thead>
        <tbody>
            <cfloop query="qPosts">
                <tr>
                    <td>#id#</td>
                    <td>#title#</td>
                    <td>#slug#</td>
                    <td>#type#</td>
                    <td>#status#</td>
                    <td>#dateFormat(published_at, "yyyy-mm-dd")#</td>
                </tr>
            </cfloop>
        </tbody>
    </table>
</cfoutput>