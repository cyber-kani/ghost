<!--- Find exact post by ID --->
<cfparam name="url.id" default="688a02858edd034b578322f0">

<cfoutput>
<h1>Searching for Post ID: #url.id#</h1>

<h2>1. Direct ID Search in Blog Database</h2>
<cfquery name="qDirect" datasource="blog">
    SELECT * FROM posts 
    WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qDirect.recordCount GT 0>
    <div style="background: ##d4edda; padding: 20px; border: 2px solid ##28a745;">
        <h2>✓ POST FOUND!</h2>
        <cfloop query="qDirect">
            <table border="1" cellpadding="10">
                <tr><td><strong>ID:</strong></td><td>#id#</td></tr>
                <tr><td><strong>Title:</strong></td><td>#title#</td></tr>
                <tr><td><strong>Slug:</strong></td><td>#slug#</td></tr>
                <tr><td><strong>Type:</strong></td><td>#type#</td></tr>
                <tr><td><strong>Status:</strong></td><td>#status#</td></tr>
                <tr><td><strong>Created:</strong></td><td>#dateFormat(created_at, "yyyy-mm-dd HH:nn:ss")#</td></tr>
            </table>
            
            <!--- Save HTML --->
            <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/post_688a02858edd034b578322f0.html">
            <cffile action="write" file="#fileName#" output="#html#" charset="utf-8">
            <p><strong>HTML saved to:</strong> <a href="/ghost/testing/post_688a02858edd034b578322f0.html" target="_blank">#fileName#</a></p>
            
            <h3>HTML Content:</h3>
            <pre style="background: ##f5f5f5; padding: 15px; overflow: auto;">#htmlEditFormat(html)#</pre>
        </cfloop>
    </div>
<cfelse>
    <p style="color: red;">Direct search: Not found</p>
</cfif>

<h2>2. Check All Post IDs (Show first 50)</h2>
<cfquery name="qAllIDs" datasource="blog">
    SELECT id, title, slug, type, status 
    FROM posts 
    ORDER BY 
        CASE WHEN id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar"> THEN 0 ELSE 1 END,
        created_at DESC
    LIMIT 50
</cfquery>

<table border="1" cellpadding="5">
    <tr style="background: ##333; color: white;">
        <th>Row</th>
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Type</th>
        <th>Status</th>
        <th>Match?</th>
    </tr>
    <cfloop query="qAllIDs">
        <tr <cfif id EQ url.id>style="background: ##ffffcc; font-weight: bold;"</cfif>>
            <td>#currentRow#</td>
            <td><code>#id#</code></td>
            <td>#title#</td>
            <td>#slug#</td>
            <td>#type#</td>
            <td>#status#</td>
            <td><cfif id EQ url.id><span style="color: green;">✓ MATCH!</span><cfelse>-</cfif></td>
        </tr>
    </cfloop>
</table>

<h2>3. Search with LIKE operator</h2>
<cfquery name="qLike" datasource="blog">
    SELECT id, title, slug, type, status 
    FROM posts 
    WHERE id LIKE <cfqueryparam value="%#url.id#%" cfsqltype="cf_sql_varchar">
    OR id LIKE <cfqueryparam value="%688a02858edd034b578322f0%" cfsqltype="cf_sql_varchar">
</cfquery>

<p>LIKE search found: #qLike.recordCount# posts</p>
<cfif qLike.recordCount GT 0>
    <cfloop query="qLike">
        <p>Found: ID = <code>#id#</code>, Title = #title#</p>
    </cfloop>
</cfif>

<h2>4. Check ID Length and Format</h2>
<cfquery name="qCheckLength" datasource="blog">
    SELECT 
        id,
        LENGTH(id) as id_length,
        title
    FROM posts
    WHERE LENGTH(id) = #len(url.id)#
    LIMIT 10
</cfquery>

<p>Posts with same ID length (#len(url.id)# characters):</p>
<cfloop query="qCheckLength">
    <p>ID: <code>#id#</code> (length: #id_length#) - #title#</p>
</cfloop>

<h2>5. Raw SQL Query</h2>
<cftry>
    <cfquery name="qRaw" datasource="blog">
        SELECT id, title FROM posts WHERE id = '688a02858edd034b578322f0'
    </cfquery>
    <p>Raw query result: #qRaw.recordCount# records</p>
    <cfif qRaw.recordCount GT 0>
        <p style="color: green; font-weight: bold;">FOUND via raw query: #qRaw.title#</p>
    </cfif>
<cfcatch>
    <p>Raw query error: #cfcatch.message#</p>
</cfcatch>
</cftry>

</cfoutput>