<!--- Image Upload Handler with SEO Optimization --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Log the form scope for debugging --->
    <cflog text="Upload attempt - Form keys: #structKeyList(form)#" file="ghost-uploads">
    
    <!--- Check if user is logged in --->
    <cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
        <!--- Check alternative session structure --->
        <cfif NOT (structKeyExists(session, "user") AND structKeyExists(session.user, "id"))>
            <cfthrow message="Unauthorized access">
        </cfif>
    </cfif>
    
    <!--- Check if file was uploaded --->
    <cfif NOT structKeyExists(form, "file") AND NOT structKeyExists(form, "image")>
        <cfthrow message="No image file uploaded">
    </cfif>
    
    <!--- Set the file field name --->
    <cfset fileFieldName = structKeyExists(form, "file") ? "file" : "image">
    
    <!--- Get optional context for SEO --->
    <cfparam name="form.postTitle" default="">
    <cfparam name="form.altText" default="">
    <cfparam name="form.type" default="">
    
    <!--- Set upload directory --->
    <cfset uploadDir = expandPath("/ghost/content/images/#year(now())#/#numberFormat(month(now()), '00')#/")>
    
    <!--- Create directory if it doesn't exist --->
    <cfif NOT directoryExists(uploadDir)>
        <cfdirectory action="create" directory="#uploadDir#" recurse="true">
    </cfif>
    
    <!--- Upload the file --->
    <cffile action="upload" 
            filefield="#fileFieldName#" 
            destination="#uploadDir#" 
            nameconflict="makeunique"
            accept="image/jpeg,image/jpg,image/png,image/gif,image/webp,image/svg+xml"
            result="uploadResult">
    
    <!--- Generate SEO-friendly filename --->
    <cfset fileExt = listLast(uploadResult.serverFile, ".")>
    
    <!--- Create SEO-friendly base name --->
    <cfset seoBaseName = "">
    
    <!--- Priority: Alt text > Post title > Type > Original filename --->
    <cfif len(trim(form.altText))>
        <cfset seoBaseName = form.altText>
    <cfelseif len(trim(form.postTitle))>
        <cfset seoBaseName = form.postTitle>
    <cfelseif len(trim(form.type))>
        <cfset seoBaseName = form.type & "-image">
    <cfelse>
        <!--- Use original filename without extension --->
        <cfset seoBaseName = listFirst(uploadResult.clientFile, ".")>
    </cfif>
    
    <!--- Clean up the filename for SEO --->
    <!--- Convert to lowercase --->
    <cfset seoBaseName = lCase(seoBaseName)>
    <!--- Replace spaces and special characters with hyphens --->
    <cfset seoBaseName = reReplace(seoBaseName, "[^a-z0-9]+", "-", "all")>
    <!--- Remove leading/trailing hyphens --->
    <cfset seoBaseName = reReplace(seoBaseName, "^-+|-+$", "", "all")>
    <!--- Limit length to 60 characters --->
    <cfif len(seoBaseName) GT 60>
        <cfset seoBaseName = left(seoBaseName, 60)>
        <!--- Make sure we don't end with a partial word --->
        <cfset lastHyphen = findLast("-", seoBaseName)>
        <cfif lastHyphen GT 40>
            <cfset seoBaseName = left(seoBaseName, lastHyphen - 1)>
        </cfif>
    </cfif>
    
    <!--- Add a short unique identifier to prevent conflicts --->
    <cfset uniqueId = lCase(left(createUUID(), 8))>
    <cfset fileName = seoBaseName & "-" & uniqueId & "." & fileExt>
    
    <!--- If seoBaseName is empty, fall back to UUID --->
    <cfif NOT len(seoBaseName)>
        <cfset fileName = createUUID() & "." & fileExt>
    </cfif>
    
    <!--- Rename to our SEO-friendly filename --->
    <cffile action="rename" 
            source="#uploadDir##uploadResult.serverFile#" 
            destination="#uploadDir##fileName#">
    
    <!--- Ensure proper file permissions --->
    <cfexecute name="/bin/chmod" arguments="644 #uploadDir##fileName#" timeout="5"></cfexecute>
    
    <!--- Build the URL path --->
    <cfset imageUrl = "/ghost/content/images/#year(now())#/#numberFormat(month(now()), '00')#/#fileName#">
    
    <!--- Return success response --->
    <cfset response = {
        "success": true,
        "url": imageUrl,
        "filename": fileName
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": cfcatch.message,
        "detail": cfcatch.detail
    }>
    <cflog text="Image upload error: #cfcatch.message# - #cfcatch.detail#" file="ghost-uploads">
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>