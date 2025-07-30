<!--- Debug Save Post Data --->
<cfparam name="request.dsn" default="blog">

<!DOCTYPE html>
<html>
<head>
    <title>Debug Save Post</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .debug-section { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .form-data { background: #e3f2fd; padding: 10px; margin: 10px 0; }
        .missing { color: #d32f2f; font-weight: bold; }
        .present { color: #388e3c; }
        pre { background: white; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
        input[type="text"] { width: 300px; padding: 5px; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
        button:hover { background: #0056b3; }
    </style>
</head>
<body>
    <h1>Debug Save Post - Test Ghost Fields</h1>
    
    <div class="debug-section">
        <h2>Test Form Submission</h2>
        <form id="testForm" method="post" action="/ghost/admin/ajax/save-post.cfm">
            <p>
                <label>Post ID: <input type="text" name="postId" value="test_<cfoutput>#createUUID()#</cfoutput>" required></label>
            </p>
            <p>
                <label>Title: <input type="text" name="title" value="Test Post with Ghost Fields" required></label>
            </p>
            <p>
                <label>Content: <textarea name="content" rows="3" style="width: 300px;">Test content</textarea></label>
            </p>
            <p>
                <label>Show Title & Feature Image: 
                    <select name="show_title_and_feature_image">
                        <option value="1">Yes (1)</option>
                        <option value="0">No (0)</option>
                    </select>
                </label>
            </p>
            <p>
                <label>Lexical: <textarea name="lexical" rows="3" style="width: 300px;">{"root":{"children":[{"type":"paragraph","children":[{"type":"text","text":"Test lexical content"}]}]}}</textarea></label>
            </p>
            <p>
                <label>Comment ID: <input type="text" name="comment_id" value="test_comment_123"></label>
            </p>
            <p>
                <label>Status: 
                    <select name="status">
                        <option value="draft">Draft</option>
                        <option value="published">Published</option>
                    </select>
                </label>
            </p>
            <p>
                <label>Type: 
                    <select name="type">
                        <option value="post">Post</option>
                        <option value="page">Page</option>
                    </select>
                </label>
            </p>
            <button type="submit">Test Save Post</button>
        </form>
        
        <div id="result"></div>
    </div>
    
    <div class="debug-section">
        <h2>Check What save-post.cfm Expects</h2>
        <div class="form-data">
            <h3>Expected Form Fields:</h3>
            <ul>
                <li class="present">✓ postId (or id)</li>
                <li class="present">✓ title</li>
                <li class="present">✓ content (html)</li>
                <li class="present">✓ show_title_and_feature_image</li>
                <li class="present">✓ lexical</li>
                <li class="present">✓ comment_id</li>
                <li>✓ status</li>
                <li>✓ type</li>
                <li>✓ And many other optional fields...</li>
            </ul>
        </div>
    </div>
    
    <div class="debug-section">
        <h2>Recent Save Attempts (Check Logs)</h2>
        <pre>
Check ColdFusion logs for any errors:
- Application log
- Exception log
- Or add cflog statements to save-post.cfm to trace execution
        </pre>
    </div>
    
    <script>
    document.getElementById('testForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const formData = new FormData(this);
        const result = document.getElementById('result');
        
        // Show what we're sending
        let debugInfo = '<h3>Sending:</h3><ul>';
        for (let [key, value] of formData.entries()) {
            debugInfo += '<li><strong>' + key + ':</strong> ' + value + '</li>';
        }
        debugInfo += '</ul>';
        result.innerHTML = debugInfo + '<p>Submitting...</p>';
        
        fetch(this.action, {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(text => {
            result.innerHTML += '<h3>Response:</h3><pre>' + text + '</pre>';
            
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    result.innerHTML += '<p class="present">✓ Save successful! Post ID: ' + data.postId + '</p>';
                    
                    // Now check if fields were saved
                    checkSavedFields(formData.get('postId'));
                } else {
                    result.innerHTML += '<p class="missing">✗ Save failed: ' + data.message + '</p>';
                }
            } catch (e) {
                result.innerHTML += '<p class="missing">✗ Invalid JSON response</p>';
            }
        })
        .catch(error => {
            result.innerHTML += '<p class="missing">✗ Network error: ' + error + '</p>';
        });
    });
    
    function checkSavedFields(postId) {
        // Query the database to verify fields were saved
        fetch('/ghost/testing/check-saved-fields.cfm?postId=' + postId)
            .then(response => response.text())
            .then(text => {
                document.getElementById('result').innerHTML += '<h3>Verification:</h3>' + text;
            });
    }
    </script>
</body>
</html>