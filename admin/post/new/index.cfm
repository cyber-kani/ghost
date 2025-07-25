<!--- Redirect to editor for new post creation --->
<cfscript>
    // Set empty ID for new post
    url.id = "";
    url.type = "post"; // Default to post unless specified
    
    // Include the editor
    include "/var/www/sites/cloudcoder.dev/wwwroot/ghost/admin/post/edit/index.cfm";
</cfscript>