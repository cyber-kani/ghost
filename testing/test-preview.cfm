<!--- Test Preview Functionality --->
<!DOCTYPE html>
<html>
<head>
    <title>Test Preview Functionality</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h1>Test Preview Functionality</h1>
        
        <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
            <div class="alert alert-success">
                Logged in as: <cfoutput>#session.USERNAME#</cfoutput>
            </div>
            
            <!--- Get a test post --->
            <cfquery name="testPost" datasource="blog">
                SELECT id, title, status
                FROM posts
                ORDER BY id DESC
                LIMIT 5
            </cfquery>
            
            <cfif testPost.recordCount>
                <h2>Available Posts for Preview:</h2>
                <div class="list-group">
                    <cfoutput query="testPost">
                        <div class="list-group-item">
                            <h5>#title#</h5>
                            <p>Status: #status# | ID: #id#</p>
                            <div class="btn-group">
                                <a href="/ghost/preview/#id#?member_status=public" target="_blank" class="btn btn-primary btn-sm">Preview as Public</a>
                                <a href="/ghost/preview/#id#?member_status=free" target="_blank" class="btn btn-info btn-sm">Preview as Free Member</a>
                                <a href="/ghost/preview/#id#?member_status=paid" target="_blank" class="btn btn-success btn-sm">Preview as Paid Member</a>
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