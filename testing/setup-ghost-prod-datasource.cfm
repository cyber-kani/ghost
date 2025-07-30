<!--- Setup ghost_prod datasource --->
<cfoutput>
<h1>Ghost_prod Database Setup Instructions</h1>

<h2>Current Datasources Available:</h2>
<p>Currently available datasources: <strong>blog</strong> and <strong>yalulife</strong></p>

<h2>To add ghost_prod datasource:</h2>

<div style="background: ##e3f2fd; padding: 20px; border: 1px solid ##2196f3; margin: 20px 0;">
    <h3>Option 1: Add to Application.cfc</h3>
    <p>Add this to your Application.cfc in the onApplicationStart() method:</p>
    <pre style="background: ##f5f5f5; padding: 15px;">
&lt;cfset this.datasources["ghost_prod"] = {
    class: 'com.mysql.jdbc.Driver',
    connectionString: 'jdbc:mysql://localhost:3306/ghost_prod?useUnicode=true&characterEncoding=UTF-8',
    username: 'your_mysql_username',
    password: 'your_mysql_password'
}&gt;
    </pre>
</div>

<div style="background: ##e8f5e9; padding: 20px; border: 1px solid ##4caf50; margin: 20px 0;">
    <h3>Option 2: Create Datasource Alias</h3>
    <p>If ghost_prod is the same database as one of the existing datasources, you can create an alias:</p>
    <pre style="background: ##f5f5f5; padding: 15px;">
&lt;!--- In your Application.cfc or a config file ---&gt;
&lt;cfset request.ghost_prod_dsn = "blog"&gt;
&lt;!--- Then use: datasource="##request.ghost_prod_dsn##" ---&gt;
    </pre>
</div>

<div style="background: ##fff3e0; padding: 20px; border: 1px solid ##ff9800; margin: 20px 0;">
    <h3>Option 3: ColdFusion/Lucee Admin Panel</h3>
    <ol>
        <li>Log into your ColdFusion/Lucee Administrator</li>
        <li>Navigate to Data & Services > Datasources</li>
        <li>Add New Datasource:
            <ul>
                <li>Name: <strong>ghost_prod</strong></li>
                <li>Driver: MySQL 5</li>
                <li>Server: localhost (or your MySQL server)</li>
                <li>Port: 3306</li>
                <li>Database: ghost_prod</li>
                <li>Username: [your MySQL username]</li>
                <li>Password: [your MySQL password]</li>
            </ul>
        </li>
        <li>Test and Save the connection</li>
    </ol>
</div>

<h2>Test the Connection:</h2>
<p>Once configured, you can test with:</p>
<pre style="background: ##f5f5f5; padding: 15px;">
&lt;cftry&gt;
    &lt;cfquery name="qTest" datasource="ghost_prod"&gt;
        SELECT COUNT(*) as post_count FROM posts
    &lt;/cfquery&gt;
    &lt;p&gt;Success! Found &lt;cfoutput&gt;##qTest.post_count##&lt;/cfoutput&gt; posts&lt;/p&gt;
&lt;cfcatch&gt;
    &lt;p&gt;Error: &lt;cfoutput&gt;##cfcatch.message##&lt;/cfoutput&gt;&lt;/p&gt;
&lt;/cfcatch&gt;
&lt;/cftry&gt;
</pre>

<h2>Important Notes:</h2>
<ul>
    <li>The datasource name "ghost_prod" needs to be configured at the server level</li>
    <li>Make sure the MySQL user has proper permissions to the ghost_prod database</li>
    <li>The database connection details depend on your specific server setup</li>
</ul>

</cfoutput>