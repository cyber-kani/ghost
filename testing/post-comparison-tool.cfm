<!--- Post Comparison Tool --->
<cfparam name="url.action" default="">
<cfparam name="url.id1" default="">
<cfparam name="url.id2" default="">
<cfparam name="url.db" default="both">

<cfoutput>
<!DOCTYPE html>
<html>
<head>
    <title>Ghost Post Comparison Tool</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .form-section { background: ##f5f5f5; padding: 20px; margin-bottom: 20px; border-radius: 5px; }
        .comparison { display: flex; gap: 20px; }
        .post-column { flex: 1; border: 1px solid ##ddd; padding: 15px; }
        .post-column h3 { margin-top: 0; color: ##0066cc; }
        pre { background: ##f9f9f9; padding: 10px; overflow: auto; }
        .metadata { background: ##e9ecef; padding: 10px; margin-bottom: 15px; }
        input[type="text"] { width: 300px; padding: 5px; }
        button { padding: 8px 20px; background: ##007bff; color: white; border: none; cursor: pointer; }
        button:hover { background: ##0056b3; }
        .error { color: red; padding: 10px; background: ##ffebee; }
        .success { color: green; padding: 10px; background: ##d4edda; }
        .db-section { margin: 20px 0; }
        .blog-db { border-left: 5px solid ##0066cc; }
        .ghost-db { border-left: 5px solid ##28a745; }
    </style>
</head>
<body>
    <h1>Ghost Post Comparison Tool</h1>
    
    <div class="form-section">
        <h2>1. List All Posts</h2>
        <form method="get">
            <input type="hidden" name="action" value="list">
            <label>
                <input type="radio" name="db" value="both" <cfif url.db EQ "both">checked</cfif>> Both Databases
                <input type="radio" name="db" value="blog" <cfif url.db EQ "blog">checked</cfif>> Blog (cc_prod) Only
                <input type="radio" name="db" value="ghost_prod" <cfif url.db EQ "ghost_prod">checked</cfif>> Ghost_prod Only
            </label>
            <button type="submit">Show Posts</button>
        </form>
    </div>
    
    <cfif url.action EQ "list">
        <cfif url.db EQ "both" OR url.db EQ "blog">
            <div class="db-section blog-db">
                <h2>Posts in Blog Database (cc_prod)</h2>
                <cfquery name="qBlogPosts" datasource="blog">
                    SELECT id, title, slug, type, status, created_at, LENGTH(html) as html_length
                    FROM posts
                    ORDER BY created_at DESC
                </cfquery>
                
                <table border="1" cellpadding="5" style="width: 100%;">
                    <tr style="background: ##0066cc; color: white;">
                        <th>ID</th>
                        <th>Title</th>
                        <th>Slug</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>HTML Size</th>
                        <th>Actions</th>
                    </tr>
                    <cfloop query="qBlogPosts">
                        <tr>
                            <td><code>#id#</code></td>
                            <td><strong>#title#</strong></td>
                            <td>#slug#</td>
                            <td>#type#</td>
                            <td>#status#</td>
                            <td>#dateFormat(created_at, "yyyy-mm-dd")#</td>
                            <td>#html_length# chars</td>
                            <td>
                                <a href="?action=view&id1=#id#&db=blog">View</a> |
                                <a href="?action=export&id1=#id#&db=blog">Export</a>
                            </td>
                        </tr>
                    </cfloop>
                </table>
                <p>Total: #qBlogPosts.recordCount# posts</p>
            </div>
        </cfif>
        
        <cfif url.db EQ "both" OR url.db EQ "ghost_prod">
            <div class="db-section ghost-db">
                <h2>Posts in Ghost_prod Database</h2>
                <cfquery name="qGhostPosts" datasource="ghost_prod">
                    SELECT id, title, slug, type, status, created_at, LENGTH(html) as html_length
                    FROM posts
                    ORDER BY created_at DESC
                </cfquery>
                
                <table border="1" cellpadding="5" style="width: 100%;">
                    <tr style="background: ##28a745; color: white;">
                        <th>ID</th>
                        <th>Title</th>
                        <th>Slug</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>HTML Size</th>
                        <th>Actions</th>
                    </tr>
                    <cfloop query="qGhostPosts">
                        <tr>
                            <td><code>#id#</code></td>
                            <td><strong>#title#</strong></td>
                            <td>#slug#</td>
                            <td>#type#</td>
                            <td>#status#</td>
                            <td>#dateFormat(created_at, "yyyy-mm-dd")#</td>
                            <td>#html_length# chars</td>
                            <td>
                                <a href="?action=view&id1=#id#&db=ghost_prod">View</a> |
                                <a href="?action=export&id1=#id#&db=ghost_prod">Export</a>
                            </td>
                        </tr>
                    </cfloop>
                </table>
                <p>Total: #qGhostPosts.recordCount# posts</p>
            </div>
        </cfif>
    </cfif>
    
    <div class="form-section">
        <h2>2. View/Export Single Post</h2>
        <form method="get">
            <input type="hidden" name="action" value="view">
            <label>Post ID: <input type="text" name="id1" value="#url.id1#" placeholder="Enter post ID"></label><br><br>
            <label>Database: 
                <select name="db">
                    <option value="blog" <cfif url.db EQ "blog">selected</cfif>>Blog (cc_prod)</option>
                    <option value="ghost_prod" <cfif url.db EQ "ghost_prod">selected</cfif>>Ghost_prod</option>
                </select>
            </label>
            <button type="submit">View Post</button>
        </form>
    </div>
    
    <cfif url.action EQ "view" AND len(url.id1)>
        <cfset datasourceName = url.db EQ "ghost_prod" ? "ghost_prod" : "blog">
        <cfquery name="qPost" datasource="#datasourceName#">
            SELECT * FROM posts WHERE id = <cfqueryparam value="#url.id1#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qPost.recordCount>
            <div class="success">
                <h3>Post Found: #qPost.title#</h3>
                <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/export_#qPost.id#.html">
                <cffile action="write" file="#fileName#" output="#qPost.html#" charset="utf-8">
                <p>HTML exported to: <a href="/ghost/testing/export_#qPost.id#.html" target="_blank">#fileName#</a></p>
            </div>
            
            <div class="metadata">
                <p><strong>ID:</strong> #qPost.id#</p>
                <p><strong>Slug:</strong> #qPost.slug#</p>
                <p><strong>Status:</strong> #qPost.status# | <strong>Type:</strong> #qPost.type#</p>
                <p><strong>Created:</strong> #dateFormat(qPost.created_at, "yyyy-mm-dd HH:nn:ss")#</p>
            </div>
            
            <h3>HTML Content:</h3>
            <pre>#htmlEditFormat(qPost.html)#</pre>
            
            <h3>Rendered:</h3>
            <div style="border: 1px solid ##ddd; padding: 20px;">
                #qPost.html#
            </div>
        <cfelse>
            <div class="error">Post not found with ID: #url.id1#</div>
        </cfif>
    </cfif>
    
    <cfif url.action EQ "export" AND len(url.id1)>
        <cfset datasourceName = url.db EQ "ghost_prod" ? "ghost_prod" : "blog">
        <cfquery name="qPost" datasource="#datasourceName#">
            SELECT * FROM posts WHERE id = <cfqueryparam value="#url.id1#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qPost.recordCount>
            <cfset fileName = "/var/www/sites/clitools.app/wwwroot/ghost/testing/export_#qPost.id#.html">
            <cffile action="write" file="#fileName#" output="#qPost.html#" charset="utf-8">
            <div class="success">
                <h3>Export Successful</h3>
                <p><strong>Post:</strong> #qPost.title#</p>
                <p><strong>Exported to:</strong> <a href="/ghost/testing/export_#qPost.id#.html" target="_blank">#fileName#</a></p>
            </div>
        </cfif>
    </cfif>
    
    <div class="form-section">
        <h2>3. Compare Two Posts</h2>
        <form method="get">
            <input type="hidden" name="action" value="compare">
            <label>Post ID 1: <input type="text" name="id1" value="#url.id1#" placeholder="First post ID"></label><br><br>
            <label>Post ID 2: <input type="text" name="id2" value="#url.id2#" placeholder="Second post ID"></label><br><br>
            <button type="submit">Compare Posts</button>
        </form>
    </div>
    
    <cfif url.action EQ "compare" AND len(url.id1) AND len(url.id2)>
        <cfquery name="qPost1" datasource="blog">
            SELECT * FROM posts WHERE id = <cfqueryparam value="#url.id1#" cfsqltype="cf_sql_varchar">
        </cfquery>
        <cfquery name="qPost2" datasource="blog">
            SELECT * FROM posts WHERE id = <cfqueryparam value="#url.id2#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qPost1.recordCount AND qPost2.recordCount>
            <h2>Comparison Results</h2>
            <div class="comparison">
                <div class="post-column">
                    <h3>Post 1: #qPost1.title#</h3>
                    <div class="metadata">
                        <p><strong>ID:</strong> #qPost1.id#</p>
                        <p><strong>Updated:</strong> #dateFormat(qPost1.updated_at, "yyyy-mm-dd HH:nn:ss")#</p>
                    </div>
                    <h4>HTML:</h4>
                    <pre>#htmlEditFormat(qPost1.html)#</pre>
                </div>
                <div class="post-column">
                    <h3>Post 2: #qPost2.title#</h3>
                    <div class="metadata">
                        <p><strong>ID:</strong> #qPost2.id#</p>
                        <p><strong>Updated:</strong> #dateFormat(qPost2.updated_at, "yyyy-mm-dd HH:nn:ss")#</p>
                    </div>
                    <h4>HTML:</h4>
                    <pre>#htmlEditFormat(qPost2.html)#</pre>
                </div>
            </div>
            
            <!--- Save comparison --->
            <cfsavecontent variable="comparisonHTML">
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Comparison: #qPost1.title# vs #qPost2.title#</title>
                    <style>
                        body { font-family: Arial, sans-serif; }
                        .container { display: flex; gap: 20px; }
                        .column { flex: 1; border: 1px solid ##ccc; padding: 20px; }
                        pre { white-space: pre-wrap; }
                    </style>
                </head>
                <body>
                    <h1>Post Comparison</h1>
                    <div class="container">
                        <div class="column">
                            <h2>#qPost1.title#</h2>
                            <p>ID: #qPost1.id#</p>
                            <hr>
                            #qPost1.html#
                        </div>
                        <div class="column">
                            <h2>#qPost2.title#</h2>
                            <p>ID: #qPost2.id#</p>
                            <hr>
                            #qPost2.html#
                        </div>
                    </div>
                </body>
                </html>
            </cfsavecontent>
            
            <cfset compFile = "/var/www/sites/clitools.app/wwwroot/ghost/testing/comparison_#qPost1.id#_vs_#qPost2.id#.html">
            <cffile action="write" file="#compFile#" output="#comparisonHTML#" charset="utf-8">
            
            <div class="success">
                <p>Comparison saved to: <a href="/ghost/testing/comparison_#qPost1.id#_vs_#qPost2.id#.html" target="_blank">#compFile#</a></p>
            </div>
        <cfelse>
            <div class="error">One or both posts not found</div>
        </cfif>
    </cfif>
</body>
</html>
</cfoutput>