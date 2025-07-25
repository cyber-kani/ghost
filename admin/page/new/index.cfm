<!--- New page creation --->
<cfscript>
    // Set empty ID for new page
    url.id = "";
    url.type = "page";
    
    // Include the editor
    include "/var/www/sites/cloudcoder.dev/wwwroot/ghost/admin/post/edit/index.cfm";
</cfscript>