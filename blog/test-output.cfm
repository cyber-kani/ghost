<!--- Test Output --->
<cfparam name="request.dsn" default="ghost_prod">

<!--- Simple test to see if output is working --->
<cfcontent reset="true" type="text/html">
<cfoutput><!DOCTYPE html>
<html>
<head>
    <title>Test Output</title>
</head>
<body>
    <h1>Test Output</h1>
    <p>If you can see this, basic output is working.</p>
    
    <h2>Database Test</h2>
    <cftry>
        <cfquery name="qTest" datasource="#request.dsn#">
            SELECT COUNT(*) as post_count
            FROM posts
            WHERE status = 'published'
        </cfquery>
        <p>Published posts: #qTest.post_count#</p>
    <cfcatch>
        <p style="color: red;">Database error: #cfcatch.message#</p>
    </cfcatch>
    </cftry>
    
    <h2>Include Test</h2>
    <cftry>
        <cfset testInclude = fileExists(expandPath("/ghost/admin/includes/handlebars-functions.cfm"))>
        <p>Handlebars functions file exists: #testInclude#</p>
    <cfcatch>
        <p style="color: red;">Include error: #cfcatch.message#</p>
    </cfcatch>
    </cftry>
    
    <p><a href="/ghost/blog/">Try main blog</a></p>
    <p><a href="/ghost/testing/blog-direct-test.cfm">Try direct test (working)</a></p>
</body>
</html></cfoutput>