<!--- Test Theme Rendering --->
<cfparam name="request.dsn" default="blog">

<!--- Include theme renderer --->
<cfinclude template="/ghost/admin/includes/theme-renderer.cfm">

<!--- Get site settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value
    FROM settings
    WHERE `key` IN ('site_title', 'site_description', 'site_url', 'active_theme')
</cfquery>

<cfset siteSettings = {}>
<cfloop query="qSettings">
    <cfset siteSettings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Build test context --->
<cfset context = {
    "site": {
        "title": structKeyExists(siteSettings, "site_title") ? siteSettings.site_title : "Ghost CFML",
        "description": structKeyExists(siteSettings, "site_description") ? siteSettings.site_description : "A simple publishing platform",
        "url": structKeyExists(siteSettings, "site_url") ? siteSettings.site_url : "http://localhost",
        "locale": "en"
    },
    "posts": [
        {
            "title": "Test Post",
            "slug": "test-post",
            "excerpt": "This is a test post excerpt",
            "url": "/ghost/blog/test-post/",
            "published_at": now(),
            "primary_tag": {
                "name": "Test Tag"
            }
        }
    ]
}>

<!--- Try to render the index.hbs template --->
<cftry>
    <cfset output = renderTheme("index.hbs", context)>
    <cfoutput>#output#</cfoutput>
<cfcatch>
    <cfoutput>
        <h1>Error rendering theme</h1>
        <p>#cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
        <pre>#cfcatch.stacktrace#</pre>
    </cfoutput>
</cfcatch>
</cftry>