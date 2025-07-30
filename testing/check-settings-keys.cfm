<!--- Check existing settings keys --->
<cfparam name="request.dsn" default="blog">

<h2>Existing Settings Keys</h2>

<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT `key`, value, type, `group`
    FROM settings
    WHERE `group` = 'core'
    ORDER BY `key`
</cfquery>

<table border="1" cellpadding="5">
    <tr>
        <th>Key</th>
        <th>Value</th>
        <th>Type</th>
        <th>Group</th>
    </tr>
    <cfoutput query="qSettings">
    <tr>
        <td>#key#</td>
        <td>#HTMLEditFormat(left(value, 50))#<cfif len(value) GT 50>...</cfif></td>
        <td>#type#</td>
        <td>#group#</td>
    </tr>
    </cfoutput>
</table>

<p>Total settings: <cfoutput>#qSettings.recordCount#</cfoutput></p>