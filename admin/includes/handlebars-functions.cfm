<!--- Handlebars Template Processing Functions for Ghost CFML --->

<!--- Main function to process Handlebars templates --->
<cffunction name="processHandlebarsTemplate" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="depth" type="numeric" required="false" default="0">
    
    <!--- Prevent infinite recursion --->
    <cfif arguments.depth GT 10>
        <cfreturn arguments.template>
    </cfif>
    
    <cfset var output = arguments.template>
    
    <!--- Remove Handlebars comments {{!-- comment --}} --->
    <cfset output = reReplace(output, '\{\{!--[\s\S]*?--\}\}', '', 'all')>
    
    <!--- Don't process {{!< layout}} here - let renderThemeTemplate handle it --->
    
    <!--- Process {{#contentFor}} blocks first (collect content) --->
    <cfset output = processContentForBlocks(output, arguments.context)>
    
    <!--- Process {{> partial}} includes --->
    <cfset output = processPartialIncludes(output, arguments.context, arguments.depth)>
    
    <!--- Process {{#if}} blocks --->
    <cfset output = processIfBlocks(output, arguments.context)>
    
    <!--- Process {{#unless}} blocks --->
    <cfset output = processUnlessBlocks(output, arguments.context)>
    
    <!--- Process {{#is}} blocks --->
    <cfset output = processIsBlocks(output, arguments.context)>
    
    <!--- Process {{else}} statements --->
    <cfset output = processElseStatements(output, arguments.context)>
    
    <!--- Process {{#foreach}} blocks --->
    <cflog text="Before processForeachBlocks: '#left(output, 100)#'" file="ghost-debug">
    <cfset output = processForeachBlocks(output, arguments.context, arguments.depth)>
    <cflog text="After processForeachBlocks: '#left(output, 100)#'" file="ghost-debug">
    
    <!--- Process {{#match}} blocks --->
    <cfset output = processMatchBlocks(output, arguments.context)>
    
    <!--- Process {{#get}} blocks (Ghost specific) --->
    <cfset output = processGetBlocks(output, arguments.context)>
    
    <!--- Process simple variables {{variable}} --->
    <cfset output = processVariables(output, arguments.context)>
    
    <!--- Process {{ghost_head}} and {{ghost_foot}} --->
    <cfset output = replace(output, "{{ghost_head}}", getGhostHead(), "all")>
    <cfset output = replace(output, "{{ghost_foot}}", getGhostFoot(), "all")>
    
    <!--- Process {{{body}}} (triple braces for unescaped content) --->
    <cfif structKeyExists(arguments.context, "body")>
        <cflog text="Replacing {{{body}}} with: '#arguments.context.body#'" file="ghost-debug">
        <cfset output = replace(output, "{{{body}}}", arguments.context.body, "all")>
    <cfelse>
        <cflog text="No body content found in context" file="ghost-debug">
        <cfset output = replace(output, "{{{body}}}", "", "all")>
    </cfif>
    
    <!--- Process {{asset}} helper --->
    <cfset output = processAssetHelper(output, arguments.context)>
    
    <!--- Process {{date}} helper --->
    <cfset output = processDateHelper(output, arguments.context)>
    
    <!--- Process {{img_url}} helper --->
    <cfset output = processImgUrlHelper(output, arguments.context)>
    
    <!--- Process {{#block}} helpers --->
    <cfset output = processBlockHelpers(output, arguments.context)>
    
    <!--- Process {{meta_title}} and {{meta_description}} --->
    <cfif structKeyExists(arguments.context, "meta_title")>
        <cfset output = replace(output, "{{meta_title}}", arguments.context.meta_title, "all")>
    </cfif>
    <cfif structKeyExists(arguments.context, "meta_description")>
        <cfset output = replace(output, "{{meta_description}}", arguments.context.meta_description, "all")>
    </cfif>
    
    <!--- Process {{canonical_url}} --->
    <cfif structKeyExists(arguments.context, "canonical_url")>
        <cfset output = replace(output, "{{canonical_url}}", arguments.context.canonical_url, "all")>
    </cfif>
    
    <!--- Process {{body_class}} --->
    <cfif structKeyExists(arguments.context, "body_class")>
        <cfset output = replace(output, "{{body_class}}", arguments.context.body_class, "all")>
    </cfif>
    
    <!--- Process {{post_class}} --->
    <cfif structKeyExists(arguments.context, "post_class")>
        <cfset output = replace(output, "{{post_class}}", arguments.context.post_class, "all")>
    </cfif>
    
    <!--- Process {{pagination}} helper --->
    <cfset output = processPaginationHelper(output, arguments.context)>
    
    <!--- Process {{t}} translation helper --->
    <cfset output = processTranslationHelper(output, arguments.context)>
    
    <!--- Process @site variables --->
    <cfset output = processSiteVariables(output, arguments.context)>
    
    <!--- Process @custom variables --->
    <cfset output = processCustomVariables(output, arguments.context)>
    
    <!--- Debug: Final output check --->
    <cfif len(trim(output)) LT 10>
        <cflog text="WARNING: processHandlebarsTemplate returning short output: '#output#' from template: '#left(arguments.template, 100)#'" file="ghost-debug">
        <cflog text="Full output: '#output#'" file="ghost-debug">
    </cfif>
    
    <!--- Check for lone closing braces --->
    <cfif trim(output) EQ "}">
        <cflog text="ERROR: Output is just a closing brace! Original template was: '#arguments.template#'" file="ghost-debug">
        <!--- Return empty string instead of just } --->
        <cfreturn "">
    </cfif>
    
    <cfreturn output>
</cffunction>

<!--- Process simple variables --->
<cffunction name="processVariables" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var matches = reMatch('\{\{([^}##/!]+)\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplace(match, '\{\{|\}\}', '', 'all'))>
        <cfset var value = getValueFromPath(arguments.context, varPath)>
        
        <!--- Convert value to string for output --->
        <cfif isSimpleValue(value)>
            <!--- Don't escape HTML for certain variables that contain markup --->
            <cfif varPath EQ "navigation" OR varPath EQ "ghost_head" OR varPath EQ "ghost_foot">
                <cfset output = replace(output, match, value, "all")>
            <cfelse>
                <cfset output = replace(output, match, htmlEditFormat(value), "all")>
            </cfif>
        <cfelseif isArray(value)>
            <cfset output = replace(output, match, arrayLen(value), "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Get value from nested path --->
<cffunction name="getValueFromPath" access="private" returntype="any">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="path" type="string" required="true">
    
    <cfset var parts = listToArray(arguments.path, ".")>
    <cfset var current = arguments.context>
    
    <!--- Handle @site special variable --->
    <cfif arrayLen(parts) GT 0 AND parts[1] EQ "@site">
        <cfif structKeyExists(current, "site")>
            <cfset current = current.site>
            <cfset arrayDeleteAt(parts, 1)>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cfif>
    
    <cfloop array="#parts#" index="part">
        <cfif isStruct(current) AND structKeyExists(current, part)>
            <cfset current = current[part]>
        <cfelseif isArray(current) AND part EQ "length">
            <!--- Handle array.length property --->
            <cfreturn arrayLen(current)>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cfloop>
    
    <!--- Return the current value, whatever type it is --->
    <cfreturn current>
</cffunction>

<!--- Process {{#if}} conditional blocks --->
<cffunction name="processIfBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '\{\{##if\s+([^}]+)\}\}([\s\S]*?)\{\{/if\}\}'>
    <cfset var matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var condition = reReplaceNoCase(match, '.*\{\{##if\s+([^}]+)\}\}.*', '\1', 'one')>
        <cfset var content = reReplaceNoCase(match, '\{\{##if[^}]+\}\}([\s\S]*?)\{\{/if\}\}', '\1', 'one')>
        <cfset var conditionValue = getValueFromPath(arguments.context, condition)>
        
        <!--- Check if condition is truthy --->
        <cfset var isTruthy = false>
        <cfif isArray(conditionValue) AND arrayLen(conditionValue) GT 0>
            <cfset isTruthy = true>
        <cfelseif isStruct(conditionValue) AND NOT structIsEmpty(conditionValue)>
            <cfset isTruthy = true>
        <cfelseif isSimpleValue(conditionValue) AND len(trim(conditionValue)) AND conditionValue NEQ false AND conditionValue NEQ 0>
            <cfset isTruthy = true>
        </cfif>
        
        <cfif isTruthy>
            <cfset output = replace(output, match, content, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{#foreach}} loops --->
<cffunction name="processForeachBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="depth" type="numeric" required="false" default="0">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '\{\{##foreach\s+([^}]+)\}\}([\s\S]*?)\{\{/foreach\}\}'>
    <cfset var matches = reMatchNoCase(pattern, output)>
    
    <cflog text="processForeachBlocks: Found #arrayLen(matches)# foreach blocks" file="ghost-debug">
    <cfif arrayLen(matches) GT 0>
        <cflog text="First match: #left(matches[1], 50)#..." file="ghost-debug">
    </cfif>
    
    <cfloop array="#matches#" index="match">
        <cfset var arrayName = trim(reReplaceNoCase(match, '.*\{\{##foreach\s+([^\s}]+).*\}\}.*', '\1', 'one'))>
        <cfset var content = reReplaceNoCase(match, '\{\{##foreach[^}]+\}\}([\s\S]*?)\{\{/foreach\}\}', '\1', 'one')>
        
        <cfif structKeyExists(arguments.context, arrayName) AND isArray(arguments.context[arrayName])>
            <cfset var loopOutput = "">
            <cfif arrayLen(arguments.context[arrayName]) GT 0>
                <cfloop array="#arguments.context[arrayName]#" index="item">
                    <!--- Create a new context with the current item --->
                    <cfset var itemContext = duplicate(arguments.context)>
                    <cfif isStruct(item)>
                        <!--- Add all item properties to the context --->
                        <cfloop collection="#item#" item="key">
                            <cfset itemContext[key] = item[key]>
                        </cfloop>
                    </cfif>
                    <!--- Process the content with the item context --->
                    <cfset var processedContent = processHandlebarsTemplate(content, itemContext, arguments.depth + 1)>
                    <cfset loopOutput &= processedContent>
                </cfloop>
            </cfif>
            <cfset output = replace(output, match, loopOutput, "all")>
        <cfelse>
            <!--- Log when array not found --->
            <cflog text="Array '#arrayName#' not found in context for foreach" file="ghost-debug">
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{asset}} helper --->
<cffunction name="processAssetHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <!--- Handle both single and double quotes --->
    <cfset var matchesDouble = reMatch('\{\{asset\s+"([^"]+)"\}\}', output)>
    <cfset var matchesSingle = reMatch("\{\{asset\s+'([^']+)'\}\}", output)>
    
    <!--- Process double quote matches --->
    <cfloop array="#matchesDouble#" index="match">
        <cfset var assetPath = reReplace(match, '\{\{asset\s+"([^"]+)"\}\}', '\1', 'all')>
        <cfset var themeName = arguments.context.theme.name>
        <!--- Handle both regular assets and built assets --->
        <cfif left(assetPath, 6) EQ "built/">
            <cfset var fullPath = "/ghost/themes/" & themeName & "/assets/" & assetPath>
        <cfelse>
            <cfset var fullPath = "/ghost/themes/" & themeName & "/assets/" & assetPath>
        </cfif>
        <cfset output = replace(output, match, fullPath, "all")>
    </cfloop>
    
    <!--- Process single quote matches --->
    <cfloop array="#matchesSingle#" index="match">
        <cfset var assetPath = reReplace(match, "\{\{asset\s+'([^']+)'\}\}", '\1', 'all')>
        <cfset var themeName = arguments.context.theme.name>
        <!--- Handle both regular assets and built assets --->
        <cfif left(assetPath, 6) EQ "built/">
            <cfset var fullPath = "/ghost/themes/" & themeName & "/assets/" & assetPath>
        <cfelse>
            <cfset var fullPath = "/ghost/themes/" & themeName & "/assets/" & assetPath>
        </cfif>
        <cfset output = replace(output, match, fullPath, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{date}} helper --->
<cffunction name="processDateHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Handle {{date variable format="format"}} --->
    <cfset var matches = reMatch('\{\{date\s+([^\s]+)\s+format="([^"]+)"\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var datePath = reReplace(match, '\{\{date\s+([^\s]+)\s+format="([^"]+)"\}\}', '\1', 'all')>
        <cfset var format = reReplace(match, '\{\{date\s+([^\s]+)\s+format="([^"]+)"\}\}', '\2', 'all')>
        
        <!--- Get the date value from context --->
        <cfset var dateValue = getValueFromPath(arguments.context, datePath)>
        
        <cfif isDate(dateValue)>
            <!--- Convert Ghost date format to CF date format --->
            <cfset var cfFormat = replace(format, "YYYY", "yyyy", "all")>
            <cfset cfFormat = replace(cfFormat, "MM", "mm", "all")>
            <cfset cfFormat = replace(cfFormat, "DD", "dd", "all")>
            <cfset cfFormat = replace(cfFormat, "MMM", "mmm", "all")>
            
            <cfset var formattedDate = dateFormat(dateValue, cfFormat)>
            <cfset output = replace(output, match, formattedDate, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <!--- Handle simple {{date format="format"}} --->
    <cfset matches = reMatch('\{\{date\s+format="([^"]+)"\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var format = reReplace(match, '\{\{date\s+format="([^"]+)"\}\}', '\1', 'all')>
        <cfset var dateValue = now()>
        
        <!--- Convert Ghost date format to CF date format --->
        <cfset var cfFormat = replace(format, "YYYY", "yyyy", "all")>
        <cfset cfFormat = replace(cfFormat, "MM", "mm", "all")>
        <cfset cfFormat = replace(cfFormat, "DD", "dd", "all")>
        <cfset cfFormat = replace(cfFormat, "MMM", "mmm", "all")>
        
        <cfset var formattedDate = dateFormat(dateValue, cfFormat)>
        <cfset output = replace(output, match, formattedDate, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{#get}} blocks (Ghost specific) --->
<cffunction name="processGetBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <!--- For now, remove {{\#get}} blocks as they require database queries --->
    <cfset var output = reReplace(arguments.template, '\{\{##get[^}]+\}\}[\s\S]*?\{\{/get\}\}', '', 'all')>
    
    <cfreturn output>
</cffunction>

<!--- Process {{pagination}} helper --->
<cffunction name="processPaginationHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <cfif structKeyExists(arguments.context, "pagination")>
        <cfset var paginationHtml = "">
        <cfset var pagination = arguments.context.pagination>
        
        <cfif structKeyExists(pagination, "pages") AND pagination.pages GT 1>
            <cfset paginationHtml &= '<nav class="pagination">'>
            
            <!--- Previous page --->
            <cfif structKeyExists(pagination, "prev") AND pagination.prev>
                <cfset paginationHtml &= '<a class="pagination-prev" href="?page=' & pagination.prev & '">Previous</a>'>
            </cfif>
            
            <!--- Page numbers --->
            <cfif structKeyExists(pagination, "pages") AND structKeyExists(pagination, "page")>
                <cfloop from="1" to="#pagination.pages#" index="i">
                    <cfif i EQ pagination.page>
                        <cfset paginationHtml &= '<span class="pagination-current">' & i & '</span>'>
                    <cfelse>
                        <cfset paginationHtml &= '<a class="pagination-page" href="?page=' & i & '">' & i & '</a>'>
                    </cfif>
                </cfloop>
            </cfif>
            
            <!--- Next page --->
            <cfif structKeyExists(pagination, "next") AND pagination.next>
                <cfset paginationHtml &= '<a class="pagination-next" href="?page=' & pagination.next & '">Next</a>'>
            </cfif>
            
            <cfset paginationHtml &= '</nav>'>
        </cfif>
        
        <cfset output = replace(output, "{{pagination}}", paginationHtml, "all")>
    <cfelse>
        <cfset output = replace(output, "{{pagination}}", "", "all")>
    </cfif>
    
    <cfreturn output>
</cffunction>

<!--- Get Ghost Head content --->
<cffunction name="getGhostHead" access="private" returntype="string">
    <cfset var output = "">
    
    <!--- Add meta tags, structured data, etc. --->
    <cfset output &= '<!-- Ghost Head -->' & chr(10)>
    <cfset output &= '<meta name="generator" content="Ghost CFML 1.0" />' & chr(10)>
    
    <cfreturn output>
</cffunction>

<!--- Get Ghost Foot content --->
<cffunction name="getGhostFoot" access="private" returntype="string">
    <cfset var output = "">
    
    <!--- Add analytics, custom scripts, etc. --->
    <cfset output &= '<!-- Ghost Foot -->' & chr(10)>
    
    <cfreturn output>
</cffunction>

<!--- Get active theme --->
<cffunction name="getActiveTheme" access="public" returntype="struct">
    <cfargument name="dsn" type="string" required="true">
    
    <!--- Get active theme from database --->
    <cfquery name="qActiveTheme" datasource="#arguments.dsn#">
        SELECT value
        FROM settings
        WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif qActiveTheme.recordCount GT 0 AND len(qActiveTheme.value)>
        <cfset var themeName = qActiveTheme.value>
    <cfelse>
        <cfset var themeName = "default">
    </cfif>
    
    <!--- Validate theme exists --->
    <cfset var themePath = expandPath("/ghost/themes/#themeName#/")>
    <cfif NOT directoryExists(themePath)>
        <!--- Fall back to default theme --->
        <cfset themeName = "default">
    </cfif>
    
    <cfset var theme = {
        "name": themeName,
        "path": "/ghost/themes/" & themeName & "/"
    }>
    
    <cfreturn theme>
</cffunction>

<!--- Process {{> partial}} includes --->
<cffunction name="processPartialIncludes" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="depth" type="numeric" required="false" default="0">
    
    <cfset var output = arguments.template>
    
    <!--- Handle partials with double quotes --->
    <cfset var matchesDouble = reMatch('\{\{>\s*"([^"]+)"\}\}', output)>
    <cfloop array="#matchesDouble#" index="match">
        <cfset var partialName = trim(reReplace(match, '\{\{>\s*"([^"]+)"\}\}', '\1', 'all'))>
        <cfset var partialPath = expandPath(arguments.context.theme.path & "partials/" & partialName & ".hbs")>
        
        <cfif fileExists(partialPath)>
            <cffile action="read" file="#partialPath#" variable="partialContent">
            <!--- Process the partial with the current context --->
            <cfset var processedPartial = processHandlebarsTemplate(partialContent, arguments.context, arguments.depth + 1)>
            <cfset output = replace(output, match, processedPartial, "all")>
        <cfelse>
            <!--- Return empty string for icon partials if not found --->
            <cfif findNoCase("icons/", partialName)>
                <cfset output = replace(output, match, "", "all")>
            <cfelse>
                <cfset output = replace(output, match, "<!-- Partial not found: " & partialName & " -->", "all")>
            </cfif>
        </cfif>
    </cfloop>
    
    <!--- Handle partials without quotes --->
    <cfset var matchesNoQuotes = reMatch('\{\{>\s*([^}"]+)\}\}', output)>
    <cfloop array="#matchesNoQuotes#" index="match">
        <cfset var partialName = trim(reReplace(match, '\{\{>\s*([^}"]+)\}\}', '\1', 'all'))>
        <cfset var partialPath = expandPath(arguments.context.theme.path & "partials/" & partialName & ".hbs")>
        
        <cfif fileExists(partialPath)>
            <cffile action="read" file="#partialPath#" variable="partialContent">
            <!--- Process the partial with the current context --->
            <cfset var processedPartial = processHandlebarsTemplate(partialContent, arguments.context, arguments.depth + 1)>
            <cfset output = replace(output, match, processedPartial, "all")>
        <cfelse>
            <cfset output = replace(output, match, "<!-- Partial not found: " & partialName & " -->", "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{#contentFor}} blocks --->
<cffunction name="processContentForBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Initialize content blocks if not exists --->
    <cfif NOT structKeyExists(arguments.context, "_contentBlocks")>
        <cfset arguments.context._contentBlocks = {}>
    </cfif>
    
    <!--- Find and extract contentFor blocks --->
    <cfset var pattern = '\{\{##contentFor\s+"([^"]+)"\}\}([\s\S]*?)\{\{/contentFor\}\}'>
    <cfset var matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var blockName = reReplaceNoCase(match, '.*\{\{##contentFor\s+"([^"]+)"\}\}.*', '\1', 'one')>
        <cfset var blockContent = reReplaceNoCase(match, '\{\{##contentFor[^}]+\}\}([\s\S]*?)\{\{/contentFor\}\}', '\1', 'one')>
        
        <!--- Store the content block --->
        <cfset arguments.context._contentBlocks[blockName] = blockContent>
        
        <!--- Remove the contentFor block from output --->
        <cfset output = replace(output, match, "", "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{#block}} helpers --->
<cffunction name="processBlockHelpers" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Replace block helpers with stored content --->
    <cfif structKeyExists(arguments.context, "_contentBlocks")>
        <cfset var matches = reMatch('\{\{\{block\s+"([^"]+)"\}\}\}', output)>
        
        <cfloop array="#matches#" index="match">
            <cfset var blockName = reReplace(match, '\{\{\{block\s+"([^"]+)"\}\}\}', '\1', 'all')>
            
            <cfif structKeyExists(arguments.context._contentBlocks, blockName)>
                <cfset output = replace(output, match, arguments.context._contentBlocks[blockName], "all")>
            <cfelse>
                <cfset output = replace(output, match, "", "all")>
            </cfif>
        </cfloop>
    </cfif>
    
    <cfreturn output>
</cffunction>

<!--- Process {{img_url}} helper --->
<cffunction name="processImgUrlHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var matches = reMatch('\{\{img_url\s+([^\s}]+)(?:\s+size="([^"]+)")?\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var parts = reMatch('([^\s]+)(?:\s+size="([^"]+)")?', match)>
        <cfset var imagePath = reReplace(match, '\{\{img_url\s+([^\s}]+).*\}\}', '\1', 'all')>
        
        <!--- For now, just return the image path as-is --->
        <cfset output = replace(output, match, imagePath, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{t}} translation helper --->
<cffunction name="processTranslationHelper" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var matches = reMatch('\{\{t\s+"([^"]+)"\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var translationKey = reReplace(match, '\{\{t\s+"([^"]+)"\}\}', '\1', 'all')>
        <!--- For now, just return the translation key as the translation --->
        <cfset output = replace(output, match, translationKey, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process @site variables --->
<cffunction name="processSiteVariables" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Process @site.variable patterns --->
    <cfif structKeyExists(arguments.context, "site")>
        <cfset var matches = reMatch('\{\{@site\.([^}]+)\}\}', output)>
        
        <cfloop array="#matches#" index="match">
            <cfset var varName = reReplace(match, '\{\{@site\.([^}]+)\}\}', '\1', 'all')>
            
            <cfif structKeyExists(arguments.context.site, varName)>
                <cfset output = replace(output, match, arguments.context.site[varName], "all")>
            <cfelse>
                <cfset output = replace(output, match, "", "all")>
            </cfif>
        </cfloop>
    </cfif>
    
    <cfreturn output>
</cffunction>

<!--- Process {{#unless}} blocks --->
<cffunction name="processUnlessBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var pattern = '\{\{##unless\s+([^}]+)\}\}([\s\S]*?)\{\{/unless\}\}'>
    <cfset var matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var condition = reReplaceNoCase(match, '.*\{\{##unless\s+([^}]+)\}\}.*', '\1', 'one')>
        <cfset var fullContent = reReplaceNoCase(match, '\{\{##unless[^}]+\}\}([\s\S]*?)\{\{/unless\}\}', '\1', 'one')>
        <cfset var conditionValue = getValueFromPath(arguments.context, condition)>
        
        <!--- Check if there's an {{else}} block --->
        <cfset var elsePos = findNoCase("{{else}}", fullContent)>
        <cfset var showContent = "">
        
        <cfif elsePos GT 0>
            <!--- Has else block --->
            <cfset var beforeElse = left(fullContent, elsePos - 1)>
            <cfset var afterElse = mid(fullContent, elsePos + 9, len(fullContent))>
            
            <!--- Unless means show beforeElse if condition is false/empty --->
            <cfif NOT isBoolean(conditionValue) AND NOT len(trim(toString(conditionValue))) OR (isBoolean(conditionValue) AND NOT conditionValue)>
                <cfset showContent = beforeElse>
            <cfelse>
                <cfset showContent = afterElse>
            </cfif>
        <cfelse>
            <!--- No else block --->
            <cfif NOT isBoolean(conditionValue) AND NOT len(trim(toString(conditionValue))) OR (isBoolean(conditionValue) AND NOT conditionValue)>
                <cfset showContent = fullContent>
            </cfif>
        </cfif>
        
        <cfset output = replace(output, match, showContent, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process {{#is}} blocks --->
<cffunction name="processIsBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <!--- For now, just remove {{#is}} blocks as they require context-aware logic --->
    <cfset output = reReplace(output, '\{\{##is[^}]+\}\}', '', 'all')>
    <cfset output = reReplace(output, '\{\{/is\}\}', '', 'all')>
    
    <cfreturn output>
</cffunction>

<!--- Process {{else}} statements --->
<cffunction name="processElseStatements" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <!--- This is handled within if/unless blocks, so just remove standalone else --->
    <cfset var output = replace(arguments.template, "{{else}}", "", "all")>
    
    <cfreturn output>
</cffunction>

<!--- Render theme template --->
<cffunction name="renderThemeTemplate" access="public" returntype="string">
    <cfargument name="templateName" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="theme" type="struct" required="true">
    
    <!--- Read template file --->
    <cfset var templatePath = expandPath(arguments.theme.path & arguments.templateName)>
    
    <cfif NOT fileExists(templatePath)>
        <cfthrow message="Template not found: #arguments.templateName#">
    </cfif>
    
    <cffile action="read" file="#templatePath#" variable="templateContent" charset="utf-8">
    
    <!--- Debug: Check template content --->
    <cflog text="Read template #arguments.templateName#, length: #len(templateContent)#" file="ghost-debug">
    
    <!--- Process layout if specified --->
    <cfset var layoutMatch = reMatch('\{\{!<\s*([^}]+)\}\}', templateContent)>
    <cfif arrayLen(layoutMatch)>
        <cfset var layoutName = trim(reReplace(layoutMatch[1], '\{\{!<\s*([^}]+)\}\}', '\1', 'all')) & '.hbs'>
        <cfset var layoutPath = expandPath(arguments.theme.path & layoutName)>
        
        <cfif fileExists(layoutPath)>
            <cffile action="read" file="#layoutPath#" variable="layoutContent">
            
            <!--- Remove the layout directive from inner template --->
            <!--- Match the exact pattern including newlines --->
            <cfset var innerTemplate = reReplace(templateContent, '^\{\{!<[^}]+\}\}\s*', '', 'one')>
            
            <!--- Trim any whitespace --->
            <cfset innerTemplate = trim(innerTemplate)>
            
            <!--- Debug: Check if innerTemplate is just } --->
            <cfif innerTemplate EQ "}">
                <cflog text="ERROR: innerTemplate is just '}' after removing layout directive!" file="ghost-debug">
                <cflog text="Original templateContent length: #len(templateContent)#" file="ghost-debug">
                <cflog text="Layout directive pattern matched: #arrayLen(layoutMatch)#" file="ghost-debug">
                <!--- Try a different approach --->
                <cfset innerTemplate = "<p>Template error - please check theme files</p>">
            </cfif>
            
            <!--- Debug: Log what we're about to process --->
            <cflog text="About to process inner template length: #len(innerTemplate)#" file="ghost-debug">
            <cflog text="Inner template starts with: '#left(innerTemplate, 50)#'" file="ghost-debug">
            
            <!--- Process the inner template first --->
            <cfset var innerContent = processHandlebarsTemplate(innerTemplate, arguments.context, 0)>
            
            <!--- Debug: Log the result --->
            <cflog text="Processed inner content length: #len(innerContent)#" file="ghost-debug">
            <cfif len(innerContent) LT 50>
                <cflog text="Short inner content: '#innerContent#'" file="ghost-debug">
            </cfif>
            
            <!--- If inner content is empty or just whitespace, use a placeholder --->
            <cfif len(trim(innerContent)) EQ 0>
                <cflog text="Inner content is empty, using placeholder" file="ghost-debug">
                <cfset innerContent = "<!-- Empty template -->">
            <cfelseif trim(innerContent) EQ "}">
                <cflog text="ERROR: Inner content is just '}', fixing..." file="ghost-debug">
                <cflog text="Original inner template was: '#innerTemplate#'" file="ghost-debug">
                <cfset innerContent = "<!-- Template processing error -->">
            </cfif>
            
            <!--- Check for lone } character --->
            <cfif trim(innerContent) EQ "}">
                <cflog text="ERROR: Inner content is just '}', setting to empty" file="ghost-debug">
                <cfset innerContent = "">
            </cfif>
            
            <!--- Add the processed inner content to context for layout --->
            <cfset arguments.context.body = innerContent>
            
            <!--- Process the layout with the inner content --->
            <cflog text="About to process layout with body content length: #len(arguments.context.body)#" file="ghost-debug">
            <cfset var finalOutput = processHandlebarsTemplate(layoutContent, arguments.context, 0)>
            <cflog text="Final output from layout: length=#len(finalOutput)#, starts with: #left(finalOutput, 50)#" file="ghost-debug">
            <cfreturn finalOutput>
        </cfif>
    </cfif>
    
    <!--- No layout, just process the template --->
    <cfreturn processHandlebarsTemplate(templateContent, arguments.context, 0)>
</cffunction>

<!--- Get active theme configuration --->
<cffunction name="getActiveTheme" access="public" returntype="struct">
    <cfargument name="datasource" type="string" required="true">
    
    <!--- Get active theme from settings --->
    <cfquery name="qTheme" datasource="#arguments.datasource#">
        SELECT value FROM settings 
        WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfset var themeName = qTheme.recordCount ? qTheme.value : "default">
    <cfset var themePath = "/ghost/themes/" & themeName & "/">
    <cfset var themeFullPath = expandPath(themePath)>
    
    <!--- Check if theme exists --->
    <cfif NOT directoryExists(themeFullPath)>
        <cfset themeName = "default">
        <cfset themePath = "/ghost/themes/default/">
        <cfset themeFullPath = expandPath(themePath)>
    </cfif>
    
    <!--- Get theme configuration --->
    <cfset var themeConfig = {
        "name": themeName,
        "path": themePath,
        "fullPath": themeFullPath,
        "version": "1.0.0",
        "description": "Theme"
    }>
    
    <!--- Try to read package.json --->
    <cfset var packagePath = themeFullPath & "package.json">
    <cfif fileExists(packagePath)>
        <cftry>
            <cffile action="read" file="#packagePath#" variable="packageContent">
            <cfset var packageData = deserializeJSON(packageContent)>
            
            <cfif structKeyExists(packageData, "version")>
                <cfset themeConfig.version = packageData.version>
            </cfif>
            <cfif structKeyExists(packageData, "description")>
                <cfset themeConfig.description = packageData.description>
            </cfif>
            
            <cfcatch>
                <!--- Ignore JSON errors --->
            </cfcatch>
        </cftry>
    </cfif>
    
    <cfreturn themeConfig>
</cffunction>

<!--- Process {{#match}} blocks --->
<cffunction name="processMatchBlocks" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Handle {{#match var "=" "value"}} syntax --->
    <cfset var pattern = '\{\{##match\s+([^\s]+)\s+"="\s+"([^"]+)"\}\}([\s\S]*?)\{\{/match\}\}'>
    <cfset var matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplaceNoCase(match, '.*\{\{##match\s+([^\s]+)\s+"=".*', '\1', 'one'))>
        <cfset var compareValue = reReplaceNoCase(match, '.*\{\{##match\s+[^\s]+\s+"="\s+"([^"]+)"\}\}.*', '\1', 'one')>
        <cfset var content = reReplaceNoCase(match, '\{\{##match[^}]+\}\}([\s\S]*?)\{\{/match\}\}', '\1', 'one')>
        
        <cfset var varValue = getValueFromPath(arguments.context, varPath)>
        
        <!--- Check if values match --->
        <cfif isSimpleValue(varValue) AND varValue EQ compareValue>
            <cfset output = replace(output, match, content, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <!--- Handle {{#match var "value"}} syntax (implicit equals) --->
    <cfset pattern = '\{\{##match\s+([^\s]+)\s+"([^"]+)"\}\}([\s\S]*?)\{\{/match\}\}'>
    <cfset matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplaceNoCase(match, '.*\{\{##match\s+([^\s]+)\s+"[^"]+"\}\}.*', '\1', 'one'))>
        <cfset var compareValue = reReplaceNoCase(match, '.*\{\{##match\s+[^\s]+\s+"([^"]+)"\}\}.*', '\1', 'one')>
        <cfset var content = reReplaceNoCase(match, '\{\{##match[^}]+\}\}([\s\S]*?)\{\{/match\}\}', '\1', 'one')>
        
        <cfset var varValue = getValueFromPath(arguments.context, varPath)>
        
        <!--- Check if values match --->
        <cfif isSimpleValue(varValue) AND varValue EQ compareValue>
            <cfset output = replace(output, match, content, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <!--- Handle {{#match var "!=" "value"}} syntax --->
    <cfset pattern = '\{\{##match\s+([^\s]+)\s+"!="\s+"([^"]+)"\}\}([\s\S]*?)\{\{/match\}\}'>
    <cfset matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplaceNoCase(match, '.*\{\{##match\s+([^\s]+)\s+"!=".*', '\1', 'one'))>
        <cfset var compareValue = reReplaceNoCase(match, '.*\{\{##match\s+[^\s]+\s+"!="\s+"([^"]+)"\}\}.*', '\1', 'one')>
        <cfset var content = reReplaceNoCase(match, '\{\{##match[^}]+\}\}([\s\S]*?)\{\{/match\}\}', '\1', 'one')>
        
        <cfset var varValue = getValueFromPath(arguments.context, varPath)>
        
        <!--- Check if values don't match --->
        <cfif isSimpleValue(varValue) AND varValue NEQ compareValue>
            <cfset output = replace(output, match, content, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <!--- Handle {{^match}} (negation) syntax --->
    <cfset pattern = '\{\{\^match\s+([^\s]+)\s+"([^"]+)"\}\}([\s\S]*?)\{\{/match\}\}'>
    <cfset matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplaceNoCase(match, '.*\{\{\^match\s+([^\s]+)\s+"[^"]+"\}\}.*', '\1', 'one'))>
        <cfset var compareValue = reReplaceNoCase(match, '.*\{\{\^match\s+[^\s]+\s+"([^"]+)"\}\}.*', '\1', 'one')>
        <cfset var content = reReplaceNoCase(match, '\{\{\^match[^}]+\}\}([\s\S]*?)\{\{/match\}\}', '\1', 'one')>
        
        <cfset var varValue = getValueFromPath(arguments.context, varPath)>
        
        <!--- Check if values DON'T match (negation) --->
        <cfif NOT isSimpleValue(varValue) OR varValue NEQ compareValue>
            <cfset output = replace(output, match, content, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process @custom variables --->
<cffunction name="processCustomVariables" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Create default custom settings if not exists --->
    <cfif NOT structKeyExists(arguments.context, "custom")>
        <cfset arguments.context.custom = {
            "navigation_layout": "Stacked",
            "header_style": "Center aligned",
            "show_publication_cover": true,
            "color_scheme": "Light"
        }>
    </cfif>
    
    <!--- Process @custom.variable patterns --->
    <cfset var matches = reMatch('\{\{@custom\.([^}]+)\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varName = reReplace(match, '\{\{@custom\.([^}]+)\}\}', '\1', 'all')>
        
        <cfif structKeyExists(arguments.context.custom, varName)>
            <cfset output = replace(output, match, arguments.context.custom[varName], "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>