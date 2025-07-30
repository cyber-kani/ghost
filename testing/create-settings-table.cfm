<!--- Create Settings Table for Ghost CMS --->
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Check if settings table exists --->
    <cfquery name="checkTable" datasource="#request.dsn#">
        SHOW TABLES LIKE 'settings'
    </cfquery>
    
    <cfif checkTable.recordCount EQ 0>
        <!--- Create settings table --->
        <cfquery datasource="#request.dsn#">
            CREATE TABLE settings (
                id INT AUTO_INCREMENT PRIMARY KEY,
                key_name VARCHAR(255) NOT NULL UNIQUE,
                value TEXT,
                type ENUM('string', 'text', 'number', 'boolean', 'json', 'color') DEFAULT 'string',
                flags VARCHAR(50) DEFAULT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                INDEX idx_key_name (key_name)
            )
        </cfquery>
        
        <p>Settings table created successfully!</p>
        
        <!--- Insert default settings --->
        <cfquery datasource="#request.dsn#">
            INSERT INTO settings (key_name, value, type, flags) VALUES
            ('title', 'Ghost CMS', 'string', 'PUBLIC'),
            ('description', 'Thoughts, stories and ideas', 'string', 'PUBLIC'),
            ('timezone', 'UTC', 'string', 'PUBLIC'),
            ('locale', 'en', 'string', 'PUBLIC'),
            ('logo', '', 'string', 'PUBLIC'),
            ('icon', '', 'string', 'PUBLIC'),
            ('cover_image', '', 'string', 'PUBLIC'),
            ('facebook', '', 'string', 'PUBLIC'),
            ('twitter', '', 'string', 'PUBLIC'),
            ('accent_color', '#15171A', 'color', 'PUBLIC'),
            ('codeinjection_head', '', 'text', NULL),
            ('codeinjection_foot', '', 'text', NULL),
            ('navigation', '[]', 'json', 'PUBLIC'),
            ('secondary_navigation', '[]', 'json', 'PUBLIC'),
            ('meta_title', '', 'string', 'PUBLIC'),
            ('meta_description', '', 'string', 'PUBLIC'),
            ('og_image', '', 'string', 'PUBLIC'),
            ('og_title', '', 'string', 'PUBLIC'),
            ('og_description', '', 'string', 'PUBLIC'),
            ('twitter_image', '', 'string', 'PUBLIC'),
            ('twitter_title', '', 'string', 'PUBLIC'),
            ('twitter_description', '', 'string', 'PUBLIC'),
            ('members_enabled', 'false', 'boolean', 'PUBLIC'),
            ('members_invite_only', 'false', 'boolean', NULL),
            ('paid_members_enabled', 'false', 'boolean', 'PUBLIC'),
            ('members_track_sources', 'true', 'boolean', NULL),
            ('email_track_opens', 'true', 'boolean', NULL),
            ('email_track_clicks', 'true', 'boolean', NULL),
            ('amp', 'false', 'boolean', 'PUBLIC'),
            ('unsplash', 'true', 'boolean', NULL),
            ('slack_url', '', 'string', NULL),
            ('slack_username', 'Ghost', 'string', NULL),
            ('staff_display_name', 'true', 'boolean', NULL),
            ('show_headline', 'true', 'boolean', NULL),
            ('mailgun_api_key', '', 'string', NULL),
            ('mailgun_domain', '', 'string', NULL),
            ('mailgun_base_url', '', 'string', NULL),
            ('email_from', 'noreply', 'string', NULL)
        </cfquery>
        
        <p>Default settings inserted successfully!</p>
    <cfelse>
        <p>Settings table already exists.</p>
    </cfif>
    
    <!--- Display current settings --->
    <cfquery name="getSettings" datasource="#request.dsn#">
        SELECT * FROM settings ORDER BY key_name
    </cfquery>
    
    <h3>Current Settings:</h3>
    <table border="1" cellpadding="5">
        <tr>
            <th>Key</th>
            <th>Value</th>
            <th>Type</th>
            <th>Flags</th>
        </tr>
        <cfoutput query="getSettings">
            <tr>
                <td>#key_name#</td>
                <td>#left(value, 50)#<cfif len(value) GT 50>...</cfif></td>
                <td>#type#</td>
                <td>#flags#</td>
            </tr>
        </cfoutput>
    </table>
    
<cfcatch>
    <h3>Error:</h3>
    <p><cfoutput>#cfcatch.message#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>