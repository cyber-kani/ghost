<!--- Test Post ID --->
<cfparam name="url.id" default="687de71ebc740c1b43f0a355">

<cfquery name="checkPost" datasource="blog">
    SELECT id, title, status, created_by
    FROM posts
    WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfoutput>
<h3>Testing Post ID: #url.id#</h3>
<cfif checkPost.recordCount>
    <p>Post found!</p>
    <ul>
        <li>ID: #checkPost.id#</li>
        <li>Title: #checkPost.title#</li>
        <li>Status: #checkPost.status#</li>
        <li>Created By: #checkPost.created_by#</li>
    </ul>
<cfelse>
    <p style="color: red;">Post NOT found in database!</p>
</cfif>

<h3>All Posts in Database:</h3>
<cfquery name="allPosts" datasource="blog">
    SELECT id, title, status
    FROM posts
    ORDER BY created_at DESC
    LIMIT 10
</cfquery>

<table border="1">
    <tr>
        <th>ID</th>
        <th>Title</th>
        <th>Status</th>
    </tr>
    <cfloop query="allPosts">
        <tr>
            <td>#id#</td>
            <td>#title#</td>
            <td>#status#</td>
        </tr>
    </cfloop>
</table>
</cfoutput>