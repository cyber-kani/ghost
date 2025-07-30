<!--- Compare posts between yalulife and blog databases --->
<cfparam name="url.title" default="Test 12">

<cfoutput>
<h1>Database Comparison for: "#url.title#"</h1>

<h2>1. From 'blog' database (cc_prod)</h2>
<cfquery name="qBlog" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        html,
        type,
        status,
        created_at,
        updated_at
    FROM posts
    WHERE title = <cfqueryparam value="#url.title#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qBlog.recordCount GT 0>
    <cfloop query="qBlog">
        <div style="border: 2px solid ##0066cc; padding: 15px; margin: 10px 0;">
            <h3>Post found in 'blog' database</h3>
            <p><strong>ID:</strong> #id#</p>
            <p><strong>Title:</strong> #title#</p>
            <p><strong>Slug:</strong> #slug#</p>
            <p><strong>Type:</strong> #type# | <strong>Status:</strong> #status#</p>
            <p><strong>Created:</strong> #dateFormat(created_at, "yyyy-mm-dd HH:nn:ss")#</p>
            
            <!--- Save HTML to file --->
            <cfset fileName1 = "/var/www/sites/clitools.app/wwwroot/ghost/testing/blog_post_#replace(slug, '-', '_', 'all')#.html">
            <cffile action="write" file="#fileName1#" output="#html#" charset="utf-8">
            <p><strong>HTML saved to:</strong> #fileName1#</p>
            
            <h4>HTML Content:</h4>
            <pre style="background: ##f5f5f5; padding: 10px; overflow: auto;"><code>#htmlEditFormat(html)#</code></pre>
        </div>
    </cfloop>
<cfelse>
    <p style="color: red;">Post not found in 'blog' database</p>
</cfif>

<h2>2. From 'yalulife' database</h2>
<cfquery name="qYalu" datasource="yalulife">
    SELECT 
        id,
        title,
        slug,
        html,
        type,
        status,
        created_at,
        updated_at
    FROM posts
    WHERE title = <cfqueryparam value="#url.title#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qYalu.recordCount GT 0>
    <cfloop query="qYalu">
        <div style="border: 2px solid ##00cc66; padding: 15px; margin: 10px 0;">
            <h3>Post found in 'yalulife' database</h3>
            <p><strong>ID:</strong> #id#</p>
            <p><strong>Title:</strong> #title#</p>
            <p><strong>Slug:</strong> #slug#</p>
            <p><strong>Type:</strong> #type# | <strong>Status:</strong> #status#</p>
            <p><strong>Created:</strong> #dateFormat(created_at, "yyyy-mm-dd HH:nn:ss")#</p>
            
            <!--- Save HTML to file --->
            <cfset fileName2 = "/var/www/sites/clitools.app/wwwroot/ghost/testing/yalulife_post_#replace(slug, '-', '_', 'all')#.html">
            <cffile action="write" file="#fileName2#" output="#html#" charset="utf-8">
            <p><strong>HTML saved to:</strong> #fileName2#</p>
            
            <h4>HTML Content:</h4>
            <pre style="background: ##f5f5f5; padding: 10px; overflow: auto;"><code>#htmlEditFormat(html)#</code></pre>
        </div>
    </cfloop>
<cfelse>
    <p style="color: red;">Post not found in 'yalulife' database</p>
</cfif>

<h2>3. Side-by-Side Comparison</h2>
<cfif qBlog.recordCount GT 0 AND qYalu.recordCount GT 0>
    <!--- Create side-by-side comparison HTML --->
    <cfsavecontent variable="comparisonHTML">
        <!DOCTYPE html>
        <html>
        <head>
            <title>Post Comparison: #url.title#</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .container { display: flex; gap: 20px; }
                .column { flex: 1; border: 1px solid ##ccc; padding: 20px; }
                .column h2 { margin-top: 0; }
                .blog-column { border-color: ##0066cc; }
                .yalu-column { border-color: ##00cc66; }
                .metadata { background: ##f5f5f5; padding: 10px; margin-bottom: 20px; }
                .content { border-top: 1px solid ##ddd; padding-top: 20px; }
                pre { white-space: pre-wrap; word-wrap: break-word; }
            </style>
        </head>
        <body>
            <h1>Post Comparison: #url.title#</h1>
            <div class="container">
                <div class="column blog-column">
                    <h2>Blog Database</h2>
                    <div class="metadata">
                        <p><strong>ID:</strong> #qBlog.id#</p>
                        <p><strong>Slug:</strong> #qBlog.slug#</p>
                        <p><strong>Status:</strong> #qBlog.status#</p>
                        <p><strong>Updated:</strong> #dateFormat(qBlog.updated_at, "yyyy-mm-dd HH:nn:ss")#</p>
                    </div>
                    <div class="content">
                        <h3>HTML Content:</h3>
                        <pre>#htmlEditFormat(qBlog.html)#</pre>
                        <hr>
                        <h3>Rendered:</h3>
                        #qBlog.html#
                    </div>
                </div>
                <div class="column yalu-column">
                    <h2>Yalulife Database</h2>
                    <div class="metadata">
                        <p><strong>ID:</strong> #qYalu.id#</p>
                        <p><strong>Slug:</strong> #qYalu.slug#</p>
                        <p><strong>Status:</strong> #qYalu.status#</p>
                        <p><strong>Updated:</strong> #dateFormat(qYalu.updated_at, "yyyy-mm-dd HH:nn:ss")#</p>
                    </div>
                    <div class="content">
                        <h3>HTML Content:</h3>
                        <pre>#htmlEditFormat(qYalu.html)#</pre>
                        <hr>
                        <h3>Rendered:</h3>
                        #qYalu.html#
                    </div>
                </div>
            </div>
        </body>
        </html>
    </cfsavecontent>
    
    <cfset comparisonFile = "/var/www/sites/clitools.app/wwwroot/ghost/testing/comparison_#replace(url.title, ' ', '_', 'all')#.html">
    <cffile action="write" file="#comparisonFile#" output="#comparisonHTML#" charset="utf-8">
    
    <p style="background: ##d4edda; padding: 15px; border: 1px solid ##c3e6cb;">
        <strong>✓ Side-by-side comparison created:</strong><br>
        <a href="/ghost/testing/comparison_#replace(url.title, ' ', '_', 'all')#.html" target="_blank">#comparisonFile#</a>
    </p>
</cfif>

</cfoutput>