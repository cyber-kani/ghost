<!--- Direct Database Test --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Direct Database Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { background: #d4edda; padding: 15px; margin: 10px 0; }
        .error { background: #f8d7da; padding: 15px; margin: 10px 0; }
        .info { background: #d1ecf1; padding: 15px; margin: 10px 0; }
        pre { background: #f5f5f5; padding: 10px; border: 1px solid #ddd; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
    </style>
</head>
<body>
    <h1>Direct Database Test</h1>
    
    <cfif url.action EQ "">
        <div class="info">
            <p>This test bypasses the AJAX handler and tests the database directly.</p>
        </div>
        
        <form method="post" action="?action=test">
            <button type="submit">Run Direct Database Test</button>
        </form>
        
    <cfelseif url.action EQ "test">
        <cfset testId = left(replace(createUUID(), "-", "", "all"), 24)>
        <cfset testTime = dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss")>
        
        <h2>Test 1: Direct INSERT with all Ghost fields</h2>
        
        <cftry>
            <cfquery datasource="#request.dsn#">
                INSERT INTO posts (
                    id, uuid, title, slug, html, plaintext,
                    type, status, created_at, updated_at,
                    email_recipient_filter, created_by,
                    show_title_and_feature_image,
                    lexical,
                    comment_id
                ) VALUES (
                    <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="Direct Test - #testTime#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="direct-test-#testId#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="<p>Direct test</p>" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="Direct test" cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="post" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="draft" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="all" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
                    <cfqueryparam value='{"direct":"test at #testTime#"}' cfsqltype="cf_sql_longvarchar">,
                    <cfqueryparam value="direct_#dateFormat(now(), "yyyymmdd")#_#timeFormat(now(), "HHmmss")#" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
            
            <div class="success">✓ INSERT successful with cf_sql_integer</div>
            
            <!--- Verify the insert --->
            <cfquery name="qCheck" datasource="#request.dsn#">
                SELECT show_title_and_feature_image, lexical, comment_id
                FROM posts
                WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qCheck.recordCount>
                <div class="info">
                    <h3>Verification:</h3>
                    <ul>
                        <li>show_title_and_feature_image: <strong>#qCheck.show_title_and_feature_image#</strong> 
                            <cfif qCheck.show_title_and_feature_image EQ 0>✓<cfelse>✗</cfif>
                        </li>
                        <li>lexical: <strong><cfif len(qCheck.lexical)>YES (#len(qCheck.lexical)# chars)<cfelse>NO</cfif></strong>
                            <cfif len(qCheck.lexical)>✓<cfelse>✗</cfif>
                        </li>
                        <li>comment_id: <strong>#qCheck.comment_id#</strong>
                            <cfif len(qCheck.comment_id)>✓<cfelse>✗</cfif>
                        </li>
                    </ul>
                </div>
            </cfif>
            
            <!--- Clean up --->
            <cfquery datasource="#request.dsn#">
                DELETE FROM posts WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
        <cfcatch>
            <div class="error">
                ✗ INSERT failed: #cfcatch.message#
                <cfif structKeyExists(cfcatch, "detail")><br>Detail: #cfcatch.detail#</cfif>
            </div>
        </cfcatch>
        </cftry>
        
        <h2>Test 2: Check if it's a session issue</h2>
        
        <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
            <div class="success">✓ Session is active (ISLOGGEDIN = true)</div>
            <cfif structKeyExists(session, "USERID")>
                <div class="info">User ID: #session.USERID#</div>
            </cfif>
        <cfelse>
            <div class="error">✗ Session is not active or user not logged in</div>
            <div class="info">
                <p>This explains why the AJAX save is failing. You need to:</p>
                <ol>
                    <li><a href="/ghost/admin/login.cfm" target="_blank">Log in to the admin panel</a></li>
                    <li>Then try the save test again</li>
                </ol>
            </div>
        </cfif>
        
        <hr>
        <p><a href="?">Run Test Again</a></p>
    </cfif>
    
</body>
</html>