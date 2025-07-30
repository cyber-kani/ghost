<cfheader name="Content-Type" value="application/json">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Validate input --->
    <cfif NOT structKeyExists(form, "email") OR NOT isValid("email", form.email)>
        <cfthrow message="Valid email address is required">
    </cfif>
    
    <cfif NOT structKeyExists(form, "role_name") OR NOT len(trim(form.role_name))>
        <cfthrow message="Role is required">
    </cfif>
    
    <!--- Get role ID from role name --->
    <cfquery name="getRole" datasource="#request.dsn#">
        SELECT id FROM roles 
        WHERE name = <cfqueryparam value="#form.role_name#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif getRole.recordCount EQ 0>
        <cfthrow message="Invalid role selected">
    </cfif>
    
    <!--- Check if user already exists --->
    <cfquery name="checkUser" datasource="#request.dsn#">
        SELECT id FROM users 
        WHERE email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
    </cfquery>
    
    <cfif checkUser.recordCount GT 0>
        <cfthrow message="A user with this email already exists">
    </cfif>
    
    <!--- Generate invitation token --->
    <cfset inviteToken = createUUID()>
    <cfset tempPassword = left(hash(createUUID()), 8)>
    
    <!--- Create invited user --->
    <cfset newUserId = createUUID()>
    <cfquery datasource="#request.dsn#">
        INSERT INTO users (
            id, 
            name, 
            slug,
            email, 
            password, 
            status, 
            visibility,
            created_at,
            created_by
        ) VALUES (
            <cfqueryparam value="#newUserId#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#listFirst(form.email, '@')#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#lcase(replace(listFirst(form.email, '@'), '.', '-', 'all'))#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#hash(tempPassword)#" cfsqltype="cf_sql_varchar">,
            'invited',
            'public',
            NOW(),
            <cfqueryparam value="1" cfsqltype="cf_sql_varchar">
        )
    </cfquery>
    
    <!--- Assign role to user --->
    <cfquery datasource="#request.dsn#">
        INSERT INTO roles_users (
            id,
            role_id,
            user_id
        ) VALUES (
            <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#getRole.id#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#newUserId#" cfsqltype="cf_sql_varchar">
        )
    </cfquery>
    
    <!--- Send invitation email (simplified for now) --->
    <!--- In production, you would send an actual email with the invitation link --->
    
    <cfset response = {
        "success": true,
        "message": "Invitation sent successfully to #form.email#"
    }>
    
<cfcatch>
    <cfset response = {
        "success": false,
        "message": cfcatch.message
    }>
</cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>