<!--- Test General Settings Direct --->
<cfparam name="request.dsn" default="blog">

<!--- Skip login check for testing --->
<cfset session.ISLOGGEDIN = true>

<!--- Get current settings --->
<cftry>
    <cfquery name="getSettings" datasource="#request.dsn#">
        SELECT `key`, value, type FROM settings
        WHERE `key` IN (
            'title', 'description', 'timezone', 'locale', 'logo', 'icon', 
            'accent_color', 'facebook', 'twitter', 'cover_image',
            'meta_title', 'meta_description', 'og_image', 'og_title', 
            'og_description', 'twitter_image', 'twitter_title', 'twitter_description'
        )
    </cfquery>
    
    <p style="color: green;">✓ Query executed successfully</p>
    <p>Found <cfoutput>#getSettings.recordCount#</cfoutput> settings</p>
    
    <!--- Convert to struct for easy access --->
    <cfset settings = {}>
    <cfloop query="getSettings">
        <cfset settings[getSettings.key] = getSettings.value>
    </cfloop>
    
    <p style="color: green;">✓ Settings converted to struct</p>
    
    <h3>Settings Found:</h3>
    <ul>
    <cfloop collection="#settings#" item="key">
        <li><cfoutput>#key#: #left(settings[key], 50)#<cfif len(settings[key]) GT 50>...</cfif></cfoutput></li>
    </cfloop>
    </ul>
    
<cfcatch>
    <p style="color: red;">✗ Error: <cfoutput>#cfcatch.message#</cfoutput></p>
    <p>Detail: <cfoutput>#cfcatch.detail#</cfoutput></p>
    <cfdump var="#cfcatch#">
</cfcatch>
</cftry>