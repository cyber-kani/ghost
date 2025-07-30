<!--- Verify Ghost Fields Exist in Database --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if fields exist --->
    <cfquery name="qColumns" datasource="#request.dsn#">
        SHOW COLUMNS FROM posts 
        WHERE Field IN ('lexical', 'show_title_and_feature_image', 'comment_id')
    </cfquery>
    
    <!--- Get a sample of recent posts to check values --->
    <cfquery name="qRecentPosts" datasource="#request.dsn#">
        SELECT id, title, created_at,
               <cfif listFindNoCase(valueList(qColumns.Field), "show_title_and_feature_image")>
                   show_title_and_feature_image,
               <cfelse>
                   NULL as show_title_and_feature_image,
               </cfif>
               <cfif listFindNoCase(valueList(qColumns.Field), "lexical")>
                   CASE WHEN lexical IS NULL THEN 'NULL' 
                        WHEN LENGTH(lexical) = 0 THEN 'EMPTY' 
                        ELSE CONCAT('LENGTH: ', LENGTH(lexical)) 
                   END as lexical_info,
               <cfelse>
                   'FIELD NOT EXISTS' as lexical_info,
               </cfif>
               <cfif listFindNoCase(valueList(qColumns.Field), "comment_id")>
                   comment_id
               <cfelse>
                   'FIELD NOT EXISTS' as comment_id
               </cfif>
        FROM posts
        ORDER BY created_at DESC
        LIMIT 10
    </cfquery>
    
    <!DOCTYPE html>
    <html>
    <head>
        <title>Verify Ghost Fields</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .exists { background: #d4edda; color: #155724; padding: 10px; margin: 5px 0; }
            .missing { background: #f8d7da; color: #721c24; padding: 10px; margin: 5px 0; }
            table { border-collapse: collapse; width: 100%; margin-top: 20px; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background: #f2f2f2; }
            .null { color: #999; font-style: italic; }
            .empty { color: #ff9800; }
            .field-missing { background: #ffebee; }
        </style>
    </head>
    <body>
        <h1>Ghost Fields Verification</h1>
        
        <h2>1. Field Existence Check:</h2>
        <cfset expectedFields = ["lexical", "show_title_and_feature_image", "comment_id"]>
        <cfset existingFields = valueList(qColumns.Field)>
        
        <cfloop array="#expectedFields#" index="field">
            <cfif listFindNoCase(existingFields, field)>
                <div class="exists">✓ Field '<strong>#field#</strong>' EXISTS in database</div>
            <cfelse>
                <div class="missing">✗ Field '<strong>#field#</strong>' is MISSING from database</div>
            </cfif>
        </cfloop>
        
        <cfif qColumns.recordCount LT 3>
            <div class="missing" style="margin-top: 20px;">
                <strong>⚠️ Not all fields exist!</strong><br>
                Please run the migration tool first: <a href="/ghost/testing/migrate-ghost-fields.cfm">/ghost/testing/migrate-ghost-fields.cfm</a>
            </div>
        </cfif>
        
        <h2>2. Field Details:</h2>
        <cfif qColumns.recordCount GT 0>
            <table>
                <tr>
                    <th>Field</th>
                    <th>Type</th>
                    <th>Null</th>
                    <th>Key</th>
                    <th>Default</th>
                </tr>
                <cfoutput query="qColumns">
                <tr>
                    <td><strong>#Field#</strong></td>
                    <td>#Type#</td>
                    <td>#Null#</td>
                    <td>#Key#</td>
                    <td><cfif len(Default)>#Default#<cfelse><span class="null">NULL</span></cfif></td>
                </tr>
                </cfoutput>
            </table>
        </cfif>
        
        <h2>3. Recent Posts Data:</h2>
        <cfif qRecentPosts.recordCount GT 0>
            <table>
                <tr>
                    <th>Post ID</th>
                    <th>Title</th>
                    <th>Created</th>
                    <th>show_title_and_feature_image</th>
                    <th>lexical</th>
                    <th>comment_id</th>
                </tr>
                <cfoutput query="qRecentPosts">
                <tr>
                    <td>#id#</td>
                    <td>#left(title, 30)#<cfif len(title) GT 30>...</cfif></td>
                    <td>#dateFormat(created_at, "mm/dd/yyyy")#</td>
                    <td <cfif show_title_and_feature_image EQ "FIELD NOT EXISTS">class="field-missing"</cfif>>
                        <cfif isBoolean(show_title_and_feature_image)>
                            #show_title_and_feature_image ? "✓ Yes" : "✗ No"#
                        <cfelse>
                            #show_title_and_feature_image#
                        </cfif>
                    </td>
                    <td <cfif lexical_info EQ "FIELD NOT EXISTS">class="field-missing"</cfif>>
                        <cfif lexical_info EQ "NULL">
                            <span class="null">NULL</span>
                        <cfelseif lexical_info EQ "EMPTY">
                            <span class="empty">EMPTY</span>
                        <cfelse>
                            #lexical_info#
                        </cfif>
                    </td>
                    <td <cfif comment_id EQ "FIELD NOT EXISTS">class="field-missing"</cfif>>
                        <cfif comment_id EQ "FIELD NOT EXISTS">
                            #comment_id#
                        <cfelseif len(comment_id)>
                            #comment_id#
                        <cfelse>
                            <span class="null">NULL</span>
                        </cfif>
                    </td>
                </tr>
                </cfoutput>
            </table>
        <cfelse>
            <p>No posts found in database.</p>
        </cfif>
        
        <h2>4. Quick Actions:</h2>
        <ul>
            <li><a href="/ghost/testing/migrate-ghost-fields.cfm">Run Migration Tool</a></li>
            <li><a href="/ghost/testing/check-posts-structure.cfm">Check Full Table Structure</a></li>
            <li><a href="/ghost/admin/posts/new.cfm">Create New Post</a></li>
        </ul>
        
    </body>
    </html>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p style="color: red;">Error: #cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>