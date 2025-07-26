<!--- Test AJAX Session Setting --->
<cfscript>
// Simulate what the AJAX handler does
session.ISLOGGEDIN = true;
session.USERID = "1";
session.USERNAME = "Test User";
session.USEREMAIL = "test@example.com";
session.USERROLE = "Owner";
</cfscript>

<cfoutput>
<h1>AJAX Session Test</h1>
<p>Session variables have been set manually.</p>

<h2>Session Variables:</h2>
<cfdump var="#session#">

<p><a href="/ghost/admin/dashboard">Try Dashboard Now</a></p>
<p><a href="/ghost/admin/test-session.cfm">View Session Test</a></p>
<p><a href="/ghost/admin/login">Back to Login</a></p>
</cfoutput>