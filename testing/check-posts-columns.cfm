<!--- Check posts table structure --->
<cftry>
    <h3>Posts Table Structure:</h3>
    
    <cfquery name="showColumns" datasource="blog">
        SHOW COLUMNS FROM posts
    </cfquery>
    
    <table border="1" cellpadding="5">
        <tr>
            <th>Field</th>
            <th>Type</th>
            <th>Null</th>
            <th>Key</th>
            <th>Default</th>
        </tr>
        <cfoutput query="showColumns">
            <tr>
                <td><strong>#Field#</strong></td>
                <td>#Type#</td>
                <td>#Null#</td>
                <td>#Key#</td>
                <td>#Default#</td>
            </tr>
        </cfoutput>
    </table>
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>