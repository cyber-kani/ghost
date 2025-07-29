<!--- Image Upload Handler --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if user is logged in --->
    <cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
        <!--- Check alternative session structure --->
        <cfif NOT (structKeyExists(session, "user") AND structKeyExists(session.user, "id"))>
            <cfthrow message="Unauthorized access">
        </cfif>
    </cfif>
    
    <!--- Check if file was uploaded --->
    <cfif NOT structKeyExists(form, "image")>
        <cfthrow message="No image file uploaded">
    </cfif>
    
    <!--- Set upload directory --->
    <cfset uploadDir = expandPath("/ghost/content/images/#year(now())#/#numberFormat(month(now()), '00')#/")>
    
    <!--- Create directory if it doesn't exist --->
    <cfif NOT directoryExists(uploadDir)>
        <cfdirectory action="create" directory="#uploadDir#" recurse="true">
    </cfif>
    
    <!--- Upload the file --->
    <cffile action="upload" 
            filefield="image" 
            destination="#uploadDir#" 
            nameconflict="makeunique"
            accept="image/jpeg,image/jpg,image/png,image/gif,image/webp,image/svg+xml"
            result="uploadResult">
    
    <!--- Generate unique filename with correct extension --->
    <cfset fileExt = listLast(uploadResult.serverFile, ".")>
    <cfset fileName = createUUID() & "." & fileExt>
    
    <!--- Rename to our UUID filename --->
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