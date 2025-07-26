<!DOCTYPE html>
<html>
<head>
    <title>Check Social Media Columns</title>
</head>
<body>
    <h1>Checking Posts Table Structure</h1>
    
    <cftry>
        <!--- Get column information --->
        <cfquery name="qColumns" datasource="blog">
            SHOW COLUMNS FROM posts
        </cfquery>
        
        <h2>Posts Table Columns:</h2>
        <table border="1">
            <tr>
                <th>Field</th>
                <th>Type</th>
                <th>Null</th>
                <th>Key</th>
                <th>Default</th>
                <th>Extra</th>
            </tr>
            <cfloop query="qColumns">
                <tr>
                    <td><cfoutput>#Field#</cfoutput></td>
                    <td><cfoutput>#Type#</cfoutput></td>
                    <td><cfoutput>#Null#</cfoutput></td>
                    <td><cfoutput>#Key#</cfoutput></td>
                    <td><cfoutput>#Default#</cfoutput></td>
                    <td><cfoutput>#Extra#</cfoutput></td>
                </tr>
            </cfloop>
        </table>
        
        <!--- Check for social media columns --->
        <h2>Social Media Columns Check:</h2>
        <cfset socialColumns = ["og_image", "og_title", "og_description", "twitter_image", "twitter_title", "twitter_description"]>
        <cfset existingColumns = valueList(qColumns.Field)>
        
        <ul>
            <cfloop array="#socialColumns#" index="col">
                <li>
                    <cfoutput>#col#: 
                        <cfif listFindNoCase(existingColumns, col)>
                            <span style="color: green;">✓ EXISTS</span>
                        <cfelse>
                            <span style="color: red;">✗ MISSING</span>
                        </cfif>
                    </cfoutput>
                </li>
            </cfloop>
        </ul>
        
        <!--- Check if posts_meta table exists --->
        <h2>Posts Meta Table Check:</h2>
        <cfquery name="qMeta" datasource="blog">
            SHOW TABLES LIKE 'posts_meta'
        </cfquery>
        
        <cfif qMeta.recordCount>
            <p style="color: green;">posts_meta table exists</p>
            
            <cfquery name="qMetaColumns" datasource="blog">
                SHOW COLUMNS FROM posts_meta
            </cfquery>
            
            <table border="1">
                <tr>
                    <th>Field</th>
                    <th>Type</th>
                </tr>
                <cfloop query="qMetaColumns">
                    <tr>
                        <td><cfoutput>#Field#</cfoutput></td>
                        <td><cfoutput>#Type#</cfoutput></td>
                    </tr>
                </cfloop>
            </table>
        <cfelse>
            <p style="color: red;">posts_meta table does not exist</p>
        </cfif>
        
        <cfcatch>
            <h2 style="color: red;">Error:</h2>
            <pre><cfoutput>#cfcatch.message#
#cfcatch.detail#</cfoutput></pre>
        </cfcatch>
    </cftry>
</body>
</html>