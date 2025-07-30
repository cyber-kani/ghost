<!--- Get specific post by ID --->
<cfparam name="url.id" default="688a02858edd034b578322f0">

<cfoutput>
<h1>Looking for Post ID: #url.id#</h1>

<h2>Searching in Blog Database</h2>
<cfquery name="qPost" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        html,
        plaintext,
        feature_image,
        status,
        type,
        published_at,
        created_at,
        updated_at
    FROM posts
    WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qPost.recordCount GT 0>
    <div style="border: 2px solid ##0066cc; padding: 20px;">
        <h2>✓ Post Found!</h2>
        <table border="1" cellpadding="10">
            <tr><td><strong>ID:</strong></td><td>#qPost.id#</td></tr>
            <tr><td><strong>Title:</strong></td><td>#qPost.title#</td></tr>
            <tr><td><strong>Slug:</strong></td><td>#qPost.slug#</td></tr>
            <tr><td><strong>Type:</strong></td><td>#qPost.type#</td></tr>
            <tr><td><strong>Status:</strong></td><td>#qPost.status#</td></tr>
            <tr><td><strong>Created:</strong></td><td>#dateFormat(qPost.created_at, "yyyy-mm-dd HH:nn:ss")#</td></tr>
            <tr><td><strong>Updated:</strong></td><td>#dateFormat(qPost.updated_at, "yyyy-mm-dd HH:nn:ss")#</td></tr>
        </table>
        
        <!--- Save HTML content --->
        <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/post_#qPost.id#.html">
        <cffile action="write" file="#fileName#" output="#qPost.html#" charset="utf-8">
        
        <h3>HTML Content (saved to #fileName#):</h3>
        <div style="background: ##f5f5f5; padding: 15px; margin: 10px 0; border: 1px solid ##ddd;">
            <pre style="white-space: pre-wrap; word-wrap: break-word;"><code>#htmlEditFormat(qPost.html)#</code></pre>
        </div>
        
        <h3>Rendered Preview:</h3>
        <div style="border: 1px solid ##ddd; padding: 20px; margin: 10px 0;">
            #qPost.html#
        </div>
        
        <p><a href="/ghost/testing/post_#qPost.id#.html" target="_blank">View saved HTML file</a></p>
    </div>
<cfelse>
    <p style="color: red; font-size: 18px;">❌ Post not found with ID: #url.id#</p>
    
    <h3>Let's search for similar IDs:</h3>
    <cfquery name="qSimilar" datasource="blog">
        SELECT id, title, slug, type, status
        FROM posts
        WHERE id LIKE <cfqueryparam value="%#left(url.id, 10)#%" cfsqltype="cf_sql_varchar">
        ORDER BY created_at DESC
        LIMIT 10
    </cfquery>
    
    <cfif qSimilar.recordCount GT 0>
        <p>Found #qSimilar.recordCount# posts with similar IDs:</p>
        <table border="1" cellpadding="5">
            <tr style="background: ##eee;">
                <th>ID</th>
                <th>Title</th>
                <th>Slug</th>
                <th>Type</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
            <cfloop query="qSimilar">
                <tr>
                    <td>#id#</td>
                    <td>#title#</td>
                    <td>#slug#</td>
                    <td>#type#</td>
                    <td>#status#</td>
                    <td><a href="get-specific-post.cfm?id=#id#">View</a></td>
                </tr>
            </cfloop>
        </table>
    <cfelse>
        <p>No similar IDs found.</p>
    </cfif>
    
    <h3>All Available Posts:</h3>
    <cfquery name="qAll" datasource="blog">
        SELECT id, title, slug, type, status
        FROM posts
        ORDER BY created_at DESC
        LIMIT 20
    </cfquery>
    
    <table border="1" cellpadding="5">
        <tr style="background: ##eee;">
            <th>ID</th>
            <th>Title</th>
            <th>Slug</th>
            <th>Type</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
        <cfloop query="qAll">
            <tr>
                <td><code>#id#</code></td>
                <td>#title#</td>
                <td>#slug#</td>
                <td>#type#</td>
                <td>#status#</td>
                <td><a href="get-specific-post.cfm?id=#id#">View</a></td>
            </tr>
        </cfloop>
    </table>
</cfif>

</cfoutput>