<!--- Test Theme Output --->
<cfparam name="request.dsn" default="blog">

<!--- Get current theme setting --->
<cfquery name="qCurrentTheme" datasource="#request.dsn#">
    SELECT value FROM settings WHERE `key` = 'active_theme'
</cfquery>

<cfset currentTheme = qCurrentTheme.recordCount ? qCurrentTheme.value : "default">

<!--- Get available themes --->
<cfset themesPath = expandPath("/ghost/themes/")>
<cfdirectory action="list" directory="#themesPath#" name="qThemes" type="dir">

<!--- Filter out system directories --->
<cfset themes = []>
<cfloop query="qThemes">
    <cfif qThemes.name NEQ "." AND qThemes.name NEQ "..">
        <!--- Check if theme has required files --->
        <cfif fileExists("#themesPath##qThemes.name#/theme.json") AND fileExists("#themesPath##qThemes.name#/index.cfm")>
            <!--- Read theme info --->
            <cfset themeJson = fileRead("#themesPath##qThemes.name#/theme.json")>
            <cfset themeInfo = deserializeJSON(themeJson)>
            <cfset themeInfo.id = qThemes.name>
            <cfset themeInfo.active = (currentTheme EQ qThemes.name)>
            <cfset arrayAppend(themes, themeInfo)>
        </cfif>
    </cfif>
</cfloop>

<h1>Theme Test Output</h1>
<p>Current Theme: <cfoutput>#currentTheme#</cfoutput></p>

<h2>Themes Array:</h2>
<cfdump var="#themes#">

<h2>Test Display:</h2>
<cfloop array="#themes#" index="theme">
    <div style="border: 1px solid #ccc; padding: 10px; margin: 10px;">
        <cfoutput>
            <strong>Theme Name:</strong> #theme.name#<br>
            <strong>Version:</strong> #theme.version#<br>
            <strong>Active:</strong> #theme.active#<br>
            <strong>ID:</strong> #theme.id#<br>
        </cfoutput>
    </div>
</cfloop>