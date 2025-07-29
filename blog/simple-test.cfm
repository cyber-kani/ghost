<!--- Ultra Simple Test --->
<cfcontent reset="true" type="text/html"><cfoutput><!DOCTYPE html>
<html>
<head><title>Simple Test</title></head>
<body>
<h1>Simple Test</h1>
<p>Current time: #now()#</p>
<p>DSN: #request.dsn#</p>
<p><a href="/ghost/blog/">Blog</a></p>
</body>
</html></cfoutput><cfabort>