<!--- Check specific post ID --->
<cfset testId = "687de71ebc740c1b43f0a355">

<cftry>
    <h3>Checking Post ID: <cfoutput>#testId#</cfoutput></h3>
    
    <!--- 1. Simple check --->
    <cfquery name="checkPost" datasource="blog">
        SELECT id, title, status, created_by
        FROM posts
        WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkPost.recordCount>
        <p style="color: green;">✅ Post found!</p>
        <cfoutput>
            <ul>
                <li>ID: #checkPost.id#</li>
                <li>Title: #checkPost.title#</li>
                <li>Status: #checkPost.status#</li>
                <li>Created By: #checkPost.created_by#</li>
            </ul>
        </cfoutput>
    <cfelse>
        <p style="color: red;">❌ Post NOT found with ID: <cfoutput>#testId#</cfoutput></p>
    </cfif>
    
    <!--- 2. Show some actual IDs --->
    <h3>Sample Post IDs in Database:</h3>
    <cfquery name="samplePosts" datasource="blog">
        SELECT id, title, LENGTH(id) as id_length
        FROM posts
        ORDER BY created_at DESC
        LIMIT 5
    </cfquery>
    
    <table border="1" cellpadding="5">
        <tr>
            <th>ID</th>
            <th>Title</th>
            <th>ID Length</th>
        </tr>
        <cfoutput query="samplePosts">
            <tr>
                <td><code>#id#</code></td>
                <td>#title#</td>
                <td>#id_length#</td>
            </tr>
        </cfoutput>
    </table>
    
    <!--- 3. Check if ID exists with LIKE --->
    <h3>Searching for similar IDs:</h3>
    <cfquery name="similarIds" datasource="blog">
        SELECT id, title
        FROM posts
        WHERE id LIKE '%687de71%'
        LIMIT 5
    </cfquery>
    
    <cfif similarIds.recordCount>
        <p>Found posts with similar ID pattern:</p>
        <cfoutput query="similarIds">
            <p>ID: <code>#id#</code> - Title: #title#</p>
        </cfoutput>
    <cfelse>
        <p>No posts found with ID containing '687de71'</p>
    </cfif>
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>