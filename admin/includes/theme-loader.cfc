<!--- Theme Loader Component - Loads and processes Ghost themes --->
<cfcomponent displayname="ThemeLoader">
    
    <!--- Get the active theme name --->
    <cffunction name="getActiveTheme" access="public" returntype="string">
        <cfparam name="request.dsn" default="blog">
        
        <cfquery name="qTheme" datasource="#request.dsn#">
            SELECT value
            FROM settings
            WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qTheme.recordCount>
            <cfreturn qTheme.value>
        <cfelse>
            <cfreturn "casper">
        </cfif>
    </cffunction>
    
    <!--- Load a theme template file --->
    <cffunction name="loadTemplate" access="public" returntype="string">
        <cfargument name="themeName" type="string" required="true">
        <cfargument name="templateName" type="string" required="true">
        
        <cfset var themePath = expandPath("/ghost/themes/#arguments.themeName#")>
        <cfset var templatePath = "#themePath#/#arguments.templateName#">
        
        <!--- Check if template exists --->
        <cfif fileExists(templatePath)>
            <cffile action="read" file="#templatePath#" variable="templateContent">
            <cfreturn templateContent>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cffunction>
    
    <!--- Load all partials for a theme --->
    <cffunction name="loadPartials" access="public" returntype="struct">
        <cfargument name="themeName" type="string" required="true">
        
        <cfset var partials = {}>
        <cfset var partialsPath = expandPath("/ghost/themes/#arguments.themeName#/partials")>
        
        <cfif directoryExists(partialsPath)>
            <!--- Get all .hbs files in partials directory --->
            <cfdirectory action="list" directory="#partialsPath#" name="qPartials" filter="*.hbs" recurse="true">
            
            <cfloop query="qPartials">
                <cfif qPartials.type EQ "file">
                    <!--- Calculate relative path from partials directory --->
                    <cfset relativePath = replace(qPartials.directory, partialsPath, "")>
                    <cfset relativePath = replace(relativePath, "\", "/", "all")>
                    <cfif left(relativePath, 1) EQ "/">
                        <cfset relativePath = mid(relativePath, 2, len(relativePath)-1)>
                    </cfif>
                    
                    <!--- Create partial name (remove .hbs extension) --->
                    <cfset partialName = replace(qPartials.name, ".hbs", "")>
                    <cfif len(relativePath)>
                        <cfset partialName = relativePath & "/" & partialName>
                    </cfif>
                    
                    <!--- Read partial content --->
                    <cffile action="read" file="#qPartials.directory#/#qPartials.name#" variable="partialContent">
                    <cfset partials[partialName] = partialContent>
                </cfif>
            </cfloop>
        </cfif>
        
        <cfreturn partials>
    </cffunction>
    
    <!--- Get theme asset URL --->
    <cffunction name="getAssetUrl" access="public" returntype="string">
        <cfargument name="themeName" type="string" required="true">
        <cfargument name="assetPath" type="string" required="true">
        
        <cfreturn "/ghost/themes/#arguments.themeName#/assets/#arguments.assetPath#">
    </cffunction>
    
    <!--- Check if theme exists --->
    <cffunction name="themeExists" access="public" returntype="boolean">
        <cfargument name="themeName" type="string" required="true">
        
        <cfset var themePath = expandPath("/ghost/themes/#arguments.themeName#")>
        <cfreturn directoryExists(themePath)>
    </cffunction>
    
    <!--- Get theme package.json data --->
    <cffunction name="getThemeConfig" access="public" returntype="struct">
        <cfargument name="themeName" type="string" required="true">
        
        <cfset var config = {}>
        <cfset var packagePath = expandPath("/ghost/themes/#arguments.themeName#/package.json")>
        
        <cfif fileExists(packagePath)>
            <cffile action="read" file="#packagePath#" variable="packageContent">
            <cftry>
                <cfset config = deserializeJSON(packageContent)>
            <cfcatch>
                <!--- Invalid JSON, return empty struct --->
            </cfcatch>
        </cfif>
        
        <cfreturn config>
    </cffunction>
    
    <!--- Process template inheritance ({{!< default}}) --->
    <cffunction name="getTemplateLayout" access="public" returntype="string">
        <cfargument name="templateContent" type="string" required="true">
        
        <cfset var layoutPattern = "{{!<\s*([^}]+)\s*}}">
        <cfset var matches = reMatch(layoutPattern, arguments.templateContent)>
        
        <cfif arrayLen(matches)>
            <!--- Extract layout name --->
            <cfset var layoutName = reReplace(matches[1], "{{!<\s*", "")>
            <cfset layoutName = reReplace(layoutName, "\s*}}", "")>
            <cfreturn trim(layoutName)>
        </cfif>
        
        <cfreturn "">
    </cffunction>
    
    <!--- Remove layout declaration from template --->
    <cffunction name="removeLayoutDeclaration" access="public" returntype="string">
        <cfargument name="templateContent" type="string" required="true">
        
        <cfset var layoutPattern = "{{!<\s*[^}]+\s*}}">
        <cfreturn reReplace(arguments.templateContent, layoutPattern, "", "all")>
    </cffunction>
    
</cfcomponent>