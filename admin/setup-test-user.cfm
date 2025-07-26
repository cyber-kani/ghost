<!--- This file creates a test user for authentication --->
<cfset testPassword = "admin123">
<cfset hashedPassword = hash(testPassword, "SHA-256")>

<cftry>
    <!--- Check if user already exists --->
    <cfquery name="checkUser" datasource="blog">
        SELECT id FROM users 
        WHERE email = 'admin@ghost.com'
    </cfquery>
    
    <cfif checkUser.recordCount eq 0>
        <!--- Create test user --->
        <cfquery datasource="blog">
            INSERT INTO users (
                id, name, slug, password, email, 
                profile_image, cover_image, bio, website, location,
                status, language, visibility, created_at, created_by,
                updated_at, updated_by
            ) VALUES (
                <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="Admin User" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="admin-user" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="admin@ghost.com" cfsqltype="cf_sql_varchar">,
                NULL, NULL,
                <cfqueryparam value="Ghost CMS Administrator" cfsqltype="cf_sql_longvarchar">,
                <cfqueryparam value="https://ghost.org" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="Internet" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="active" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="en_US" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="public" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="1" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
        
        <p>Test user created successfully!</p>
        <p>Email: admin@ghost.com</p>
        <p>Password: admin123</p>
    <cfelse>
        <!--- Update existing user's password --->
        <cfquery datasource="blog">
            UPDATE users 
            SET password = <cfqueryparam value="#hashedPassword#" cfsqltype="cf_sql_varchar">,
                updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
            WHERE email = 'admin@ghost.com'
        </cfquery>
        
        <p>Test user password updated!</p>
        <p>Email: admin@ghost.com</p>
        <p>Password: admin123</p>
    </cfif>
    
    <!--- Also ensure user has admin role --->
    <cfquery name="getRole" datasource="blog">
        SELECT id FROM roles WHERE name = 'Administrator'
    </cfquery>
    
    <cfif getRole.recordCount gt 0>
        <cfquery name="getUserId" datasource="blog">
            SELECT id FROM users WHERE email = 'admin@ghost.com'
        </cfquery>
        
        <cfif getUserId.recordCount gt 0>
            <!--- Check if role assignment exists --->
            <cfquery name="checkRoleAssignment" datasource="blog">
                SELECT * FROM roles_users 
                WHERE user_id = <cfqueryparam value="#getUserId.id#" cfsqltype="cf_sql_varchar">
                AND role_id = <cfqueryparam value="#getRole.id#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif checkRoleAssignment.recordCount eq 0>
                <!--- Assign admin role --->
                <cfquery datasource="blog">
                    INSERT INTO roles_users (id, role_id, user_id)
                    VALUES (
                        <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#getRole.id#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#getUserId.id#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
                <p>Admin role assigned!</p>
            </cfif>
        </cfif>
    </cfif>
    
    <p><a href="/ghost/admin/login">Go to login page</a></p>
    
    <cfcatch>
        <p>Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        <p>Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
    </cfcatch>
</cftry>