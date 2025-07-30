<!--- Alternative ways to access the post --->
<cfoutput>
<h1>Alternative Access Methods</h1>

<h2>Since direct database access isn't working, here are alternatives:</h2>

<div style="background: ##e8f5e9; padding: 20px; margin: 20px 0; border: 1px solid ##4caf50;">
    <h3>Option 1: Manual SQL Export/Import</h3>
    <p>Run this on the server where ghost_prod exists:</p>
    <textarea style="width: 100%; height: 150px; font-family: monospace;">
# Connect to MySQL and export the specific post
mysql -u root -p

USE ghost_prod;

# Find the post
SELECT id, title, slug FROM posts WHERE id = '688a02858edd034b578322f0';

# Export to file
SELECT * FROM posts WHERE id = '688a02858edd034b578322f0' 
INTO OUTFILE '/tmp/ghost_post_688a.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
    </textarea>
</div>

<div style="background: ##e3f2fd; padding: 20px; margin: 20px 0; border: 1px solid ##2196f3;">
    <h3>Option 2: Create Import Script</h3>
    <p>If you can get the post data (HTML content), I can help you import it:</p>
    <form method="post" action="import-post.cfm">
        <label>Post Title: <input type="text" name="title" size="50"></label><br><br>
        <label>Post Slug: <input type="text" name="slug" size="50"></label><br><br>
        <label>Post HTML: <textarea name="html" rows="10" cols="80"></textarea></label><br><br>
        <button type="submit">Import to cc_prod</button>
    </form>
</div>

<div style="background: ##fff3e0; padding: 20px; margin: 20px 0; border: 1px solid ##ff9800;">
    <h3>Option 3: Check Different Connection</h3>
    <p>The ghost_prod might be on a different server. Try:</p>
    <pre>
# From command line
mysql -h [ghost_prod_server] -u [username] -p ghost_prod

# Or create a new datasource with different host
    </pre>
</div>

<h2>Quick Test - List all accessible databases:</h2>
<cftry>
    <cfquery name="qDbs" datasource="blog">
        SHOW DATABASES
    </cfquery>
    <p><strong>Databases visible to CFML user:</strong></p>
    <ul style="background: ##f5f5f5; padding: 20px;">
    <cfloop query="qDbs">
        <li><cfif Database EQ "ghost_prod"><strong style="color: green;"></cfif>#Database#<cfif Database EQ "ghost_prod"> ← ghost_prod found!</strong></cfif></li>
    </cfloop>
    </ul>
<cfcatch>
    <p>Could not list databases: #cfcatch.message#</p>
</cfcatch>
</cftry>

<h2>Working with Available Data:</h2>
<p>While we solve the ghost_prod access, you can work with posts in cc_prod:</p>
<p><a href="post-comparison-tool.cfm?action=list" style="background: ##4caf50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">View All Available Posts</a></p>

</cfoutput>