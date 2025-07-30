<!--- List all posts from both databases --->
<cfoutput>
<h1>All Posts in Both Databases</h1>

<h2>1. Blog Database (cc_prod)</h2>
<cfquery name="qBlogPosts" datasource="blog">
    SELECT id, title, slug, type, status, created_at
    FROM posts
    ORDER BY created_at DESC
    LIMIT 20
</cfquery>

<table border="1" cellpadding="5" style="margin-bottom: 30px;">
    <tr style="background: ##0066cc; color: white;">
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Type</th>
        <th>Status</th>
        <th>Created</th>
    </tr>
    <cfloop query="qBlogPosts">
        <tr>
            <td>#id#</td>
            <td><strong>#title#</strong></td>
            <td>#slug#</td>
            <td>#type#</td>
            <td>#status#</td>
            <td>#dateFormat(created_at, "yyyy-mm-dd")#</td>
        </tr>
    </cfloop>
</table>

<h2>2. Yalulife Database</h2>
<cfquery name="qYaluPosts" datasource="yalulife">
    SELECT id, title, slug, type, status, created_at
    FROM posts
    ORDER BY created_at DESC
    LIMIT 20
</cfquery>

<table border="1" cellpadding="5">
    <tr style="background: ##00cc66; color: white;">
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Type</th>
        <th>Status</th>
        <th>Created</th>
    </tr>
    <cfloop query="qYaluPosts">
        <tr>
            <td>#id#</td>
            <td><strong>#title#</strong></td>
            <td>#slug#</td>
            <td>#type#</td>
            <td>#status#</td>
            <td>#dateFormat(created_at, "yyyy-mm-dd")#</td>
        </tr>
    </cfloop>
</table>

<h2>Quick Links to Compare Specific Posts</h2>
<p>Use these links to compare posts that exist in both databases:</p>
<ul>
    <li><a href="compare-databases.cfm?title=About%20this%20site">Compare "About this site"</a></li>
    <li><a href="compare-databases.cfm?title=Privacy%20Policy">Compare "Privacy Policy"</a></li>
</ul>

</cfoutput>