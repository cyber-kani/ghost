<!--- Check ID column sizes in database --->
<cfset tables = ["posts", "posts_authors", "posts_tags", "posts_meta", "users", "tags"]>

<h2>ID Column Information</h2>

<cfloop array="#tables#" index="tableName">
    <h3>#tableName# table:</h3>
    <cftry>
        <cfquery name="qColumns" datasource="#request.dsn#">
            SELECT 
                COLUMN_NAME,
                DATA_TYPE,
                CHARACTER_MAXIMUM_LENGTH,
                IS_NULLABLE
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = <cfqueryparam value="#tableName#" cfsqltype="cf_sql_varchar">
            AND COLUMN_NAME = 'id'
            AND TABLE_SCHEMA = DATABASE()
        </cfquery>
        
        <cfif qColumns.recordCount>
            <ul>
                <li>Column: #qColumns.COLUMN_NAME#</li>
                <li>Type: #qColumns.DATA_TYPE#</li>
                <li>Max Length: #qColumns.CHARACTER_MAXIMUM_LENGTH ?: "N/A"#</li>
                <li>Nullable: #qColumns.IS_NULLABLE#</li>
            </ul>
        <cfelse>
            <p>No ID column found</p>
        </cfif>
        
        <cfcatch>
            <p>Error checking table: #cfcatch.message#</p>
        </cfcatch>
    </cftry>
</cfloop>

<h2>Sample IDs from posts table:</h2>
<cftry>
    <cfquery name="qSampleIds" datasource="#request.dsn#">
        SELECT id, LENGTH(id) as id_length
        FROM posts
        LIMIT 5
    </cfquery>
    
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Length</th>
        </tr>
        <cfloop query="qSampleIds">
            <tr>
                <td>#qSampleIds.id#</td>
                <td>#qSampleIds.id_length#</td>
            </tr>
        </cfloop>
    </table>
    
    <cfcatch>
        <p>Error getting sample IDs: #cfcatch.message#</p>
    </cfcatch>
</cftry>