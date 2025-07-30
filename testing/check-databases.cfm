<!--- Check both databases for posts --->
<cfoutput>
<h1>Database Comparison</h1>

<h2>1. Checking cc_prod database (default blog datasource)</h2>
<cfquery name="qCC" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        type,
        status,
        LENGTH(html) as html_length
    FROM posts
    WHERE title LIKE <cfqueryparam value="%Test%" cfsqltype="cf_sql_varchar">
    ORDER BY created_at DESC
    LIMIT 10
</cfquery>

<p>Found #qCC.recordCount# posts with "Test" in title:</p>
<table border="1" cellpadding="5">
    <tr>
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Type</th>
        <th>Status</th>
        <th>HTML Length</th>
    </tr>
    <cfloop query="qCC">
        <tr>
            <td>#id#</td>
            <td>#title#</td>
            <td>#slug#</td>
            <td>#type#</td>
            <td>#status#</td>
            <td>#html_length#</td>
        </tr>
    </cfloop>
</table>

<h2>2. Checking ghost_prod database</h2>
<cfquery name="qGhost" datasource="ghost_prod">
    SELECT 
        id,
        title,
        slug,
        type,
        status,
        LENGTH(html) as html_length
    FROM posts
    WHERE title LIKE <cfqueryparam value="%Test%" cfsqltype="cf_sql_varchar">
    ORDER BY created_at DESC
    LIMIT 10
</cfquery>

<p>Found #qGhost.recordCount# posts with "Test" in title:</p>
<table border="1" cellpadding="5">
    <tr>
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Type</th>
        <th>Status</th>
        <th>HTML Length</th>
    </tr>
    <cfloop query="qGhost">
        <tr>
            <td>#id#</td>
            <td>#title#</td>
            <td>#slug#</td>
            <td>#type#</td>
            <td>#status#</td>
            <td>#html_length#</td>
        </tr>
    </cfloop>
</table>

<h2>3. Looking specifically for "Test 12"</h2>
<cfquery name="qTest12CC" datasource="blog">
    SELECT id, title, html FROM posts WHERE title = <cfqueryparam value="Test 12" cfsqltype="cf_sql_varchar">
</cfquery>
<cfquery name="qTest12Ghost" datasource="ghost_prod">
    SELECT id, title, html FROM posts WHERE title = <cfqueryparam value="Test 12" cfsqltype="cf_sql_varchar">
</cfquery>

<p>In cc_prod (blog): <cfif qTest12CC.recordCount GT 0>Found - ID: #qTest12CC.id#<cfelse>Not found</cfif></p>
<p>In ghost_prod: <cfif qTest12Ghost.recordCount GT 0>Found - ID: #qTest12Ghost.id#<cfelse>Not found</cfif></p>

</cfoutput>