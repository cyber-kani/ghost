<!--- Check all tables for the post ID --->
<cfoutput>
<h1>Searching for ID: 688a02858edd034b578322f0 in all tables</h1>

<h2>1. Check posts_meta table</h2>
<cftry>
    <cfquery name="qPostsMeta" datasource="blog">
        SELECT * FROM posts_meta 
        WHERE post_id = '688a02858edd034b578322f0'
        OR id = '688a02858edd034b578322f0'
    </cfquery>
    <p>posts_meta: #qPostsMeta.recordCount# records found</p>
<cfcatch>
    <p>posts_meta table error or doesn't exist: #cfcatch.message#</p>
</cfcatch>
</cftry>

<h2>2. Check posts_tags table</h2>
<cftry>
    <cfquery name="qPostsTags" datasource="blog">
        SELECT * FROM posts_tags 
        WHERE post_id = '688a02858edd034b578322f0'
        OR id = '688a02858edd034b578322f0'
    </cfquery>
    <p>posts_tags: #qPostsTags.recordCount# records found</p>
<cfcatch>
    <p>posts_tags table error: #cfcatch.message#</p>
</cfcatch>
</cftry>

<h2>3. Check for test/draft posts with different status</h2>
<cfquery name="qAllStatuses" datasource="blog">
    SELECT id, title, status, type, visibility
    FROM posts
    WHERE 1=1
    ORDER BY created_at DESC
</cfquery>

<h3>All posts by status:</h3>
<table border="1" cellpadding="5">
    <tr>
        <th>ID</th>
        <th>Title</th>
        <th>Status</th>
        <th>Type</th>
        <th>Visibility</th>
    </tr>
    <cfloop query="qAllStatuses">
        <tr>
            <td><code style="font-size: 11px;">#id#</code></td>
            <td>#title#</td>
            <td>#status#</td>
            <td>#type#</td>
            <td>#visibility#</td>
        </tr>
    </cfloop>
</table>

<h2>4. Show Database Structure</h2>
<cftry>
    <cfquery name="qColumns" datasource="blog">
        SHOW COLUMNS FROM posts
    </cfquery>
    <h3>Posts table structure:</h3>
    <table border="1" cellpadding="5">
        <cfloop query="qColumns">
            <tr>
                <td>#Field#</td>
                <td>#Type#</td>
                <td>#Null#</td>
                <td>#Key#</td>
            </tr>
        </cfloop>
    </table>
<cfcatch>
    <p>Could not get table structure</p>
</cfcatch>
</cftry>

<h2>5. Maybe it's in a different format?</h2>
<p>The ID 688a02858edd034b578322f0 looks like a MongoDB ObjectId (24 hex characters).</p>
<p>Current database IDs look different (e.g., "c2eed506ad1642cd8ebb2570").</p>

<h3>Let's search for "Test 12" by title instead:</h3>
<cfquery name="qByTitle" datasource="blog">
    SELECT id, title, slug, html
    FROM posts
    WHERE LOWER(title) LIKE '%test%'
    OR title = 'Test 12'
    OR title LIKE '%12%'
</cfquery>

<cfif qByTitle.recordCount GT 0>
    <h3>Posts with "test" or "12" in title:</h3>
    <cfloop query="qByTitle">
        <div style="border: 1px solid ##ccc; padding: 10px; margin: 10px 0;">
            <p><strong>ID:</strong> <code>#id#</code></p>
            <p><strong>Title:</strong> #title#</p>
            <p><strong>Slug:</strong> #slug#</p>
            <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/found_#id#.html">
            <cffile action="write" file="#fileName#" output="#html#" charset="utf-8">
            <p>HTML saved to: <a href="/ghost/testing/found_#id#.html">#fileName#</a></p>
        </div>
    </cfloop>
<cfelse>
    <p>No posts found with "test" or "12" in title</p>
</cfif>

</cfoutput>