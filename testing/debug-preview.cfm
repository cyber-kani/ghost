<!--- Debug Preview --->
<cftry>
    <cfset testId = "687de71ebc740c1b43f0a355">
    
    <h3>Debug Preview Page</h3>
    
    <h4>1. Testing Database Connection:</h4>
    <cfquery name="testDB" datasource="blog">
        SELECT 1 as test
    </cfquery>
    <p>Database connection: <cfif testDB.recordCount>✅ OK<cfelse>❌ Failed</cfif></p>
    
    <h4>2. Testing Post Query:</h4>
    <cfquery name="postData" datasource="blog">
        SELECT 
            p.id,
            p.title,
            p.slug,
            p.content,
            p.excerpt,
            p.feature_image,
            p.status,
            p.visibility,
            p.meta_title,
            p.meta_description,
            p.published_at,
            p.created_at,
            p.updated_at,
            u.name as author_name,
            u.slug as author_slug,
            u.bio as author_bio,
            u.profile_image as author_image
        FROM posts p
        INNER JOIN users u ON p.created_by = u.id
        WHERE p.id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <p>Post found: <cfif postData.recordCount>✅ YES (Title: <cfoutput>#postData.title#</cfoutput>)<cfelse>❌ NO</cfif></p>
    
    <h4>3. Checking Post ID Type in Database:</h4>
    <cfquery name="checkIdType" datasource="blog">
        SELECT 
            id,
            LENGTH(id) as id_length,
            CAST(id AS CHAR) as id_as_char
        FROM posts
        WHERE id LIKE '%687de71%'
        LIMIT 5
    </cfquery>
    
    <cfif checkIdType.recordCount>
        <p>Found posts with similar ID:</p>
        <table border="1">
            <tr><th>ID</th><th>Length</th><th>As Char</th></tr>
            <cfoutput query="checkIdType">
                <tr><td>#id#</td><td>#id_length#</td><td>#id_as_char#</td></tr>
            </cfoutput>
        </table>
    <cfelse>
        <p>No posts found with ID containing '687de71'</p>
    </cfif>
    
    <h4>4. All Recent Posts:</h4>
    <cfquery name="allPosts" datasource="blog">
        SELECT id, title, status, created_at
        FROM posts
        ORDER BY created_at DESC
        LIMIT 10
    </cfquery>
    
    <table border="1">
        <tr><th>ID</th><th>Title</th><th>Status</th><th>Created</th></tr>
        <cfoutput query="allPosts">
            <tr>
                <td>#id#</td>
                <td>#title#</td>
                <td>#status#</td>
                <td>#dateFormat(created_at, "yyyy-mm-dd")#</td>
            </tr>
        </cfoutput>
    </table>
    
    <h4>5. Test Preview URL:</h4>
    <cfif allPosts.recordCount>
        <p>Try preview with first post: 
            <a href="/ghost/preview/<cfoutput>#allPosts.id[1]#</cfoutput>?member_status=public" target="_blank">
                Preview Post ID: <cfoutput>#allPosts.id[1]#</cfoutput>
            </a>
        </p>
    </cfif>
    
    <cfcatch>
        <h3 style="color: red;">Error occurred:</h3>
        <cfoutput>
            <p><strong>Message:</strong> #cfcatch.message#</p>
            <p><strong>Detail:</strong> #cfcatch.detail#</p>
            <p><strong>Type:</strong> #cfcatch.type#</p>
        </cfoutput>
    </cfcatch>
</cftry>