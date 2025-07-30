<!--- Diagnose database access issues --->
<cfoutput>
<h1>Database Access Diagnosis</h1>

<h2>Current Situation:</h2>
<div style="background: ##ffebee; padding: 20px; border: 1px solid ##f44336;">
    <h3>❌ Access Denied</h3>
    <p>The CFML user does not have access to the ghost_prod database.</p>
    <p>Error: Access denied for user 'cfml'@'localhost' to database 'ghost_prod'</p>
</div>

<h2>Solution - MySQL Commands:</h2>
<div style="background: ##e3f2fd; padding: 20px; border: 1px solid ##2196f3;">
    <h3>Run these commands as MySQL root user:</h3>
    <pre style="background: ##263238; color: ##aed581; padding: 15px; font-family: monospace;">
# Connect to MySQL as root
mysql -u root -p

# Grant access to ghost_prod database
GRANT ALL PRIVILEGES ON ghost_prod.* TO 'cfml'@'localhost';
FLUSH PRIVILEGES;

# Verify the grant was successful
SHOW GRANTS FOR 'cfml'@'localhost';

# Exit MySQL
exit;</pre>
</div>

<h2>Alternative Solutions:</h2>

<h3>1. Check if ghost_prod database exists:</h3>
<cftry>
    <cfquery name="qDatabases" datasource="blog">
        SHOW DATABASES
    </cfquery>
    <p><strong>Available databases visible to CFML user:</strong></p>
    <ul>
    <cfloop query="qDatabases">
        <li>#Database#</li>
    </cfloop>
    </ul>
<cfcatch>
    <p>Could not list databases</p>
</cfcatch>
</cftry>

<h3>2. Current user permissions:</h3>
<cftry>
    <cfquery name="qCurrentUser" datasource="blog">
        SELECT USER() as current_user, DATABASE() as current_db
    </cfquery>
    <p><strong>Current user:</strong> #qCurrentUser.current_user#</p>
    <p><strong>Current database:</strong> #qCurrentUser.current_db#</p>
<cfcatch>
    <p>Could not get user info</p>
</cfcatch>
</cftry>

<h3>3. Work with existing data:</h3>
<p>Since we cannot access ghost_prod, here are the posts available in the cc_prod database:</p>

<cfquery name="qAvailable" datasource="blog">
    SELECT 
        id,
        title,
        slug,
        status,
        type,
        created_at
    FROM posts
    ORDER BY created_at DESC
    LIMIT 10
</cfquery>

<table border="1" cellpadding="5">
    <tr style="background: ##333; color: white;">
        <th>ID</th>
        <th>Title</th>
        <th>Slug</th>
        <th>Status</th>
        <th>Type</th>
        <th>Action</th>
    </tr>
    <cfloop query="qAvailable">
        <tr>
            <td><code>#id#</code></td>
            <td>#title#</td>
            <td>#slug#</td>
            <td>#status#</td>
            <td>#type#</td>
            <td><a href="get-specific-post.cfm?id=#id#">View & Export</a></td>
        </tr>
    </cfloop>
</table>

<h2>What You Can Do Now:</h2>
<ol>
    <li><strong>Ask your system administrator</strong> to run the MySQL GRANT commands above</li>
    <li><strong>Work with existing posts</strong> in the cc_prod database using the links above</li>
    <li><strong>Import the post</strong> if you have access to the ghost_prod database through another method</li>
</ol>

<h2>Once Access is Granted:</h2>
<p>After the MySQL permissions are granted, you'll be able to:</p>
<ul>
    <li>Access ghost_prod.posts directly</li>
    <li>Compare posts between databases</li>
    <li>Export the specific post with ID 688a02858edd034b578322f0</li>
</ul>

</cfoutput>