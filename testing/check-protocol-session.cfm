<!--- Check Protocol and Session --->
<cfparam name="request.dsn" default="blog">

<!DOCTYPE html>
<html>
<head>
    <title>Check Protocol and Session</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        table { border-collapse: collapse; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background: #f5f5f5; }
    </style>
</head>
<body>
    <h1>Protocol and Session Check</h1>
    
    <div class="info">
        <h2>Server Variables:</h2>
        <table>
            <tr><th>Variable</th><th>Value</th></tr>
            <tr><td>SERVER_NAME</td><td><cfoutput>#cgi.server_name#</cfoutput></td></tr>
            <tr><td>SERVER_PORT</td><td><cfoutput>#cgi.server_port#</cfoutput></td></tr>
            <tr><td>SERVER_PORT_SECURE</td><td><cfoutput>#cgi.server_port_secure#</cfoutput></td></tr>
            <tr><td>HTTPS</td><td><cfoutput>#cgi.https#</cfoutput></td></tr>
            <tr><td>REQUEST_SCHEME</td><td><cfoutput>#cgi.request_scheme ?: 'Not Available'#</cfoutput></td></tr>
        </table>
        
        <p><strong>Detected Protocol:</strong> 
            <cfset protocol = (cgi.server_port_secure OR cgi.https EQ "on" OR cgi.server_port EQ "443") ? "https" : "http">
            <cfoutput>#protocol#</cfoutput>
        </p>
        
        <p><strong>AJAX URL would be:</strong> 
            <cfoutput>#protocol#://#cgi.server_name#/ghost/admin/ajax/save-post.cfm</cfoutput>
        </p>
    </div>
    
    <div class="info">
        <h2>Session Status:</h2>
        <cfif structKeyExists(session, "ISLOGGEDIN") AND session.ISLOGGEDIN>
            <p class="success">✓ User is logged in</p>
            <table>
                <tr><th>Session Variable</th><th>Value</th></tr>
                <cfif structKeyExists(session, "USERID")>
                    <tr><td>USERID</td><td><cfoutput>#session.USERID#</cfoutput></td></tr>
                </cfif>
                <cfif structKeyExists(session, "USERNAME")>
                    <tr><td>USERNAME</td><td><cfoutput>#session.USERNAME#</cfoutput></td></tr>
                </cfif>
                <tr><td>ISLOGGEDIN</td><td><cfoutput>#session.ISLOGGEDIN#</cfoutput></td></tr>
            </table>
        <cfelse>
            <p class="error">✗ User is NOT logged in</p>
            <p>You need to <a href="/ghost/admin/login.cfm">log in</a> before testing the save functionality.</p>
        </cfif>
    </div>
    
    <div class="info">
        <h2>Cookie Status:</h2>
        <table>
            <tr><th>Cookie</th><th>Exists</th><th>Value</th></tr>
            <tr>
                <td>CFID</td>
                <td><cfif structKeyExists(cookie, "CFID")><span class="success">✓</span><cfelse><span class="error">✗</span></cfif></td>
                <td><cfif structKeyExists(cookie, "CFID")><cfoutput>#cookie.CFID#</cfoutput><cfelse>N/A</cfif></td>
            </tr>
            <tr>
                <td>CFTOKEN</td>
                <td><cfif structKeyExists(cookie, "CFTOKEN")><span class="success">✓</span><cfelse><span class="error">✗</span></cfif></td>
                <td><cfif structKeyExists(cookie, "CFTOKEN")><cfoutput>#left(cookie.CFTOKEN, 10)#...</cfoutput><cfelse>N/A</cfif></td>
            </tr>
        </table>
    </div>
    
    <div class="info">
        <h2>Quick Test Links:</h2>
        <ul>
            <li><a href="/ghost/testing/test-save-with-logging.cfm">Test Save with Logging</a> - Now uses correct protocol</li>
            <li><a href="/ghost/testing/test-save-ghost-fields.cfm">Test Save Ghost Fields</a> - Now uses correct protocol</li>
            <li><a href="/ghost/testing/direct-db-test.cfm">Direct Database Test</a> - Bypasses HTTP entirely</li>
            <li><a href="/ghost/admin/login.cfm">Login Page</a> - If session expired</li>
        </ul>
    </div>
</body>
</html>