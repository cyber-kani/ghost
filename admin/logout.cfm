<!--- Clear session variables --->
<cfset structClear(session)>

<!--- Redirect to login page --->
<cflocation url="/ghost/admin/login" addtoken="false">