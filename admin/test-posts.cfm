<!DOCTYPE html>
<html>
<head>
    <title>Test Posts</title>
</head>
<body>
    <h1>Testing Posts Query</h1>
    
    <cfquery name="qAllPosts" datasource="blog">
        SELECT 
            id,
            slug,
            title,
            status,
            type,
            published_at,
            created_at
        FROM posts
        ORDER BY created_at DESC
    </cfquery>
    
    <h2>All Posts:</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Title</th>
            <th>Slug</th>
            <th>Status</th>
            <th>Type</th>
            <th>Published At</th>
            <th>Created At</th>
        </tr>
        <cfloop query="qAllPosts">
            <tr>
                <td>#id#</td>
                <td>#title#</td>
                <td>#slug#</td>
                <td>#status#</td>
                <td>#type#</td>
                <td><cfif isDate(published_at)>#dateFormat(published_at, "yyyy-mm-dd")#<cfelse>NULL</cfif></td>
                <td><cfif isDate(created_at)>#dateFormat(created_at, "yyyy-mm-dd")#<cfelse>NULL</cfif></td>
            </tr>
        </cfloop>
    </table>
    
    <h2>Published Posts Count:</h2>
    <cfquery name="qPublishedCount" datasource="blog">
        SELECT COUNT(*) as total
        FROM posts
        WHERE status = 'published'
    </cfquery>
    <p>Total published posts: #qPublishedCount.total#</p>
    
    <h2>Testing AJAX endpoint:</h2>
    <button onclick="testAjax()">Test AJAX</button>
    <div id="result"></div>
    
    <script>
    function testAjax() {
        fetch('/ghost/admin/ajax/get-published-posts.cfm')
            .then(response => response.json())
            .then(data => {
                document.getElementById('result').innerHTML = '<pre>' + JSON.stringify(data, null, 2) + '</pre>';
            })
            .catch(error => {
                document.getElementById('result').innerHTML = 'Error: ' + error;
            });
    }
    </script>
</body>
</html>