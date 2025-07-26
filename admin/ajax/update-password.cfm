<!--- 
Password Update Action Page
Handles AJAX requests for user password changes based on Ghost CMS architecture
--->

<cfheader name="Content-Type" value="application/json">
<cfsetting requestTimeout="30">

<cfscript>
/**
 * Hash password using bcrypt (Ghost uses bcrypt with 10 rounds)
 */
function hashPassword(string password) {
    try {
        // Use CFML's built-in password hashing (bcrypt)
        return hash(arguments.password, "bcrypt", "utf-8", 10);
    } catch (any e) {
        // Fallback to SHA-256 if bcrypt not available
        return hash(arguments.password, "SHA-256");
    }
}

/**
 * Verify password against hash
 */
function verifyPassword(string password, string hashedPassword) {
    try {
        // For bcrypt hashes (starts with $2a$, $2b$, $2y$)
        if (left(arguments.hashedPassword, 4) == "$2a$" || 
            left(arguments.hashedPassword, 4) == "$2b$" || 
            left(arguments.hashedPassword, 4) == "$2y$") {
            // Use bcrypt verification
            var testHash = hash(arguments.password, "bcrypt", "utf-8", 10);
            return compare(arguments.hashedPassword, testHash) == 0;
        } else {
            // For SHA-256 hashes (fallback)
            var testHash = hash(arguments.password, "SHA-256");
            return compare(arguments.hashedPassword, testHash) == 0;
        }
    } catch (any e) {
        return false;
    }
}

/**
 * Update user password following Ghost security patterns
 */
function updateUserPassword(struct passwordData) {
    try {
        // Validate required fields
        if (!structKeyExists(passwordData, "userId") || len(trim(passwordData.userId)) == 0) {
            return {
                success: false,
                message: "User ID is required"
            };
        }
        
        if (!structKeyExists(passwordData, "currentPassword") || len(trim(passwordData.currentPassword)) == 0) {
            return {
                success: false,
                message: "Current password is required"
            };
        }
        
        if (!structKeyExists(passwordData, "newPassword") || len(trim(passwordData.newPassword)) == 0) {
            return {
                success: false,
                message: "New password is required"
            };
        }
        
        if (!structKeyExists(passwordData, "confirmPassword") || len(trim(passwordData.confirmPassword)) == 0) {
            return {
                success: false,
                message: "Password confirmation is required"
            };
        }
        
        // Validate password strength
        if (len(passwordData.newPassword) < 8) {
            return {
                success: false,
                message: "Password must be at least 8 characters long"
            };
        }
        
        // Check if new passwords match
        if (passwordData.newPassword != passwordData.confirmPassword) {
            return {
                success: false,
                message: "New passwords do not match"
            };
        }
        
        // Get current user record
        var userQuery = queryExecute("
            SELECT id, password, email, name
            FROM users 
            WHERE id = :userId AND status = 'active'
        ", {
            userId: {value: trim(passwordData.userId), cfsqltype: "cf_sql_varchar"}
        }, {datasource: "ghost_prod"});
        
        if (userQuery.recordCount == 0) {
            return {
                success: false,
                message: "User not found or inactive"
            };
        }
        
        var currentHashedPassword = userQuery.password[1];
        
        // Verify current password
        if (!verifyPassword(passwordData.currentPassword, currentHashedPassword)) {
            return {
                success: false,
                message: "Current password is incorrect"
            };
        }
        
        // Don't allow same password
        if (verifyPassword(passwordData.newPassword, currentHashedPassword)) {
            return {
                success: false,
                message: "New password must be different from current password"
            };
        }
        
        // Hash new password
        var newHashedPassword = hashPassword(passwordData.newPassword);
        
        // Update password in database
        var updateResult = queryExecute("
            UPDATE users SET
                password = :password,
                updated_at = :updatedAt,
                updated_by = :updatedBy
            WHERE id = :userId
        ", {
            password: {value: newHashedPassword, cfsqltype: "cf_sql_varchar"},
            updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
            updatedBy: {value: trim(passwordData.userId), cfsqltype: "cf_sql_varchar"},
            userId: {value: trim(passwordData.userId), cfsqltype: "cf_sql_varchar"}
        }, {datasource: "ghost_prod"});
        
        // Log password change for security (optional)
        try {
            // You could add logging here for security audit
            // logSecurityEvent("password_changed", passwordData.userId);
        } catch (any e) {
            // Don't fail the whole operation if logging fails
        }
        
        return {
            success: true,
            message: "Password updated successfully. You may need to log in again on other devices.",
            data: {
                passwordChanged: true,
                timestamp: now()
            }
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error updating password: " & e.message
        };
    }
}

// Main request handling
response = {success: false, message: "Invalid request"};

if (cgi.request_method == "POST") {
    
    // Get current user ID from database (for now use first admin user)
    try {
        userQuery = queryExecute("
            SELECT id FROM users 
            WHERE status = 'active' 
            ORDER BY created_at ASC 
            LIMIT 1
        ", {}, {datasource: "ghost_prod"});
        
        if (userQuery.recordCount > 0) {
            currentUserId = userQuery.id[1];
        } else {
            response = {success: false, message: "User not found"};
        }
    } catch (any e) {
        response = {success: false, message: "Error finding user: " & e.message};
    }
    
    if (structKeyExists(variables, "currentUserId")) {
        // Handle password change request
        passwordData = {
            userId: currentUserId,
            currentPassword: form.currentPassword ?: "",
            newPassword: form.newPassword ?: "",
            confirmPassword: form.confirmPassword ?: ""
        };
        
        response = updateUserPassword(passwordData);
    }
}

// Output JSON response
writeOutput(serializeJSON(response));
</cfscript>