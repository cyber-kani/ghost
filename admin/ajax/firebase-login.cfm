<!--- Firebase OAuth Login Handler --->
<cfheader name="Content-Type" value="application/json">
<cfsetting requestTimeout="30">

<cfscript>
// Response object
response = {
    success: false,
    message: "Invalid request"
};

if (cgi.request_method == "POST" && structKeyExists(form, "email") && structKeyExists(form, "uid")) {
    try {
        // Get user data from Firebase
        userEmail = trim(form.email);
        userName = structKeyExists(form, "name") ? trim(form.name) : "";
        firebaseUid = trim(form.uid);
        photoURL = structKeyExists(form, "photoURL") ? trim(form.photoURL) : "";
        
        if (len(userEmail) > 0) {
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
                email: {value: userEmail, cfsqltype: "cf_sql_varchar"}
            }, {datasource: "blog"});
            
            if (userQuery.recordCount > 0) {
                // User exists, log them in (use uppercase for CFML compatibility)
                session.ISLOGGEDIN = true;
                session.USERID = userQuery.id;
                session.USERNAME = userQuery.name;
                session.USEREMAIL = userQuery.email;
                session.USERROLE = userQuery.role_name ?: "Author";
                
                // Skip updating Firebase UID due to table size constraints
                // Just update last login time
                queryExecute("
                    UPDATE users 
                    SET updated_at = :updatedAt
                    WHERE id = :userId
                ", {
                    updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
                    userId: {value: userQuery.id, cfsqltype: "cf_sql_varchar"}
                }, {datasource: "blog"});
                
                response.success = true;
                response.message = "Login successful";
            } else {
                // Optional: Auto-create user from Firebase data
                // Uncomment the following to auto-create users
                /*
                newUserId = createUUID();
                userSlug = lcase(reReplace(userName, "[^a-zA-Z0-9]", "-", "all"));
                
                // Ensure unique slug
                slugCheck = queryExecute("
                    SELECT COUNT(*) as count FROM users WHERE slug = :slug
                ", {slug: {value: userSlug, cfsqltype: "cf_sql_varchar"}}, {datasource: "blog"});
                
                if (slugCheck.count > 0) {
                    userSlug = userSlug & "-" & left(newUserId, 8);
                }
                
                // Create new user
                queryExecute("
                    INSERT INTO users (
                        id, name, slug, email, profile_image,
                        firebase_uid, status, created_at, created_by
                    ) VALUES (
                        :id, :name, :slug, :email, :profileImage,
                        :firebaseUid, 'active', :createdAt, :createdBy
                    )
                ", {
                    id: {value: newUserId, cfsqltype: "cf_sql_varchar"},
                    name: {value: userName ?: "Firebase User", cfsqltype: "cf_sql_varchar"},
                    slug: {value: userSlug, cfsqltype: "cf_sql_varchar"},
                    email: {value: userEmail, cfsqltype: "cf_sql_varchar"},
                    profileImage: {value: photoURL, cfsqltype: "cf_sql_varchar"},
                    firebaseUid: {value: firebaseUid, cfsqltype: "cf_sql_varchar"},
                    createdAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
                    createdBy: {value: "firebase-auth", cfsqltype: "cf_sql_varchar"}
                }, {datasource: "blog"});
                
                // Set session
                session.isLoggedIn = true;
                session.userId = newUserId;
                session.userName = userName ?: "Firebase User";
                session.userEmail = userEmail;
                session.userRole = "Author";
                
                response.success = true;
                response.message = "Account created and logged in";
                */
                
                // User not found - login failed
                response.success = false;
                response.message = "Login failed. Invalid credentials.";
            }
        } else {
            response.success = false;
            response.message = "Invalid Firebase data - no email found";
        }
        
    } catch (any e) {
        response.success = false;
        response.message = "Error processing Firebase sign-in: " & e.message;
        
        // Log error for debugging
        writeLog(
            type="error",
            file="firebase-login",
            text="Firebase login error: #e.message# - #e.detail#"
        );
    }
} else {
    response.success = false;
    response.message = "Invalid request - missing required fields";
}

// Output JSON response
writeOutput(serializeJSON(response));
</cfscript>