<!--- Handlebars Template Processing Functions for Ghost CFML --->

<!--- Main function to process Handlebars templates --->
<cffunction name="processHandlebarsTemplate" access="public" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Remove Handlebars comments {{!-- comment --}} --->
    <cfset output = reReplace(output, '\{\{!--[\s\S]*?--\}\}', '', 'all')>
    
    <!--- Process {{!< layout}} extends --->
    <cfset output = reReplace(output, '\{\{!<\s*([^}]+)\}\}', '', 'all')>
    
    <!--- Process {{#contentFor}} blocks first (collect content) --->
    <cfset output = processContentForBlocks(output, arguments.context)>
    
    <!--- Process {{> partial}} includes --->
    <cfset output = processPartialIncludes(output, arguments.context)>
    
    <!--- Process {{#if}} blocks --->
    <cfset output = processIfBlocks(output, arguments.context)>
    
    <!--- Process {{#unless}} blocks --->
    <cfset output = processUnlessBlocks(output, arguments.context)>
    
    <!--- Process {{#is}} blocks --->
    <cfset output = processIsBlocks(output, arguments.context)>
    
    <!--- Process {{else}} statements --->
    <cfset output = processElseStatements(output, arguments.context)>
    
    <!--- Process {{#foreach}} blocks --->
    <cfset output = processForeachBlocks(output, arguments.context)>
    
    <!--- Process {{#get}} blocks (Ghost specific) --->
    <cfset output = processGetBlocks(output, arguments.context)>
    
    <!--- Process simple variables {{variable}} --->
    <cfset output = processVariables(output, arguments.context)>
    
    <!--- Process {{ghost_head}} and {{ghost_foot}} --->
    <cfset output = replace(output, "{{ghost_head}}", getGhostHead(), "all")>
    <cfset output = replace(output, "{{ghost_foot}}", getGhostFoot(), "all")>
    
    <!--- Process {{{body}}} (triple braces for unescaped content) --->
    <cfif structKeyExists(arguments.context, "body")>
        <cfset output = replace(output, "{{{body}}}", arguments.context.body, "all")>
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
            <cfset output = replace(output, match, htmlEditFormat(value), "all")>
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
    
    <cfset var output = arguments.template>
    <cfset var pattern = '\{\{##foreach\s+([^}]+)\}\}([\s\S]*?)\{\{/foreach\}\}'>
    <cfset var matches = reMatchNoCase(pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var arrayName = trim(reReplaceNoCase(match, '.*\{\{##foreach\s+([^\s}]+).*\}\}.*', '\1', 'one'))>
        <cfset var content = reReplaceNoCase(match, '\{\{##foreach[^}]+\}\}([\s\S]*?)\{\{/foreach\}\}', '\1', 'one')>
        
        <cfif structKeyExists(arguments.context, arrayName) AND isArray(arguments.context[arrayName])>
            <cfset var loopOutput = "">
            <cfloop array="#arguments.context[arrayName]#" index="item">
                <cfset var itemContent = content>
                <!--- Replace item properties --->
                <cfif isStruct(item)>
                    <cfloop collection="#item#" item="key">
                        <cfif isSimpleValue(item[key])>
                            <cfset itemContent = replace(itemContent, "{{" & key & "}}", htmlEditFormat(item[key]), "all")>
                        </cfif>
                    </cfloop>
                </cfif>
                <cfset loopOutput &= itemContent>
            </cfloop>
            <cfset output = replace(output, match, loopOutput, "all")>
        <cfelse>
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
    
    <cfset var output = arguments.template>
    <cfset var matches = reMatch('\{\{>\s*"?([^}"]+)"?\}\}', output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var partialName = trim(reReplace(match, '\{\{>\s*"?([^}"]+)"?\}\}', '\1', 'all'))>
        <cfset var partialPath = expandPath(arguments.context.theme.path & "partials/" & partialName & ".hbs")>
        
        <cfif fileExists(partialPath)>
            <cffile action="read" file="#partialPath#" variable="partialContent">
            <!--- Process the partial with the current context --->
            <cfset var processedPartial = processHandlebarsTemplate(partialContent, arguments.context)>
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
        <cfset var content = reReplaceNoCase(match, '\{\{##unless[^}]+\}\}([\s\S]*?)\{\{/unless\}\}', '\1', 'one')>
        <cfset var conditionValue = getValueFromPath(arguments.context, condition)>
        
        <!--- Unless means show if condition is false/empty --->
        <cfif NOT len(conditionValue) OR conditionValue EQ false>
            <cfset output = replace(output, match, content, "all")>
        <cfelse>
            <cfset output = replace(output, match, "", "all")>
        </cfif>
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
    
    <cffile action="read" file="#templatePath#" variable="templateContent">
    
    <!--- Process layout if specified --->
    <cfset var layoutMatch = reMatch('\{\{!<\s*([^}]+)\}\}', templateContent)>
    <cfif arrayLen(layoutMatch)>
        <cfset var layoutName = trim(reReplace(layoutMatch[1], '\{\{!<\s*([^}]+)\}\}', '\1', 'all')) & '.hbs'>
        <cfset var layoutPath = expandPath(arguments.theme.path & layoutName)>
        
        <cfif fileExists(layoutPath)>
            <cffile action="read" file="#layoutPath#" variable="layoutContent">
            
            <!--- Process the inner template first --->
            <cfset var innerContent = processHandlebarsTemplate(templateContent, arguments.context)>
            
            <!--- Add the processed inner content to context for layout --->
            <cfset arguments.context.body = innerContent>
            
            <!--- Process the layout with the inner content --->
            <cfreturn processHandlebarsTemplate(layoutContent, arguments.context)>
        </cfif>
    </cfif>
    
    <!--- No layout, just process the template --->
    <cfreturn processHandlebarsTemplate(templateContent, arguments.context)>
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