<cfheader name="Content-Type" value="application/json">
<cfsetting enablecfoutputonly="true">

<cftry>
    <cfset result = {}>
    
    <!--- Check if file was uploaded --->
    <cfif not isDefined("form.file") or form.file eq "">
        <cfset result.success = false>
        <cfset result.message = "No file uploaded">
        <cfoutput>#serializeJSON(result)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- File validation --->
    <cfset maxFileSize = 50 * 1024 * 1024> <!--- 50MB in bytes --->
    <cfset uploadDir = "/var/www/sites/clitools.app/wwwroot/ghost/content/files">
    
    <!--- Create upload directory if it doesn't exist --->
    <cfif not directoryExists(uploadDir)>
        <cfdirectory action="create" directory="#uploadDir#" mode="755">
    </cfif>
    
    <!--- Upload file first --->
    <cffile action="upload" 
            fileField="file" 
            destination="#uploadDir#" 
            nameConflict="makeunique"
            result="uploadResult">
    
    <!--- Check if upload was successful --->
    <cfif uploadResult.fileWasSaved>
        <!--- Get file info from upload result --->
        <cfset originalFileName = uploadResult.clientFileName>
        <cfset fileExtension = uploadResult.clientFileExt>
        <cfset fileSize = uploadResult.fileSize>
        <cfset tempFileName = uploadResult.serverFile>
        <cfset tempFilePath = uploadDir & "/" & tempFileName>
        
        <!--- Check file size after upload --->
        <cfif fileSize gt maxFileSize>
            <!--- Delete the uploaded file --->
            <cffile action="delete" file="#tempFilePath#">
            <cfset result.success = false>
            <cfset result.message = "File size exceeds 50MB limit">
            <cfoutput>#serializeJSON(result)#</cfoutput>
            <cfabort>
        </cfif>
        
        <!--- Sanitize filename --->
        <cfset cleanFileName = reReplace(originalFileName, "[^a-zA-Z0-9._-]", "_", "ALL")>
        <cfset cleanFileName = reReplace(cleanFileName, "_{2,}", "_", "ALL")>
        
        <!--- Add timestamp to prevent overwriting --->
        <cfset timestamp = dateFormat(now(), "yyyymmdd") & "_" & timeFormat(now(), "HHmmss")>
        <cfset baseName = listFirst(cleanFileName, ".")>
        <cfset finalFileName = baseName & "_" & timestamp & "." & fileExtension>
        
        <!--- Set final upload path --->
        <cfset uploadPath = uploadDir & "/" & finalFileName>
        
        <!--- Rename to final name --->
        <cffile action="move" 
                source="#tempFilePath#" 
                destination="#uploadPath#">
        
        <!--- Set proper permissions --->
        <cfexecute name="chmod" 
                   arguments="644 #uploadPath#" 
                   timeout="10">
        </cfexecute>
        
        <!--- Build URL for web access --->
        <cfset fileUrl = "/ghost/content/files/" & finalFileName>
        
        <!--- Return success response --->
        <cfset result.success = true>
        <cfset result.url = fileUrl>
        <cfset result.fileName = originalFileName>
        <cfset result.size = fileSize>
        <cfset result.message = "File uploaded successfully">
        
    <cfelse>
        <cfset result.success = false>
        <cfset result.message = "Failed to save file">
    </cfif>
    
    <cfcatch type="any">
        <!--- Log error --->
        <cflog file="file_upload_errors" 
               text="File upload error: #cfcatch.message# - #cfcatch.detail#" 
               type="error">
        
        <cfset result.success = false>
        <cfset result.message = "Upload failed: " & cfcatch.message>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(result)#</cfoutput>