<!--- Theme Upload Handler --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if user is logged in --->
    <cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
        <cfthrow message="Unauthorized access">
    </cfif>

    <!--- Check if file was uploaded --->
    <cfif NOT structKeyExists(form, "themeFile") OR NOT len(form.themeFile)>
        <cfthrow message="No theme file uploaded">
    </cfif>

    <!--- Create temp directory for theme extraction --->
    <cfset tempDir = getTempDirectory() & createUUID() & "/">
    <cfdirectory action="create" directory="#tempDir#">

    <!--- Upload file to temp location --->
    <cffile action="upload" 
            filefield="themeFile" 
            destination="#tempDir#" 
            nameconflict="makeunique"
            accept="application/zip,application/x-zip-compressed">

    <!--- Verify it's a zip file --->
    <cfif NOT listFindNoCase("zip", cffile.serverFileExt)>
        <cfdirectory action="delete" directory="#tempDir#" recurse="true">
        <cfthrow message="Invalid file type. Please upload a zip file.">
    </cfif>

    <!--- Extract the zip file --->
    <cfzip action="unzip" 
           file="#tempDir##cffile.serverFile#" 
           destination="#tempDir#extracted/"
           overwrite="true">

    <!--- Find the theme directory (might be nested) --->
    <cfdirectory action="list" directory="#tempDir#extracted/" name="qExtracted" type="dir">
    
    <cfset themeDir = "">
    <cfset themeName = "">
    
    <!--- Check if package.json exists in root --->
    <cfif fileExists("#tempDir#extracted/package.json")>
        <cfset themeDir = tempDir & "extracted/">
        <!--- Read package.json to get theme name --->
        <cffile action="read" file="#themeDir#package.json" variable="packageJson">
        <cfset packageData = deserializeJSON(packageJson)>
        <cfset themeName = packageData.name>
    <cfelse>
        <!--- Check first level subdirectory --->
        <cfloop query="qExtracted">
            <cfif name NEQ "." AND name NEQ ".." AND directoryExists("#tempDir#extracted/#name#")>
                <cfif fileExists("#tempDir#extracted/#name#/package.json")>
                    <cfset themeDir = tempDir & "extracted/" & name & "/">
                    <!--- Read package.json to get theme name --->
                    <cffile action="read" file="#themeDir#package.json" variable="packageJson">
                    <cfset packageData = deserializeJSON(packageJson)>
                    <cfset themeName = packageData.name>
                    <cfbreak>
                </cfif>
            </cfif>
        </cfloop>
    </cfif>

    <!--- Validate theme structure --->
    <cfif NOT len(themeDir) OR NOT fileExists("#themeDir#package.json")>
        <cfdirectory action="delete" directory="#tempDir#" recurse="true">
        <cfthrow message="Invalid theme structure. Theme must contain a package.json file.">
    </cfif>

    <!--- Validate required theme files --->
    <cfset requiredFiles = ["index.hbs", "post.hbs", "default.hbs"]>
    <cfset missingFiles = []>
    
    <cfloop array="#requiredFiles#" index="requiredFile">
        <cfif NOT fileExists("#themeDir##requiredFile#")>
            <cfset arrayAppend(missingFiles, requiredFile)>
        </cfif>
    </cfloop>

    <cfif arrayLen(missingFiles)>
        <cfdirectory action="delete" directory="#tempDir#" recurse="true">
        <cfthrow message="Missing required theme files: #arrayToList(missingFiles, ', ')#">
    </cfif>

    <!--- Sanitize theme name --->
    <cfset themeName = reReplace(themeName, "[^a-zA-Z0-9\-_]", "", "all")>
    <cfif NOT len(themeName)>
        <cfset themeName = "theme-" & dateFormat(now(), "yyyymmdd") & timeFormat(now(), "HHmmss")>
    </cfif>

    <!--- Check if theme already exists --->
    <cfset targetDir = expandPath("/ghost/themes/#themeName#/")>
    <cfif directoryExists(targetDir)>
        <!--- Generate unique name --->
        <cfset counter = 1>
        <cfset originalName = themeName>
        <cfloop condition="directoryExists(targetDir)">
            <cfset themeName = originalName & "-" & counter>
            <cfset targetDir = expandPath("/ghost/themes/#themeName#/")>
            <cfset counter++>
        </cfloop>
    </cfif>

    <!--- Copy theme to themes directory --->
    <cfdirectory action="create" directory="#targetDir#">
    
    <!--- Copy all theme files --->
    <cfset copyDirectory(themeDir, targetDir)>

    <!--- Clean up temp directory --->
    <cfdirectory action="delete" directory="#tempDir#" recurse="true">

    <!--- Return success response --->
    <cfset response = {
        "success": true,
        "message": "Theme uploaded successfully",
        "themeName": themeName
    }>

<cfcatch>
    <!--- Clean up temp directory if it exists --->
    <cfif isDefined("tempDir") AND directoryExists(tempDir)>
        <cfdirectory action="delete" directory="#tempDir#" recurse="true">
    </cfif>
    
    <cfset response = {
        "success": false,
        "message": cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>

<!--- Helper function to copy directory recursively --->
<cffunction name="copyDirectory" access="private" returntype="void">
    <cfargument name="source" required="true">
    <cfargument name="destination" required="true">
    
    <!--- Get all items in source directory --->
    <cfdirectory action="list" directory="#arguments.source#" name="qItems">
    
    <cfloop query="qItems">
        <cfif type EQ "file">
            <!--- Copy file --->
            <cffile action="copy" 
                    source="#arguments.source##name#" 
                    destination="#arguments.destination##name#">
        <cfelseif type EQ "dir" AND name NEQ "." AND name NEQ "..">
            <!--- Create subdirectory and copy contents --->
            <cfdirectory action="create" directory="#arguments.destination##name#">
            <cfset copyDirectory("#arguments.source##name#/", "#arguments.destination##name#/")>
        </cfif>
    </cfloop>
</cffunction>