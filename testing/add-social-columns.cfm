<!DOCTYPE html>
<html>
<head>
    <title>Add Social Media Columns</title>
</head>
<body>
    <h1>Adding Social Media Columns to Posts Table</h1>
    
    <cftry>
        <!--- Add social media columns if they don't exist --->
        <cfset columnsToAdd = [
            {name: "meta_title", type: "VARCHAR(255)", default: "NULL"},
            {name: "meta_description", type: "TEXT", default: "NULL"},
            {name: "og_image", type: "VARCHAR(2000)", default: "NULL"},
            {name: "og_title", type: "VARCHAR(255)", default: "NULL"},
            {name: "og_description", type: "TEXT", default: "NULL"},
            {name: "twitter_image", type: "VARCHAR(2000)", default: "NULL"},
            {name: "twitter_title", type: "VARCHAR(255)", default: "NULL"},
            {name: "twitter_description", type: "TEXT", default: "NULL"}
        ]>
        
        <cfloop array="#columnsToAdd#" index="col">
            <cftry>
                <cfquery datasource="blog">
                    ALTER TABLE posts ADD COLUMN #col.name# #col.type# DEFAULT #col.default#
                </cfquery>
                <p style="color: green;">✓ Added column: <cfoutput>#col.name#</cfoutput></p>
                
                <cfcatch>
                    <cfif cfcatch.message contains "Duplicate column">
                        <p style="color: blue;">ℹ Column already exists: <cfoutput>#col.name#</cfoutput></p>
                    <cfelse>
                        <p style="color: red;">✗ Error adding column <cfoutput>#col.name#: #cfcatch.message#</cfoutput></p>
                    </cfif>
                </cfcatch>
            </cftry>
        </cfloop>
        
        <h2>Final Table Structure:</h2>
        <cfquery name="qColumns" datasource="blog">
            SHOW COLUMNS FROM posts
        </cfquery>
        
        <table border="1">
            <tr>
                <th>Field</th>
                <th>Type</th>
                <th>Null</th>
                <th>Default</th>
            </tr>
            <cfloop query="qColumns">
                <cfif listFindNoCase("meta_title,meta_description,og_image,og_title,og_description,twitter_image,twitter_title,twitter_description", Field)>
                    <tr style="background-color: #e8f5e9;">
                <cfelse>
                    <tr>
                </cfif>
                    <td><cfoutput>#Field#</cfoutput></td>
                    <td><cfoutput>#Type#</cfoutput></td>
                    <td><cfoutput>#Null#</cfoutput></td>
                    <td><cfoutput>#Default#</cfoutput></td>
                </tr>
            </cfloop>
        </table>
        
        <p style="color: green; font-weight: bold;">✓ Social media columns are ready!</p>
        
        <cfcatch>
            <h2 style="color: red;">Error:</h2>
            <pre><cfoutput>#cfcatch.message#
#cfcatch.detail#</cfoutput></pre>
        </cfcatch>
    </cftry>
</body>
</html>