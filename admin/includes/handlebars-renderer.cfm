<!--- Simple Handlebars-compatible Renderer for Ghost Themes --->
<!--- This is a simplified implementation that supports basic Ghost theme features --->

<cffunction name="getActiveThemeName" access="public" returntype="string">
    <cfargument name="datasource" type="string" default="blog">
    
    <cfquery name="qTheme" datasource="#arguments.datasource#">
        SELECT value FROM settings 
        WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfreturn qTheme.recordCount ? qTheme.value : "default">
</cffunction>

<cffunction name="getThemePath" access="public" returntype="string">
    <cfargument name="themeName" type="string" required="true">
    <cfreturn "/ghost/themes/#arguments.themeName#/">
</cffunction>

<cffunction name="readThemeTemplate" access="public" returntype="string">
    <cfargument name="themeName" type="string" required="true">
    <cfargument name="templateName" type="string" required="true">
    
    <cfset var templatePath = expandPath(getThemePath(arguments.themeName) & arguments.templateName)>
    
    <cfif NOT fileExists(templatePath)>
        <!--- Try without .hbs extension --->
        <cfset templatePath = expandPath(getThemePath(arguments.themeName) & arguments.templateName & ".hbs")>
        <cfif NOT fileExists(templatePath)>
            <cfthrow message="Template not found: #arguments.templateName# in theme #arguments.themeName#">
        </cfif>
    </cfif>
    
    <cffile action="read" file="#templatePath#" variable="local.template">
    <cfreturn local.template>
</cffunction>

<cffunction name="processSimpleVariables" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var result = arguments.template>
    
    <!--- Process simple variables like {{title}}, {{description}} --->
    <cfset var matches = reMatchNoCase('\{\{([a-zA-Z0-9_\-\.]+)\}\}', result)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varName = reReplaceNoCase(match, '\{\{|\}\}', '', 'all')>
        <cfset var value = "">
        
        <!--- Handle dot notation --->
        <cfif find(".", varName)>
            <cfset var parts = listToArray(varName, ".")>
            <cfset var current = arguments.context>
            <cfloop array="#parts#" index="part">
                <cfif isStruct(current) AND structKeyExists(current, part)>
                    <cfset current = current[part]>
                <cfelse>
                    <cfset current = "">
                    <cfbreak>
                </cfif>
            </cfloop>
            <cfset value = isSimpleValue(current) ? current : "">
        <cfelseif structKeyExists(arguments.context, varName)>
            <cfset value = isSimpleValue(arguments.context[varName]) ? arguments.context[varName] : "">
        </cfif>
        
        <cfset result = replace(result, match, value, "all")>
    </cfloop>
    
    <cfreturn result>
</cffunction>

<cffunction name="processIfStatements" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var result = arguments.template>
    <cfset var hashChar = chr(35)>
    
    <!--- Process {{#if variable}} blocks --->
    <cfset var pattern = '\{\{' & hashChar & 'if\s+([^}]+)\}\}([\s\S]*?)\{\{/if\}\}'>
    
    <cfloop condition="reFindNoCase(pattern, result)">
        <cfset var match = reFindNoCase(pattern, result, 1, true)>
        <cfif match.pos[1] GT 0>
            <cfset var fullMatch = mid(result, match.pos[1], match.len[1])>
            <cfset var condition = mid(result, match.pos[2], match.len[2])>
            <cfset var content = mid(result, match.pos[3], match.len[3])>
            
            <!--- Evaluate condition --->
            <cfset var conditionMet = false>
            <cfif structKeyExists(arguments.context, trim(condition))>
                <cfset var value = arguments.context[trim(condition)]>
                <cfif isBoolean(value)>
                    <cfset conditionMet = value>
                <cfelseif isSimpleValue(value)>
                    <cfset conditionMet = len(trim(value)) GT 0>
                <cfelseif isArray(value)>
                    <cfset conditionMet = arrayLen(value) GT 0>
                <cfelseif isStruct(value)>
                    <cfset conditionMet = structCount(value) GT 0>
                </cfif>
            </cfif>
            
            <cfif conditionMet>
                <cfset result = replace(result, fullMatch, content, "one")>
            <cfelse>
                <cfset result = replace(result, fullMatch, "", "one")>
            </cfif>
        <cfelse>
            <cfbreak>
        </cfif>
    </cfloop>
    
    <cfreturn result>
</cffunction>

<cffunction name="processForeachLoops" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var result = arguments.template>
    <cfset var hashChar = chr(35)>
    
    <!--- Process {{#foreach items}} blocks --->
    <cfset var pattern = '\{\{' & hashChar & 'foreach\s+([^}]+)\}\}([\s\S]*?)\{\{/foreach\}\}'>
    
    <cfloop condition="reFindNoCase(pattern, result)">
        <cfset var match = reFindNoCase(pattern, result, 1, true)>
        <cfif match.pos[1] GT 0>
            <cfset var fullMatch = mid(result, match.pos[1], match.len[1])>
            <cfset var itemsName = trim(mid(result, match.pos[2], match.len[2]))>
            <cfset var loopContent = mid(result, match.pos[3], match.len[3])>
            
            <cfset var output = "">
            
            <cfif structKeyExists(arguments.context, itemsName) AND isArray(arguments.context[itemsName])>
                <cfloop array="#arguments.context[itemsName]#" index="item">
                    <cfset var itemContext = duplicate(arguments.context)>
                    <cfset structAppend(itemContext, item)>
                    <cfset output &= processSimpleVariables(loopContent, itemContext)>
                </cfloop>
            </cfif>
            
            <cfset result = replace(result, fullMatch, output, "one")>
        <cfelse>
            <cfbreak>
        </cfif>
    </cfloop>
    
    <cfreturn result>
</cffunction>

<cffunction name="processPartials" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var result = arguments.template>
    
    <!--- Process {{> partial}} includes --->
    <cfset var matches = reMatchNoCase('\{\{>\s*([^}]+)\}\}', result)>
    
    <cfloop array="#matches#" index="match">
        <cfset var partialName = trim(reReplaceNoCase(match, '\{\{>|\}\}', '', 'all'))>
        
        <cftry>
            <cfset var partialContent = readThemeTemplate(arguments.themeName, "partials/" & partialName & ".hbs")>
            <cfset partialContent = renderSimpleTemplate(partialContent, arguments.context, arguments.themeName)>
            <cfset result = replace(result, match, partialContent, "all")>
        <cfcatch>
            <!--- If partial not found, just remove the tag --->
            <cfset result = replace(result, match, "", "all")>
        </cfcatch>
        </cftry>
    </cfloop>
    
    <cfreturn result>
</cffunction>

<cffunction name="renderSimpleTemplate" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var result = arguments.template>
    
    <!--- Remove comments --->
    <cfset result = reReplace(result, '\{\{!--[\s\S]*?--\}\}', '', 'all')>
    
    <!--- Process in order --->
    <cfset result = processPartials(result, arguments.context, arguments.themeName)>
    <cfset result = processForeachLoops(result, arguments.context)>
    <cfset result = processIfStatements(result, arguments.context)>
    <cfset result = processSimpleVariables(result, arguments.context)>
    
    <!--- Process special Ghost helpers --->
    <cfset result = processGhostHelpers(result, arguments.context)>
    
    <cfreturn result>
</cffunction>

<cffunction name="processGhostHelpers" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var result = arguments.template>
    
    <!--- {{ghost_head}} --->
    <cfset result = replace(result, "{{ghost_head}}", '<meta name="generator" content="Ghost CFML" />', "all")>
    
    <!--- {{ghost_foot}} --->
    <cfset result = replace(result, "{{ghost_foot}}", '<!-- Ghost Foot -->', "all")>
    
    <!--- {{asset "css/style.css"}} --->
    <cfset var assetMatches = reMatchNoCase('\{\{asset\s+"([^"]+)"\}\}', result)>
    <cfloop array="#assetMatches#" index="match">
        <cfset var assetPath = reReplaceNoCase(match, '\{\{asset\s+"|"\}\}', '', 'all')>
        <cfset var fullPath = "/ghost/themes/" & getActiveThemeName() & "/assets/" & assetPath>
        <cfset result = replace(result, match, fullPath, "all")>
    </cfloop>
    
    <!--- {{body_class}} --->
    <cfif structKeyExists(arguments.context, "body_class")>
        <cfset result = replace(result, "{{body_class}}", arguments.context.body_class, "all")>
    <cfelse>
        <cfset result = replace(result, "{{body_class}}", "home-template", "all")>
    </cfif>
    
    <cfreturn result>
</cffunction>

<cffunction name="renderThemeTemplate" access="public" returntype="string">
    <cfargument name="templateName" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="datasource" type="string" default="blog">
    
    <cfset var themeName = getActiveThemeName(arguments.datasource)>
    <cfset var template = readThemeTemplate(themeName, arguments.templateName)>
    
    <!--- Check for layout directive --->
    <cfset var layoutMatch = reFindNoCase('\{\{!<\s*([^}]+)\}\}', template, 1, true)>
    <cfset var layout = "">
    
    <cfif layoutMatch.pos[1] GT 0>
        <cfset layout = trim(mid(template, layoutMatch.pos[2], layoutMatch.len[2]))>
        <!--- Remove layout directive from template --->
        <cfset template = replace(template, mid(template, layoutMatch.pos[1], layoutMatch.len[1]), "")>
    </cfif>
    
    <!--- Render the template --->
    <cfset var renderedContent = renderSimpleTemplate(template, arguments.context, themeName)>
    
    <!--- If layout specified, render within layout --->
    <cfif len(layout)>
        <cfset arguments.context["{{{body}}}"] = renderedContent>
        <cfset var layoutTemplate = readThemeTemplate(themeName, layout & ".hbs")>
        <cfset renderedContent = renderSimpleTemplate(layoutTemplate, arguments.context, themeName)>
        <!--- Replace {{{body}}} with the content --->
        <cfset renderedContent = replace(renderedContent, "{{{body}}}", arguments.context["{{{body}}}"], "all")>
    </cfif>
    
    <cfreturn renderedContent>
</cffunction>