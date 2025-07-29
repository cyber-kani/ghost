<!--- Diagnostic Page --->
<cfsetting showdebugoutput="false">
<cfcontent reset="true" type="text/html">

<!DOCTYPE html>
<html>
<head>
    <title>Blog Diagnostic</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid ##ddd; }
        .success { color: ##0a0; }
        .error { color: ##c00; }
        pre { background: ##f5f5f5; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>Blog Diagnostic Page</h1>
    
    <div class="section">
        <h2>1. Basic Output Test</h2>
        <p class="success">✓ If you can see this, basic CF output is working</p>
    </div>
    
    <div class="section">
        <h2>2. Application Variables</h2>
        <cftry>
            <cfoutput>
            <p>Application Name: #application.name#</p>
            <p>DSN: #request.dsn#</p>
            <p>Debug Mode: #application.debugMode#</p>
            </cfoutput>
            <p class="success">✓ Application variables accessible</p>
        <cfcatch>
            <p class="error">✗ Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        </cfcatch>
        </cftry>
    </div>
    
    <div class="section">
        <h2>3. Database Connection</h2>
        <cftry>
            <cfquery name="qTest" datasource="#request.dsn#">
                SELECT COUNT(*) as cnt FROM posts
            </cfquery>
            <cfoutput>
            <p class="success">✓ Database connected - Posts count: #qTest.cnt#</p>
            </cfoutput>
        <cfcatch>
            <p class="error">✗ Database Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        </cfcatch>
        </cftry>
    </div>
    
    <div class="section">
        <h2>4. Include Test</h2>
        <cftry>
            <cfif fileExists(expandPath("/ghost/admin/includes/handlebars-functions.cfm"))>
                <p class="success">✓ Handlebars functions file exists</p>
                <cfinclude template="/ghost/admin/includes/handlebars-functions.cfm">
                <p class="success">✓ Include successful</p>
            <cfelse>
                <p class="error">✗ Handlebars functions file not found</p>
            </cfif>
        <cfcatch>
            <p class="error">✗ Include Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        </cfcatch>
        </cftry>
    </div>
    
    <div class="section">
        <h2>5. Simple Template Test</h2>
        <cftry>
            <cfset testTemplate = "Hello {{name}}!">
            <cfset testContext = {"name": "World"}>
            <cfset result = processHandlebarsTemplate(testTemplate, testContext)>
            <cfoutput>
            <p>Template: #testTemplate#</p>
            <p>Result: #result#</p>
            </cfoutput>
            <p class="success">✓ Template processing works</p>
        <cfcatch>
            <p class="error">✗ Template Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        </cfcatch>
        </cftry>
    </div>
    
    <div class="section">
        <h2>6. Blog Index Include</h2>
        <cftry>
            <p>Attempting to process blog index...</p>
            <cfsavecontent variable="blogOutput">
                <cfinclude template="/ghost/blog/index.cfm">
            </cfsavecontent>
            <p>Output length: <cfoutput>#len(blogOutput)#</cfoutput> characters</p>
            <cfif len(trim(blogOutput)) GT 0>
                <p class="success">✓ Blog produced output</p>
                <h3>First 500 characters:</h3>
                <pre><cfoutput>#htmlEditFormat(left(blogOutput, 500))#</cfoutput></pre>
            <cfelse>
                <p class="error">✗ Blog produced no output</p>
            </cfif>
        <cfcatch>
            <p class="error">✗ Blog Include Error: <cfoutput>#cfcatch.message#</cfoutput></p>
            <pre><cfoutput>#cfcatch.detail#</cfoutput></pre>
        </cfcatch>
        </cftry>
    </div>
    
    <div class="section">
        <h2>Links</h2>
        <ul>
            <li><a href="/ghost/blog/">Main Blog</a></li>
            <li><a href="/ghost/testing/blog-direct-test.cfm">Direct Test (Working)</a></li>
            <li><a href="/ghost/blog/index-simple.cfm">Simple Index</a></li>
        </ul>
    </div>
</body>
</html>

<cfabort>