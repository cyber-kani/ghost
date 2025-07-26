<!--- Test Preview Modal Functionality --->
<!DOCTYPE html>
<html>
<head>
    <title>Test Preview Modal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Test Preview Modal Functionality</h1>
        
        <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
            <div class="alert alert-success">
                Logged in as: <cfoutput>#session.USERNAME#</cfoutput>
            </div>
            
            <!--- Get posts to test --->
            <cfquery name="testPosts" datasource="blog">
                SELECT id, title, status
                FROM posts
                ORDER BY updated_at DESC
                LIMIT 10
            </cfquery>
            
            <cfif testPosts.recordCount>
                <h2>Test Instructions:</h2>
                <div class="alert alert-info">
                    <ol>
                        <li>Click "Edit Post" on any post below</li>
                        <li>In the editor, click the "Preview" button (for draft posts) or check for "Unpublish"/"Update" buttons (for published posts)</li>
                        <li>The preview should open in a full-screen modal overlay (not a new window)</li>
                        <li>You should be able to:
                            <ul>
                                <li>Switch between Web/Email preview (draft posts only)</li>
                                <li>Switch between Desktop/Mobile view</li>
                                <li>Change member status (Public visitor, Free member, Paid member)</li>
                                <li>Close the preview with the Close button</li>
                            </ul>
                        </li>
                    </ol>
                </div>
                
                <h3>Available Posts:</h3>
                <div class="list-group">
                    <cfoutput query="testPosts">
                        <div class="list-group-item">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h5>#title#</h5>
                                    <span class="badge bg-#status eq 'published' ? 'success' : 'secondary'#">#status#</span>
                                </div>
                                <a href="/ghost/admin/posts/edit/#id#" class="btn btn-primary btn-sm">Edit Post</a>
                            </div>
                        </div>
                    </cfoutput>
                </div>
                
                <h3 class="mt-4">Direct Preview Links (for testing):</h3>
                <div class="list-group">
                    <cfoutput query="testPosts">
                        <div class="list-group-item">
                            <h6>#title#</h6>
                            <div class="btn-group btn-group-sm">
                                <a href="/ghost/preview/#id#?member_status=public" target="_blank" class="btn btn-outline-primary">Public</a>
                                <a href="/ghost/preview/#id#?member_status=free" target="_blank" class="btn btn-outline-info">Free</a>
                                <a href="/ghost/preview/#id#?member_status=paid" target="_blank" class="btn btn-outline-success">Paid</a>
                            </div>
                        </div>
                    </cfoutput>
                </div>
            <cfelse>
                <div class="alert alert-warning">No posts found in database.</div>
            </cfif>
        <cfelse>
            <div class="alert alert-danger">
                You must be logged in to test preview functionality.
                <a href="/ghost/admin/login" class="btn btn-primary btn-sm">Login</a>
            </div>
        </cfif>
    </div>
</body>
</html>