<!--- Check if post exists --->
<cfset postId = "f7769ae6d71776fb5064fc52">

<h3>Checking Post ID: <cfoutput>#postId#</cfoutput></h3>

<cftry>
    <cfquery name="checkPost" datasource="blog">
        SELECT id, title, status, created_by
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
            </ul>
        </cfoutput>
        
        <h4>Test Preview URL:</h4>
        <p><a href="/ghost/preview-public.cfm?id=#postId#&member_status=public" target="_blank">Test Preview</a></p>
    <cfelse>
        <p style="color: red;">❌ Post NOT found with ID: <cfoutput>#postId#</cfoutput></p>
    </cfif>
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>