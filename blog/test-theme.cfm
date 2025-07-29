<!--- Test Theme Rendering --->
<cfparam name="request.dsn" default="blog">

<!--- Include the theme renderer --->
<cfinclude template="/ghost/admin/includes/handlebars-renderer.cfm">

<cftry>
    <!--- Get active theme --->
    <cfset themeName = getActiveThemeName(request.dsn)>
    <cfoutput>
        <h1>Theme Test</h1>
        <p>Active Theme: #themeName#</p>
    </cfoutput>
    
    <!--- Try to read a simple template --->
    <cfset testContext = {
        "site": {
            "title": "Test Site",
            "description": "Test Description"
        },
        "posts": [],
        "body_class": "test-template"
    }>
    
    <!--- Test rendering --->
    <cfset output = renderThemeTemplate("index", testContext, request.dsn)>
    <cfoutput>
        <h2>Rendered Output:</h2>
        <pre>#htmlEditFormat(left(output, 500))#...</pre>
    </cfoutput>
    
<cfcatch>
    <cfoutput>
        <h2>Error:</h2>
        <p>#cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>