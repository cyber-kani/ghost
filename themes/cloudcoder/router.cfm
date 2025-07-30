<!--- CloudCoder Theme Router --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.path" default="">

<!--- Parse the URL path --->
<cfset pathSegments = listToArray(url.path, "/")>
<cfset segmentCount = arrayLen(pathSegments)>

<!--- Route to appropriate template --->
<cfif segmentCount EQ 0>
    <!--- Home page --->
    <cfinclude template="index.cfm">
<cfelseif segmentCount EQ 1>
    <!--- Check if it's a tag --->
    <cfif pathSegments[1] EQ "tag" AND structKeyExists(url, "slug")>
        <cfinclude template="tag.cfm">
    <cfelse>
        <!--- Single slug - could be post or page --->
        <cfset url.slug = pathSegments[1]>
        
        <!--- Check if it's a page first --->
        <cfquery name="qCheckPage" datasource="#request.dsn#">
            SELECT id FROM posts 
            WHERE slug = <cfqueryparam value="#url.slug#" cfsqltype="cf_sql_varchar">
            AND type = <cfqueryparam value="page" cfsqltype="cf_sql_varchar">
            AND status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <cfif qCheckPage.recordCount GT 0>
            <cfinclude template="page.cfm">
        <cfelse>
            <cfinclude template="post.cfm">
        </cfif>
    </cfif>
<cfelseif segmentCount GTE 2 AND pathSegments[1] EQ "tag">
    <!--- Tag page --->
    <cfset url.slug = pathSegments[2]>
    <cfinclude template="tag.cfm">
<cfelse>
    <!--- 404 --->
    <cfheader statuscode="404" statustext="Not Found">
    <cfabort>
</cfif>