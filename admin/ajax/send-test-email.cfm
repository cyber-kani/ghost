<cfheader name="Content-Type" value="application/json">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Get JSON data from request body --->
    <cfset requestData = getHttpRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Validate input --->
    <cfif NOT structKeyExists(jsonData, "email") OR NOT isValid("email", jsonData.email)>
        <cfthrow message="Valid email address is required">
    </cfif>
    
    <cfif NOT structKeyExists(jsonData, "settings") OR NOT isStruct(jsonData.settings)>
        <cfthrow message="Mail settings are required">
    </cfif>
    
    <cfset mailSettings = jsonData.settings>
    
    <!--- Validate mail configuration based on service type --->
    <cfif structKeyExists(mailSettings, "mail_service") AND mailSettings.mail_service EQ "Mailjet">
        <!--- Validate Mailjet API credentials --->
        <cfif NOT structKeyExists(mailSettings, "mailjetApiKey") OR NOT len(trim(mailSettings.mailjetApiKey))>
            <cfthrow message="Mailjet API Key is required">
        </cfif>
        <cfif NOT structKeyExists(mailSettings, "mailjetSecret") OR NOT len(trim(mailSettings.mailjetSecret))>
            <cfthrow message="Mailjet Secret Key is required">
        </cfif>
    <cfelse>
        <!--- Validate SMTP configuration for other services --->
        <cfif NOT len(trim(mailSettings.mail_host))>
            <cfthrow message="SMTP host is required">
        </cfif>
    </cfif>
    
    <cfif NOT len(trim(mailSettings.mail_from_address))>
        <cfthrow message="From email address is required">
    </cfif>
    
    <!--- Prepare test email content --->
    <cfset testSubject = "Test Email from Ghost CMS">
    <cfset testBody = "
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: ##333; }
                .header { background: ##15171a; color: white; padding: 20px; text-align: center; }
                .content { padding: 20px; }
                .footer { background: ##f4f5f6; padding: 15px; text-align: center; font-size: 12px; color: ##666; }
            </style>
        </head>
        <body>
            <div class='header'>
                <h1>Ghost CMS Mail Test</h1>
            </div>
            <div class='content'>
                <h2>Congratulations!</h2>
                <p>Your mail configuration is working correctly. This is a test email sent from your Ghost CMS installation.</p>
                <p><strong>Mail Settings Used:</strong></p>
                <ul>
                    <cfif structKeyExists(mailSettings, "mail_service") AND mailSettings.mail_service EQ "Mailjet">
                        <li>Service: Mailjet API</li>
                        <li>SMTP Host: in-v3.mailjet.com</li>
                        <li>Port: 587</li>
                        <li>Security: STARTTLS</li>
                    <cfelse>
                        <li>Service: SMTP</li>
                        <li>SMTP Host: #mailSettings.mail_host#</li>
                        <li>Port: #mailSettings.mail_port#</li>
                        <li>Security: #mailSettings.mail_secure#</li>
                    </cfif>
                    <li>From: #mailSettings.mail_from_address#</li>
                </ul>
                <p>If you received this email, your mail configuration is working properly and you can start sending emails from your publication.</p>
            </div>
            <div class='footer'>
                <p>This is an automated test email from Ghost CMS</p>
                <p>Sent on #dateFormat(now(), 'mmm dd, yyyy')# at #timeFormat(now(), 'h:mm tt')#</p>
            </div>
        </body>
        </html>
    ">
    
    <!--- Send email based on service type --->
    <cfif structKeyExists(mailSettings, "mail_service") AND mailSettings.mail_service EQ "Mailjet">
        <!--- Use Mailjet API --->
        <cfset apiUrl = "https://api.mailjet.com/v3.1/send">
        
        <!--- Prepare from name --->
        <cfset fromName = "Ghost CMS">
        <cfif len(trim(mailSettings.mail_from_name)) GT 0>
            <cfset fromName = mailSettings.mail_from_name>
        </cfif>
        
        <!--- Build payload step by step --->
        <cfset fromObj = structNew()>
        <cfset fromObj.Email = mailSettings.mail_from_address>
        <cfset fromObj.Name = fromName>
        
        <cfset toObj = structNew()>
        <cfset toObj.Email = jsonData.email>
        
        <cfset messageObj = structNew()>
        <cfset messageObj.From = fromObj>
        <cfset messageObj.To = [toObj]>
        <cfset messageObj.Subject = testSubject>
        <cfset messageObj.HTMLPart = testBody>
        
        <!--- Add Reply-To if configured --->
        <cfif len(trim(mailSettings.mail_reply_to))>
            <cfset replyToObj = structNew()>
            <cfset replyToObj.Email = mailSettings.mail_reply_to>
            <cfset messageObj.ReplyTo = replyToObj>
        </cfif>
        
        <cfset payload = structNew()>
        <cfset payload.Messages = [messageObj]>
        
        <!--- Convert to JSON --->
        <cfset jsonPayload = serializeJSON(payload)>
        
        <!--- Make HTTP request --->
        <cfhttp url="#apiUrl#" method="POST" timeout="30">
            <cfhttpparam type="header" name="Content-Type" value="application/json">
            <cfhttpparam type="header" name="Authorization" value="Basic #toBase64(mailSettings.mailjetApiKey & ':' & mailSettings.mailjetSecret)#">
            <cfhttpparam type="body" value="#jsonPayload#">
        </cfhttp>
        
        <!--- Check Mailjet response --->
        <cfif cfhttp.statusCode NEQ "200 OK">
            <cfthrow message="Mailjet API error: #cfhttp.statusCode# - #cfhttp.fileContent#">
        </cfif>
        
    <cfelse>
        <!--- Use SMTP for other services --->
        <cfmail 
            to="#jsonData.email#"
            from="#mailSettings.mail_from_address#"
            subject="#testSubject#"
            type="html"
            server="#mailSettings.mail_host#"
            port="#mailSettings.mail_port#"
            username="#mailSettings.mail_username#"
            password="#mailSettings.mail_password#"
            useSSL="#(mailSettings.mail_secure EQ 'SSL')#"
            useTLS="#(mailSettings.mail_secure EQ 'STARTTLS')#"
            timeout="30">
            
            <cfif len(trim(mailSettings.mail_from_name))>
                <cfmailparam name="From" value="#mailSettings.mail_from_name# <#mailSettings.mail_from_address#>">
            </cfif>
            
            <cfif len(trim(mailSettings.mail_reply_to))>
                <cfmailparam name="Reply-To" value="#mailSettings.mail_reply_to#">
            </cfif>
            
            <cfmailparam name="X-Mailer" value="Ghost CMS">
            <cfmailparam name="X-Priority" value="3">
            
            #testBody#
        </cfmail>
    </cfif>
    
    <!--- Log the test email attempt --->
    <cfset serviceName = "SMTP">
    <cfset logDetails = "SMTP">
    <cfif structKeyExists(mailSettings, 'mail_service')>
        <cfset serviceName = mailSettings.mail_service>
        <cfif mailSettings.mail_service EQ "Mailjet">
            <cfset logDetails = "Mailjet API">
        <cfelse>
            <cfset logDetails = mailSettings.mail_host & ":" & mailSettings.mail_port>
        </cfif>
    </cfif>
    <cflog file="mail-test" text="Test email sent successfully to #jsonData.email# using #logDetails# (Service: #serviceName#)">
    
    <cfset response = {
        "success": true,
        "message": "Test email sent successfully to #jsonData.email#"
    }>
    
<cfcatch>
    <!--- Log the error --->
    <cflog file="mail-test" text="Test email failed: #cfcatch.message# - #cfcatch.detail#" type="error">
    
    <cfset response = {
        "success": false,
        "message": cfcatch.message,
        "detail": cfcatch.detail
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>