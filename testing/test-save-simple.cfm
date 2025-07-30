<!--- Simple Save Test --->
<cfparam name="request.dsn" default="blog">

<!--- Direct test without AJAX --->
<cfset testId = "simple_" & left(replace(createUUID(), "-", "", "all"), 12)>
<cfset form.postId = testId>
<cfset form.title = "Simple Test">
<cfset form.content = "<p>Test content</p>">
<cfset form.plaintext = "Test content">
<cfset form.slug = "simple-test-#testId#">
<cfset form.excerpt = "">
<cfset form.meta_title = "">
<cfset form.meta_description = "">
<cfset form.visibility = "public">
<cfset form.featured = "0">
<cfset form.status = "draft">
<cfset form.type = "post">
<cfset form.tags = "[]">
<cfset form.authors = "[]">
<cfset form.show_title_and_feature_image = "0">
<cfset form.lexical = '{"test":"simple"}'>
<cfset form.comment_id = "simple_test_123">
<cfset form.published_at = "">
<cfset form.feature_image = "">
<cfset form.custom_template = "">
<cfset form.codeinjection_head = "">
<cfset form.codeinjection_foot = "">
<cfset form.canonical_url = "">
<cfset form.og_title = "">
<cfset form.og_description = "">
<cfset form.og_image = "">
<cfset form.twitter_title = "">
<cfset form.twitter_description = "">
<cfset form.twitter_image = "">

<!DOCTYPE html>
<html>
<head>
    <title>Simple Save Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background: #d4edda; padding: 15px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 15px; margin: 10px 0; }
        .info { background: #d1ecf1; padding: 15px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <h1>Simple Save Test</h1>
    
    <h2>Session Check:</h2>
    <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
        <div class="success">
            ✓ Logged in
            <cfif structKeyExists(session, "USERID")>
                (User: <cfoutput>#session.USERID#</cfoutput>)
            </cfif>
        </div>
        
        <h2>Running save-post.cfm logic directly:</h2>
        
        <cftry>
            <!--- Include save-post.cfm logic --->
            <cfinclude template="/ghost/admin/ajax/save-post.cfm">
            
            <div class="info">
                <p>Save completed. Check response above.</p>
            </div>
            
        <cfcatch>
            <div class="error">
                <h3>Error:</h3>
                <p><cfoutput>#cfcatch.message#</cfoutput></p>
                <p><cfoutput>#cfcatch.detail#</cfoutput></p>
            </div>
        </cfcatch>
        </cftry>
        
        <h2>Check if test post was saved:</h2>
        <cfquery name="qCheck" datasource="#request.dsn#">
            SELECT id, title, show_title_and_feature_image, 
                   CASE WHEN lexical IS NULL THEN 'NULL' 
                        WHEN LENGTH(lexical) > 0 THEN CONCAT('YES (', LENGTH(lexical), ' chars)')
                        ELSE 'EMPTY' 
                   END as lexical_status,
                   comment_id
            FROM posts
            WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qCheck.recordCount>
            <div class="success">
                <h3>✓ Post Found in Database!</h3>
                <table border="1" cellpadding="5">
                    <tr><th>Field</th><th>Value</th></tr>
                    <tr><td>ID</td><td><cfoutput>#qCheck.id#</cfoutput></td></tr>
                    <tr><td>Title</td><td><cfoutput>#qCheck.title#</cfoutput></td></tr>
                    <tr><td>show_title_and_feature_image</td><td><cfoutput>#qCheck.show_title_and_feature_image#</cfoutput></td></tr>
                    <tr><td>lexical</td><td><cfoutput>#qCheck.lexical_status#</cfoutput></td></tr>
                    <tr><td>comment_id</td><td><cfoutput>#qCheck.comment_id#</cfoutput></td></tr>
                </table>
            </div>
            
            <!--- Clean up --->
            <cfquery datasource="#request.dsn#">
                DELETE FROM posts WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfquery datasource="#request.dsn#">
                DELETE FROM posts_authors WHERE post_id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
        <cfelse>
            <div class="error">✗ Post not found in database</div>
        </cfif>
        
    <cfelse>
        <div class="error">
            ✗ Not logged in! 
            <a href="/ghost/admin/login.cfm">Please log in first</a>
        </div>
    </cfif>
    
    <hr>
    <h2>Summary:</h2>
    <p>This test bypasses HTTP/AJAX and runs the save-post.cfm logic directly to isolate the issue.</p>
</body>
</html>