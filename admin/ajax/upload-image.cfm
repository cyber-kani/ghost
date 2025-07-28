<!--- Image Upload AJAX Endpoint --->
<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">
<cfcontent reset="true">

<cfparam name="request.dsn" default="blog">

<cfset response = {success: false, message: "", url: ""}>

<cftry>
    <!--- Get upload type (profile, cover, or feature) --->
    <cfset uploadType = structKeyExists(form, "type") ? form.type : "profile">
    
    <!--- Get user ID from session --->
    <cfif structKeyExists(session, "USERID") and len(session.USERID)>
        <cfset userId = session.USERID>
    <cfelseif structKeyExists(session, "userId") and len(session.userId)>
        <cfset userId = session.userId>
    <cfelse>
        <cfset response.message = "User not logged in">
        <cfset response.MESSAGE = response.message>
        <cflog file="ghost-upload" text="Upload failed: User not logged in">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    
    <!--- Debug: Log what we received --->
    <cflog file="ghost-upload" text="Upload request received. Form fields: #structKeyList(form)#">
    
    <!--- Check if file was uploaded --->
    <cfif not structKeyExists(form, "file")>
        <cfset response.message = "No file field found in form data">
        <cflog file="ghost-upload" text="No file field found">
    <cfelseif not len(trim(form.file))>
        <cfset response.message = "File field is empty">
        <cflog file="ghost-upload" text="File field is empty">
    <cfelse>
        <!--- We have a file, proceed with upload logic --->
        <cflog file="ghost-upload" text="File field found: #form.file#">
        
        <!--- Define upload directory based on upload type --->
        <cfif uploadType eq "feature">
            <cfset uploadDir = "/var/www/sites/clitools.app/wwwroot/ghost/content/images/posts/">
            <cfset webPath = "/ghost/content/images/posts/">
        <cfelseif uploadType eq "content">
            <!--- Content images (from image cards) go to year/month folders --->
            <cfset currentYear = year(now())>
            <cfset currentMonth = numberFormat(month(now()), "00")>
            <cfset uploadDir = "/var/www/sites/clitools.app/wwwroot/ghost/content/images/#currentYear#/#currentMonth#/">
            <cfset webPath = "/ghost/content/images/#currentYear#/#currentMonth#/">
        <cfelse>
            <cfset uploadDir = "/var/www/sites/clitools.app/wwwroot/ghost/content/images/profile/">
            <cfset webPath = "/ghost/content/images/profile/">
        </cfif>
        
        <!--- Create directory if it doesn't exist --->
        <cfif not directoryExists(uploadDir)>
            <cfdirectory action="create" directory="#uploadDir#" mode="755">
        </cfif>
        
        <!--- Upload the file --->
        <cffile action="upload" 
                filefield="file" 
                destination="#uploadDir#" 
                accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
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
                <cflog file="ghost-upload" text="Renamed file from '#uploadResult.serverFile#' to '#sanitizedFileName#'">
            </cfif>
        </cfif>
        
        <cflog file="ghost-upload" text="Upload result: fileWasSaved=#uploadResult.fileWasSaved#, serverFile=#uploadResult.serverFile#">
        
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
            
            <!--- Always resize image if width exceeds 2000px to ensure consistency --->
            <cftry>
                <cfimage action="info" source="#uploadedFilePath#" structName="imageInfo">
                <cflog file="ghost-upload" text="Image info: width=#imageInfo.width#, height=#imageInfo.height#">
                
                <cfif imageInfo.width gt 2000>
                    <!--- Calculate new height maintaining aspect ratio --->
                    <cfset newWidth = 2000>
                    <cfset newHeight = round((imageInfo.height * newWidth) / imageInfo.width)>
                    
                    <!--- Resize the image --->
                    <cfimage action="resize" 
                             source="#uploadedFilePath#" 
                             width="#newWidth#" 
                             height="#newHeight#" 
                             destination="#uploadedFilePath#" 
                             overwrite="true">
                    
                    <cflog file="ghost-upload" text="Resized image from #imageInfo.width#x#imageInfo.height# to #newWidth#x#newHeight#">
                </cfif>
                
                <cfcatch>
                    <cflog file="ghost-upload" text="Failed to resize image: #cfcatch.message#">
                    <!--- Continue without failing the upload --->
                </cfcatch>
            </cftry>
            
            <!--- Generate web-accessible URL --->
            <cfset imageUrl = webPath & uploadResult.serverFile>
            
            <!--- Update user's profile image in database --->
            <cftry>
                <cfif uploadType eq "profile">
                    <cfquery datasource="blog">
                        UPDATE users 
                        SET profile_image = <cfqueryparam value="#imageUrl#" cfsqltype="cf_sql_varchar">,
                            updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                            updated_by = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
                        WHERE id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                <cfelseif uploadType eq "cover">
                    <cfquery datasource="blog">
                        UPDATE users 
                        SET cover_image = <cfqueryparam value="#imageUrl#" cfsqltype="cf_sql_varchar">,
                            updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                            updated_by = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
                        WHERE id = <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                </cfif>
                
                <!--- Update session if needed --->
                <cfif uploadType eq "profile" and structKeyExists(session, "user") and isStruct(session.user)>
                    <cfset session.user.profile_image = imageUrl>
                </cfif>
                
                <cflog file="ghost-upload" text="Database updated for #uploadType# image">
                <cfcatch>
                    <cflog file="ghost-upload" text="Failed to update database: #cfcatch.message#">
                </cfcatch>
            </cftry>
            
            <cfset response.success = true>
            <cfset response.message = "Image uploaded successfully">
            <cfset response.url = imageUrl>
            
            <!--- Add uppercase variants for JavaScript compatibility --->
            <cfset response.SUCCESS = true>
            <cfset response.MESSAGE = response.message>
            <cfset response.URL = response.url>
            
            <cflog file="ghost-upload" text="Upload successful: #imageUrl#">
        <cfelse>
            <cfset response.message = "Failed to save uploaded file">
            <cfset response.MESSAGE = response.message>
            <cflog file="ghost-upload" text="Upload failed: file was not saved">
        </cfif>
    </cfif>
    
    <cfcatch any>
        <cfset response.message = "Error uploading image: " & cfcatch.message & " - " & cfcatch.detail>
        <cfset response.detail = cfcatch.detail>
        <cfset response.type = cfcatch.type>
        <cflog file="ghost-upload" text="Upload error: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<!--- Always return JSON response --->
<cfset jsonResponse = serializeJSON(response)>
<cflog file="ghost-upload" text="Final response: #jsonResponse#">
<cfoutput>#jsonResponse#</cfoutput>