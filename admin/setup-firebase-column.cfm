<!--- Add Firebase UID column to users table --->
<cftry>
    <!--- Check if column already exists --->
    <cfquery name="checkColumn" datasource="blog">
        SELECT COLUMN_NAME 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users' 
        AND COLUMN_NAME = 'firebase_uid'
    </cfquery>
    
    <cfif checkColumn.recordCount eq 0>
        <!--- Add firebase_uid column --->
        <cfquery datasource="blog">
            ALTER TABLE users 
            ADD COLUMN firebase_uid VARCHAR(255) NULL AFTER email,
            ADD INDEX idx_firebase_uid (firebase_uid);
        </cfquery>
        
        <p>Firebase UID column added successfully!</p>
    <cfelse>
        <p>Firebase UID column already exists.</p>
    </cfif>
    
    <p><a href="/ghost/admin/login">Go to login page</a></p>
    
    <cfcatch>
        <p>Error: <cfoutput>#cfcatch.message#</cfoutput></p>
        <p>Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
    </cfcatch>
</cftry>