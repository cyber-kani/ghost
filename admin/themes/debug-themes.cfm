<!--- Debug Themes --->
<cfparam name="request.dsn" default="blog">

<!--- Get current theme setting --->
<cfquery name="qCurrentTheme" datasource="#request.dsn#">
    SELECT value FROM settings WHERE `key` = 'active_theme'
</cfquery>

<cfset currentTheme = qCurrentTheme.recordCount ? qCurrentTheme.value : "default">

<!--- Get available themes --->
<cfset themesPath = expandPath("/ghost/themes/")>
<cfdirectory action="list" directory="#themesPath#" name="qThemes" type="dir">

<cfoutput>
<h1>Theme Debug Info</h1>
<p>Current Active Theme: <strong>#currentTheme#</strong></p>

<h2>Available Themes:</h2>
<ul>
<cfloop query="qThemes">
    <cfif qThemes.name NEQ "." AND qThemes.name NEQ "..">
        <li>
            Theme Directory: #qThemes.name#
            <cfif fileExists("#themesPath##qThemes.name#/theme.json")>
                <br>theme.json exists
                <cftry>
                    <cfset themeJson = fileRead("#themesPath##qThemes.name#/theme.json")>
                    <cfset themeInfo = deserializeJSON(themeJson)>
                    <br>Name: #themeInfo.name#
                    <br>Version: #themeInfo.version#
                    <br>Active: #(currentTheme EQ qThemes.name ? "YES" : "NO")#
                <cfcatch>
                    <br>Error reading theme.json: #cfcatch.message#
                </cfcatch>
                </cftry>
            <cfelse>
                <br>No theme.json found
            </cfif>
        </li>
    </cfif>
</cfloop>
</ul>
</cfoutput>