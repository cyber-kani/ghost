<!DOCTYPE html>
<html>
<head>
    <title>Database Posts Check</title>
    <style>
        table { border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .published { background-color: #d4edda; }
        .draft { background-color: #f8d7da; }
    </style>
</head>
<body>
    <h1>Database Posts Analysis</h1>
    
    <cftry>
        <!--- Check database connection --->
        <cfquery name="qTest" datasource="blog">
            SELECT 1 as test
        </cfquery>
        <p style="color: green;">✓ Database connection successful</p>
        
        <!--- Get all posts with full details --->
        <cfquery name="qAllPosts" datasource="blog">
            SELECT 
                p.id,
                p.uuid,
                p.title,
                p.slug,
                p.status,
                p.type,
                p.published_at,
                p.created_at,
                p.updated_at,
                p.author_id,
                u.name as author_name,
                u.email as author_email
            FROM posts p
            LEFT JOIN users u ON p.author_id = u.id
            ORDER BY p.created_at DESC
        </cfquery>
        
        <h2>All Posts in Database (#qAllPosts.recordCount# total):</h2>
        <table>
            <tr>
                <th>ID</th>
                <th>UUID</th>
                <th>Title</th>
                <th>Slug</th>
                <th>Status</th>
                <th>Type</th>
                <th>Author</th>
                <th>Published At</th>
                <th>Created At</th>
            </tr>
            <cfloop query="qAllPosts">
                <tr class="#status#">
                    <td>#id#</td>
                    <td>#Left(uuid, 8)#...</td>
                    <td>#HTMLEditFormat(title)#</td>
                    <td>#slug#</td>
                    <td><strong>#status#</strong></td>
                    <td>#type#</td>
                    <td>#author_name# (#author_id#)</td>
                    <td>
                        <cfif NOT isNull(published_at) AND isDate(published_at)>
                            #dateFormat(published_at, "yyyy-mm-dd")# #timeFormat(published_at, "HH:mm:ss")#
                        <cfelse>
                            NULL
                        </cfif>
                    </td>
                    <td>#dateFormat(created_at, "yyyy-mm-dd HH:mm:ss")#</td>
                </tr>
            </cfloop>
        </table>
        
        <!--- Count by status --->
        <cfquery name="qStatusCount" datasource="blog">
            SELECT 
                status,
                COUNT(*) as count
            FROM posts
            GROUP BY status
        </cfquery>
        
        <h2>Posts by Status:</h2>
        <ul>
            <cfloop query="qStatusCount">
                <li><strong>#status#:</strong> #count# posts</li>
            </cfloop>
        </ul>
        
        <!--- Get only published posts with the exact query from AJAX --->
        <cfquery name="qPublishedPosts" datasource="blog">
            SELECT 
                p.id,
                p.slug,
                p.title,
                p.custom_excerpt as excerpt,
                p.feature_image,
                p.published_at,
                u.name as author_name
            FROM posts p
            LEFT JOIN users u ON p.author_id = u.id
            WHERE p.status = 'published'
            ORDER BY p.published_at DESC, p.created_at DESC
            LIMIT 50
        </cfquery>
        
        <h2>Published Posts Query Result (#qPublishedPosts.recordCount# posts):</h2>
        <cfif qPublishedPosts.recordCount GT 0>
            <table>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Slug</th>
                    <th>Excerpt</th>
                    <th>Published At</th>
                </tr>
                <cfloop query="qPublishedPosts">
                    <tr>
                        <td>#id#</td>
                        <td>#HTMLEditFormat(title)#</td>
                        <td>#slug#</td>
                        <td><cfif NOT isNull(excerpt)>#HTMLEditFormat(excerpt)#<cfelse>NULL</cfif></td>
                        <td>
                            <cfif NOT isNull(published_at) AND isDate(published_at)>
                                #dateFormat(published_at, "yyyy-mm-dd")# #timeFormat(published_at, "HH:mm:ss")#
                            <cfelse>
                                NULL
                            </cfif>
                        </td>
                    </tr>
                </cfloop>
            </table>
        <cfelse>
            <p style="color: red;">No published posts found!</p>
        </cfif>
        
        <!--- Test the AJAX endpoint directly --->
        <h2>Testing AJAX Endpoint:</h2>
        <button onclick="testAjax()">Test get-published-posts.cfm</button>
        <div id="ajaxResult" style="margin-top: 10px; padding: 10px; background: #f5f5f5; border: 1px solid #ddd;"></div>
        
        <!--- Check session --->
        <h2>Session Check:</h2>
        <cfif structKeyExists(session, "user") AND structKeyExists(session.user, "id")>
            <p style="color: green;">✓ User is logged in: #session.user.email# (ID: #session.user.id#)</p>
        <cfelse>
            <p style="color: red;">✗ User is NOT logged in - this will cause AJAX to fail!</p>
        </cfif>
        
        <cfcatch>
            <h2 style="color: red;">Error:</h2>
            <pre>#cfcatch.message#
#cfcatch.detail#</pre>
        </cfcatch>
    </cftry>
    
    <script>
    function testAjax() {
        const resultDiv = document.getElementById('ajaxResult');
        resultDiv.innerHTML = 'Loading...';
        
        fetch('/ghost/admin/ajax/get-published-posts.cfm')
            .then(response => {
                console.log('Response status:', response.status);
                console.log('Response headers:', response.headers);
                return response.text();
            })
            .then(text => {
                console.log('Raw response:', text);
                try {
                    const data = JSON.parse(text);
                    resultDiv.innerHTML = '<h3>Success!</h3><pre>' + JSON.stringify(data, null, 2) + '</pre>';
                } catch (e) {
                    resultDiv.innerHTML = '<h3>Parse Error:</h3><pre>' + e + '\n\nRaw response:\n' + text + '</pre>';
                }
            })
            .catch(error => {
                resultDiv.innerHTML = '<h3>Fetch Error:</h3><pre>' + error + '</pre>';
                console.error('Fetch error:', error);
            });
    }
    </script>
</body>
</html>