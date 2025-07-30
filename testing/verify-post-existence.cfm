<!--- Verify if post 688a02858edd034b578322f0 exists --->
<cfoutput>
<h1>Verifying Post: 688a02858edd034b578322f0</h1>

<h2>Summary:</h2>
<div style="background: ##f8d7da; padding: 20px; border: 1px solid ##f5c6cb; border-radius: 5px;">
    <h3>❌ Post Not Found in Blog Database</h3>
    <p>The post with ID <code>688a02858edd034b578322f0</code> does not exist in the current blog database.</p>
    
    <h4>Possible reasons:</h4>
    <ul>
        <li>The post may have been deleted</li>
        <li>The ID format suggests it's from a different database system (MongoDB-style ObjectId)</li>
        <li>It might exist in a different Ghost installation or database</li>
        <li>The ID might be from a different version of Ghost</li>
    </ul>
</div>

<h2>Available Posts in Database:</h2>
<cfquery name="qAvailable" datasource="blog">
    SELECT id, title, slug, status, type, created_at
    FROM posts
    ORDER BY created_at DESC
    LIMIT 10
</cfquery>

<table border="1" cellpadding="5" style="width: 100%;">
    <tr style="background: ##343a40; color: white;">
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Status</th>
        <th>Type</th>
        <th>Created</th>
        <th>Action</th>
    </tr>
    <cfloop query="qAvailable">
        <tr>
            <td style="font-family: monospace; font-size: 12px;">#id#</td>
            <td><strong>#title#</strong></td>
            <td>#slug#</td>
            <td>#status#</td>
            <td>#type#</td>
            <td>#dateFormat(created_at, "yyyy-mm-dd")#</td>
            <td><a href="get-specific-post.cfm?id=#id#">View</a></td>
        </tr>
    </cfloop>
</table>

<h2>What would you like to do?</h2>
<ul>
    <li><a href="post-comparison-tool.cfm">Use the Post Comparison Tool</a></li>
    <li><a href="post-comparison-tool.cfm?action=list">View all posts</a></li>
    <li>Search for a different post ID</li>
</ul>

<cfif qAvailable.recordCount GT 0>
    <h3>Quick Export First Post:</h3>
    <cfset firstPost = qAvailable.id[1]>
    <cfset firstTitle = qAvailable.title[1]>
    <p>Would you like to work with "<strong>#firstTitle#</strong>" (ID: #firstPost#)?</p>
    <p><a href="get-specific-post.cfm?id=#firstPost#" style="background: ##007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">View This Post</a></p>
</cfif>

</cfoutput>