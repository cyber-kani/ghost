<!--- Trace Save Process --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">

<!DOCTYPE html>
<html>
<head>
    <title>Trace Save Process</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .success { color: #28a745; }
        .error { color: #dc3545; }
        .info { color: #17a2b8; }
        .code { background: #f8f9fa; padding: 10px; border: 1px solid #dee2e6; font-family: monospace; }
        button { padding: 10px 20px; background: #007bff; color: white; border: none; cursor: pointer; }
        pre { white-space: pre-wrap; }
    </style>
</head>
<body>
    <h1>Trace Save Process</h1>
    
    <cfif url.action EQ "">
        <div class="section">
            <h2>Test Save with Detailed Tracing</h2>
            <p>This will create a test post and show exactly what happens at each step.</p>
            <button onclick="window.location.href='?action=trace'">Start Trace Test</button>
        </div>
        
    <cfelseif url.action EQ "trace">
        <cfset traceId = createUUID()>
        <cfset testId = left(replace(traceId, "-", "", "all"), 24)>
        
        <div class="section">
            <h2>Step 1: Prepare Test Data</h2>
            <div class="code">
                Post ID: #testId#<br>
                show_title_and_feature_image: 0<br>
                lexical: {"trace":"#traceId#"}<br>
                comment_id: trace_#dateFormat(now(), "yyyymmdd")#_#timeFormat(now(), "HHmmss")#
            </div>
        </div>
        
        <div class="section">
            <h2>Step 2: Direct Database Insert Test</h2>
            <cftry>
                <cfquery datasource="#request.dsn#" result="insertResult">
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
                        <cfqueryparam value="Trace Test Post" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="trace-test-#testId#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="<p>Trace test</p>" cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="Trace test" cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="post" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="draft" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="all" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="0" cfsqltype="cf_sql_integer">,
                        <cfqueryparam value='{"trace":"#traceId#"}' cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="trace_#dateFormat(now(), "yyyymmdd")#_#timeFormat(now(), "HHmmss")#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
                
                <p class="success">✓ Direct INSERT successful</p>
                
                <!--- Verify --->
                <cfquery name="qVerify" datasource="#request.dsn#">
                    SELECT show_title_and_feature_image, lexical, comment_id
                    FROM posts
                    WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif qVerify.recordCount>
                    <div class="code">
                        <strong>Verification:</strong><br>
                        show_title_and_feature_image: #qVerify.show_title_and_feature_image# 
                        <cfif qVerify.show_title_and_feature_image EQ 0><span class="success">✓</span><cfelse><span class="error">✗</span></cfif><br>
                        lexical: <cfif len(qVerify.lexical)>YES (#len(qVerify.lexical)# chars) <span class="success">✓</span><cfelse>NO <span class="error">✗</span></cfif><br>
                        comment_id: #qVerify.comment_id# <cfif len(qVerify.comment_id)><span class="success">✓</span><cfelse><span class="error">✗</span></cfif>
                    </div>
                </cfif>
                
                <!--- Clean up --->
                <cfquery datasource="#request.dsn#">
                    DELETE FROM posts WHERE id = <cfqueryparam value="#testId#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
            <cfcatch>
                <p class="error">✗ Direct INSERT failed: #cfcatch.message#</p>
                <p>Detail: #cfcatch.detail#</p>
            </cfcatch>
            </cftry>
        </div>
        
        <div class="section">
            <h2>Step 3: Check Column Data Types</h2>
            <cfquery name="qDataTypes" datasource="#request.dsn#">
                SELECT 
                    COLUMN_NAME,
                    DATA_TYPE,
                    COLUMN_TYPE,
                    IS_NULLABLE,
                    COLUMN_DEFAULT
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'posts'
                AND COLUMN_NAME IN ('show_title_and_feature_image', 'lexical', 'comment_id')
            </cfquery>
            
            <cfif qDataTypes.recordCount>
                <table border="1" cellpadding="5">
                    <tr>
                        <th>Column</th>
                        <th>Data Type</th>
                        <th>Column Type</th>
                        <th>Nullable</th>
                        <th>Default</th>
                    </tr>
                    <cfoutput query="qDataTypes">
                    <tr>
                        <td><strong>#COLUMN_NAME#</strong></td>
                        <td>#DATA_TYPE#</td>
                        <td>#COLUMN_TYPE#</td>
                        <td>#IS_NULLABLE#</td>
                        <td><cfif len(COLUMN_DEFAULT)>#COLUMN_DEFAULT#<cfelse>NULL</cfif></td>
                    </tr>
                    </cfoutput>
                </table>
                
                <cfif qDataTypes.recordCount LT 3>
                    <p class="error">⚠️ Not all Ghost fields found! Expected 3, found #qDataTypes.recordCount#</p>
                </cfif>
            <cfelse>
                <p class="error">✗ No Ghost fields found in database!</p>
            </cfif>
        </div>
        
        <div class="section">
            <h2>Step 4: Test Different SQL Types</h2>
            <cfset testId2 = left(replace(createUUID(), "-", "", "all"), 24)>
            
            <h3>Test with different cfsqltype values:</h3>
            
            <!--- Test 1: Using cf_sql_integer for boolean --->
            <cftry>
                <cfquery datasource="#request.dsn#">
                    INSERT INTO posts (
                        id, uuid, title, slug, html, plaintext,
                        type, status, created_at, updated_at,
                        email_recipient_filter, created_by,
                        show_title_and_feature_image
                    ) VALUES (
                        <cfqueryparam value="#testId2#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="Type Test" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="type-test" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="<p>Test</p>" cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="Test" cfsqltype="cf_sql_longvarchar">,
                        <cfqueryparam value="post" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="draft" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="all" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="1" cfsqltype="cf_sql_integer">
                    )
                </cfquery>
                
                <p class="success">✓ cf_sql_integer works for show_title_and_feature_image</p>
                
                <cfquery datasource="#request.dsn#">
                    DELETE FROM posts WHERE id = <cfqueryparam value="#testId2#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
            <cfcatch>
                <p class="error">✗ cf_sql_integer failed: #cfcatch.message#</p>
            </cfcatch>
            </cftry>
        </div>
        
        <div class="section">
            <h2>Step 5: Recommendations</h2>
            <cfquery name="qColumnType" datasource="#request.dsn#">
                SELECT COLUMN_TYPE 
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = 'posts'
                AND COLUMN_NAME = 'show_title_and_feature_image'
            </cfquery>
            
            <cfif qColumnType.recordCount AND qColumnType.COLUMN_TYPE CONTAINS "tinyint">
                <p class="info">ℹ️ show_title_and_feature_image is TINYINT - use cf_sql_integer instead of cf_sql_bit</p>
            </cfif>
            
            <div class="code">
                <strong>Updated save-post.cfm should use:</strong><br>
                &lt;cfqueryparam value="#showTitleAndFeatureImage#" cfsqltype="cf_sql_integer"&gt;
            </div>
        </div>
    </cfif>
    
    <hr>
    <p><a href="?">← Start Over</a></p>
</body>
</html>