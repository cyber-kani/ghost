<!--- Find all posts with Test in title --->
<cfoutput>
<h1>Finding Posts with "Test" in Title</h1>

<h2>1. Blog Database</h2>
<cfquery name="qBlogTest" datasource="blog">
    SELECT id, title, slug, type, status, html
    FROM posts
    WHERE LOWER(title) LIKE <cfqueryparam value="%test%" cfsqltype="cf_sql_varchar">
    ORDER BY created_at DESC
</cfquery>

<p>Found #qBlogTest.recordCount# posts with "test" in title:</p>
<cfif qBlogTest.recordCount GT 0>
    <cfloop query="qBlogTest">
        <div style="border: 1px solid ##0066cc; padding: 10px; margin: 10px 0;">
            <h3>#title#</h3>
            <p>ID: #id# | Slug: #slug# | Type: #type# | Status: #status#</p>
            <p>HTML Length: #len(html)# characters</p>
            
            <!--- Save this post --->
            <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/blog_#replace(slug, '-', '_', 'all')#.html">
            <cffile action="write" file="#fileName#" output="#html#" charset="utf-8">
            <p>Saved to: <a href="/ghost/testing/blog_#replace(slug, '-', '_', 'all')#.html">#fileName#</a></p>
        </div>
    </cfloop>
</cfif>

<h2>2. Yalulife Database</h2>
<cfquery name="qYaluTest" datasource="yalulife">
    SELECT id, title, slug, type, status, html
    FROM posts
    WHERE LOWER(title) LIKE <cfqueryparam value="%test%" cfsqltype="cf_sql_varchar">
    ORDER BY created_at DESC
</cfquery>

<p>Found #qYaluTest.recordCount# posts with "test" in title:</p>
<cfif qYaluTest.recordCount GT 0>
    <cfloop query="qYaluTest">
        <div style="border: 1px solid ##00cc66; padding: 10px; margin: 10px 0;">
            <h3>#title#</h3>
            <p>ID: #id# | Slug: #slug# | Type: #type# | Status: #status#</p>
            <p>HTML Length: #len(html)# characters</p>
            
            <!--- Save this post --->
            <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/yalulife_#replace(slug, '-', '_', 'all')#.html">
            <cffile action="write" file="#fileName#" output="#html#" charset="utf-8">
            <p>Saved to: <a href="/ghost/testing/yalulife_#replace(slug, '-', '_', 'all')#.html">#fileName#</a></p>
        </div>
    </cfloop>
</cfif>

<h2>3. Let's find ANY recent post to compare</h2>
<cfquery name="qBlogRecent" datasource="blog" maxrows="1">
    SELECT id, title, slug, html FROM posts 
    WHERE type = 'post' AND status = 'published' AND html IS NOT NULL AND html != ''
    ORDER BY created_at DESC
</cfquery>

<cfquery name="qYaluRecent" datasource="yalulife" maxrows="1">
    SELECT id, title, slug, html FROM posts 
    WHERE type = 'post' AND status = 'published' AND html IS NOT NULL AND html != ''
    ORDER BY created_at DESC
</cfquery>

<cfif qBlogRecent.recordCount GT 0>
    <p><strong>Most recent post in Blog DB:</strong> <a href="compare-databases.cfm?title=#urlEncodedFormat(qBlogRecent.title)#">#qBlogRecent.title#</a></p>
</cfif>

<cfif qYaluRecent.recordCount GT 0>
    <p><strong>Most recent post in Yalulife DB:</strong> <a href="compare-databases.cfm?title=#urlEncodedFormat(qYaluRecent.title)#">#qYaluRecent.title#</a></p>
</cfif>

</cfoutput>