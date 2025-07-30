<!--- Check posts table structure --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Get column information from posts table --->
    <cfquery name="qColumns" datasource="#request.dsn#">
        SHOW COLUMNS FROM posts
    </cfquery>
    
    <!DOCTYPE html>
    <html>
    <head>
        <title>Posts Table Structure</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            table { border-collapse: collapse; width: 100%; margin-top: 20px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            .missing { background-color: #ffcccc; }
            .exists { background-color: #ccffcc; }
            .new-field { font-weight: bold; color: #0066cc; }
        </style>
    </head>
    <body>
        <h1>Posts Table Structure - Blog Database</h1>
        
        <h2>Current Columns:</h2>
        <table>
            <tr>
                <th>Field</th>
                <th>Type</th>
                <th>Null</th>
                <th>Key</th>
                <th>Default</th>
                <th>Extra</th>
            </tr>
            <cfoutput query="qColumns">
                <tr>
                    <td>#Field#</td>
                    <td>#Type#</td>
                    <td>#Null#</td>
                    <td>#Key#</td>
                    <td><cfif len(Default)>#Default#<cfelse><em>NULL</em></cfif></td>
                    <td>#Extra#</td>
                </tr>
            </cfoutput>
        </table>
        
        <!--- Check for specific fields --->
        <cfset fieldsToCheck = ["lexical", "show_title_and_feature_image", "comment_id"]>
        <cfset existingFields = valueList(qColumns.Field)>
        
        <h2>Ghost Fields Check:</h2>
        <table>
            <tr>
                <th>Field Name</th>
                <th>Status</th>
                <th>Ghost Schema Type</th>
                <th>Recommended SQL Type</th>
            </tr>
            <cfloop array="#fieldsToCheck#" index="fieldName">
                <cfset exists = listFindNoCase(existingFields, fieldName)>
                <tr class="<cfif exists>exists<cfelse>missing</cfif>">
                    <td class="new-field">#fieldName#</td>
                    <td><cfif exists>✓ EXISTS<cfelse>✗ MISSING</cfif></td>
                    <td>
                        <cfif fieldName EQ "lexical">
                            text (maxlength: 1000000000, fieldtype: 'long')
                        <cfelseif fieldName EQ "show_title_and_feature_image">
                            boolean (defaultTo: true)
                        <cfelseif fieldName EQ "comment_id">
                            string (maxlength: 50)
                        </cfif>
                    </td>
                    <td>
                        <cfif fieldName EQ "lexical">
                            LONGTEXT
                        <cfelseif fieldName EQ "show_title_and_feature_image">
                            BOOLEAN DEFAULT 1
                        <cfelseif fieldName EQ "comment_id">
                            VARCHAR(50)
                        </cfif>
                    </td>
                </tr>
            </cfloop>
        </table>
        
        <cfif NOT listFindNoCase(existingFields, "lexical") OR NOT listFindNoCase(existingFields, "show_title_and_feature_image") OR NOT listFindNoCase(existingFields, "comment_id")>
            <h2>SQL Script to Add Missing Fields:</h2>
            <pre style="background: #f5f5f5; padding: 15px; border: 1px solid #ddd;">
ALTER TABLE posts
<cfif NOT listFindNoCase(existingFields, "lexical")>    ADD COLUMN lexical LONGTEXT NULL AFTER mobiledoc<cfif NOT listFindNoCase(existingFields, "show_title_and_feature_image") OR NOT listFindNoCase(existingFields, "comment_id")>,</cfif></cfif>
<cfif NOT listFindNoCase(existingFields, "show_title_and_feature_image")>    ADD COLUMN show_title_and_feature_image BOOLEAN NOT NULL DEFAULT 1<cfif NOT listFindNoCase(existingFields, "comment_id")>,</cfif></cfif>
<cfif NOT listFindNoCase(existingFields, "comment_id")>    ADD COLUMN comment_id VARCHAR(50) NULL</cfif>;
            </pre>
            
            <p><strong>Note:</strong> Run this SQL script in your MySQL database to add the missing fields.</p>
        <cfelse>
            <p style="color: green; font-weight: bold;">✓ All Ghost fields are already present in the database!</p>
        </cfif>
        
        <h2>Additional Information:</h2>
        <ul>
            <li><strong>lexical:</strong> Stores content in Lexical editor format (newer Ghost editor)</li>
            <li><strong>show_title_and_feature_image:</strong> Controls whether to display title and feature image in the post</li>
            <li><strong>comment_id:</strong> Links posts to their comment threads</li>
        </ul>
        
    </body>
    </html>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>Error checking table structure: #cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>