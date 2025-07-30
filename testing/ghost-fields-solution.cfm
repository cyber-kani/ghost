<!--- Ghost Fields Complete Solution --->
<!DOCTYPE html>
<html>
<head>
    <title>Ghost Fields - Complete Solution</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; max-width: 1200px; }
        .step { background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #007bff; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; }
        .warning { background: #fff3cd; color: #856404; padding: 15px; border-radius: 5px; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; }
        pre { background: #f0f0f0; padding: 15px; border: 1px solid #ddd; overflow-x: auto; }
        code { background: #f0f0f0; padding: 2px 5px; font-family: monospace; }
        .button { display: inline-block; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 5px; }
        .button:hover { background: #0056b3; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border: 1px solid #ddd; }
        th { background: #e9ecef; }
    </style>
</head>
<body>
    <h1>Ghost Fields Implementation - Complete Solution</h1>
    
    <div class="warning">
        <h2>⚠️ Important: Database Fields Must Exist First!</h2>
        <p>The new Ghost fields (lexical, show_title_and_feature_image, comment_id) must be added to your database before they can be saved.</p>
    </div>
    
    <div class="step">
        <h2>Step 1: Add Fields to Database</h2>
        <p>Run the migration tool to add the missing fields:</p>
        <a href="/ghost/testing/migrate-ghost-fields.cfm" class="button">Run Migration Tool →</a>
        
        <p>Or manually run this SQL:</p>
        <pre>
ALTER TABLE posts
    ADD COLUMN lexical LONGTEXT NULL COMMENT 'Lexical editor content' AFTER mobiledoc,
    ADD COLUMN show_title_and_feature_image BOOLEAN NOT NULL DEFAULT 1 COMMENT 'Display title and feature image',
    ADD COLUMN comment_id VARCHAR(50) NULL COMMENT 'Comment thread identifier';
        </pre>
    </div>
    
    <div class="step">
        <h2>Step 2: Verify Fields Exist</h2>
        <p>Check that all fields have been added to the database:</p>
        <a href="/ghost/testing/verify-fields-exist.cfm" class="button">Verify Fields →</a>
    </div>
    
    <div class="step">
        <h2>Step 3: Implementation Status</h2>
        <table>
            <tr>
                <th>Component</th>
                <th>File</th>
                <th>Status</th>
                <th>Changes</th>
            </tr>
            <tr>
                <td>Save Post Handler</td>
                <td>/admin/ajax/save-post.cfm</td>
                <td style="color: green;">✓ Updated</td>
                <td>
                    - Added lexical and comment_id parameters<br>
                    - Updated INSERT statement<br>
                    - Updated UPDATE statement<br>
                    - Added debug logging
                </td>
            </tr>
            <tr>
                <td>Editor Template</td>
                <td>/admin/includes/editor/editor-template.cfm</td>
                <td style="color: green;">✓ Updated</td>
                <td>
                    - Added hidden fields for lexical and comment_id<br>
                    - show_title_and_feature_image field already existed
                </td>
            </tr>
            <tr>
                <td>Editor Scripts</td>
                <td>/admin/includes/editor/editor-scripts.cfm</td>
                <td style="color: green;">✓ Updated</td>
                <td>
                    - Added JavaScript to populate lexical field<br>
                    - Added JavaScript to preserve comment_id<br>
                    - show_title_and_feature_image already handled
                </td>
            </tr>
        </table>
    </div>
    
    <div class="step">
        <h2>Step 4: Test the Implementation</h2>
        <a href="/ghost/testing/debug-save-post.cfm" class="button">Test Save Post →</a>
        <p>This tool will help you test if the fields are being saved correctly.</p>
    </div>
    
    <div class="step">
        <h2>Step 5: Field Usage Guide</h2>
        
        <h3>1. show_title_and_feature_image (BOOLEAN)</h3>
        <ul>
            <li>Already visible in the post editor settings panel</li>
            <li>Toggle switch to show/hide title and feature image</li>
            <li>Default value: 1 (true)</li>
            <li>Saved automatically when post is saved</li>
        </ul>
        
        <h3>2. lexical (LONGTEXT)</h3>
        <ul>
            <li>Will store Lexical editor JSON content</li>
            <li>Currently empty - placeholder for future Lexical editor implementation</li>
            <li>Can store up to 4GB of JSON data</li>
            <li>Example content: <code>{"root":{"children":[{"type":"paragraph","children":[{"type":"text","text":"Hello"}]}]}}</code></li>
        </ul>
        
        <h3>3. comment_id (VARCHAR(50))</h3>
        <ul>
            <li>Links posts to comment threads</li>
            <li>Can be set programmatically when integrating with a commenting system</li>
            <li>Format: Any unique identifier up to 50 characters</li>
            <li>Example: "comment_thread_12345"</li>
        </ul>
    </div>
    
    <div class="step">
        <h2>Troubleshooting</h2>
        
        <h3>If fields are not saving:</h3>
        <ol>
            <li>Check ColdFusion logs: <code>/var/log/coldfusion/ghost-save-post.log</code></li>
            <li>Verify database fields exist using the verification tool</li>
            <li>Check browser console for JavaScript errors</li>
            <li>Use the debug save post tool to test manually</li>
        </ol>
        
        <h3>Common Issues:</h3>
        <ul>
            <li><strong>Fields don't exist error:</strong> Run the migration tool first</li>
            <li><strong>Values are NULL:</strong> Check that JavaScript is populating the hidden fields</li>
            <li><strong>Session timeout:</strong> Log in again and retry</li>
        </ul>
    </div>
    
    <div class="success">
        <h2>✓ Implementation Complete</h2>
        <p>All code changes have been made. The system is ready to save the new Ghost fields once they exist in the database.</p>
        <p><strong>Next steps:</strong></p>
        <ol>
            <li>Run the migration to add database fields</li>
            <li>Test creating/editing a post</li>
            <li>Verify fields are being saved</li>
        </ol>
    </div>
    
    <p><a href="/ghost/testing/">← Back to Testing Tools</a></p>
</body>
</html>