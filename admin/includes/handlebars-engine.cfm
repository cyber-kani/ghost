<!--- Ghost-style Handlebars Engine for CFML --->
<!--- Based on Ghost's implementation but adapted for CFML --->

<!--- Get active theme configuration --->
<cffunction name="getActiveTheme" access="public" returntype="struct">
    <cfargument name="datasource" type="string" required="true">
    
    <cfset var theme = {
        "name": "simple",
        "path": "/ghost/themes/simple/",
        "version": "1.0.0"
    }>
    
    <cfreturn theme>
</cffunction>

<!--- Initialize Handlebars Engine --->
<cffunction name="initHandlebarsEngine" access="public" returntype="struct">
    <cfset var engine = {}>
    
    <!--- Template cache --->
    <cfset engine.templateCache = {}>
    
    <!--- Registered helpers --->
    <cfset engine.helpers = {}>
    
    <!--- Core rendering function --->
    <cfset engine.render = renderTemplate>
    
    <!--- Helper registration --->
    <cfset engine.registerHelper = registerHelper>
    
    <!--- Built-in helpers --->
    <cfset registerCoreHelpers(engine)>
    
    <cfreturn engine>
</cffunction>

<!--- Register a helper function --->
<cffunction name="registerHelper" access="private" returntype="void">
    <cfargument name="engine" type="struct" required="true">
    <cfargument name="name" type="string" required="true">
    <cfargument name="helperFunc" type="any" required="true">
    
    <cfset arguments.engine.helpers[arguments.name] = arguments.helperFunc>
</cffunction>

<!--- Register core helpers --->
<cffunction name="registerCoreHelpers" access="private" returntype="void">
    <cfargument name="engine" type="struct" required="true">
    
    <!--- Register each helper --->
    <cfset engine.registerHelper(engine, "foreach", helperForeach)>
    <cfset engine.registerHelper(engine, "if", helperIf)>
    <cfset engine.registerHelper(engine, "unless", helperUnless)>
    <cfset engine.registerHelper(engine, "match", helperMatch)>
    <cfset engine.registerHelper(engine, "is", helperIs)>
    <cfset engine.registerHelper(engine, "has", helperHas)>
    <cfset engine.registerHelper(engine, "get", helperGet)>
    <cfset engine.registerHelper(engine, "content", helperContent)>
    <cfset engine.registerHelper(engine, "excerpt", helperExcerpt)>
    <cfset engine.registerHelper(engine, "url", helperUrl)>
    <cfset engine.registerHelper(engine, "date", helperDate)>
    <cfset engine.registerHelper(engine, "img_url", helperImgUrl)>
    <cfset engine.registerHelper(engine, "asset", helperAsset)>
    <cfset engine.registerHelper(engine, "body_class", helperBodyClass)>
    <cfset engine.registerHelper(engine, "post_class", helperPostClass)>
    <cfset engine.registerHelper(engine, "ghost_head", helperGhostHead)>
    <cfset engine.registerHelper(engine, "ghost_foot", helperGhostFoot)>
    <cfset engine.registerHelper(engine, "meta_title", helperMetaTitle)>
    <cfset engine.registerHelper(engine, "meta_description", helperMetaDescription)>
    <cfset engine.registerHelper(engine, "navigation", helperNavigation)>
    <cfset engine.registerHelper(engine, "pagination", helperPagination)>
    <cfset engine.registerHelper(engine, "plural", helperPlural)>
    <cfset engine.registerHelper(engine, "encode", helperEncode)>
    <cfset engine.registerHelper(engine, "t", helperTranslate)>
    <cfset engine.registerHelper(engine, "concat", helperConcat)>
    <cfset engine.registerHelper(engine, "link", helperLink)>
    <cfset engine.registerHelper(engine, "link_class", helperLinkClass)>
    <cfset engine.registerHelper(engine, "tags", helperTags)>
    <cfset engine.registerHelper(engine, "authors", helperAuthors)>
    <cfset engine.registerHelper(engine, "reading_time", helperReadingTime)>
    <cfset engine.registerHelper(engine, "prev_post", helperPrevPost)>
    <cfset engine.registerHelper(engine, "next_post", helperNextPost)>
    <cfset engine.registerHelper(engine, "price", helperPrice)>
    <cfset engine.registerHelper(engine, "tiers", helperTiers)>
    <cfset engine.registerHelper(engine, "comments", helperComments)>
    <cfset engine.registerHelper(engine, "collection", helperCollection)>
    <cfset engine.registerHelper(engine, "recommendations", helperRecommendations)>
    <cfset engine.registerHelper(engine, "total_members", helperTotalMembers)>
    <cfset engine.registerHelper(engine, "total_paid_members", helperTotalPaidMembers)>
    <cfset engine.registerHelper(engine, "search", helperSearch)>
    <cfset engine.registerHelper(engine, "cancel_link", helperCancelLink)>
    <cfset engine.registerHelper(engine, "raw", helperRaw)>
</cffunction>

<!--- Main template rendering function --->
<cffunction name="renderTemplate" access="private" returntype="string">
    <cfargument name="engine" type="struct" required="true">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="options" type="struct" required="false" default="#{}#">
    
    <cfset var output = arguments.template>
    <cfset var processedSections = {}>
    
    <!--- Phase 1: Process layout inheritance --->
    <cfset output = processLayoutInheritance(output, arguments.context, arguments.engine, arguments.options)>
    
    <!--- Phase 2: Process partials --->
    <cfset output = processPartials(output, arguments.context, arguments.engine, arguments.options)>
    
    <!--- Phase 3: Process block helpers --->
    <cfset output = processBlockHelpers(output, arguments.context, arguments.engine, processedSections)>
    
    <!--- Phase 4: Process inline helpers --->
    <cfset output = processInlineHelpers(output, arguments.context, arguments.engine)>
    
    <!--- Phase 5: Process variables --->
    <cfset output = processVariables(output, arguments.context)>
    
    <cfreturn output>
</cffunction>

<!--- Process layout inheritance {{!< layout}} --->
<cffunction name="processLayoutInheritance" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    <cfargument name="options" type="struct" required="true">
    
    <cfset var layoutPattern = '{{!<\s*([^}]+)\s*}}'>
    <cfset var matches = reMatchNoCase(layoutPattern, arguments.template)>
    
    <cfif arrayLen(matches)>
        <cfset var layoutName = trim(reReplace(matches[1], '{{!<\s*([^}]+)\s*}}', '\1', 'all'))>
        <cfset var innerContent = reReplace(arguments.template, '{{!<\s*[^}]+\s*}}\s*', '', 'one')>
        
        <!--- Process inner content first --->
        <cfset innerContent = processBlockHelpers(innerContent, arguments.context, arguments.engine, {})>
        <cfset innerContent = processInlineHelpers(innerContent, arguments.context, arguments.engine)>
        <cfset innerContent = processVariables(innerContent, arguments.context)>
        
        <!--- Add body to context --->
        <cfset arguments.context.body = innerContent>
        
        <!--- Load and process layout --->
        <cfif structKeyExists(arguments.options, "themePath")>
            <cfset var layoutPath = arguments.options.themePath & layoutName & ".hbs">
            <cfif fileExists(layoutPath)>
                <cffile action="read" file="#layoutPath#" variable="layoutContent">
                <cfreturn arguments.engine.render(arguments.engine, layoutContent, arguments.context, arguments.options)>
            </cfif>
        </cfif>
    </cfif>
    
    <cfreturn arguments.template>
</cffunction>

<!--- Process partials {{> partial}} --->
<cffunction name="processPartials" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    <cfargument name="options" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var partialPattern = '{{\s*>\s*([^}]+)\s*}}'>
    <cfset var matches = reMatchNoCase(partialPattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var partialName = trim(reReplace(match, '{{\s*>\s*([^}]+)\s*}}', '\1', 'all'))>
        <cfset var partialContent = "">
        
        <!--- Try to load partial --->
        <cfif structKeyExists(arguments.options, "partialsPath")>
            <cfset var partialPath = arguments.options.partialsPath & partialName & ".hbs">
            <cfif fileExists(partialPath)>
                <cffile action="read" file="#partialPath#" variable="partialContent">
                <!--- Process the partial with current context --->
                <cfset partialContent = arguments.engine.render(arguments.engine, partialContent, arguments.context, arguments.options)>
            </cfif>
        </cfif>
        
        <cfset output = replace(output, match, partialContent, "all")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process block helpers --->
<cffunction name="processBlockHelpers" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    <cfargument name="processedSections" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Define patterns for different block helpers --->
    <!--- Using chr(35) for # to avoid CFML parsing issues --->
    <cfset var hashChar = chr(35)>
    <cfset var helperPatterns = [
        {name: "foreach", pattern: '{{' & hashChar & 'foreach\s+([^}]+)}}([\s\S]*?){{/foreach}}'},
        {name: "if", pattern: '{{' & hashChar & 'if\s+([^}]+)}}([\s\S]*?){{/if}}'},
        {name: "unless", pattern: '{{' & hashChar & 'unless\s+([^}]+)}}([\s\S]*?){{/unless}}'},
        {name: "match", pattern: '{{' & hashChar & 'match\s+([^}]+)}}([\s\S]*?){{/match}}'},
        {name: "is", pattern: '{{' & hashChar & 'is\s+([^}]+)}}([\s\S]*?){{/is}}'},
        {name: "has", pattern: '{{' & hashChar & 'has\s+([^}]+)}}([\s\S]*?){{/has}}'},
        {name: "get", pattern: '{{' & hashChar & 'get\s+([^}]+)}}([\s\S]*?){{/get}}'},
        {name: "contentFor", pattern: '{{' & hashChar & 'contentFor\s+([^}]+)}}([\s\S]*?){{/contentFor}}'}
    ]>
    
    <!--- Process each helper type --->
    <cfloop array="#helperPatterns#" index="helperDef">
        <cfif structKeyExists(arguments.engine.helpers, helperDef.name)>
            <cfset output = processHelperType(output, helperDef, arguments.context, arguments.engine, arguments.processedSections)>
        </cfif>
    </cfloop>
    
    <!--- Process {{else}} statements --->
    <cfset output = processElseStatements(output)>
    
    <cfreturn output>
</cffunction>

<!--- Process a specific helper type --->
<cffunction name="processHelperType" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="helperDef" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    <cfargument name="processedSections" type="struct" required="true">
    
    <cfset var output = arguments.template>
    <cfset var matches = reMatchNoCase(arguments.helperDef.pattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var helperArgs = extractHelperArgs(match, arguments.helperDef.name)>
        <cfset var blockContent = extractBlockContent(match, arguments.helperDef.name)>
        
        <!--- Create options object like Handlebars --->
        <cfset var options = {
            fn: createBlockFunction(blockContent, arguments.context, arguments.engine),
            inverse: createInverseFunction(blockContent, arguments.context, arguments.engine),
            hash: helperArgs.hash,
            data: arguments.context
        }>
        
        <!--- Call the helper --->
        <cfset var helperResult = arguments.engine.helpers[arguments.helperDef.name](
            helperArgs.params,
            options,
            arguments.context
        )>
        
        <cfset output = replace(output, match, helperResult, "one")>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Extract helper arguments --->
<cffunction name="extractHelperArgs" access="private" returntype="struct">
    <cfargument name="match" type="string" required="true">
    <cfargument name="helperName" type="string" required="true">
    
    <cfset var hashChar = chr(35)>
    <cfset var pattern = '{{' & hashChar & arguments.helperName & '\s+([^}]+)}}'>
    <cfset var argsString = reReplace(arguments.match, '.*' & pattern & '.*', '\1', 'one')>
    
    <!--- Parse arguments --->
    <cfset var result = {
        params: [],
        hash: {}
    }>
    
    <!--- Simple parsing - split by spaces but respect quotes --->
    <cfset var parts = []>
    <cfset var currentPart = "">
    <cfset var inQuotes = false>
    <cfset var quoteChar = "">
    
    <cfloop from="1" to="#len(argsString)#" index="i">
        <cfset var char = mid(argsString, i, 1)>
        
        <cfif (char EQ '"' OR char EQ "'") AND NOT inQuotes>
            <cfset inQuotes = true>
            <cfset quoteChar = char>
        <cfelseif char EQ quoteChar AND inQuotes>
            <cfset inQuotes = false>
            <cfset arrayAppend(parts, currentPart)>
            <cfset currentPart = "">
        <cfelseif char EQ " " AND NOT inQuotes AND len(currentPart)>
            <cfset arrayAppend(parts, currentPart)>
            <cfset currentPart = "">
        <cfelseif NOT (char EQ " " AND NOT inQuotes AND len(currentPart) EQ 0)>
            <cfset currentPart &= char>
        </cfif>
    </cfloop>
    
    <cfif len(currentPart)>
        <cfset arrayAppend(parts, currentPart)>
    </cfif>
    
    <!--- Separate params from hash arguments --->
    <cfloop array="#parts#" index="part">
        <cfif find("=", part)>
            <cfset var key = listFirst(part, "=")>
            <cfset var value = listRest(part, "=")>
            <cfset result.hash[key] = value>
        <cfelse>
            <cfset arrayAppend(result.params, part)>
        </cfif>
    </cfloop>
    
    <cfreturn result>
</cffunction>

<!--- Extract block content --->
<cffunction name="extractBlockContent" access="private" returntype="string">
    <cfargument name="match" type="string" required="true">
    <cfargument name="helperName" type="string" required="true">
    
    <cfset var hashChar = chr(35)>
    <cfset var pattern = '{{' & hashChar & arguments.helperName & '[^}]+}}([\s\S]*?){{/' & arguments.helperName & '}}'>
    <cfset var content = reReplace(arguments.match, pattern, '\1', 'one')>
    
    <cfreturn content>
</cffunction>

<!--- Create block function --->
<cffunction name="createBlockFunction" access="private" returntype="any">
    <cfargument name="content" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    
    <cfreturn function(itemContext = arguments.context) {
        var processedContent = arguments.content;
        
        // Check for {{else}} and only use content before it
        if (find("{{else}}", processedContent)) {
            processedContent = listFirst(processedContent, "{{else}}");
        }
        
        // Process with the provided context
        return arguments.engine.render(arguments.engine, processedContent, itemContext, {});
    }>
</cffunction>

<!--- Create inverse function --->
<cffunction name="createInverseFunction" access="private" returntype="any">
    <cfargument name="content" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    
    <cfreturn function(itemContext = arguments.context) {
        var processedContent = "";
        
        // Check for {{else}} and only use content after it
        if (find("{{else}}", arguments.content)) {
            processedContent = listLast(arguments.content, "{{else}}");
        }
        
        // Process with the provided context
        if (len(processedContent)) {
            return arguments.engine.render(arguments.engine, processedContent, itemContext, {});
        }
        return "";
    }>
</cffunction>

<!--- Process {{else}} statements --->
<cffunction name="processElseStatements" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    
    <!--- {{else}} is handled within block helpers --->
    <cfreturn arguments.template>
</cffunction>

<!--- Process inline helpers --->
<cffunction name="processInlineHelpers" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="engine" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Pattern for inline helpers {{helper arg1 arg2}} --->
    <cfset var inlinePattern = '{{([a-zA-Z_]+)(\s+[^}]+)?}}'>
    <cfset var matches = reMatchNoCase(inlinePattern, output)>
    
    <cfloop array="#matches#" index="match">
        <!--- Skip block helpers and special tags --->
        <cfset var specialChars = chr(35) & '/!^'>
        <cfif NOT reFind('{{[' & specialChars & ']', match)>
            <cfset var helperName = trim(reReplace(match, '{{([a-zA-Z_]+).*}}', '\1', 'one'))>
            
            <cfif structKeyExists(arguments.engine.helpers, helperName)>
                <cfset var helperArgs = extractHelperArgs(match, helperName)>
                
                <!--- Create minimal options --->
                <cfset var options = {
                    hash: helperArgs.hash,
                    data: arguments.context
                }>
                
                <!--- Call the helper --->
                <cfset var result = arguments.engine.helpers[helperName](
                    helperArgs.params,
                    options,
                    arguments.context
                )>
                
                <cfset output = replace(output, match, result, "one")>
            </cfif>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Process variables --->
<cffunction name="processVariables" access="private" returntype="string">
    <cfargument name="template" type="string" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = arguments.template>
    
    <!--- Process {{{variable}}} (triple braces - unescaped) --->
    <cfset var triplePattern = '{{{([^}]+)}}}'>
    <cfset var matches = reMatchNoCase(triplePattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplace(match, '{{{([^}]+)}}}', '\1', 'all'))>
        <cfset var value = getValueFromPath(arguments.context, varPath)>
        <cfset output = replace(output, match, value, "all")>
    </cfloop>
    
    <!--- Process {{variable}} (double braces - escaped) --->
    <cfset var hashChar = chr(35)>
    <cfset var doublePattern = '{{([^' & hashChar & '/>][^}]*)}}'>
    <cfset matches = reMatchNoCase(doublePattern, output)>
    
    <cfloop array="#matches#" index="match">
        <cfset var varPath = trim(reReplace(match, '{{([^}]+)}}', '\1', 'all'))>
        <cfset var value = getValueFromPath(arguments.context, varPath)>
        
        <!--- Skip if it looks like a helper --->
        <cfif NOT find(" ", varPath) AND NOT find("(", varPath)>
            <cfif isSimpleValue(value)>
                <cfset value = htmlEditFormat(value)>
            </cfif>
            <cfset output = replace(output, match, value, "all")>
        </cfif>
    </cfloop>
    
    <cfreturn output>
</cffunction>

<!--- Get value from path like @site.title or post.author.name --->
<cffunction name="getValueFromPath" access="private" returntype="any">
    <cfargument name="context" type="struct" required="true">
    <cfargument name="path" type="string" required="true">
    
    <cfset var parts = listToArray(arguments.path, ".")>
    <cfset var current = arguments.context>
    
    <!--- Handle special @ variables --->
    <cfif left(parts[1], 1) EQ "@">
        <cfset var specialVar = mid(parts[1], 2, len(parts[1])-1)>
        <cfif structKeyExists(current, specialVar)>
            <cfset current = current[specialVar]>
            <cfset arrayDeleteAt(parts, 1)>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cfif>
    
    <!--- Navigate through the path --->
    <cfloop array="#parts#" index="part">
        <cfif isStruct(current) AND structKeyExists(current, part)>
            <cfset current = current[part]>
        <cfelse>
            <cfreturn "">
        </cfif>
    </cfloop>
    
    <cfreturn current>
</cffunction>

<!--- HELPER IMPLEMENTATIONS --->

<!--- foreach helper --->
<cffunction name="helperForeach" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif arrayLen(arguments.params) EQ 0>
        <cfreturn "">
    </cfif>
    
    <cfset var items = getValueFromPath(arguments.context, arguments.params[1])>
    <cfset var output = "">
    
    <cfif isArray(items) AND arrayLen(items) GT 0>
        <cfset var from = structKeyExists(arguments.options.hash, "from") ? arguments.options.hash.from : 1>
        <cfset var to = structKeyExists(arguments.options.hash, "to") ? arguments.options.hash.to : arrayLen(items)>
        <cfset var limit = structKeyExists(arguments.options.hash, "limit") ? arguments.options.hash.limit : arrayLen(items)>
        
        <cfif limit LT arrayLen(items)>
            <cfset to = min(from + limit - 1, arrayLen(items))>
        </cfif>
        
        <cfloop from="#from#" to="#to#" index="i">
            <cfset var itemContext = duplicate(arguments.context)>
            
            <!--- Add item properties to context --->
            <cfif isStruct(items[i])>
                <cfloop collection="#items[i]#" item="key">
                    <cfset itemContext[key] = items[i][key]>
                </cfloop>
            </cfif>
            
            <!--- Add special @-variables --->
            <cfset itemContext["@index"] = i>
            <cfset itemContext["@number"] = i>
            <cfset itemContext["@first"] = (i EQ from)>
            <cfset itemContext["@last"] = (i EQ to)>
            <cfset itemContext["@odd"] = (i MOD 2 EQ 1)>
            <cfset itemContext["@even"] = (i MOD 2 EQ 0)>
            
            <cfset output &= arguments.options.fn(itemContext)>
        </cfloop>
    <cfelseif structKeyExists(arguments.options, "inverse")>
        <cfset output = arguments.options.inverse(arguments.context)>
    </cfif>
    
    <cfreturn output>
</cffunction>

<!--- if helper --->
<cffunction name="helperIf" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif arrayLen(arguments.params) EQ 0>
        <cfreturn "">
    </cfif>
    
    <cfset var condition = getValueFromPath(arguments.context, arguments.params[1])>
    
    <cfif isBoolean(condition) AND condition>
        <cfreturn arguments.options.fn(arguments.context)>
    <cfelseif isNumeric(condition) AND condition NEQ 0>
        <cfreturn arguments.options.fn(arguments.context)>
    <cfelseif isSimpleValue(condition) AND len(trim(condition))>
        <cfreturn arguments.options.fn(arguments.context)>
    <cfelseif isArray(condition) AND arrayLen(condition)>
        <cfreturn arguments.options.fn(arguments.context)>
    <cfelseif isStruct(condition) AND structCount(condition)>
        <cfreturn arguments.options.fn(arguments.context)>
    <cfelseif structKeyExists(arguments.options, "inverse")>
        <cfreturn arguments.options.inverse(arguments.context)>
    </cfif>
    
    <cfreturn "">
</cffunction>

<!--- unless helper --->
<cffunction name="helperUnless" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <!--- unless is the opposite of if --->
    <cfset var tempOptions = duplicate(arguments.options)>
    <cfset var tempFn = tempOptions.fn>
    <cfset tempOptions.fn = tempOptions.inverse>
    <cfset tempOptions.inverse = tempFn>
    
    <cfreturn helperIf(arguments.params, tempOptions, arguments.context)>
</cffunction>

<!--- match helper --->
<cffunction name="helperMatch" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif arrayLen(arguments.params) LT 2>
        <cfreturn "">
    </cfif>
    
    <cfset var left = getValueFromPath(arguments.context, arguments.params[1])>
    <cfset var operator = "=">
    <cfset var right = "">
    
    <cfif arrayLen(arguments.params) EQ 2>
        <cfset right = arguments.params[2]>
    <cfelseif arrayLen(arguments.params) GTE 3>
        <cfset operator = arguments.params[2]>
        <cfset right = arguments.params[3]>
    </cfif>
    
    <!--- Remove quotes from right value if present --->
    <cfif left(right, 1) EQ '"' AND right(right, 1) EQ '"'>
        <cfset right = mid(right, 2, len(right) - 2)>
    </cfif>
    
    <cfset var result = false>
    
    <cfswitch expression="#operator#">
        <cfcase value="=">
            <cfset result = (left EQ right)>
        </cfcase>
        <cfcase value="!=">
            <cfset result = (left NEQ right)>
        </cfcase>
        <cfcase value=">">
            <cfset result = (left GT right)>
        </cfcase>
        <cfcase value="<">
            <cfset result = (left LT right)>
        </cfcase>
        <cfcase value=">=">
            <cfset result = (left GTE right)>
        </cfcase>
        <cfcase value="<=">
            <cfset result = (left LTE right)>
        </cfcase>
        <cfdefaultcase>
            <cfset result = (left EQ right)>
        </cfdefaultcase>
    </cfswitch>
    
    <cfif result>
        <cfreturn arguments.options.fn(arguments.context)>
    <cfelseif structKeyExists(arguments.options, "inverse")>
        <cfreturn arguments.options.inverse(arguments.context)>
    </cfif>
    
    <cfreturn "">
</cffunction>

<!--- Other helper stubs - implement as needed --->
<cffunction name="helperIs" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperHas" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperGet" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperContent" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "html")>
        <cfreturn arguments.context.html>
    <cfelseif structKeyExists(arguments.context, "content")>
        <cfreturn arguments.context.content>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperExcerpt" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "excerpt")>
        <cfreturn arguments.context.excerpt>
    <cfelseif structKeyExists(arguments.context, "custom_excerpt")>
        <cfreturn arguments.context.custom_excerpt>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperUrl" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "url")>
        <cfreturn arguments.context.url>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperDate" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var date = "">
    <cfset var format = "MMM DD, YYYY">
    
    <cfif arrayLen(arguments.params) GT 0>
        <cfset date = getValueFromPath(arguments.context, arguments.params[1])>
    </cfif>
    
    <cfif structKeyExists(arguments.options.hash, "format")>
        <cfset format = arguments.options.hash.format>
    </cfif>
    
    <cfif isDate(date)>
        <cfreturn dateFormat(date, format)>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperImgUrl" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var image = "">
    
    <cfif arrayLen(arguments.params) GT 0>
        <cfset image = getValueFromPath(arguments.context, arguments.params[1])>
    <cfelseif structKeyExists(arguments.context, "feature_image")>
        <cfset image = arguments.context.feature_image>
    </cfif>
    
    <cfreturn image>
</cffunction>

<cffunction name="helperAsset" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif arrayLen(arguments.params) GT 0>
        <cfreturn "/assets/" & arguments.params[1]>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperBodyClass" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "body_class")>
        <cfreturn arguments.context.body_class>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperPostClass" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "post_class")>
        <cfreturn arguments.context.post_class>
    </cfif>
    
    <cfreturn "post">
</cffunction>

<cffunction name="helperGhostHead" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var output = "">
    <cfset output &= '<!-- Ghost Head -->' & chr(10)>
    <cfset output &= '<meta name="generator" content="Ghost CFML" />' & chr(10)>
    
    <cfif structKeyExists(arguments.context, "meta_description")>
        <cfset output &= '<meta name="description" content="' & htmlEditFormat(arguments.context.meta_description) & '" />' & chr(10)>
    </cfif>
    
    <cfreturn output>
</cffunction>

<cffunction name="helperGhostFoot" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfreturn '<!-- Ghost Foot -->' & chr(10)>
</cffunction>

<cffunction name="helperMetaTitle" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "meta_title")>
        <cfreturn arguments.context.meta_title>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperMetaDescription" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "meta_description")>
        <cfreturn arguments.context.meta_description>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperNavigation" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "navigation")>
        <cfreturn arguments.context.navigation>
    </cfif>
    
    <cfreturn "">
</cffunction>

<cffunction name="helperPagination" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfif structKeyExists(arguments.context, "pagination")>
        <cfset var p = arguments.context.pagination>
        <cfset var html = '<nav class="pagination">'>
        
        <cfif structKeyExists(p, "prev") AND p.prev>
            <cfset html &= '<a href="?page=' & p.prev & '">Previous</a>'>
        </cfif>
        
        <cfif structKeyExists(p, "page") AND structKeyExists(p, "pages")>
            <cfset html &= '<span>Page ' & p.page & ' of ' & p.pages & '</span>'>
        </cfif>
        
        <cfif structKeyExists(p, "next") AND p.next>
            <cfset html &= '<a href="?page=' & p.next & '">Next</a>'>
        </cfif>
        
        <cfset html &= '</nav>'>
        <cfreturn html>
    </cfif>
    
    <cfreturn "">
</cffunction>

<!--- Add more helper implementations as needed --->
<cffunction name="helperPlural" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperEncode" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperTranslate" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperConcat" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <cfset var result = "">
    <cfloop array="#arguments.params#" index="param">
        <cfset result &= param>
    </cfloop>
    
    <cfreturn result>
</cffunction>

<cffunction name="helperLink" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperLinkClass" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperTags" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperAuthors" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperReadingTime" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperPrevPost" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperNextPost" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperPrice" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperTiers" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperComments" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperCollection" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperRecommendations" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperTotalMembers" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperTotalPaidMembers" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperSearch" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperCancelLink" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    <cfreturn "">
</cffunction>

<cffunction name="helperRaw" access="private" returntype="string">
    <cfargument name="params" type="array" required="true">
    <cfargument name="options" type="struct" required="true">
    <cfargument name="context" type="struct" required="true">
    
    <!--- Raw helper returns content without processing --->
    <cfif structKeyExists(arguments.options, "fn")>
        <cfreturn arguments.options.fn(arguments.context)>
    </cfif>
    
    <cfreturn "">
</cffunction>