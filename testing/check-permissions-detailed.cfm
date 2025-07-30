<!--- Detailed permissions check --->
<cfoutput>
<h1>Detailed Permissions Check</h1>

<h2>1. Check current user and host:</h2>
<cftry>
    <cfquery name="qUser" datasource="blog">
        SELECT 
            USER() as full_user,
            CURRENT_USER() as current_user,
            DATABASE() as current_db
    </cfquery>
    <div style="background: ##f5f5f5; padding: 15px;">
        <p><strong>Full User:</strong> #qUser.full_user#</p>
        <p><strong>Current User:</strong> #qUser.current_user#</p>
        <p><strong>Current Database:</strong> #qUser.current_db#</p>
    </div>
<cfcatch>
    <p>Error getting user info: #cfcatch.message#</p>
</cfcatch>
</cftry>

<h2>2. Show current grants:</h2>
<cftry>
    <cfquery name="qGrants" datasource="blog">
        SHOW GRANTS FOR CURRENT_USER()
    </cfquery>
    <div style="background: ##e8f5e9; padding: 15px;">
        <h3>Current User Grants:</h3>
        <cfloop query="qGrants">
            <pre style="background: ##263238; color: ##fff; padding: 10px;">#qGrants[columnList]#</pre>
        </cfloop>
    </div>
<cfcatch>
    <p>Error getting grants: #cfcatch.message#</p>
</cfcatch>
</cftry>

<h2>3. Check if ghost_prod exists:</h2>
<cftry>
    <cfquery name="qCheckDB" datasource="blog">
        SELECT SCHEMA_NAME 
        FROM INFORMATION_SCHEMA.SCHEMATA 
        WHERE SCHEMA_NAME = 'ghost_prod'
    </cfquery>
    <cfif qCheckDB.recordCount GT 0>
        <p style="color: green;"><strong>✓ ghost_prod database EXISTS</strong></p>
    <cfelse>
        <p style="color: red;"><strong>✗ ghost_prod database NOT FOUND</strong></p>
    </cfif>
<cfcatch>
    <p>Could not check database existence</p>
</cfcatch>
</cftry>

<h2>4. Alternative: Create a new datasource</h2>
<div style="background: ##fff3e0; padding: 20px; border: 1px solid ##ff9800;">
    <h3>If ghost_prod exists but permissions aren't working:</h3>
    <p>You might need to:</p>
    <ol>
        <li><strong>Create a new MySQL user</strong> specifically for ghost_prod:
            <pre style="background: ##263238; color: ##aed581; padding: 10px;">
CREATE USER 'ghost_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON ghost_prod.* TO 'ghost_user'@'localhost';
FLUSH PRIVILEGES;</pre>
        </li>
        <li><strong>Add a new datasource</strong> in ColdFusion/Lucee Admin with this new user</li>
    </ol>
</div>

<h2>5. Workaround - Export/Import:</h2>
<div style="background: ##e3f2fd; padding: 20px; border: 1px solid ##2196f3;">
    <h3>If you have access to ghost_prod through another method:</h3>
    <p>Export the specific post and import it:</p>
    <pre style="background: ##263238; color: ##aed581; padding: 10px;">
# Export from ghost_prod (run where you have access)
mysqldump -u root -p ghost_prod posts --where="id='688a02858edd034b578322f0'" > ghost_post.sql

# Import to cc_prod
mysql -u root -p cc_prod < ghost_post.sql</pre>
</div>

<h2>6. Manual Copy Option:</h2>
<p>If you can access the ghost_prod database through phpMyAdmin or another tool:</p>
<ol>
    <li>Find the post with ID: 688a02858edd034b578322f0</li>
    <li>Export just that row</li>
    <li>I can help you import it into cc_prod</li>
</ol>

<h2>Current Status:</h2>
<div style="background: ##ffebee; padding: 20px; border: 1px solid ##f44336;">
    <p><strong>Problem:</strong> CFML user cannot access ghost_prod database</p>
    <p><strong>Likely causes:</strong></p>
    <ul>
        <li>The GRANT command wasn't run as MySQL root</li>
        <li>The GRANT was for a different host (not 'localhost')</li>
        <li>The database name is different</li>
        <li>MySQL service needs restart after grants</li>
    </ul>
</div>

</cfoutput>