<!--- Get post from ghost_prod database --->
<cfparam name="request.dsn" default="ghost_prod">

<!--- Query the post --->
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
        custom_excerpt
    FROM posts
    WHERE id = <cfqueryparam value="688a02858edd034b578322f0" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qPost.recordCount GT 0>
    <!--- Save to file --->
    <cfset postContent = qPost.html>
    <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/ghost_prod_post_688a02858edd034b578322f0.html">
    
    <cffile action="write" file="#fileName#" output="#postContent#" charset="utf-8">
    
    <cfoutput>
        <h1>Post from ghost_prod database</h1>
        <p><strong>ID:</strong> #qPost.id#</p>
        <p><strong>Title:</strong> #qPost.title#</p>
        <p><strong>Slug:</strong> #qPost.slug#</p>
        <p><strong>Published:</strong> #dateFormat(qPost.published_at, "yyyy-mm-dd")# #timeFormat(qPost.published_at, "HH:mm:ss")#</p>
        <p><strong>HTML content saved to:</strong> #fileName#</p>
        
        <h2>Preview:</h2>
        <div style="border: 1px solid ##ccc; padding: 20px; margin: 20px 0;">
            #qPost.html#
        </div>
    </cfoutput>
<cfelse>
    <p>Post not found in ghost_prod database with ID: 688a02858edd034b578322f0</p>
</cfif>