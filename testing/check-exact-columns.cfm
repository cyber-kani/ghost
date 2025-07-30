<!--- Check exact column names --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <cfquery name="qAllColumns" datasource="#request.dsn#">
        SHOW COLUMNS FROM posts
    </cfquery>
    
    <!DOCTYPE html>
    <html>
    <head>
        <title>Exact Column Names</title>
        <style>
            body { font-family: monospace; margin: 20px; }
            .ghost-field { background: #e3f2fd; font-weight: bold; }
            table { border-collapse: collapse; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background: #f2f2f2; }
        </style>
    </head>
    <body>
        <h1>Exact Column Names in posts table</h1>
        
        <table>
            <tr>
                <th>Field Name</th>
                <th>Type</th>
                <th>Is Ghost Field?</th>
            </tr>
            <cfoutput query="qAllColumns">
                <cfset isGhostField = listFindNoCase("lexical,show_title_and_feature_image,comment_id", Field)>
                <tr <cfif isGhostField>class="ghost-field"</cfif>>
                    <td>#Field#</td>
                    <td>#Type#</td>
                    <td><cfif isGhostField>YES - Ghost Field</cfif></td>
                </tr>
            </cfoutput>
        </table>
        
        <h2>Quick Test - Direct SQL Update</h2>
        <p>Try this SQL directly in your database:</p>
        <pre>
UPDATE posts 
SET show_title_and_feature_image = 0,
    lexical = '{"test": "data"}',
    comment_id = 'test_123'
WHERE id = (SELECT id FROM posts ORDER BY created_at DESC LIMIT 1);
        </pre>
        
        <p>Then check if it worked:</p>
        <pre>
SELECT id, title, show_title_and_feature_image, lexical, comment_id 
FROM posts 
ORDER BY created_at DESC 
LIMIT 1;
        </pre>
        
    </body>
    </html>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>#cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>