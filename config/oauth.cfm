<!--- OAuth Configuration File --->
<!--- 
This file contains OAuth configuration settings for third-party authentication.
For security, consider moving these settings to environment variables in production.
--->

<cfscript>
// Google OAuth Configuration
application.oauth = {
    google: {
        // Replace with your actual Google OAuth Client ID
        clientId: "YOUR_GOOGLE_CLIENT_ID",
        
        // Optional: Client Secret (for server-side validation)
        // clientSecret: "YOUR_GOOGLE_CLIENT_SECRET",
        
        // Authorized redirect URIs (must match Google Console settings)
        redirectUri: "https://clitools.app/ghost/admin/login",
        
        // Authorized JavaScript origins
        authorizedOrigins: [
            "https://clitools.app",
            "http://localhost" // For local development
        ]
    }
};

/*
Setup Instructions for Google OAuth:

1. Go to https://console.cloud.google.com
2. Create a new project or select an existing one
3. Enable the Google+ API:
   - Go to "APIs & Services" > "Library"
   - Search for "Google+ API"
   - Click on it and press "Enable"

4. Create OAuth 2.0 credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client ID"
   - Choose "Web application" as the application type
   - Name your OAuth client (e.g., "CFGhost CMS")

5. Configure OAuth consent screen:
   - Add your application name
   - Add your support email
   - Add authorized domains: clitools.app
   - Save the consent screen

6. Configure the OAuth client:
   - Authorized JavaScript origins:
     * https://clitools.app
     * http://localhost (for development)
   
   - Authorized redirect URIs:
     * https://clitools.app/ghost/admin/login
     * http://localhost/ghost/admin/login (for development)

7. Copy the Client ID and update this file

8. (Optional) For enhanced security, also copy the Client Secret
   and implement server-side token validation

Common Issues:
- Error 401: invalid_client - Client ID is incorrect or not found
- Error 400: redirect_uri_mismatch - Redirect URI doesn't match Google Console
- Error 403: access_denied - User cancelled the sign-in flow

Testing:
- Always test with both HTTP and HTTPS versions
- Ensure cookies are enabled for session management
- Check browser console for JavaScript errors
*/
</cfscript>