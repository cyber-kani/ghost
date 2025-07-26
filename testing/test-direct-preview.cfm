<!--- Test Direct Preview Access --->
<cfset url.id = "687de71ebc740c1b43f0a355">
<cfset url.member_status = "public">

<h3>Testing Direct Preview Access</h3>

<cftry>
    <p>Including preview.cfm directly...</p>
    <cfinclude template="../admin/preview.cfm">
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>