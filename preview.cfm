<!--- Simple Preview Handler at Root --->
<cfparam name="url.id" default="">

<!--- Extract ID from path if not in URL --->
<cfif NOT len(url.id) AND structKeyExists(url, "path") AND find("/", url.path)>
    <cfset url.id = listLast(url.path, "/")>
</cfif>

<!--- Include the actual preview file --->
<cfinclude template="admin/preview.cfm">