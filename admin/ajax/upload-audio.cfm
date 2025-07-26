<!--- Audio Upload AJAX Endpoint --->
<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">
<cfcontent reset="true">

<cfset response = {success: false, message: "", url: "", duration: 0}>

<cftry>
    <!--- Get user ID from session --->
    <cfif structKeyExists(session, "USERID") and len(session.USERID)>
        <cfset userId = session.USERID>
    <cfelseif structKeyExists(session, "userId") and len(session.userId)>
        <cfset userId = session.userId>
    <cfelse>
        <cfset response.message = "User not logged in">
        <cfset response.MESSAGE = response.message>
        <cflog file="ghost-upload" text="Audio upload failed: User not logged in">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Debug: Log what we received --->
    <cflog file="ghost-upload" text="Audio upload request received. Form fields: #structKeyList(form)#">
    
    <!--- Check if file was uploaded --->
    <cfif not structKeyExists(form, "file")>
        <cfset response.message = "No file field found in form data">
        <cflog file="ghost-upload" text="No audio file field found">
    <cfelseif not len(trim(form.file))>
        <cfset response.message = "File field is empty">
        <cflog file="ghost-upload" text="Audio file field is empty">
    <cfelse>
        <!--- We have a file, proceed with upload logic --->
        <cflog file="ghost-upload" text="Audio file field found: #form.file#">
        
        <!--- Define upload directory for audio --->
        <cfset uploadDir = "/var/www/sites/clitools.app/wwwroot/ghost/content/audio/">
        <cfset webPath = "/ghost/content/audio/">
        
        <!--- Create directory if it doesn't exist --->
        <cfif not directoryExists(uploadDir)>
            <cfdirectory action="create" directory="#uploadDir#" mode="755">
        </cfif>
        
        <!--- Upload the file --->
        <cffile action="upload" 
                filefield="file" 
                destination="#uploadDir#" 
                accept="audio/mpeg,audio/mp3,audio/wav,audio/ogg,audio/webm,audio/m4a,audio/aac"
                nameconflict="makeunique"
                result="uploadResult">
        
        <!--- Sanitize filename by removing spaces and special characters --->
        <cfif uploadResult.fileWasSaved>
            <cfset originalFile = uploadDir & uploadResult.serverFile>
            <cfset sanitizedFileName = reReplace(uploadResult.serverFile, "[^a-zA-Z0-9._-]", "_", "all")>
            <cfset sanitizedFileName = reReplace(sanitizedFileName, "_+", "_", "all")>
            <cfset newFilePath = uploadDir & sanitizedFileName>
            
            <!--- Rename file to sanitized version if different --->
            <cfif sanitizedFileName neq uploadResult.serverFile>
                <cffile action="rename" source="#originalFile#" destination="#newFilePath#">
                <cfset uploadResult.serverFile = sanitizedFileName>
                <cflog file="ghost-upload" text="Renamed audio file from '#uploadResult.serverFile#' to '#sanitizedFileName#'">
            </cfif>
        </cfif>
        
        <cflog file="ghost-upload" text="Audio upload result: fileWasSaved=#uploadResult.fileWasSaved#, serverFile=#uploadResult.serverFile#">
        
        <!--- Check if upload was successful --->
        <cfif uploadResult.fileWasSaved>
            <!--- Set proper file permissions for web access --->
            <cfset uploadedFilePath = uploadDir & uploadResult.serverFile>
            <cftry>
                <cfexecute name="chmod" arguments="644 '#uploadedFilePath#'" timeout="5" />
                <cflog file="ghost-upload" text="Set file permissions to 644 for: #uploadedFilePath#">
                <cfcatch>
                    <cflog file="ghost-upload" text="Failed to set permissions: #cfcatch.message#">
                </cfcatch>
            </cftry>
            
            <!--- Try to get audio duration using ffprobe --->
            <cfset audioDuration = 0>
            <cftry>
                <cfexecute name="ffprobe" 
                           arguments="-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 '#uploadedFilePath#'" 
                           variable="durationOutput" 
                           timeout="10" />
                <cfif isNumeric(trim(durationOutput))>
                    <cfset audioDuration = round(trim(durationOutput))>
                </cfif>
                <cflog file="ghost-upload" text="Audio duration: #audioDuration# seconds">
                <cfcatch>
                    <cflog file="ghost-upload" text="Failed to get audio duration: #cfcatch.message#">
                </cfcatch>
            </cftry>
            
            <!--- Generate web-accessible URL --->
            <cfset audioUrl = webPath & uploadResult.serverFile>
            
            <cfset response.success = true>
            <cfset response.message = "Audio uploaded successfully">
            <cfset response.url = audioUrl>
            <cfset response.duration = audioDuration>
            
            <!--- Add uppercase variants for JavaScript compatibility --->
            <cfset response.SUCCESS = true>
            <cfset response.MESSAGE = response.message>
            <cfset response.URL = response.url>
            <cfset response.DURATION = audioDuration>
            
            <cflog file="ghost-upload" text="Audio upload successful: #audioUrl# (duration: #audioDuration#s)">
        <cfelse>
            <cfset response.message = "Failed to save uploaded audio">
            <cfset response.MESSAGE = response.message>
            <cflog file="ghost-upload" text="Audio upload failed: file was not saved">
        </cfif>
    </cfif>
    
    <cfcatch any>
        <cfset response.message = "Error uploading audio: " & cfcatch.message & " - " & cfcatch.detail>
        <cfset response.detail = cfcatch.detail>
        <cfset response.type = cfcatch.type>
        <cflog file="ghost-upload" text="Audio upload error: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<!--- Always return JSON response --->
<cfset jsonResponse = serializeJSON(response)>
<cflog file="ghost-upload" text="Audio upload final response: #jsonResponse#">
<cfoutput>#jsonResponse#</cfoutput>