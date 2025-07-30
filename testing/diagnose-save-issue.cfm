<!--- Diagnose Ghost Fields Save Issue --->
<cfparam name="request.dsn" default="blog">

<!DOCTYPE html>
<html>
<head>
    <title>Diagnose Ghost Fields Save Issue</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; max-width: 1000px; }
        .section { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; padding: 10px; margin: 5px 0; }
        .error { background: #f8d7da; color: #721c24; padding: 10px; margin: 5px 0; }
        .warning { background: #fff3cd; color: #856404; padding: 10px; margin: 5px 0; }
        .info { background: #d1ecf1; color: #0c5460; padding: 10px; margin: 5px 0; }
        pre { background: white; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 8px; text-align: left; border: 1px solid #ddd; }
        th { background: #e9ecef; }
        .test-form { background: #e3f2fd; padding: 15px; border-radius: 5px; }
        input[type="text"], textarea { width: 100%; padding: 5px; margin: 5px 0; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>Diagnose Ghost Fields Save Issue</h1>
    
    <cfset diagnostics = {}>
    
    <!--- 1. Check Database Structure --->
    <div class="section">
        <h2>1. Database Structure Check</h2>
        <cftry>
            <cfquery name="qColumns" datasource="#request.dsn#">
                SHOW COLUMNS FROM posts 
                WHERE Field IN ('lexical', 'show_title_and_feature_image', 'comment_id')
            </cfquery>
            
            <cfset diagnostics.dbFields = []>
            
            <table>
                <tr>
                    <th>Field</th>
                    <th>Type</th>
                    <th>Null</th>
                    <th>Default</th>
                    <th>Status</th>
                </tr>
                <cfoutput query="qColumns">
                    <cfset arrayAppend(diagnostics.dbFields, Field)>
                    <tr>
                        <td><strong>#Field#</strong></td>
                        <td>#Type#</td>
                        <td>#Null#</td>
                        <td><cfif len(Default)>#Default#<cfelse>NULL</cfif></td>
                        <td class="success">✓ Exists</td>
                    </tr>
                </cfoutput>
            </table>
            
            <cfset missingFields = []>
            <cfloop list="lexical,show_title_and_feature_image,comment_id" index="field">
                <cfif NOT arrayContains(diagnostics.dbFields, field)>
                    <cfset arrayAppend(missingFields, field)>
                </cfif>
            </cfloop>
            
            <cfif arrayLen(missingFields) GT 0>
                <div class="error">Missing fields: #arrayToList(missingFields)#</div>
            <cfelse>
                <div class="success">✓ All Ghost fields exist in database</div>
            </cfif>
            
        <cfcatch>
            <div class="error">Database check failed: #cfcatch.message#</div>
        </cfcatch>
        </cftry>
    </div>
    
    <!--- 2. Test Direct Insert/Update --->
    <div class="section">
        <h2>2. Test Direct Database Operations</h2>
        
        <cfset testId = "test_" & left(replace(createUUID(), "-", "", "all"), 18)>
        
        <cftry>
            <!--- Test INSERT --->
            <cfquery datasource="#request.dsn#">
                INSERT INTO posts (
                    id, uuid, title, slug, html, plaintext, 
                    type, status, created_at, updated_at,
                    email_recipient_filter, created_by,
                    show_title_and_feature_image, lexical, comment_id
                ) VALUES (
                    <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="Test Post for Ghost Fields" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="test-ghost-fields" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="<p>Test content</p>" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="Test content" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="post" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="draft" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="all" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
                    <cfqueryparam value='{"test":"lexical content"}' cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="test_comment_123" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
            
            <div class="success">✓ INSERT successful with test ID: #testId#</div>
            
            <!--- Verify INSERT --->
            <cfquery name="qVerify" datasource="#request.dsn#">
                SELECT id, title, show_title_and_feature_image, lexical, comment_id
                FROM posts
                WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qVerify.recordCount>
                <table>
                    <tr>
                        <th>Field</th>
                        <th>Value</th>
                        <th>Status</th>
                    </tr>
                    <tr>
                        <td>show_title_and_feature_image</td>
                        <td>#qVerify.show_title_and_feature_image#</td>
                        <td><cfif qVerify.show_title_and_feature_image EQ 0>✓ Correct (0)<cfelse>✗ Wrong</cfif></td>
                    </tr>
                    <tr>
                        <td>lexical</td>
                        <td><cfif len(qVerify.lexical)>#left(qVerify.lexical, 50)#...<cfelse>NULL</cfif></td>
                        <td><cfif len(qVerify.lexical)>✓ Saved<cfelse>✗ Not saved</cfif></td>
                    </tr>
                    <tr>
                        <td>comment_id</td>
                        <td>#qVerify.comment_id#</td>
                        <td><cfif qVerify.comment_id EQ "test_comment_123">✓ Correct<cfelse>✗ Wrong</cfif></td>
                    </tr>
                </table>
            </cfif>
            
            <!--- Test UPDATE --->
            <cfquery datasource="#request.dsn#">
                UPDATE posts SET
                    show_title_and_feature_image = <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
                    lexical = <cfqueryparam value='{"updated":"lexical content"}' cfsqltype="cf_sql_longvarchar">,
                    comment_id = <cfqueryparam value="updated_comment_456" cfsqltype="cf_sql_varchar">
                WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <div class="success">✓ UPDATE successful</div>
            
            <!--- Clean up test post --->
            <cfquery datasource="#request.dsn#">
                DELETE FROM posts WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <div class="info">✓ Test post cleaned up</div>
            
        <cfcatch>
            <div class="error">Database operation failed: #cfcatch.message#<br>#cfcatch.detail#</div>
        </cfcatch>
        </cftry>
    </div>
    
    <!--- 3. Test Form Submission --->
    <div class="section">
        <h2>3. Test Form Submission to save-post.cfm</h2>
        
        <div class="test-form">
            <form id="testSaveForm" method="post" action="/ghost/admin/ajax/save-post.cfm">
                <input type="hidden" name="postId" value="diagnostic_test_#createUUID()#">
                <input type="hidden" name="title" value="Diagnostic Test Post">
                <input type="hidden" name="content" value="<p>Test content</p>">
                <input type="hidden" name="plaintext" value="Test content">
                <input type="hidden" name="slug" value="diagnostic-test">
                <input type="hidden" name="excerpt" value="">
                <input type="hidden" name="meta_title" value="">
                <input type="hidden" name="meta_description" value="">
                <input type="hidden" name="visibility" value="public">
                <input type="hidden" name="featured" value="0">
                <input type="hidden" name="status" value="draft">
                <input type="hidden" name="type" value="post">
                <input type="hidden" name="tags" value="[]">
                <input type="hidden" name="authors" value="[]">
                
                <!--- Ghost fields --->
                <input type="hidden" name="show_title_and_feature_image" value="0">
                <input type="hidden" name="lexical" value='{"root":{"children":[{"type":"paragraph","children":[{"type":"text","text":"Test lexical"}]}]}}'>
                <input type="hidden" name="comment_id" value="test_comment_789">
                
                <button type="submit">Test Save Post</button>
            </form>
            
            <div id="testResult"></div>
        </div>
    </div>
    
    <!--- 4. Check Recent Posts --->
    <div class="section">
        <h2>4. Recent Posts Ghost Fields Status</h2>
        
        <cfquery name="qRecent" datasource="#request.dsn#">
            SELECT 
                id, 
                title, 
                created_at,
                show_title_and_feature_image,
                CASE 
                    WHEN lexical IS NULL THEN 'NULL'
                    WHEN LENGTH(lexical) = 0 THEN 'EMPTY'
                    ELSE CONCAT('Has content (', LENGTH(lexical), ' chars)')
                END as lexical_status,
                comment_id
            FROM posts
            ORDER BY created_at DESC
            LIMIT 5
        </cfquery>
        
        <table>
            <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Created</th>
                <th>show_title_and_feature_image</th>
                <th>lexical</th>
                <th>comment_id</th>
            </tr>
            <cfoutput query="qRecent">
                <tr>
                    <td>#left(id, 10)#...</td>
                    <td>#left(title, 30)#<cfif len(title) GT 30>...</cfif></td>
                    <td>#dateFormat(created_at, "mm/dd HH:nn")#</td>
                    <td>#show_title_and_feature_image#</td>
                    <td>#lexical_status#</td>
                    <td><cfif len(comment_id)>#comment_id#<cfelse><em>NULL</em></cfif></td>
                </tr>
            </cfoutput>
        </table>
    </div>
    
    <!--- 5. Recommendations --->
    <div class="section">
        <h2>5. Diagnostic Summary</h2>
        
        <cfif structKeyExists(diagnostics, "dbFields") AND arrayLen(diagnostics.dbFields) EQ 3>
            <div class="success">✓ Database structure is correct</div>
        </cfif>
        
        <div class="warning">
            <h3>Things to check:</h3>
            <ol>
                <li>Are you logged in? (Session must have ISLOGGEDIN = true)</li>
                <li>Check browser console for JavaScript errors</li>
                <li>Check ColdFusion logs: <code>tail -f /var/log/coldfusion/ghost-save-post.log</code></li>
                <li>Verify the form is sending all fields (use browser DevTools Network tab)</li>
            </ol>
        </div>
    </div>
    
    <script>
    document.getElementById('testSaveForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const formData = new FormData(this);
        const result = document.getElementById('testResult');
        
        result.innerHTML = '<p>Submitting...</p>';
        
        // Log what we're sending
        console.log('Sending Ghost fields:');
        console.log('show_title_and_feature_image:', formData.get('show_title_and_feature_image'));
        console.log('lexical:', formData.get('lexical'));
        console.log('comment_id:', formData.get('comment_id'));
        
        fetch(this.action, {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(text => {
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    result.innerHTML = '<div class="success">✓ Save successful! Post ID: ' + data.postId + '</div>';
                    
                    // Now check if fields were saved
                    checkSavedPost(data.postId);
                } else {
                    result.innerHTML = '<div class="error">✗ Save failed: ' + data.message + '</div>';
                }
            } catch (e) {
                result.innerHTML = '<div class="error">Response: <pre>' + text + '</pre></div>';
            }
        })
        .catch(error => {
            result.innerHTML = '<div class="error">Network error: ' + error + '</div>';
        });
    });
    
    function checkSavedPost(postId) {
        fetch('/ghost/testing/check-saved-fields.cfm?postId=' + postId)
            .then(response => response.text())
            .then(html => {
                document.getElementById('testResult').innerHTML += html;
            });
    }
    </script>
</body>
</html>