<!--- Firebase Configuration File --->
<!--- 
Firebase Authentication Setup Instructions for CFGhost

Firebase is easier to set up than raw Google OAuth and provides more features
including automatic token management, multiple auth providers, and better security.

SETUP INSTRUCTIONS:

1. Create a Firebase Project:
   - Go to https://console.firebase.google.com
   - Click "Create a project" or select an existing one
   - Enter project name (e.g., "CFGhost CMS")
   - Disable Google Analytics (optional)
   - Click "Create project"

2. Enable Authentication:
   - In Firebase Console, go to "Authentication" in the left menu
   - Click "Get started"
   - Go to "Sign-in method" tab
   - Click on "Google" provider
   - Toggle "Enable" switch
   - Add your public-facing email for project support
   - Click "Save"

3. Add Your Domain:
   - Still in Authentication > Settings tab
   - Scroll to "Authorized domains"
   - Click "Add domain"
   - Add: clitools.app
   - Add: localhost (for local development)

4. Get Your Configuration:
   - Go to Project Settings (gear icon)
   - Scroll to "Your apps" section
   - Click "</>" (Web) icon
   - Register app with nickname "CFGhost Web"
   - Copy the firebaseConfig object
   - Paste it in login.cfm replacing the placeholder

5. Optional: Add Firebase Admin SDK (for enhanced security):
   - Go to Project Settings > Service accounts
   - Click "Generate new private key"
   - Save the JSON file securely
   - Use it for server-side token verification

FIREBASE CONFIG EXAMPLE:
const firebaseConfig = {
    apiKey: "AIzaSyD-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abcdef123456789012345"
};

BENEFITS OF FIREBASE AUTH:
- No need to manage OAuth tokens
- Automatic token refresh
- Multiple auth providers (Google, Facebook, Twitter, GitHub, etc.)
- Built-in security rules
- User management dashboard
- Email/password auth option
- Phone number auth option
- Anonymous auth for guests
- Custom auth tokens

TROUBLESHOOTING:
- "auth/unauthorized-domain": Add your domain to authorized domains
- "auth/popup-blocked": Ensure popups are allowed
- "auth/network-request-failed": Check internet connection
- "auth/invalid-api-key": Verify Firebase config is correct

SECURITY NOTES:
- Firebase API keys are safe to expose (they're restricted by domain)
- Always validate users server-side before granting access
- Consider implementing Firebase Admin SDK for enhanced security
- Use Firebase Security Rules for client-side data access
--->

<cfscript>
// This file can be used to store Firebase configuration server-side
// For now, configuration is directly in login.cfm for simplicity
</cfscript>