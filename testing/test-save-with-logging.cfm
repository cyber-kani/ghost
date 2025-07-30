<!--- Test Save with Enhanced Logging --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Test Save with Logging</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background: #d4edda; padding: 15px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 15px; margin: 10px 0; }
        .info { background: #d1ecf1; padding: 15px; margin: 10px 0; }
        .warning { background: #fff3cd; padding: 15px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
        .test-btn { padding: 10px 20px; background: #28a745; color: white; text-decoration: none; display: inline-block; margin: 5px; }
        .raw-response { background: #f8f9fa; border: 1px solid #dee2e6; padding: 10px; margin: 10px 0; font-family: monospace; font-size: 12px; }
    </style>
</head>
<body>
    <h1>Test Save with Enhanced Logging</h1>
    
    <cfif url.action EQ "">
        <div class="info">
            <h2>This test will:</h2>
            <ol>
                <li>Create a test post with Ghost fields</li>
                <li>Show the raw HTTP response</li>
                <li>Log any errors to a file</li>
                <li>Verify the fields were saved</li>
            </ol>
        </div>
        
        <a href="?action=test" class="test-btn">Run Test</a>
        
    <cfelseif url.action EQ "test">
        <h2>Running Test...</h2>
        
        <cfset testId = "test_log_" & left(replace(createUUID(), "-", "", "all"), 12)>
        <cfset testTime = dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")>
        <cfset logFile = expandPath("/ghost/logs/save-test.log")>
        
        <!--- Ensure log directory exists --->
        <cfif not directoryExists(expandPath("/ghost/logs"))>
            <cfdirectory action="create" directory="#expandPath('/ghost/logs')#">
        </cfif>
        
        <!--- Log test start --->
        <cffile action="append" file="#logFile#" output="#chr(10)#=== TEST START: #testTime# ===#chr(10)#Test ID: #testId#">
        
        <div class="info">
            <h3>Test Parameters:</h3>
            <ul>
                <li>Post ID: <strong><cfoutput>#testId#</cfoutput></strong></li>
                <li>Title: Test Ghost Fields - <cfoutput>#testTime#</cfoutput></li>
                <li>show_title_and_feature_image: <strong>0</strong> (false)</li>
                <li>lexical: <strong>{"test": "lexical content at <cfoutput>#testTime#</cfoutput>"}</strong></li>
                <li>comment_id: <strong>comment_<cfoutput>#dateFormat(now(), "yyyymmdd")#_#timeFormat(now(), "HHmmss")#</cfoutput></strong></li>
            </ul>
        </div>
        
        <!--- Simulate form submission to save-post.cfm --->
        <cftry>
            <!--- Determine protocol based on current request --->
            <cfset protocol = cgi.server_port_secure ? "https" : "http">
            <cfif cgi.server_port EQ "443" OR cgi.https EQ "on">
                <cfset protocol = "https">
            </cfif>
            
            <cfhttp url="#protocol#://#cgi.server_name#/ghost/admin/ajax/save-post.cfm" method="post" result="saveResult" timeout="30" redirect="true">
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
                <cfhttpparam type="formfield" name="lexical" value='{"test": "lexical content at #testTime#"}'>
                <cfhttpparam type="formfield" name="comment_id" value="comment_#dateFormat(now(), "yyyymmdd")#_#timeFormat(now(), "HHmmss")#">
                <!--- Include session cookie --->
                <cfif structKeyExists(cookie, "CFID")>
                    <cfhttpparam type="cookie" name="CFID" value="#cookie.CFID#">
                </cfif>
                <cfif structKeyExists(cookie, "CFTOKEN")>
                    <cfhttpparam type="cookie" name="CFTOKEN" value="#cookie.CFTOKEN#">
                </cfif>
            </cfhttp>
            
            <!--- Log raw response --->
            <cffile action="append" file="#logFile#" output="HTTP Status: #saveResult.statusCode##chr(10)#Response Headers: #structKeyList(saveResult.responseHeader)##chr(10)#Response Length: #len(saveResult.fileContent)# chars">
            
            <div class="info">
                <h3>HTTP Response Details:</h3>
                <ul>
                    <li>Status Code: <strong><cfoutput>#saveResult.statusCode#</cfoutput></strong></li>
                    <li>Content Type: <strong><cfoutput>#saveResult.responseHeader['Content-Type'] ?: 'Not specified'#</cfoutput></strong></li>
                    <li>Response Length: <strong><cfoutput>#len(saveResult.fileContent)#</cfoutput> characters</strong></li>
                </ul>
            </div>
            
            <div class="raw-response">
                <h3>Raw Response:</h3>
                <pre><cfoutput>#htmlEditFormat(left(saveResult.fileContent, 5000))#<cfif len(saveResult.fileContent) GT 5000>... (truncated)</cfif></cfoutput></pre>
            </div>
            
            <!--- Try to parse as JSON --->
            <cftry>
                <cfset responseData = deserializeJSON(saveResult.fileContent)>
                <cffile action="append" file="#logFile#" output="JSON Parse: SUCCESS#chr(10)#Success: #responseData.success ?: 'not specified'##chr(10)#Message: #responseData.message ?: 'not specified'#">
                
                <cfif structKeyExists(responseData, "success") AND responseData.success>
                    <div class="success">
                        <h3>✓ Save Response:</h3>
                        <p>Success: <cfoutput>#responseData.success#</cfoutput></p>
                        <p>Message: <cfoutput>#responseData.message#</cfoutput></p>
                        <cfif structKeyExists(responseData, "postId")>
                            <p>Post ID: <cfoutput>#responseData.postId#</cfoutput></p>
                        </cfif>
                    </div>
                    
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
                            <h3>Database Verification:</h3>
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
                                    <td><cfoutput>#qCheck.show_title_and_feature_image#</cfoutput></td>
                                    <td>
                                        <cfif qCheck.show_title_and_feature_image EQ 0>
                                            <span style="color: green;">✓ SAVED</span>
                                        <cfelse>
                                            <span style="color: red;">✗ NOT SAVED</span>
                                        </cfif>
                                    </td>
                                </tr>
                                <tr>
                                    <td>lexical</td>
                                    <td>Has content</td>
                                    <td>
                                        <cfif isNull(qCheck.lexical)>
                                            NULL
                                        <cfelseif len(qCheck.lexical)>
                                            <cfoutput>#len(qCheck.lexical)#</cfoutput> chars
                                        <cfelse>
                                            EMPTY
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(qCheck.lexical)>
                                            <span style="color: green;">✓ SAVED</span>
                                        <cfelse>
                                            <span style="color: red;">✗ NOT SAVED</span>
                                        </cfif>
                                    </td>
                                </tr>
                                <tr>
                                    <td>comment_id</td>
                                    <td>comment_*</td>
                                    <td>
                                        <cfif isNull(qCheck.comment_id)>
                                            NULL
                                        <cfelse>
                                            <cfoutput>#qCheck.comment_id#</cfoutput>
                                        </cfif>
                                    </td>
                                    <td>
                                        <cfif len(qCheck.comment_id) AND qCheck.comment_id CONTAINS "comment_">
                                            <span style="color: green;">✓ SAVED</span>
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
                    <div class="error">
                        <h3>Save Failed:</h3>
                        <p>Success: <cfoutput>#responseData.success ?: false#</cfoutput></p>
                        <p>Message: <cfoutput>#responseData.message ?: 'No message'#</cfoutput></p>
                    </div>
                </cfif>
                
            <cfcatch>
                <cffile action="append" file="#logFile#" output="JSON Parse: FAILED#chr(10)#Error: #cfcatch.message#">
                <div class="error">
                    <h3>JSON Parse Error:</h3>
                    <p><cfoutput>#cfcatch.message#</cfoutput></p>
                    <p><cfoutput>#cfcatch.detail#</cfoutput></p>
                </div>
                
                <!--- Check if it's an HTML error page --->
                <cfif saveResult.fileContent CONTAINS "<html" OR saveResult.fileContent CONTAINS "<!DOCTYPE">
                    <div class="warning">
                        <p>The response appears to be an HTML page instead of JSON. This usually indicates:</p>
                        <ul>
                            <li>A ColdFusion error page</li>
                            <li>A login/session timeout page</li>
                            <li>A server configuration issue</li>
                        </ul>
                    </div>
                </cfif>
            </cfcatch>
            </cftry>
            
        <cfcatch>
            <cffile action="append" file="#logFile#" output="HTTP Request: FAILED#chr(10)#Error: #cfcatch.message#">
            <div class="error">
                <h3>HTTP Request Error:</h3>
                <p><cfoutput>#cfcatch.message#</cfoutput></p>
                <p><cfoutput>#cfcatch.detail#</cfoutput></p>
            </div>
        </cfcatch>
        </cftry>
        
        <cffile action="append" file="#logFile#" output="=== TEST END: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")# ===#chr(10)#">
        
        <hr>
        <p><a href="?" class="test-btn">Run Test Again</a></p>
        <p><a href="/ghost/logs/save-test.log" target="_blank">View Full Log File</a></p>
    </cfif>
    
    <hr>
    <h2>Next Steps:</h2>
    <ol>
        <li>Check the raw response above to see what save-post.cfm is returning</li>
        <li>If it's HTML instead of JSON, it's likely a ColdFusion error</li>
        <li>Check if you're logged in (session might have expired)</li>
        <li>Try creating a post manually to see if the same error occurs</li>
    </ol>
</body>
</html>