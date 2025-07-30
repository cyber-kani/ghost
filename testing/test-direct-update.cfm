<!--- Test Direct Update with Ghost Fields --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">
<cfparam name="url.postId" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Test Direct Update</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background: #d4edda; color: #155724; padding: 15px; margin: 10px 0; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; margin: 10px 0; }
        .info { background: #d1ecf1; color: #0c5460; padding: 15px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border: 1px solid #ddd; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background: #e9ecef; }
        input[type="text"] { width: 300px; padding: 5px; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <h1>Test Direct Update with Ghost Fields</h1>
    
    <cfif url.action EQ "">
        <!--- Get a recent post to test with --->
        <cfquery name="qRecent" datasource="#request.dsn#">
            SELECT id, title, show_title_and_feature_image, 
                   CASE WHEN lexical IS NULL THEN 'NULL' ELSE 'HAS VALUE' END as lexical_status,
                   comment_id
            FROM posts
            ORDER BY created_at DESC
            LIMIT 10
        </cfquery>
        
        <h2>Select a Post to Test Update:</h2>
        <table>
            <tr>
                <th>Select</th>
                <th>ID</th>
                <th>Title</th>
                <th>show_title_and_feature_image</th>
                <th>lexical</th>
                <th>comment_id</th>
            </tr>
            <cfoutput query="qRecent">
                <tr>
                    <td><a href="?action=update&postId=#id#">Test Update</a></td>
                    <td>#left(id, 12)#...</td>
                    <td>#left(title, 30)#</td>
                    <td>#show_title_and_feature_image#</td>
                    <td>#lexical_status#</td>
                    <td><cfif len(comment_id)>#comment_id#<cfelse>NULL</cfif></td>
                </tr>
            </cfoutput>
        </table>
        
    <cfelseif url.action EQ "update" AND len(url.postId)>
        <h2>Testing Update for Post: <cfoutput>#url.postId#</cfoutput></h2>
        
        <cftry>
            <!--- First get current values --->
            <cfquery name="qBefore" datasource="#request.dsn#">
                SELECT title, show_title_and_feature_image, lexical, comment_id
                FROM posts
                WHERE id = <cfqueryparam value="#url.postId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qBefore.recordCount>
                <div class="info">
                    <h3>Before Update:</h3>
                    <ul>
                        <li>Title: <cfoutput>#qBefore.title#</cfoutput></li>
                        <li>show_title_and_feature_image: <cfoutput>#qBefore.show_title_and_feature_image#</cfoutput></li>
                        <li>lexical: <cfoutput><cfif isNull(qBefore.lexical)>NULL<cfelseif len(qBefore.lexical)>Has content (#len(qBefore.lexical)# chars)<cfelse>EMPTY</cfif></cfoutput></li>
                        <li>comment_id: <cfoutput><cfif isNull(qBefore.comment_id)>NULL<cfelseif len(qBefore.comment_id)>#qBefore.comment_id#<cfelse>EMPTY</cfif></cfoutput></li>
                    </ul>
                </div>
                
                <!--- Update with test values --->
                <cfset testTime = dateTimeFormat(now(), "HH:nn:ss")>
                <cfset newShowTitle = qBefore.show_title_and_feature_image ? 0 : 1>
                <cfset newLexical = '{"test":"Updated at #testTime#","root":{"children":[{"type":"paragraph","children":[{"type":"text","text":"Test"}]}]}}'>
                <cfset newCommentId = "comment_#testTime#">
                
                <cfquery datasource="#request.dsn#">
                    UPDATE posts 
                    SET show_title_and_feature_image = <cfqueryparam value="#newShowTitle#" cfsqltype="cf_sql_bit">,
                        lexical = <cfqueryparam value="#newLexical#" cfsqltype="cf_sql_longvarchar">,
                        comment_id = <cfqueryparam value="#newCommentId#" cfsqltype="cf_sql_varchar">
                    WHERE id = <cfqueryparam value="#url.postId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <!--- Verify update --->
                <cfquery name="qAfter" datasource="#request.dsn#">
                    SELECT title, show_title_and_feature_image, lexical, comment_id
                    FROM posts
                    WHERE id = <cfqueryparam value="#url.postId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <div class="success">
                    <h3>After Update:</h3>
                    <ul>
                        <li>Title: <cfoutput>#qAfter.title#</cfoutput></li>
                        <li>show_title_and_feature_image: <cfoutput>#qAfter.show_title_and_feature_image#</cfoutput> 
                            <cfif qAfter.show_title_and_feature_image NEQ newShowTitle>
                                <span style="color: red;">ERROR: Should be #newShowTitle#</span>
                            <cfelse>
                                <span style="color: green;">✓ Updated correctly</span>
                            </cfif>
                        </li>
                        <li>lexical: <cfoutput><cfif isNull(qAfter.lexical)>NULL<cfelseif len(qAfter.lexical)>Has content (#len(qAfter.lexical)# chars)<cfelse>EMPTY</cfif></cfoutput>
                            <cfif len(qAfter.lexical)>
                                <span style="color: green;">✓ Updated correctly</span>
                            <cfelse>
                                <span style="color: red;">ERROR: Not saved</span>
                            </cfif>
                        </li>
                        <li>comment_id: <cfoutput><cfif isNull(qAfter.comment_id)>NULL<cfelseif len(qAfter.comment_id)>#qAfter.comment_id#<cfelse>EMPTY</cfif></cfoutput>
                            <cfif qAfter.comment_id EQ newCommentId>
                                <span style="color: green;">✓ Updated correctly</span>
                            <cfelse>
                                <span style="color: red;">ERROR: Should be #newCommentId#</span>
                            </cfif>
                        </li>
                    </ul>
                </div>
                
                <div class="info">
                    <p><strong>Conclusion:</strong> If the direct UPDATE worked, then the issue is with how save-post.cfm is processing the form data.</p>
                    <p><a href="?">← Test another post</a></p>
                </div>
                
            <cfelse>
                <div class="error">Post not found!</div>
            </cfif>
            
        <cfcatch>
            <div class="error">
                Error: <cfoutput>#cfcatch.message#<br>#cfcatch.detail#</cfoutput>
            </div>
        </cfcatch>
        </cftry>
    </cfif>
    
    <hr>
    <h2>Quick Links:</h2>
    <ul>
        <li><a href="/ghost/testing/diagnose-save-issue.cfm">Full Diagnostics</a></li>
        <li><a href="/ghost/testing/check-exact-columns.cfm">Check Column Names</a></li>
        <li><a href="/ghost/admin/posts/new.cfm">Create New Post</a></li>
    </ul>
</body>
</html>