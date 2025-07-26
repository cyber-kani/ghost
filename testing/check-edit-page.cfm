<!DOCTYPE html>
<html>
<head>
    <title>Check Edit Page</title>
</head>
<body>
    <h1>Testing Edit Page</h1>
    
    <cfparam name="url.id" default="687de71ebc740c1b43f0a355">
    
    <cftry>
        <!--- Test if we can access the database --->
        <cfquery name="testQuery" datasource="blog">
            SELECT id, title, status FROM posts WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif testQuery.recordCount>
            <p style="color: green;">✓ Found post: <cfoutput>#testQuery.title#</cfoutput></p>
        <cfelse>
            <p style="color: red;">✗ No post found with ID: <cfoutput>#url.id#</cfoutput></p>
        </cfif>
        
        <!--- Test if posts-functions.cfm exists --->
        <cfif fileExists(expandPath("../includes/posts-functions.cfm"))>
            <p style="color: green;">✓ posts-functions.cfm exists</p>
            
            <!--- Try to include it --->
            <cfinclude template="../includes/posts-functions.cfm">
            <p style="color: green;">✓ posts-functions.cfm included successfully</p>
            
            <!--- Try to call getPostById --->
            <cfset postResult = getPostById(url.id)>
            <cfif postResult.success>
                <p style="color: green;">✓ getPostById() executed successfully</p>
                <cfdump var="#postResult#" label="Post Result">
            <cfelse>
                <p style="color: red;">✗ getPostById() failed: <cfoutput>#postResult.message#</cfoutput></p>
            </cfif>
        <cfelse>
            <p style="color: red;">✗ posts-functions.cfm not found</p>
        </cfif>
        
        <cfcatch>
            <h2 style="color: red;">Error:</h2>
            <pre><cfoutput>#cfcatch.message#
#cfcatch.detail#
#cfcatch.tagContext[1].template# (line #cfcatch.tagContext[1].line#)</cfoutput></pre>
        </cfcatch>
    </cftry>
    
    <h2>Test Direct Access to Edit Page:</h2>
    <p><a href="/ghost/admin/posts/edit-ghost-style.cfm?id=<cfoutput>#url.id#</cfoutput>" target="_blank">Click here to test edit page</a></p>
</body>
</html>