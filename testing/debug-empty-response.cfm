<!--- Debug Empty Response --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Debug Empty Response</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background: #d4edda; padding: 15px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 15px; margin: 10px 0; }
        .info { background: #d1ecf1; padding: 15px; margin: 10px 0; }
        .warning { background: #fff3cd; padding: 15px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
        .hex-dump { font-family: monospace; font-size: 12px; }
        table { border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    </style>
</head>
<body>
    <h1>Debug Empty Response Issue</h1>
    
    <cfif url.action EQ "">
        <h2>Step 1: Check Session</h2>
        <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
            <div class="success">
                ✓ Session is active
                <cfif structKeyExists(session, "USERID")>
                    (User ID: <cfoutput>#session.USERID#</cfoutput>)
                </cfif>
            </div>
        <cfelse>
            <div class="error">
                ✗ Not logged in! 
                <a href="/ghost/admin/login.cfm">Please log in first</a>
            </div>
        </cfif>
        
        <h2>Step 2: Direct Call Test</h2>
        <form method="post" action="?action=direct">
            <button type="submit">Test Direct Call to save-post.cfm</button>
        </form>
        
        <h2>Step 3: Simple AJAX Test</h2>
        <button onclick="testAjax()">Test AJAX Call</button>
        
        <div id="ajaxResult"></div>
        
        <script>
        function testAjax() {
            const testId = 'ajax_test_' + Date.now();
            const formData = new FormData();
            formData.append('postId', testId);
            formData.append('title', 'AJAX Test');
            formData.append('content', '<p>Test</p>');
            formData.append('plaintext', 'Test');
            formData.append('slug', 'ajax-test');
            formData.append('status', 'draft');
            formData.append('type', 'post');
            formData.append('tags', '[]');
            formData.append('authors', '[]');
            formData.append('show_title_and_feature_image', '1');
            formData.append('lexical', '');
            formData.append('comment_id', '');
            
            fetch('/ghost/admin/ajax/save-post.cfm', {
                method: 'POST',
                body: formData,
                credentials: 'same-origin'
            })
            .then(response => {
                console.log('Response status:', response.status);
                console.log('Response headers:', response.headers);
                return response.text();
            })
            .then(text => {
                document.getElementById('ajaxResult').innerHTML = `
                    <div class="info">
                        <h3>AJAX Response:</h3>
                        <p>Length: ${text.length} characters</p>
                        <p>First 100 chars: <code>${text.substring(0, 100)}</code></p>
                        <pre>${text}</pre>
                    </div>
                `;
            })
            .catch(error => {
                document.getElementById('ajaxResult').innerHTML = `
                    <div class="error">
                        <h3>AJAX Error:</h3>
                        <p>${error}</p>
                    </div>
                `;
            });
        }
        </script>
        
    <cfelseif url.action EQ "direct">
        <h2>Direct POST to save-post.cfm</h2>
        
        <cfset testId = "direct_test_" & left(replace(createUUID(), "-", "", "all"), 12)>
        
        <!--- Direct form submission --->
        <cfhttp url="#(cgi.https EQ 'on' ? 'https' : 'http')#://#cgi.server_name#/ghost/admin/ajax/save-post.cfm" 
                method="post" 
                result="directResult" 
                redirect="false"
                throwonerror="false">
            <cfhttpparam type="formfield" name="postId" value="#testId#">
            <cfhttpparam type="formfield" name="title" value="Direct Test">
            <cfhttpparam type="formfield" name="content" value="<p>Direct test content</p>">
            <cfhttpparam type="formfield" name="plaintext" value="Direct test content">
            <cfhttpparam type="formfield" name="slug" value="direct-test-#testId#">
            <cfhttpparam type="formfield" name="status" value="draft">
            <cfhttpparam type="formfield" name="type" value="post">
            <cfhttpparam type="formfield" name="tags" value="[]">
            <cfhttpparam type="formfield" name="authors" value="[]">
            <cfhttpparam type="formfield" name="show_title_and_feature_image" value="1">
            <cfhttpparam type="formfield" name="lexical" value="">
            <cfhttpparam type="formfield" name="comment_id" value="">
            <cfif structKeyExists(cookie, "CFID")>
                <cfhttpparam type="cookie" name="CFID" value="#cookie.CFID#">
            </cfif>
            <cfif structKeyExists(cookie, "CFTOKEN")>
                <cfhttpparam type="cookie" name="CFTOKEN" value="#cookie.CFTOKEN#">
            </cfif>
        </cfhttp>
        
        <div class="info">
            <h3>Response Details:</h3>
            <table>
                <tr><th>Property</th><th>Value</th></tr>
                <tr><td>Status Code</td><td><cfoutput>#directResult.statusCode#</cfoutput></td></tr>
                <tr><td>Content Length</td><td><cfoutput>#len(directResult.fileContent)#</cfoutput> characters</td></tr>
                <tr><td>Content Type</td><td><cfoutput>#directResult.responseHeader['Content-Type'] ?: 'Not specified'#</cfoutput></td></tr>
                <tr><td>Mime Type</td><td><cfoutput>#directResult.mimeType ?: 'Not specified'#</cfoutput></td></tr>
            </table>
        </div>
        
        <cfif len(directResult.fileContent) EQ 0>
            <div class="error">
                <h3>⚠️ Response is EMPTY!</h3>
                <p>The save-post.cfm endpoint returned no content at all.</p>
            </div>
            
            <h3>Possible Causes:</h3>
            <ul>
                <li>ColdFusion error with output suppressed</li>
                <li>Session expired (redirect to login)</li>
                <li>Server configuration issue</li>
                <li>Early cfabort without output</li>
            </ul>
            
        <cfelse>
            <div class="info">
                <h3>Raw Response (First 500 chars):</h3>
                <pre><cfoutput>#htmlEditFormat(left(directResult.fileContent, 500))#</cfoutput></pre>
            </div>
            
            <div class="info">
                <h3>Hex Dump (First 50 bytes):</h3>
                <div class="hex-dump">
                    <cfset hexDump = "">
                    <cfloop from="1" to="#min(50, len(directResult.fileContent))#" index="i">
                        <cfset char = mid(directResult.fileContent, i, 1)>
                        <cfset hexDump &= "[" & formatBaseN(asc(char), 16) & "]">
                    </cfloop>
                    <cfoutput>#hexDump#</cfoutput>
                </div>
            </div>
            
            <cfif left(directResult.fileContent, 1) EQ " " OR left(directResult.fileContent, 1) EQ chr(9) OR left(directResult.fileContent, 1) EQ chr(10) OR left(directResult.fileContent, 1) EQ chr(13)>
                <div class="warning">
                    ⚠️ Response starts with whitespace! This will break JSON parsing.
                </div>
            </cfif>
        </cfif>
        
        <h3>Response Headers:</h3>
        <table>
            <cfloop collection="#directResult.responseHeader#" item="key">
                <tr>
                    <td><cfoutput>#key#</cfoutput></td>
                    <td><cfoutput>#directResult.responseHeader[key]#</cfoutput></td>
                </tr>
            </cfloop>
        </table>
        
        <hr>
        <a href="?">Back to Tests</a>
    </cfif>
    
    <hr>
    <h2>Next Steps:</h2>
    <ol>
        <li>Check if you're logged in</li>
        <li>Look at the response details above</li>
        <li>Check ColdFusion logs for errors</li>
        <li>Try the direct database test instead</li>
    </ol>
</body>
</html>