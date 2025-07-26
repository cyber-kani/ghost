<!--- Add Google user to database --->
<cfparam name="url.email" default="kani.somaratne@gmail.com">
<cfparam name="url.name" default="Kanishka Somaratne">

<cftry>
    <!--- Check if user already exists --->\n    <cfquery name="checkUser" datasource="blog">
        SELECT id FROM users 
        WHERE email = <cfqueryparam value="#url.email#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkUser.recordCount eq 0>
        <!--- Create new user --->
        <cfset userId = createUUID()>
        <cfset userSlug = lcase(reReplace(url.name, "[^a-zA-Z0-9]", "-", "all"))>
        
        <cfquery datasource="blog">
            INSERT INTO users (
                id, name, slug, password, email, 
                status, visibility, created_at, created_by,
                updated_at, updated_by
            ) VALUES (
                <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#url.name#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#userSlug#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="" cfsqltype="cf_sql_varchar">, <!--- No password for OAuth users --->
                <cfqueryparam value="#url.email#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="active" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="public" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="google-oauth" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="google-oauth" cfsqltype="cf_sql_varchar">
            )
        </cfquery>
        
        <!--- Get admin role --->
        <cfquery name="getRole" datasource="blog">
            SELECT id FROM roles WHERE name = 'Administrator'
        </cfquery>
        
        <cfif getRole.recordCount gt 0>
            <!--- Assign admin role --->
            <cfquery datasource="blog">
                INSERT INTO roles_users (id, role_id, user_id)
                VALUES (
                    <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#getRole.id#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
                )
            </cfquery>
            <p>Admin role assigned!</p>
        </cfif>
        
        <p style="color: green; font-weight: bold;">User created successfully!</p>
        <p>Email: <cfoutput>#url.email#</cfoutput></p>
        <p>Name: <cfoutput>#url.name#</cfoutput></p>
        <p>Role: Administrator</p>
    <cfelse>
        <p style="color: blue;">User already exists with email: <cfoutput>#url.email#</cfoutput></p>
    </cfif>
    
    <p><a href="/ghost/admin/login">Go to login page</a></p>
    
    <cfcatch>
        <p style="color: red;">Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        <p>Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
    </cfcatch>
</cftry>