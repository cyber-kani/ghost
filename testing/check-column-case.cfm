<!--- Check Column Name Case Sensitivity --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <cfquery name="qColumns" datasource="#request.dsn#">
        SELECT 
            COLUMN_NAME,
            DATA_TYPE,
            IS_NULLABLE,
            COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'posts'
        AND COLUMN_NAME IN ('lexical', 'LEXICAL', 'show_title_and_feature_image', 'SHOW_TITLE_AND_FEATURE_IMAGE', 'comment_id', 'COMMENT_ID')
    </cfquery>
    
    <!DOCTYPE html>
    <html>
    <head>
        <title>Column Name Case Check</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .important { background: #fff3cd; padding: 15px; margin: 20px 0; border: 1px solid #ffeeba; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background: #f2f2f2; }
            .exact-name { font-family: monospace; font-size: 14px; background: #e3f2fd; padding: 2px 5px; }
        </style>
    </head>
    <body>
        <h1>Column Name Case Sensitivity Check</h1>
        
        <cfif qColumns.recordCount GT 0>
            <div class="important">
                <h2>⚠️ Important: Exact Column Names Found</h2>
                <p>MySQL column names can be case-sensitive depending on the server configuration. Here are the exact names:</p>
            </div>
            
            <table>
                <tr>
                    <th>Exact Column Name</th>
                    <th>Data Type</th>
                    <th>Nullable</th>
                    <th>Default</th>
                </tr>
                <cfoutput query="qColumns">
                <tr>
                    <td class="exact-name">#COLUMN_NAME#</td>
                    <td>#DATA_TYPE#</td>
                    <td>#IS_NULLABLE#</td>
                    <td><cfif len(COLUMN_DEFAULT)>#COLUMN_DEFAULT#<cfelse>NULL</cfif></td>
                </tr>
                </cfoutput>
            </table>
            
            <h2>Quick Test with Exact Names</h2>
            <cfset testId = "case_test_" & left(replace(createUUID(), "-", "", "all"), 12)>
            
            <cftry>
                <!--- Try insert with exact column names from database --->
                <cfquery datasource="#request.dsn#">
                    INSERT INTO posts (
                        id, uuid, title, slug, html, plaintext,
                        type, status, created_at, updated_at,
                        email_recipient_filter, created_by
                        <cfloop query="qColumns">
                            <cfif COLUMN_NAME EQ "show_title_and_feature_image">
                                , `show_title_and_feature_image`
                            <cfelseif COLUMN_NAME EQ "lexical">
                                , `lexical`
                            <cfelseif COLUMN_NAME EQ "comment_id">
                                , `comment_id`
                            </cfif>
                        </cfloop>
                    ) VALUES (
                        <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="Case Sensitivity Test" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="case-test" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="<p>Test</p>" cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="Test" cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="post" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="draft" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="all" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
                        <cfloop query="qColumns">
                            <cfif COLUMN_NAME EQ "show_title_and_feature_image">
                                , <cfqueryparam value="0" cfsqltype="cf_sql_bit">
                            <cfelseif COLUMN_NAME EQ "lexical">
                                , <cfqueryparam value='{"case":"test"}' cfsqltype="cf_sql_longvarchar">
                            <cfelseif COLUMN_NAME EQ "comment_id">
                                , <cfqueryparam value="case_test_123" cfsqltype="cf_sql_varchar">
                            </cfif>
                        </cfloop>
                    )
                </cfquery>
                
                <p style="color: green;">✓ INSERT with exact column names successful!</p>
                
                <!--- Clean up --->
                <cfquery datasource="#request.dsn#">
                    DELETE FROM posts WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
            <cfcatch>
                <p style="color: red;">✗ INSERT failed: #cfcatch.message#</p>
            </cfcatch>
            </cftry>
            
        <cfelse>
            <p style="color: red;">No Ghost fields found! This suggests they might have different names or don't exist.</p>
        </cfif>
        
        <h2>Alternative Check - Using SHOW COLUMNS</h2>
        <cfquery name="qShowColumns" datasource="#request.dsn#">
            SHOW COLUMNS FROM posts
            WHERE Field IN ('lexical', 'show_title_and_feature_image', 'comment_id', 
                           'LEXICAL', 'SHOW_TITLE_AND_FEATURE_IMAGE', 'COMMENT_ID')
        </cfquery>
        
        <cfif qShowColumns.recordCount GT 0>
            <p>SHOW COLUMNS found these fields:</p>
            <ul>
                <cfoutput query="qShowColumns">
                    <li class="exact-name">#Field#</li>
                </cfoutput>
            </ul>
        </cfif>
        
    </body>
    </html>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>#cfcatch.message#</p>
    </cfoutput>
</cfcatch>
</cftry>