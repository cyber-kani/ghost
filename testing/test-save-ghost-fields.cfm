<!--- Simple Test Save with Ghost Fields --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Test Save Ghost Fields</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background: #d4edda; padding: 15px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 15px; margin: 10px 0; }
        .info { background: #d1ecf1; padding: 15px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border: 1px solid #ddd; }
        .test-btn { padding: 10px 20px; background: #28a745; color: white; text-decoration: none; display: inline-block; margin: 5px; }
        .test-btn:hover { background: #218838; }
    </style>
</head>
<body>
    <h1>Test Save Ghost Fields</h1>
    
    <cfif url.action EQ "">
        <div class="info">
            <h2>This test will:</h2>
            <ol>
                <li>Create a new post with Ghost fields using save-post.cfm</li>
                <li>Verify the fields were saved</li>
                <li>Show exactly what happened</li>
            </ol>
        </div>
        
        <a href="?action=test" class="test-btn">Run Test</a>
        
    <cfelseif url.action EQ "test">
        <h2>Running Test...</h2>
        
        <cfset testId = "ghost_test_" & left(replace(createUUID(), "-", "", "all"), 12)>
        <cfset testTime = dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")>
        
        <div class="info">
            <h3>Test Parameters:</h3>
            <ul>
                <li>Post ID: <strong>#testId#</strong></li>
                <li>Title: Test Ghost Fields - #testTime#</li>
                <li>show_title_and_feature_image: <strong>0</strong> (false)</li>
                <li>lexical: <strong>{"test": "lexical content"}</strong></li>
                <li>comment_id: <strong>comment_test_123</strong></li>
            </ul>
        </div>
        
        <!--- Simulate form submission to save-post.cfm --->
        <!--- Determine protocol --->
        <cfset protocol = (cgi.server_port_secure OR cgi.https EQ "on" OR cgi.server_port EQ "443") ? "https" : "http">
        <cfhttp url="#protocol#://#cgi.server_name#/ghost/admin/ajax/save-post.cfm" method="post" result="saveResult" redirect="true">
            <cfhttpparam type="formfield" name="postId" value="#testId#">
            <cfhttpparam type="formfield" name="title" value="Test Ghost Fields - #testTime#">
            <cfhttpparam type="formfield" name="content" value="<p>Test content for Ghost fields</p>">
            <cfhttpparam type="formfield" name="plaintext" value="Test content for Ghost fields">
            <cfhttpparam type="formfield" name="slug" value="test-ghost-fields-#testId#">
            <cfhttpparam type="formfield" name="excerpt" value="">
            <cfhttpparam type="formfield" name="meta_title" value="">
            <cfhttpparam type="formfield" name="meta_description" value="">
            <cfhttpparam type="formfield" name="visibility" value="public">
            <cfhttpparam type="formfield" name="featured" value="0">
            <cfhttpparam type="formfield" name="status" value="draft">
            <cfhttpparam type="formfield" name="type" value="post">
            <cfhttpparam type="formfield" name="tags" value="[]">
            <cfhttpparam type="formfield" name="authors" value="[]">
            <cfhttpparam type="formfield" name="show_title_and_feature_image" value="0">
            <cfhttpparam type="formfield" name="lexical" value='{"test": "lexical content"}'>
            <cfhttpparam type="formfield" name="comment_id" value="comment_test_123">
            <!--- Include session cookie --->
            <cfhttpparam type="cookie" name="CFID" value="#cookie.CFID#">
            <cfhttpparam type="cookie" name="CFTOKEN" value="#cookie.CFTOKEN#">
        </cfhttp>
        
        <div class="info">
            <h3>Save Response:</h3>
            <pre>#saveResult.fileContent#</pre>
        </div>
        
        <cftry>
            <cfset responseData = deserializeJSON(saveResult.fileContent)>
            
            <cfif responseData.success>
                <div class="success">✓ Save reported success!</div>
                
                <!--- Now check if fields were actually saved --->
                <cfquery name="qCheck" datasource="#request.dsn#">
                    SELECT 
                        id,
                        title,
                        show_title_and_feature_image,
                        lexical,
                        comment_id
                    FROM posts
                    WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif qCheck.recordCount>
                    <div class="info">
                        <h3>Verification Results:</h3>
                        <table border="1" cellpadding="5">
                            <tr>
                                <th>Field</th>
                                <th>Expected</th>
                                <th>Actual</th>
                                <th>Status</th>
                            </tr>
                            <tr>
                                <td>show_title_and_feature_image</td>
                                <td>0</td>
                                <td>#qCheck.show_title_and_feature_image#</td>
                                <td>
                                    <cfif qCheck.show_title_and_feature_image EQ 0>
                                        <span style="color: green;">✓ CORRECT</span>
                                    <cfelse>
                                        <span style="color: red;">✗ WRONG</span>
                                    </cfif>
                                </td>
                            </tr>
                            <tr>
                                <td>lexical</td>
                                <td>{"test": "lexical content"}</td>
                                <td>
                                    <cfif isNull(qCheck.lexical)>
                                        NULL
                                    <cfelseif len(qCheck.lexical)>
                                        #left(qCheck.lexical, 50)#...
                                    <cfelse>
                                        EMPTY
                                    </cfif>
                                </td>
                                <td>
                                    <cfif len(qCheck.lexical) AND qCheck.lexical CONTAINS "lexical content">
                                        <span style="color: green;">✓ CORRECT</span>
                                    <cfelse>
                                        <span style="color: red;">✗ NOT SAVED</span>
                                    </cfif>
                                </td>
                            </tr>
                            <tr>
                                <td>comment_id</td>
                                <td>comment_test_123</td>
                                <td>
                                    <cfif isNull(qCheck.comment_id)>
                                        NULL
                                    <cfelse>
                                        #qCheck.comment_id#
                                    </cfif>
                                </td>
                                <td>
                                    <cfif qCheck.comment_id EQ "comment_test_123">
                                        <span style="color: green;">✓ CORRECT</span>
                                    <cfelse>
                                        <span style="color: red;">✗ NOT SAVED</span>
                                    </cfif>
                                </td>
                            </tr>
                        </table>
                    </div>
                    
                    <!--- Clean up test post --->
                    <cfquery datasource="#request.dsn#">
                        DELETE FROM posts WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    <cfquery datasource="#request.dsn#">
                        DELETE FROM posts_authors WHERE post_id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <div class="info">✓ Test post cleaned up</div>
                    
                <cfelse>
                    <div class="error">✗ Post was not found in database after save!</div>
                </cfif>
                
            <cfelse>
                <div class="error">✗ Save failed: #responseData.message#</div>
            </cfif>
            
        <cfcatch>
            <div class="error">Error parsing response: #cfcatch.message#</div>
        </cfcatch>
        </cftry>
        
        <hr>
        <a href="?" class="test-btn">Run Test Again</a>
    </cfif>
    
    <hr>
    <h2>Check Logs:</h2>
    <pre>tail -f /var/log/coldfusion/ghost-save-post.log</pre>
    
</body>
</html>