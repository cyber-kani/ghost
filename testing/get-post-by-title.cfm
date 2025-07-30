<!--- Get post by title from ghost_prod database --->
<cfparam name="request.dsn" default="ghost_prod">
<cfparam name="url.title" default="Test 12">

<!--- Query the post by title --->
<cfquery name="qPost" datasource="#request.dsn#">
    SELECT 
        id,
        title,
        slug,
        html,
        plaintext,
        feature_image,
        published_at,
        created_at,
        updated_at,
        custom_excerpt,
        status,
        type
    FROM posts
    WHERE title = <cfqueryparam value="#url.title#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qPost.recordCount GT 0>
    <!--- Save to file --->
    <cfset postContent = qPost.html>
    <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ghost_prod_post_test12.html">
    
    <cffile action="write" file="#fileName#" output="#postContent#" charset="utf-8">
    
    <cfoutput>
        <h1>Post from ghost_prod database</h1>
        <p><strong>ID:</strong> #qPost.id#</p>
        <p><strong>Title:</strong> #qPost.title#</p>
        <p><strong>Slug:</strong> #qPost.slug#</p>
        <p><strong>Type:</strong> #qPost.type#</p>
        <p><strong>Status:</strong> #qPost.status#</p>
        <p><strong>Published:</strong> #dateFormat(qPost.published_at, "yyyy-mm-dd")# #timeFormat(qPost.published_at, "HH:mm:ss")#</p>
        <p><strong>HTML content saved to:</strong> #fileName#</p>
        
        <h2>HTML Content:</h2>
        <div style="border: 1px solid ##ccc; padding: 20px; margin: 20px 0; background: ##f5f5f5;">
            <pre><code>#htmlEditFormat(qPost.html)#</code></pre>
        </div>
        
        <h2>Rendered Preview:</h2>
        <div style="border: 1px solid ##ccc; padding: 20px; margin: 20px 0;">
            #qPost.html#
        </div>
    </cfoutput>
<cfelse>
    <p>Post not found in ghost_prod database with title: #url.title#</p>
    
    <!--- Let's search for similar titles --->
    <cfquery name="qSimilar" datasource="#request.dsn#">
        SELECT id, title, slug, type, status
        FROM posts
        WHERE title LIKE <cfqueryparam value="%Test%" cfsqltype="cf_sql_varchar">
        ORDER BY created_at DESC
        LIMIT 10
    </cfquery>
    
    <cfif qSimilar.recordCount GT 0>
        <h2>Similar posts found:</h2>
        <ul>
            <cfoutput query="qSimilar">
                <li><strong>#title#</strong> (ID: #id#, Slug: #slug#, Type: #type#, Status: #status#)</li>
            </cfoutput>
        </ul>
    </cfif>
</cfif>