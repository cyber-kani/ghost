<!--- Check posts_meta table --->
<cftry>
    <h3>1. Check if posts_meta table exists:</h3>
    <cfquery name="checkTable" datasource="blog">
        SHOW TABLES LIKE 'posts_meta'
    </cfquery>
    
    <cfif checkTable.recordCount>
        <p style="color: green;">✅ posts_meta table exists</p>
        
        <h4>Table Structure:</h4>
        <cfquery name="showColumns" datasource="blog">
            SHOW COLUMNS FROM posts_meta
        </cfquery>
        
        <table border="1" cellpadding="5">
            <tr>
                <th>Field</th>
                <th>Type</th>
                <th>Null</th>
                <th>Key</th>
            </tr>
            <cfoutput query="showColumns">
                <tr>
                    <td>#Field#</td>
                    <td>#Type#</td>
                    <td>#Null#</td>
                    <td>#Key#</td>
                </tr>
            </cfoutput>
        </table>
        
        <h4>Sample data:</h4>
        <cfquery name="sampleData" datasource="blog">
            SELECT *
            FROM posts_meta
            LIMIT 5
        </cfquery>
        
        <cfif sampleData.recordCount>
            <table border="1" cellpadding="5">
                <tr>
                    <cfloop list="#sampleData.columnList#" index="col">
                        <th><cfoutput>#col#</cfoutput></th>
                    </cfloop>
                </tr>
                <cfoutput query="sampleData">
                    <tr>
                        <cfloop list="#columnList#" index="col">
                            <td>#evaluate(col)#</td>
                        </cfloop>
                    </tr>
                </cfoutput>
            </table>
        <cfelse>
            <p>No meta data found for og/twitter fields</p>
        </cfif>
        
    <cfelse>
        <p style="color: red;">❌ posts_meta table does NOT exist</p>
        
        <h4>Available tables:</h4>
        <cfquery name="allTables" datasource="blog">
            SHOW TABLES
        </cfquery>
        
        <ul>
            <cfoutput query="allTables">
                <li>#allTables[columnList][1]#</li>
            </cfoutput>
        </ul>
    </cfif>
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>