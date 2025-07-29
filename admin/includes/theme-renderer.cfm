<!--- Theme Renderer - Renders Ghost themes with Handlebars --->
<cfparam name="request.dsn" default="blog">

<!--- Create theme loader instance --->
<cfset themeLoader = createObject("component", "ghost.admin.includes.theme-loader")>

<!--- Render a theme template --->
<cffunction name="renderTheme" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="false" default="">
    
    <!--- Get active theme if not specified --->
    <cfif NOT len(arguments.themeName)>
        <cfset arguments.themeName = themeLoader.getActiveTheme()>
    </cfif>
    
    <!--- Load template content --->
    <cfset var templateContent = themeLoader.loadTemplate(arguments.themeName, arguments.template)>
    
    <cfif NOT len(templateContent)>
        <cfthrow message="Template not found: #arguments.template# in theme #arguments.themeName#">
    </cfif>
    
    <!--- Check for layout inheritance --->
    <cfset var layoutName = themeLoader.getTemplateLayout(templateContent)>
    <cfset var processedContent = themeLoader.removeLayoutDeclaration(templateContent)>
    
    <!--- Load partials --->
    <cfset var partials = themeLoader.loadPartials(arguments.themeName)>
    
    <!--- Process the template with Handlebars --->
    <cfset var renderedContent = processHandlebars(processedContent, arguments.context, partials, arguments.themeName)>
    
    <!--- If template has a layout, process it --->
    <cfif len(layoutName)>
        <!--- Add rendered content to context as 'body' --->
        <cfset arguments.context.body = renderedContent>
        
        <!--- Render the layout --->
        <cfset renderedContent = renderTheme("#layoutName#.hbs", arguments.context, arguments.themeName)>
    </cfif>
    
    <cfreturn renderedContent>
</cffunction>

<!--- Process Handlebars template --->
<cffunction name="processHandlebars" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="partials" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Process partials first {{> "partial-name"}} --->
    <cfset output = processPartials(output, arguments.partials, arguments.context, arguments.themeName)>
    
    <!--- Process block helpers --->
    <cfset output = processBlockHelpers(output, arguments.context, arguments.themeName)>
    
    <!--- Process variables {{variable}} and {{{variable}}} --->
    <cfset output = processVariables(output, arguments.context, arguments.themeName)>
    
    <!--- Process helper functions --->
    <cfset output = processHelpers(output, arguments.context, arguments.themeName)>
    
    <cfreturn output>
</cffunction>

<!--- Process partials --->
<cffunction name="processPartials" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="partials" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var output = arguments.template>
    <cfset var partialPattern = '{{>\s*"([^"]+)"}}'>
    <cfset var matches = reMatch(partialPattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var partialName = reReplace(match, '{{>\s*"', '')>
        <cfset partialName = reReplace(partialName, '"}}', '')>
        
        <cfif structKeyExists(arguments.partials, partialName)>
            <!--- Process the partial with current context --->
            <cfset var partialContent = processHandlebars(arguments.partials[partialName], arguments.context, arguments.partials, arguments.themeName)>
            <cfset output = replace(output, match, partialContent, "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process block helpers like {{#foreach}} {{#if}} etc --->
<cffunction name="processBlockHelpers" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Process {{#foreach posts}} --->
    <cfset output = processForeachHelper(output, arguments.context)>
    
    <!--- Process {{#if}} --->
    <cfset output = processIfHelper(output, arguments.context)>
    
    <!--- Process {{#unless}} --->
    <cfset output = processUnlessHelper(output, arguments.context)>
    
    <cfreturn output>
</cffunction>

<!--- Process foreach helper --->
<cffunction name="processForeachHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '{{#foreach\s+([^}]+)}}([\s\S]*?){{/foreach}}'>
    
    <!--- Find all foreach blocks --->
    <cfset var pos = 1>
    <cfloop condition="true">
        <cfset var match = reFind(pattern, output, pos, true)>
        <cfif match.pos[1] EQ 0>
            <cfbreak>
        </cfif>
        
        <cfset var fullMatch = mid(output, match.pos[1], match.len[1])>
        <cfset var varName = mid(output, match.pos[2], match.len[2])>
        <cfset var content = mid(output, match.pos[3], match.len[3])>
        
        <!--- Get the array/query to loop over --->
        <cfif structKeyExists(arguments.context, varName)>
            <cfset var loopData = arguments.context[varName]>
            <cfset var loopOutput = "">
            
            <!--- Handle arrays --->
            <cfif isArray(loopData)>
                <cfloop from="1" to="#arrayLen(loopData)#" index="i">
                    <cfset var itemContext = duplicate(arguments.context)>
                    <cfset itemContext["this"] = loopData[i]>
                    <cfset itemContext["@index"] = i - 1>
                    <cfset itemContext["@number"] = i>
                    <cfset itemContext["@first"] = (i EQ 1)>
                    <cfset itemContext["@last"] = (i EQ arrayLen(loopData))>
                    
                    <cfset loopOutput &= processHandlebars(content, itemContext, {}, "")>
                </cfloop>
            <!--- Handle queries --->
            <cfelseif isQuery(loopData)>
                <cfloop query="loopData">
                    <cfset var itemContext = duplicate(arguments.context)>
                    <!--- Add all columns as properties --->
                    <cfloop list="#loopData.columnList#" index="col">
                        <cfset itemContext[col] = loopData[col][loopData.currentRow]>
                    </cfloop>
                    <cfset itemContext["@index"] = loopData.currentRow - 1>
                    <cfset itemContext["@number"] = loopData.currentRow>
                    <cfset itemContext["@first"] = (loopData.currentRow EQ 1)>
                    <cfset itemContext["@last"] = (loopData.currentRow EQ loopData.recordCount)>
                    
                    <cfset loopOutput &= processHandlebars(content, itemContext, {}, "")>
                </cfloop>
            </cfif>
            
            <cfset output = replace(output, fullMatch, loopOutput)>
        <cfelse>
            <cfset output = replace(output, fullMatch, "")>
        </cfif>
        
        <cfset pos = match.pos[1] + len(loopOutput)>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process if helper --->
<cffunction name="processIfHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '{{#if\s+([^}]+)}}([\s\S]*?){{/if}}'>
    
    <cfloop condition="reFind(pattern, output)">
        <cfset var match = reFind(pattern, output, 1, true)>
        <cfif match.pos[1] EQ 0>
            <cfbreak>
        </cfif>
        
        <cfset var fullMatch = mid(output, match.pos[1], match.len[1])>
        <cfset var condition = trim(mid(output, match.pos[2], match.len[2]))>
        <cfset var content = mid(output, match.pos[3], match.len[3])>
        
        <!--- Evaluate condition --->
        <cfset var conditionMet = false>
        <cfif structKeyExists(arguments.context, condition)>
            <cfset var value = arguments.context[condition]>
            <cfif isBoolean(value)>
                <cfset conditionMet = value>
            <cfelseif isNumeric(value)>
                <cfset conditionMet = value NEQ 0>
            <cfelseif isSimpleValue(value)>
                <cfset conditionMet = len(trim(value)) GT 0>
            <cfelseif isArray(value)>
                <cfset conditionMet = arrayLen(value) GT 0>
            <cfelseif isStruct(value)>
                <cfset conditionMet = structCount(value) GT 0>
            </cfif>
        </cfif>
        
        <cfif conditionMet>
            <cfset output = replace(output, fullMatch, processHandlebars(content, arguments.context, {}, ""))>
        <cfelse>
            <cfset output = replace(output, fullMatch, "")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process unless helper (opposite of if) --->
<cffunction name="processUnlessHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '{{#unless\s+([^}]+)}}([\s\S]*?){{/unless}}'>
    
    <cfloop condition="reFind(pattern, output)">
        <cfset var match = reFind(pattern, output, 1, true)>
        <cfif match.pos[1] EQ 0>
            <cfbreak>
        </cfif>
        
        <cfset var fullMatch = mid(output, match.pos[1], match.len[1])>
        <cfset var condition = trim(mid(output, match.pos[2], match.len[2]))>
        <cfset var content = mid(output, match.pos[3], match.len[3])>
        
        <!--- Evaluate condition (opposite of if) --->
        <cfset var conditionMet = true>
        <cfif structKeyExists(arguments.context, condition)>
            <cfset var value = arguments.context[condition]>
            <cfif isBoolean(value)>
                <cfset conditionMet = NOT value>
            <cfelseif isNumeric(value)>
                <cfset conditionMet = value EQ 0>
            <cfelseif isSimpleValue(value)>
                <cfset conditionMet = len(trim(value)) EQ 0>
            <cfelseif isArray(value)>
                <cfset conditionMet = arrayLen(value) EQ 0>
            <cfelseif isStruct(value)>
                <cfset conditionMet = structCount(value) EQ 0>
            </cfif>
        </cfif>
        
        <cfif conditionMet>
            <cfset output = replace(output, fullMatch, processHandlebars(content, arguments.context, {}, ""))>
        <cfelse>
            <cfset output = replace(output, fullMatch, "")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process variables --->
<cffunction name="processVariables" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Process unescaped variables {{{variable}}} first --->
    <cfset var unescapedPattern = '{{{([^}]+)}}}'>
    <cfset var matches = reMatch(unescapedPattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varName = trim(reReplace(match, '{{{', ''))>
        <cfset varName = reReplace(varName, '}}}', '')>
        <cfset var value = getContextValue(varName, arguments.context)>
        <cfset output = replace(output, match, value, "all")>
    </cfloop>
    
    <!--- Process escaped variables {{variable}} --->
    <cfset var escapedPattern = '{{([^#{}]+)}}'>
    <cfset matches = reMatch(escapedPattern, output)>
    
    <cfloop array="#matches#" index="match">
        <!--- Skip helpers and block expressions --->
        <cfif NOT reFind('^{{[#/>]', match)>
            <cfset var varName = trim(reReplace(match, '{{', ''))>
            <cfset varName = reReplace(varName, '}}', '')>
            
            <!--- Skip if it's a helper function --->
            <cfif NOT reFind('\(', varName)>
                <cfset var value = getContextValue(varName, arguments.context)>
                <cfset value = htmlEditFormat(value)>
                <cfset output = replace(output, match, value, "all")>
            </cfif>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Get value from context (supports dot notation) --->
<cffunction name="getContextValue" access="private" returntype="string">
    <cfargument name="path" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var parts = listToArray(arguments.path, ".")>
    <cfset var current = arguments.context>
    
    <cfloop array="#parts#" index="part">
        <cfif isStruct(current) AND structKeyExists(current, part)>
            <cfset current = current[part]>
        <cfelseif part EQ "@site" AND structKeyExists(arguments.context, "site")>
            <cfset current = arguments.context.site>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cfloop>
    
    <cfif isSimpleValue(current)>
        <cfreturn current>
    <cfelse>
        <cfreturn "">
    </cfif>
</cffunction>

<!--- Process helper functions --->
<cffunction name="processHelpers" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Process {{asset}} helper --->
    <cfset output = processAssetHelper(output, arguments.themeName)>
    
    <!--- Process {{date}} helper --->
    <cfset output = processDateHelper(output, arguments.context)>
    
    <!--- Process {{img_url}} helper --->
    <cfset output = processImgUrlHelper(output, arguments.context)>
    
    <!--- Process {{url}} helper --->
    <cfset output = processUrlHelper(output, arguments.context)>
    
    <!--- Process {{body_class}} helper --->
    <cfset output = replace(output, "{{body_class}}", getBodyClass(arguments.context), "all")>
    
    <!--- Process {{post_class}} helper --->
    <cfset output = replace(output, "{{post_class}}", getPostClass(arguments.context), "all")>
    
    <!--- Process {{ghost_head}} helper --->
    <cfset output = replace(output, "{{ghost_head}}", getGhostHead(arguments.context), "all")>
    
    <!--- Process {{ghost_foot}} helper --->
    <cfset output = replace(output, "{{ghost_foot}}", getGhostFoot(arguments.context), "all")>
    
    <!--- Process {{navigation}} helper --->
    <cfset output = replace(output, "{{navigation}}", getNavigation(arguments.context), "all")>
    
    <!--- Process {{meta_title}} helper --->
    <cfset output = replace(output, "{{meta_title}}", getMetaTitle(arguments.context), "all")>
    
    <cfreturn output>
</cffunction>

<!--- Process asset helper --->
<cffunction name="processAssetHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '{{asset\s+"([^"]+)"}}'>
    <cfset var matches = reMatch(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var assetPath = reReplace(match, '{{asset\s+"', '')>
        <cfset assetPath = reReplace(assetPath, '"}}', '')>
        <cfset var assetUrl = themeLoader.getAssetUrl(arguments.themeName, assetPath)>
        <cfset output = replace(output, match, assetUrl, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process date helper --->
<cffunction name="processDateHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '{{date\s+format="([^"]+)"}}'>
    <cfset var matches = reMatch(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var format = reReplace(match, '{{date\s+format="', '')>
        <cfset format = reReplace(format, '"}}', '')>
        
        <!--- Convert Ghost date format to CF date format --->
        <cfset var cfFormat = format>
        <cfset cfFormat = replace(cfFormat, "YYYY", "yyyy", "all")>
        <cfset cfFormat = replace(cfFormat, "DD", "dd", "all")>
        <cfset cfFormat = replace(cfFormat, "MMM", "mmm", "all")>
        
        <cfset var dateValue = now()>
        <cfif structKeyExists(arguments.context, "published_at")>
            <cfset dateValue = arguments.context.published_at>
        </cfif>
        
        <cfset var formattedDate = dateFormat(dateValue, cfFormat)>
        <cfset output = replace(output, match, formattedDate, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process img_url helper --->
<cffunction name="processImgUrlHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '{{img_url\s+([^\s]+)(\s+[^}]+)?}}'>
    <cfset var matches = reMatch(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <!--- For now, just return the image URL as-is --->
        <cfset var parts = reReplace(match, '{{img_url\s+', '')>
        <cfset parts = reReplace(parts, '}}', '')>
        <cfset var imagePath = listFirst(parts, " ")>
        
        <cfset var imageUrl = getContextValue(imagePath, arguments.context)>
        <cfset imageUrl = replace(imageUrl, "__GHOST_URL__", "/ghost", "all")>
        
        <cfset output = replace(output, match, imageUrl, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process url helper --->
<cffunction name="processUrlHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Simple {{url}} replacement --->
    <cfif structKeyExists(arguments.context, "slug")>
        <cfset var postUrl = "/ghost/blog/" & arguments.context.slug & "/">
        <cfset output = replace(output, "{{url}}", postUrl, "all")>
    </cfif>
    
    <cfreturn output>
</cffunction>

<!--- Helper functions --->
<cffunction name="getBodyClass" access="private" returntype="string">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var classes = []>
    
    <!--- Add template type classes --->
    <cfif structKeyExists(arguments.context, "template")>
        <cfset arrayAppend(classes, arguments.context.template & "-template")>
    </cfif>
    
    <cfreturn arrayToList(classes, " ")>
</cffunction>

<cffunction name="getPostClass" access="private" returntype="string">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var classes = ["post"]>
    
    <cfif structKeyExists(arguments.context, "featured") AND arguments.context.featured>
        <cfset arrayAppend(classes, "featured")>
    </cfif>
    
    <cfif structKeyExists(arguments.context, "page") AND arguments.context.page>
        <cfset arrayAppend(classes, "page")>
    </cfif>
    
    <cfreturn arrayToList(classes, " ")>
</cffunction>

<cffunction name="getGhostHead" access="private" returntype="string">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var head = "">
    <cfset head &= '<meta name="generator" content="Ghost CFML">'>
    
    <cfreturn head>
</cffunction>

<cffunction name="getGhostFoot" access="private" returntype="string">
    <cfargument name="context" type="struct" required="true">
    
    <cfreturn "">
</cffunction>

<cffunction name="getNavigation" access="private" returntype="string">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var nav = '<ul class="nav">'>
    <cfset nav &= '<li class="nav-home"><a href="/ghost/blog/">Home</a></li>'>
    
    <!--- Add navigation items from database if available --->
    
    <cfset nav &= '</ul>'>
    
    <cfreturn nav>
</cffunction>

<cffunction name="getMetaTitle" access="private" returntype="string">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var title = "">
    
    <cfif structKeyExists(arguments.context, "title")>
        <cfset title = arguments.context.title>
    </cfif>
    
    <cfif structKeyExists(arguments.context, "site") AND structKeyExists(arguments.context.site, "title")>
        <cfif len(title)>
            <cfset title &= " - ">
        </cfif>
        <cfset title &= arguments.context.site.title>
    </cfif>
    
    <cfreturn title>
</cffunction>