<!--- Check database access and find ghost_prod data --->
<cfoutput>
<h1>Database Access Check</h1>

<h2>1. Check if "blog" datasource has the post you're looking for:</h2>
<cfset searchId = "688a02858edd034b578322f0">

<cfquery name="qBlogCheck" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        status,
        type,
        created_at
    FROM posts
    WHERE id = <cfqueryparam value="#searchId#" cfsqltype="cf_sql_varchar">
    OR id LIKE <cfqueryparam value="%#searchId#%" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qBlogCheck.recordCount GT 0>
    <div style="background: ##d4edda; padding: 15px;">
        <h3>✓ Found in 'blog' datasource!</h3>
        <cfloop query="qBlogCheck">
            <p>ID: #id#, Title: #title#</p>
        </cfloop>
    </div>
<cfelse>
    <p>Not found in 'blog' datasource</p>
</cfif>

<h2>2. Check current database name for each datasource:</h2>
<cftry>
    <cfquery name="qBlogDB" datasource="blog">
        SELECT DATABASE() as db_name
    </cfquery>
    <p><strong>Blog datasource connects to database:</strong> #qBlogDB.db_name#</p>
<cfcatch>
    <p>Could not determine blog database name</p>
</cfcatch>
</cftry>

<cftry>
    <cfquery name="qYaluDB" datasource="yalulife">
        SELECT DATABASE() as db_name
    </cfquery>
    <p><strong>Yalulife datasource connects to database:</strong> #qYaluDB.db_name#</p>
<cfcatch>
    <p>Could not determine yalulife database name</p>
</cfcatch>
</cftry>

<h2>3. Workaround - Direct Database Query:</h2>
<p>If the ghost_prod database is on the same MySQL server, you might be able to access it using fully qualified table names:</p>

<cftry>
    <cfquery name="qCrossDB" datasource="blog">
        SELECT 
            p.id,
            p.title,
            p.slug,
            p.html,
            p.status
        FROM ghost_prod.posts p
        WHERE p.id = <cfqueryparam value="#searchId#" cfsqltype="cf_sql_varchar">
        LIMIT 1
    </cfquery>
    
    <cfif qCrossDB.recordCount GT 0>
        <div style="background: ##d4edda; padding: 20px; border: 2px solid ##28a745;">
            <h3>✓ SUCCESS! Found post in ghost_prod database!</h3>
            <cfloop query="qCrossDB">
                <table border="1" cellpadding="10">
                    <tr><td><strong>ID:</strong></td><td>#id#</td></tr>
                    <tr><td><strong>Title:</strong></td><td>#title#</td></tr>
                    <tr><td><strong>Slug:</strong></td><td>#slug#</td></tr>
                    <tr><td><strong>Status:</strong></td><td>#status#</td></tr>
                </table>
                
                <!--- Save HTML --->
                <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ghost_prod_post_#id#.html">
                <cffile action="write" file="#fileName#" output="#html#" charset="utf-8">
                <p><strong>HTML saved to:</strong> <a href="/ghost/testing/ghost_prod_post_#id#.html" target="_blank">#fileName#</a></p>
                
                <h4>HTML Content:</h4>
                <pre style="background: ##f5f5f5; padding: 15px; overflow: auto; max-height: 400px;">#htmlEditFormat(html)#</pre>
            </cfloop>
        </div>
    <cfelse>
        <p>Post not found using cross-database query</p>
    </cfif>
<cfcatch>
    <div style="background: ##ffebee; padding: 15px; border: 1px solid ##ef5350;">
        <p><strong>Cross-database query failed:</strong> #cfcatch.message#</p>
        <p>This might mean:</p>
        <ul>
            <li>The ghost_prod database doesn't exist on this server</li>
            <li>The user doesn't have permissions to access ghost_prod</li>
            <li>The databases are on different servers</li>
        </ul>
    </div>
</cfcatch>
</cftry>

<h2>4. Alternative: List all posts and find the one you need:</h2>
<cfquery name="qAllPosts" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        status,
        created_at,
        LENGTH(html) as html_size
    FROM posts
    ORDER BY created_at DESC
</cfquery>

<p>Total posts available: #qAllPosts.recordCount#</p>
<p><a href="post-comparison-tool.cfm?action=list">View all posts in comparison tool</a></p>

</cfoutput>