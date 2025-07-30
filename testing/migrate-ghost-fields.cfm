<!--- Migrate Ghost Fields to Blog Database --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Ghost Fields Migration</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; max-width: 800px; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .info { background: #d1ecf1; color: #0c5460; padding: 15px; border-radius: 5px; margin: 10px 0; }
        .warning { background: #fff3cd; color: #856404; padding: 15px; border-radius: 5px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 15px; border: 1px solid #ddd; overflow-x: auto; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #0056b3; }
        .field-check { margin: 10px 0; padding: 10px; background: #f8f9fa; border-left: 4px solid #dee2e6; }
        .field-exists { border-left-color: #28a745; }
        .field-missing { border-left-color: #dc3545; }
    </style>
</head>
<body>
    <h1>Ghost Fields Migration Tool</h1>
    
    <cfif url.action EQ "">
        <!--- Check current status --->
        <cftry>
            <cfquery name="qColumns" datasource="#request.dsn#">
                SHOW COLUMNS FROM posts
            </cfquery>
            
            <cfset existingFields = valueList(qColumns.Field)>
            <cfset hasLexical = listFindNoCase(existingFields, "lexical")>
            <cfset hasShowTitle = listFindNoCase(existingFields, "show_title_and_feature_image")>
            <cfset hasCommentId = listFindNoCase(existingFields, "comment_id")>
            
            <h2>Current Status:</h2>
            
            <div class="field-check <cfif hasLexical>field-exists<cfelse>field-missing</cfif>">
                <strong>lexical field:</strong> 
                <cfif hasLexical>
                    ✓ EXISTS
                <cfelse>
                    ✗ MISSING - Will store Lexical editor content (Ghost's new editor format)
                </cfif>
            </div>
            
            <div class="field-check <cfif hasShowTitle>field-exists<cfelse>field-missing</cfif>">
                <strong>show_title_and_feature_image field:</strong> 
                <cfif hasShowTitle>
                    ✓ EXISTS
                <cfelse>
                    ✗ MISSING - Controls display of title and feature image
                </cfif>
            </div>
            
            <div class="field-check <cfif hasCommentId>field-exists<cfelse>field-missing</cfif>">
                <strong>comment_id field:</strong> 
                <cfif hasCommentId>
                    ✓ EXISTS
                <cfelse>
                    ✗ MISSING - Links posts to comment threads
                </cfif>
            </div>
            
            <cfif NOT hasLexical OR NOT hasShowTitle OR NOT hasCommentId>
                <h2>Migration Required</h2>
                <p>The following SQL commands will be executed to add the missing fields:</p>
                
                <pre>
ALTER TABLE posts
<cfif NOT hasLexical>    ADD COLUMN lexical LONGTEXT NULL COMMENT 'Lexical editor content'<cfif NOT hasShowTitle OR NOT hasCommentId>,</cfif></cfif>
<cfif NOT hasShowTitle>    ADD COLUMN show_title_and_feature_image BOOLEAN NOT NULL DEFAULT 1 COMMENT 'Display title and feature image'<cfif NOT hasCommentId>,</cfif></cfif>
<cfif NOT hasCommentId>    ADD COLUMN comment_id VARCHAR(50) NULL COMMENT 'Comment thread identifier'</cfif>;
                </pre>
                
                <form method="post" action="?action=migrate">
                    <button type="submit" onclick="return confirm('Are you sure you want to add these fields to the posts table?')">
                        Execute Migration
                    </button>
                </form>
                
                <div class="warning">
                    <strong>Note:</strong> This will modify the posts table structure. Make sure to backup your database before proceeding.
                </div>
            <cfelse>
                <div class="success">
                    <strong>✓ All Ghost fields are already present!</strong><br>
                    No migration needed.
                </div>
            </cfif>
            
        <cfcatch>
            <div class="error">
                <strong>Error checking database:</strong><br>
                #cfcatch.message#<br>
                #cfcatch.detail#
            </div>
        </cfcatch>
        </cftry>
        
    <cfelseif url.action EQ "migrate">
        <!--- Execute migration --->
        <h2>Executing Migration...</h2>
        
        <cftry>
            <!--- First check what needs to be added --->
            <cfquery name="qColumns" datasource="#request.dsn#">
                SHOW COLUMNS FROM posts
            </cfquery>
            
            <cfset existingFields = valueList(qColumns.Field)>
            <cfset hasLexical = listFindNoCase(existingFields, "lexical")>
            <cfset hasShowTitle = listFindNoCase(existingFields, "show_title_and_feature_image")>
            <cfset hasCommentId = listFindNoCase(existingFields, "comment_id")>
            
            <cfset migrationsNeeded = []>
            <cfset migrationsCompleted = []>
            
            <!--- Add lexical field --->
            <cfif NOT hasLexical>
                <cftry>
                    <cfquery datasource="#request.dsn#">
                        ALTER TABLE posts 
                        ADD COLUMN lexical LONGTEXT NULL COMMENT 'Lexical editor content'
                        AFTER mobiledoc
                    </cfquery>
                    <cfset arrayAppend(migrationsCompleted, "✓ Added 'lexical' field")>
                <cfcatch>
                    <cfset arrayAppend(migrationsNeeded, "✗ Failed to add 'lexical' field: #cfcatch.message#")>
                </cfcatch>
                </cftry>
            </cfif>
            
            <!--- Add show_title_and_feature_image field --->
            <cfif NOT hasShowTitle>
                <cftry>
                    <cfquery datasource="#request.dsn#">
                        ALTER TABLE posts 
                        ADD COLUMN show_title_and_feature_image BOOLEAN NOT NULL DEFAULT 1 
                        COMMENT 'Display title and feature image'
                    </cfquery>
                    <cfset arrayAppend(migrationsCompleted, "✓ Added 'show_title_and_feature_image' field")>
                <cfcatch>
                    <cfset arrayAppend(migrationsNeeded, "✗ Failed to add 'show_title_and_feature_image' field: #cfcatch.message#")>
                </cfcatch>
                </cftry>
            </cfif>
            
            <!--- Add comment_id field --->
            <cfif NOT hasCommentId>
                <cftry>
                    <cfquery datasource="#request.dsn#">
                        ALTER TABLE posts 
                        ADD COLUMN comment_id VARCHAR(50) NULL 
                        COMMENT 'Comment thread identifier'
                    </cfquery>
                    <cfset arrayAppend(migrationsCompleted, "✓ Added 'comment_id' field")>
                <cfcatch>
                    <cfset arrayAppend(migrationsNeeded, "✗ Failed to add 'comment_id' field: #cfcatch.message#")>
                </cfcatch>
                </cftry>
            </cfif>
            
            <!--- Display results --->
            <cfif arrayLen(migrationsCompleted) GT 0>
                <div class="success">
                    <h3>Migrations Completed:</h3>
                    <cfloop array="#migrationsCompleted#" index="msg">
                        <cfoutput>#msg#<br></cfoutput>
                    </cfloop>
                </div>
            </cfif>
            
            <cfif arrayLen(migrationsNeeded) GT 0>
                <div class="error">
                    <h3>Migrations Failed:</h3>
                    <cfloop array="#migrationsNeeded#" index="msg">
                        <cfoutput>#msg#<br></cfoutput>
                    </cfloop>
                </div>
            </cfif>
            
            <cfif arrayLen(migrationsCompleted) GT 0 AND arrayLen(migrationsNeeded) EQ 0>
                <div class="info">
                    <strong>Migration completed successfully!</strong><br>
                    All Ghost fields have been added to the posts table.
                </div>
            </cfif>
            
            <p><a href="?">← Back to Status Check</a></p>
            
        <cfcatch>
            <div class="error">
                <strong>Migration Error:</strong><br>
                #cfcatch.message#<br>
                #cfcatch.detail#
            </div>
        </cfcatch>
        </cftry>
    </cfif>
    
    <hr style="margin-top: 40px;">
    
    <h2>Field Information:</h2>
    <ul>
        <li>
            <strong>lexical:</strong> 
            <ul>
                <li>Type: LONGTEXT (can store up to 4GB of text)</li>
                <li>Purpose: Stores content in Lexical editor format</li>
                <li>Ghost's new editor that replaces Mobiledoc</li>
            </ul>
        </li>
        <li>
            <strong>show_title_and_feature_image:</strong>
            <ul>
                <li>Type: BOOLEAN (1 or 0)</li>
                <li>Default: 1 (true)</li>
                <li>Purpose: Controls whether the post title and feature image are displayed</li>
            </ul>
        </li>
        <li>
            <strong>comment_id:</strong>
            <ul>
                <li>Type: VARCHAR(50)</li>
                <li>Purpose: Unique identifier linking posts to their comment threads</li>
                <li>Can be used for integrating with commenting systems</li>
            </ul>
        </li>
    </ul>
    
    <p><a href="/ghost/testing/">← Back to Testing Tools</a></p>
</body>
</html>