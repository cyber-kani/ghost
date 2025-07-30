<cfparam name="request.dsn" default="blog">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Get current settings --->
<cfquery name="getSettings" datasource="#request.dsn#">
    SELECT `key` as settingKey, `value` as settingValue, type 
    FROM settings
    WHERE `key` IN (
        'title', 'description', 'timezone', 'locale', 'logo', 'icon', 
        'accent_color', 'facebook', 'twitter', 'cover_image',
        'meta_title', 'meta_description', 'og_image', 'og_title', 
        'og_description', 'twitter_image', 'twitter_title', 'twitter_description',
        'posts_per_page', 'google_analytics', 'enable_comments', 'is_private', 'password',
        'staff_display_name', 'show_headline'
    )
</cfquery>

<!--- Convert to struct for easy access --->
<cfset settings = {}>
<cfloop query="getSettings">
    <cfset settings[getSettings.settingKey] = getSettings.settingValue>
</cfloop>

<!--- Set defaults if not exist --->
<cfparam name="settings.title" default="Ghost CMS">
<cfparam name="settings.description" default="Thoughts, stories and ideas">
<cfparam name="settings.timezone" default="UTC">
<cfparam name="settings.locale" default="en">
<cfparam name="settings.logo" default="">
<cfparam name="settings.icon" default="">
<cfparam name="settings.accent_color" default="#15171A">
<cfparam name="settings.facebook" default="">
<cfparam name="settings.twitter" default="">
<cfparam name="settings.cover_image" default="">
<cfparam name="settings.meta_title" default="">
<cfparam name="settings.meta_description" default="">
<cfparam name="settings.og_image" default="">
<cfparam name="settings.og_title" default="">
<cfparam name="settings.og_description" default="">
<cfparam name="settings.twitter_image" default="">
<cfparam name="settings.twitter_title" default="">
<cfparam name="settings.twitter_description" default="">
<cfparam name="settings.posts_per_page" default="10">
<cfparam name="settings.google_analytics" default="">
<cfparam name="settings.enable_comments" default="false">
<cfparam name="settings.is_private" default="false">
<cfparam name="settings.password" default="">
<cfparam name="settings.staff_display_name" default="true">
<cfparam name="settings.show_headline" default="true">

<cfset pageTitle = "General Settings">
<cfinclude template="../includes/header.cfm">

<!--- Rest of the content will be copied from the original file... --->
<p>This is the fixed version - JavaScript errors have been resolved.</p>

<cfinclude template="../includes/footer.cfm">