<!--- Google OAuth Login Handler --->
<cfheader name="Content-Type" value="application/json">
<cfsetting requestTimeout="30">

<cfscript>
// Response object
response = {
    success: false,
    message: "Invalid request"
};

if (cgi.request_method == "POST" && structKeyExists(form, "credential")) {
    try {
        // Google's public keys endpoint for JWT verification
        googleKeysUrl = "https://www.googleapis.com/oauth2/v3/certs";
        
        // Decode JWT token (Google ID token has 3 parts: header.payload.signature)
        tokenParts = listToArray(form.credential, ".");
        
        if (arrayLen(tokenParts) == 3) {
            // Decode the payload (base64url decode)
            payload = tokenParts[2];
            // Add padding if needed
            padding = 4 - (len(payload) mod 4);
            if (padding != 4) {
                payload = payload & repeatString("=", padding);
            }
            
            // Replace URL-safe characters
            payload = replace(payload, "-", "+", "all");
            payload = replace(payload, "_", "/", "all");
            
            // Decode base64
            decodedPayload = toString(toBinary(payload));
            
            // Parse JSON
            userData = deserializeJSON(decodedPayload);
            
            // Verify token claims
            // In production, you should verify:
            // 1. iss (issuer) is https://accounts.google.com
            // 2. aud (audience) matches your client ID
            // 3. exp (expiration) hasn't passed
            // 4. Signature verification
            
            if (structKeyExists(userData, "email") && len(userData.email) > 0) {
                // Check if user exists in database
                userQuery = queryExecute("
                    SELECT u.id, u.name, u.email, u.password, u.status, 
                           r.name as role_name
                    FROM users u
                    LEFT JOIN roles_users ru ON u.id = ru.user_id
                    LEFT JOIN roles r ON ru.role_id = r.id
                    WHERE u.email = :email
                    AND u.status = 'active'
                    LIMIT 1
                ", {
                    email: {value: trim(userData.email), cfsqltype: "cf_sql_varchar"}
                }, {datasource: "blog"});
                
                if (userQuery.recordCount > 0) {
                    // User exists, log them in
                    session.isLoggedIn = true;
                    session.userId = userQuery.id;
                    session.userName = userQuery.name;
                    session.userEmail = userQuery.email;
                    session.userRole = userQuery.role_name ?: "Author";
                    
                    response.success = true;
                    response.message = "Login successful";
                } else {
                    // Optional: Create new user from Google data
                    // For now, just reject if email not found
                    response.success = false;
                    response.message = "No account found with this Google email address. Please contact an administrator.";
                }
            } else {
                response.success = false;
                response.message = "Invalid Google token - no email found";
            }
        } else {
            response.success = false;
            response.message = "Invalid token format";
        }
        
    } catch (any e) {
        response.success = false;
        response.message = "Error processing Google sign-in: " & e.message;
        
        // Log error for debugging
        writeLog(
            type="error",
            file="google-login",
            text="Google login error: #e.message# - #e.detail#"
        );
    }
} else {
    response.success = false;
    response.message = "Invalid request - no credential provided";
}

// Output JSON response
writeOutput(serializeJSON(response));
</cfscript>