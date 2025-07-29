<!--- Test blog output --->
<cfhttp url="http://localhost/ghost/blog/" method="get" result="response">
</cfhttp>

<cfoutput>
<pre>
Status: #response.statusCode#
<br>
First 2000 chars of content:
#left(response.fileContent, 2000)#
</pre>
</cfoutput>