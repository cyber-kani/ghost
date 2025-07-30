<!--- Get post from ghost_prod database using cross-database query --->
<cfoutput>
<h1>Accessing Ghost_prod Post</h1>

<cfset postId = "688a02858edd034b578322f0">

<cftry>
    <!--- Access ghost_prod database through blog datasource using fully qualified table name --->
    <cfquery name="qPost" datasource="blog">
        SELECT 
            p.id,
            p.title,
            p.slug,
            p.html,
            p.plaintext,
            p.feature_image,
            p.status,
            p.type,
            p.published_at,
            p.created_at,
            p.updated_at,
            p.custom_excerpt
        FROM ghost_prod.posts p
        WHERE p.id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qPost.recordCount GT 0>
        <div style="background: ##d4edda; padding: 20px; border: 2px solid ##28a745;">
            <h2>✓ Post Successfully Retrieved from ghost_prod!</h2>
            <table border="1" cellpadding="10" style="background: white;">
                <tr><td><strong>ID:</strong></td><td>#qPost.id#</td></tr>
                <tr><td><strong>Title:</strong></td><td>#qPost.title#</td></tr>
                <tr><td><strong>Slug:</strong></td><td>#qPost.slug#</td></tr>
                <tr><td><strong>Status:</strong></td><td>#qPost.status#</td></tr>
                <tr><td><strong>Type:</strong></td><td>#qPost.type#</td></tr>
                <tr><td><strong>Created:</strong></td><td>#dateFormat(qPost.created_at, "yyyy-mm-dd HH:nn:ss")#</td></tr>
                <tr><td><strong>Updated:</strong></td><td>#dateFormat(qPost.updated_at, "yyyy-mm-dd HH:nn:ss")#</td></tr>
            </table>
            
            <!--- Save HTML content to file --->
            <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ghost_prod_post_test12.html">
            <cffile action="write" file="#fileName#" output="#qPost.html#" charset="utf-8">
            
            <h3>HTML Content Saved!</h3>
            <p>File saved to: <a href="/ghost/testing/ghost_prod_post_test12.html" target="_blank">#fileName#</a></p>
            
            <h3>HTML Content Preview:</h3>
            <div style="background: ##f5f5f5; padding: 15px; border: 1px solid ##ddd; max-height: 400px; overflow: auto;">
                <pre style="white-space: pre-wrap; word-wrap: break-word;">#htmlEditFormat(qPost.html)#</pre>
            </div>
            
            <h3>Rendered Preview:</h3>
            <div style="border: 1px solid ##ddd; padding: 20px; background: white;">
                #qPost.html#
            </div>
        </div>
    <cfelse>
        <p style="color: red;">Post not found!</p>
    </cfif>
    
<cfcatch>
    <div style="background: ##ffebee; padding: 20px; border: 1px solid ##f44336;">
        <h3>Error:</h3>
        <p>#cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </div>
</cfcatch>
</cftry>

<h2>Compare with cc_prod Database:</h2>
<p><a href="compare-databases.cfm?title=Test%2012" style="background: ##2196f3; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Compare "Test 12" between databases</a></p>

</cfoutput>