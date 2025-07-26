<!--- Video Upload AJAX Endpoint --->
<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">
<cfcontent reset="true">

<cfset response = {success: false, message: "", url: "", duration: 0, thumbnailUrl: ""}>

<cftry>
    <!--- Get user ID from session --->
    <cfif structKeyExists(session, "USERID") and len(session.USERID)>
        <cfset userId = session.USERID>
    <cfelseif structKeyExists(session, "userId") and len(session.userId)>
        <cfset userId = session.userId>
    <cfelse>
        <cfset response.message = "User not logged in">
        <cfset response.MESSAGE = response.message>
        <cflog file="ghost-upload" text="Video upload failed: User not logged in">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Debug: Log what we received --->
    <cflog file="ghost-upload" text="Video upload request received. Form fields: #structKeyList(form)#">
    
    <!--- Check if file was uploaded --->
    <cfif not structKeyExists(form, "file")>
        <cfset response.message = "No file field found in form data">
        <cflog file="ghost-upload" text="No video file field found">
    <cfelseif not len(trim(form.file))>
        <cfset response.message = "File field is empty">
        <cflog file="ghost-upload" text="Video file field is empty">
    <cfelse>
        <!--- We have a file, proceed with upload logic --->
        <cflog file="ghost-upload" text="Video file field found: #form.file#">
        
        <!--- Define upload directory for videos --->
        <cfset uploadDir = "/var/www/sites/clitools.app/wwwroot/ghost/content/videos/">
        <cfset webPath = "/ghost/content/videos/">
        
        <!--- Create directory if it doesn't exist --->
        <cfif not directoryExists(uploadDir)>
            <cfdirectory action="create" directory="#uploadDir#" mode="755">
        </cfif>
        
        <!--- Upload the file --->
        <cffile action="upload" 
                filefield="file" 
                destination="#uploadDir#" 
                accept="video/mp4,video/webm,video/ogg,video/mpeg,video/quicktime,video/x-msvideo"
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
                <cflog file="ghost-upload" text="Renamed video file from '#uploadResult.serverFile#' to '#sanitizedFileName#'">
            </cfif>
        </cfif>
        
        <cflog file="ghost-upload" text="Video upload result: fileWasSaved=#uploadResult.fileWasSaved#, serverFile=#uploadResult.serverFile#">
        
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
            
            <!--- Try to get video duration using ffprobe --->
            <cfset videoDuration = 0>
            <cftry>
                <cfexecute name="ffprobe" 
                           arguments="-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 '#uploadedFilePath#'" 
                           variable="durationOutput" 
                           timeout="10" />
                <cfif isNumeric(trim(durationOutput))>
                    <cfset videoDuration = round(trim(durationOutput))>
                </cfif>
                <cflog file="ghost-upload" text="Video duration: #videoDuration# seconds">
                <cfcatch>
                    <cflog file="ghost-upload" text="Failed to get video duration: #cfcatch.message#">
                </cfcatch>
            </cftry>
            
            <!--- Generate web-accessible URL --->
            <cfset videoUrl = webPath & uploadResult.serverFile>
            
            <!--- Process thumbnail if provided --->
            <cfset thumbnailUrl = "">
            <cfif structKeyExists(form, "thumbnail") and len(trim(form.thumbnail))>
                <cftry>
                    <cffile action="upload" 
                            filefield="thumbnail" 
                            destination="#uploadDir#" 
                            accept="image/jpeg,image/jpg,image/png"
                            nameconflict="makeunique"
                            result="thumbnailResult">
                    
                    <cfif thumbnailResult.fileWasSaved>
                        <!--- Sanitize thumbnail filename --->
                        <cfset thumbnailFile = uploadDir & thumbnailResult.serverFile>
                        <cfset sanitizedThumbName = reReplace(thumbnailResult.serverFile, "[^a-zA-Z0-9._-]", "_", "all")>
                        <cfset sanitizedThumbName = reReplace(sanitizedThumbName, "_+", "_", "all")>
                        <cfset newThumbPath = uploadDir & sanitizedThumbName>
                        
                        <cfif sanitizedThumbName neq thumbnailResult.serverFile>
                            <cffile action="rename" source="#thumbnailFile#" destination="#newThumbPath#">
                        </cfif>
                        
                        <!--- Set permissions --->
                        <cfexecute name="chmod" arguments="644 '#newThumbPath#'" timeout="5" />
                        
                        <cfset thumbnailUrl = webPath & sanitizedThumbName>
                        <cflog file="ghost-upload" text="Thumbnail uploaded: #thumbnailUrl#">
                    </cfif>
                    
                    <cfcatch>
                        <cflog file="ghost-upload" text="Failed to upload thumbnail: #cfcatch.message#">
                    </cfcatch>
                </cftry>
            </cfif>
            
            <cfset response.success = true>
            <cfset response.message = "Video uploaded successfully">
            <cfset response.url = videoUrl>
            <cfset response.duration = videoDuration>
            <cfset response.thumbnailUrl = thumbnailUrl>
            
            <!--- Add uppercase variants for JavaScript compatibility --->
            <cfset response.SUCCESS = true>
            <cfset response.MESSAGE = response.message>
            <cfset response.URL = response.url>
            <cfset response.DURATION = videoDuration>
            <cfset response.THUMBNAILURL = thumbnailUrl>
            
            <cflog file="ghost-upload" text="Video upload successful: #videoUrl# with thumbnail: #thumbnailUrl#">
        <cfelse>
            <cfset response.message = "Failed to save uploaded video">
            <cfset response.MESSAGE = response.message>
            <cflog file="ghost-upload" text="Video upload failed: file was not saved">
        </cfif>
    </cfif>
    
    <cfcatch any>
        <cfset response.message = "Error uploading video: " & cfcatch.message & " - " & cfcatch.detail>
        <cfset response.detail = cfcatch.detail>
        <cfset response.type = cfcatch.type>
        <cflog file="ghost-upload" text="Video upload error: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<!--- Always return JSON response --->
<cfset jsonResponse = serializeJSON(response)>
<cflog file="ghost-upload" text="Video upload final response: #jsonResponse#">
<cfoutput>#jsonResponse#</cfoutput>