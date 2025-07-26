<!--- Test Unpublish Functionality --->
<!DOCTYPE html>
<html>
<head>
    <title>Test Unpublish Functionality</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Test Unpublish Functionality</h1>
        
        <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
            <div class="alert alert-success">
                Logged in as: <cfoutput>#session.USERNAME#</cfoutput>
            </div>
            
            <!--- Get published posts --->
            <cfquery name="publishedPosts" datasource="blog">
                SELECT id, title, status, published_at
                FROM posts
                WHERE status = 'published'
                ORDER BY published_at DESC
                LIMIT 10
            </cfquery>
            
            <cfif publishedPosts.recordCount>
                <h2>Published Posts:</h2>
                <p>Edit any of these posts to test the unpublish functionality.</p>
                <div class="list-group">
                    <cfoutput query="publishedPosts">
                        <div class="list-group-item">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h5>#title#</h5>
                                    <small class="text-muted">Published: #dateFormat(published_at, "mmm dd, yyyy")#</small>
                                </div>
                                <a href="/ghost/admin/posts/edit/#id#" class="btn btn-primary btn-sm">Edit Post</a>
                            </div>
                        </div>
                    </cfoutput>
                </div>
                
                <div class="alert alert-info mt-4">
                    <h5>Testing Instructions:</h5>
                    <ol>
                        <li>Click "Edit Post" on any published post above</li>
                        <li>You should see "Unpublish" and "Update" buttons instead of "Preview" and "Publish"</li>
                        <li>Click "Unpublish" to test the unpublishing feature</li>
                        <li>The post should revert to draft status</li>
                    </ol>
                </div>
            <cfelse>
                <div class="alert alert-warning">
                    <h5>No published posts found</h5>
                    <p>You need to publish some posts first to test the unpublish functionality.</p>
                    <a href="/ghost/admin/posts" class="btn btn-primary">Go to Posts</a>
                </div>
            </cfif>
            
            <!--- Get draft posts to test publishing --->
            <cfquery name="draftPosts" datasource="blog">
                SELECT id, title, status
                FROM posts
                WHERE status = 'draft'
                ORDER BY updated_at DESC
                LIMIT 5
            </cfquery>
            
            <cfif draftPosts.recordCount>
                <h3 class="mt-5">Draft Posts (to test publishing):</h3>
                <div class="list-group">
                    <cfoutput query="draftPosts">
                        <div class="list-group-item">
                            <div class="d-flex justify-content-between align-items-center">
                                <h6>#title#</h6>
                                <a href="/ghost/admin/posts/edit/#id#" class="btn btn-outline-primary btn-sm">Edit Draft</a>
                            </div>
                        </div>
                    </cfoutput>
                </div>
            </cfif>
        <cfelse>
            <div class="alert alert-danger">
                You must be logged in to test unpublish functionality.
                <a href="/ghost/admin/login" class="btn btn-primary btn-sm">Login</a>
            </div>
        </cfif>
    </div>
</body>
</html>