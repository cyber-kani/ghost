<!--- Ghost Site Configuration --->
<!--- This file contains site-wide configuration settings --->

<!--- Site URL Configuration --->
<!--- This replaces __GHOST_URL__ placeholders in content --->
<!--- Update this when moving to a new server or domain --->

<!--- Initialize site configuration structure --->
<cfset application.siteConfig = {}>

<!--- Base URL for the site (no trailing slash) --->
<cfset application.siteConfig.ghostUrl = "https://clitools.app/ghost">

<!--- Content paths --->
<cfset application.siteConfig.contentPath = "/content">
<cfset application.siteConfig.imagesPath = "/content/images">
<cfset application.siteConfig.filesPath = "/content/files">
<cfset application.siteConfig.audioPath = "/content/audio">
<cfset application.siteConfig.videoPath = "/content/videos">

<!--- Upload settings --->
<cfset application.siteConfig.maxImageSize = 10485760> <!--- 10MB in bytes --->
<cfset application.siteConfig.maxFileSize = 52428800> <!--- 50MB in bytes --->
<cfset application.siteConfig.maxVideoSize = 104857600> <!--- 100MB in bytes --->
<cfset application.siteConfig.maxAudioSize = 52428800> <!--- 50MB in bytes --->

<!--- Allowed file extensions --->
<cfset application.siteConfig.allowedImageTypes = "jpg,jpeg,png,gif,webp,svg">
<cfset application.siteConfig.allowedVideoTypes = "mp4,webm,mov">
<cfset application.siteConfig.allowedAudioTypes = "mp3,wav,m4a">
<cfset application.siteConfig.allowedFileTypes = "pdf,doc,docx,xls,xlsx,ppt,pptx,zip,txt">

<!--- Site metadata --->
<cfset application.siteConfig.siteName = "Ghost CFML">
<cfset application.siteConfig.siteDescription = "A Ghost CMS clone built with CFML">
<cfset application.siteConfig.siteLanguage = "en">
<cfset application.siteConfig.siteTimezone = "UTC">

<!--- Feature flags --->
<cfset application.siteConfig.enableMembership = false>
<cfset application.siteConfig.enableNewsletter = false>
<cfset application.siteConfig.enableComments = false>

<!--- Debug settings --->
<cfset application.siteConfig.debugMode = true>
<cfset application.siteConfig.showErrors = true>
<cfset application.siteConfig.logErrors = true>

<!--- Cache settings --->
<cfset application.siteConfig.cacheEnabled = false>
<cfset application.siteConfig.cacheTimeout = 3600> <!--- 1 hour in seconds --->

<!--- Helper function to replace __GHOST_URL__ in content --->
<cffunction name="replaceGhostUrl" returntype="string" output="false">
    <cfargument name="content" type="string" required="true">
    
    <cfif len(trim(arguments.content))>
        <cfreturn replace(arguments.content, "__GHOST_URL__", application.siteConfig.ghostUrl, "all")>
    </cfif>
    <cfreturn arguments.content>
</cffunction>

<!--- Helper function to get full content URL --->
<cffunction name="getContentUrl" returntype="string" output="false">
    <cfargument name="path" type="string" required="true">
    
    <cfif left(arguments.path, 1) EQ "/">
        <cfreturn application.siteConfig.ghostUrl & arguments.path>
    <cfelseif findNoCase("http", arguments.path) EQ 1>
        <cfreturn arguments.path>
    <cfelse>
        <cfreturn application.siteConfig.ghostUrl & "/" & arguments.path>
    </cfif>
</cffunction>

<!--- Helper function to get image URL --->
<cffunction name="getImageUrl" returntype="string" output="false">
    <cfargument name="path" type="string" required="true">
    
    <cfif len(trim(arguments.path))>
        <!--- Replace __GHOST_URL__ placeholder --->
        <cfset local.processedPath = replaceGhostUrl(arguments.path)>
        
        <!--- Handle relative paths --->
        <cfif left(local.processedPath, 1) EQ "/" AND NOT findNoCase("/ghost", local.processedPath)>
            <cfset local.processedPath = "/ghost" & local.processedPath>
        </cfif>
        
        <cfreturn local.processedPath>
    </cfif>
    <cfreturn "">
</cffunction>

<!--- Helper function to check if image file exists --->
<cffunction name="imageFileExists" returntype="boolean" output="false">
    <cfargument name="imageUrl" type="string" required="true">
    
    <cfif NOT len(trim(arguments.imageUrl))>
        <cfreturn false>
    </cfif>
    
    <!--- Convert URL to file path --->
    <cfset local.filePath = arguments.imageUrl>
    
    <!--- Remove domain if present --->
    <cfif findNoCase("http", local.filePath) EQ 1>
        <cfset local.filePath = replaceNoCase(local.filePath, "https://clitools.app", "")>
        <cfset local.filePath = replaceNoCase(local.filePath, "http://clitools.app", "")>
    </cfif>
    
    <!--- Convert to physical path --->
    <cfset local.physicalPath = expandPath(local.filePath)>
    
    <!--- Check if file exists --->
    <cfreturn fileExists(local.physicalPath)>
</cffunction>