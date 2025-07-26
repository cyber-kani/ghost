<!--- Debug Session Page --->
<cfscript>
// Set test session variables
session.ISLOGGEDIN = true;
session.USERID = "1";
session.USERNAME = "Debug User";
session.USEREMAIL = "debug@example.com";
session.USERROLE = "Owner";
</cfscript>

<cfoutput>
<h1>Session Debug</h1>

<h2>After Setting Session Variables:</h2>
<p><strong>ISLOGGEDIN exists:</strong> #structKeyExists(session, "ISLOGGEDIN")#</p>
<p><strong>ISLOGGEDIN value:</strong> #session.ISLOGGEDIN#</p>
<p><strong>ISLOGGEDIN type:</strong> #getMetadata(session.ISLOGGEDIN).getName()#</p>

<h2>Session Check Logic:</h2>
<p><strong>NOT structKeyExists(session, "ISLOGGEDIN"):</strong> #NOT structKeyExists(session, "ISLOGGEDIN")#</p>
<p><strong>NOT session.ISLOGGEDIN:</strong> #NOT session.ISLOGGEDIN#</p>
<p><strong>Combined condition (should be FALSE):</strong> #(NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN)#</p>

<h2>Full Session Dump:</h2>
<cfdump var="#session#">

<hr>
<h2>Test Header Logic:</h2>
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <p style="color: red; font-weight: bold;">WOULD REDIRECT TO LOGIN</p>
<cfelse>
    <p style="color: green; font-weight: bold;">WOULD ALLOW ACCESS TO DASHBOARD</p>
    <p><a href="/ghost/admin/dashboard">Try Dashboard</a></p>
</cfif>

<p><a href="/ghost/admin/login">Back to Login</a></p>
</cfoutput>