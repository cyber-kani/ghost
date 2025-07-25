<!--- Simple session initialization for testing --->
<cfif not structKeyExists(session, "user")>
    <cfset session.user = {
        name: "Admin User",
        email: "admin@ghost.com", 
        role: "Administrator"
    }>
</cfif>

<!--- Redirect to dashboard --->
<cflocation url="/ghost/admin/index.cfm" addtoken="false">