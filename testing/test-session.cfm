<!--- Test Session Page --->
<cfoutput>
<h1>Session Test</h1>
<h2>Session Variables:</h2>
<cfdump var="#session#">

<h2>Application Variables:</h2>
<cfdump var="#application#">

<h2>CGI Variables:</h2>
<cfdump var="#cgi#">

<p><a href="/ghost/admin/dashboard">Try Dashboard</a></p>
<p><a href="/ghost/admin/login">Back to Login</a></p>
</cfoutput>