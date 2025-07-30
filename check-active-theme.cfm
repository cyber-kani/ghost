<!--- Check Current Active Theme --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Get active theme setting --->
    <cfquery name="qActiveTheme" datasource="#request.dsn#">
        SELECT value FROM settings WHERE `key` = 'active_theme'
    </cfquery>
    
    <cfoutput>
        <h1>Current Active Theme</h1>
        <cfif qActiveTheme.recordCount GT 0>
            <p>Active theme: <strong>#qActiveTheme.value#</strong></p>
        <cfelse>
            <p>No active theme set. Using default templates.</p>
        </cfif>
        
        <!--- Check if theme directory exists --->
        <cfif qActiveTheme.recordCount GT 0>
            <cfset themePath = expandPath("/ghost/themes/#qActiveTheme.value#/")>
            <cfif directoryExists(themePath)>
                <p>✅ Theme directory exists at: #themePath#</p>
                
                <!--- Check for theme files --->
                <h3>Theme files:</h3>
                <ul>
                    <cfif fileExists("#themePath#theme.json")>
                        <li>✅ theme.json</li>
                    <cfelse>
                        <li>❌ theme.json (missing)</li>
                    </cfif>
                    <cfif fileExists("#themePath#index.cfm")>
                        <li>✅ index.cfm</li>
                    <cfelse>
                        <li>❌ index.cfm (missing)</li>
                    </cfif>
                    <cfif fileExists("#themePath#post.cfm")>
                        <li>✅ post.cfm</li>
                    <cfelse>
                        <li>❌ post.cfm (missing)</li>
                    </cfif>
                    <cfif fileExists("#themePath#page.cfm")>
                        <li>✅ page.cfm</li>
                    <cfelse>
                        <li>❌ page.cfm (missing)</li>
                    </cfif>
                    <cfif fileExists("#themePath#tag.cfm")>
                        <li>✅ tag.cfm</li>
                    <cfelse>
                        <li>❌ tag.cfm (missing)</li>
                    </cfif>
                </ul>
            <cfelse>
                <p>❌ Theme directory does not exist!</p>
            </cfif>
        </cfif>
        
        <h3>Available Themes:</h3>
        <cfset themesPath = expandPath("/ghost/themes/")>
        <cfdirectory action="list" directory="#themesPath#" name="qThemes" type="dir">
        <ul>
        <cfloop query="qThemes">
            <cfif qThemes.name NEQ "." AND qThemes.name NEQ "..">
                <li>#qThemes.name# <cfif qActiveTheme.recordCount GT 0 AND qActiveTheme.value EQ qThemes.name>(active)</cfif></li>
            </cfif>
        </cfloop>
        </ul>
        
        <p><a href="/ghost/admin/themes">Manage themes</a> | <a href="/ghost/">View blog</a></p>
    </cfoutput>
    
<cfcatch>
    <cfoutput>
        <h1>Error</h1>
        <p>Failed to check theme: #cfcatch.message#</p>
        <p>#cfcatch.detail#</p>
    </cfoutput>
</cfcatch>
</cftry>