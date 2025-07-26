<!--- Verify if post exists --->
<cfset postId = "687de71ebc740c1b43f0a355">

<cftry>
    <h3>Checking if post exists with ID: <cfoutput>#postId#</cfoutput></h3>
    
    <cfquery name="checkPost" datasource="blog">
        SELECT id, title, status, created_by, html
        FROM posts
        WHERE id = <cfqueryparam value="#postId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkPost.recordCount>
        <p style="color: green;">✅ Post found!</p>
        <cfoutput>
            <ul>
                <li><strong>ID:</strong> #checkPost.id#</li>
                <li><strong>Title:</strong> #checkPost.title#</li>
                <li><strong>Status:</strong> #checkPost.status#</li>
                <li><strong>Created By:</strong> #checkPost.created_by#</li>
                <li><strong>Content Length:</strong> #len(checkPost.html)# characters</li>
            </ul>
        </cfoutput>
        
        <h4>Test Preview URLs:</h4>
        <ul>
            <li><a href="/ghost/preview/#postId#?member_status=public" target="_blank">Preview URL (should work)</a></li>
            <li><a href="/ghost/admin/preview.cfm?id=#postId#&member_status=public" target="_blank">Direct Preview Page</a></li>
        </ul>
    <cfelse>
        <p style="color: red;">❌ Post NOT found!</p>
        
        <!--- Show some existing posts --->
        <h4>Existing Posts (first 5):</h4>
        <cfquery name="existingPosts" datasource="blog">
            SELECT id, title, status
            FROM posts
            ORDER BY created_at DESC
            LIMIT 5
        </cfquery>
        
        <table border="1" cellpadding="5">
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Status</th>
                <th>Preview Link</th>
            </tr>
            <cfoutput query="existingPosts">
                <tr>
                    <td><code>#id#</code></td>
                    <td>#title#</td>
                    <td>#status#</td>
                    <td><a href="/ghost/preview/#id#?member_status=public" target="_blank">Preview</a></td>
                </tr>
            </cfoutput>
        </table>
    </cfif>
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>