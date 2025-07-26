<!--- Simple Preview Test --->
<cfparam name="url.id" default="">
<cfparam name="url.member_status" default="public">

<cfoutput>
<h1>Preview Debug</h1>
<p>Requested ID: #url.id#</p>
<p>Member Status: #url.member_status#</p>
</cfoutput>

<cftry>
    <!--- Simple query without joins first --->
    <cfquery name="postData" datasource="blog">
        SELECT id, title, content, status
        FROM posts
        WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif postData.recordCount>
        <cfoutput>
            <h2>Post Found!</h2>
            <p>Title: #postData.title#</p>
            <p>Status: #postData.status#</p>
            <p>Content Length: #len(postData.content)# characters</p>
        </cfoutput>
    <cfelse>
        <h2 style="color: red;">Post NOT found with ID: <cfoutput>#url.id#</cfoutput></h2>
        
        <!--- Show available posts --->
        <cfquery name="availablePosts" datasource="blog">
            SELECT id, title
            FROM posts
            ORDER BY created_at DESC
            LIMIT 5
        </cfquery>
        
        <h3>Available Posts:</h3>
        <ul>
            <cfoutput query="availablePosts">
                <li>ID: #id# - Title: #title#</li>
            </cfoutput>
        </ul>
    </cfif>
    
    <cfcatch>
        <h2 style="color: red;">Error:</h2>
        <cfoutput>
            <p>#cfcatch.message#</p>
            <p>#cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>