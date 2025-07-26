<!--- Check Post ID Format --->
<cfset testId = "687de71ebc740c1b43f0a355">

<h2>Checking Post ID Format</h2>

<h3>1. Check if this ID exists:</h3>
<cftry>
    <cfquery name="checkExact" datasource="blog">
        SELECT id, title 
        FROM posts 
        WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkExact.recordCount>
        <p style="color: green;">✅ Post found with exact ID!</p>
    <cfelse>
        <p style="color: red;">❌ No post found with ID: <cfoutput>#testId#</cfoutput></p>
    </cfif>
    
    <cfcatch>
        <p style="color: red;">Error checking exact ID: <cfoutput>#cfcatch.message#</cfoutput></p>
    </cfcatch>
</cftry>

<h3>2. Show actual post IDs in database:</h3>
<cfquery name="showIds" datasource="blog">
    SELECT 
        id,
        title,
        LENGTH(id) as id_length,
        CASE 
            WHEN id REGEXP '^[0-9]+$' THEN 'Numeric'
            ELSE 'String'
        END as id_type
    FROM posts
    ORDER BY created_at DESC
    LIMIT 10
</cfquery>

<table border="1" cellpadding="5">
    <tr>
        <th>ID</th>
        <th>Title</th>
        <th>ID Length</th>
        <th>ID Type</th>
    </tr>
    <cfoutput query="showIds">
        <tr>
            <td><code>#id#</code></td>
            <td>#title#</td>
            <td>#id_length#</td>
            <td>#id_type#</td>
        </tr>
    </cfoutput>
</table>

<h3>3. Database Column Information:</h3>
<cfquery name="columnInfo" datasource="blog">
    SHOW COLUMNS FROM posts WHERE Field = 'id'
</cfquery>

<cfoutput query="columnInfo">
    <p><strong>Column Type:</strong> #Type#</p>
    <p><strong>Key:</strong> #Key#</p>
</cfoutput>

<h3>4. Test Preview URLs:</h3>
<cfif showIds.recordCount>
    <p>Click to test preview with actual post IDs:</p>
    <ul>
        <cfoutput query="showIds" maxrows="3">
            <li>
                <a href="/ghost/preview/#id#?member_status=public" target="_blank">
                    Preview: #title# (ID: #id#)
                </a>
            </li>
        </cfoutput>
    </ul>
</cfif>