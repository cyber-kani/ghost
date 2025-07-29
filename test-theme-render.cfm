<!--- Test Theme Rendering --->
<cfparam name="request.dsn" default="blog">

<!--- Include theme renderer --->
<cfinclude template="/ghost/admin/includes/theme-renderer.cfm">

<!--- Simple context --->
<cfset context = {
    "@site": {
        "title": "Test Site",
        "url": "http://localhost"
    },
    "posts": []
}>

<!--- Try to render --->
<cftry>
    <cfset output = renderTheme("index.hbs", context)>
    <cfoutput>Success: Theme rendered</cfoutput>
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>#cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>