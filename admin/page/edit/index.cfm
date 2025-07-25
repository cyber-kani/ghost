<!--- Page editor - uses same editor as posts but with type=page --->
<cfscript>
    // Extract ID from URL path: /ghost/admin/page/edit/[id]
    pathInfo = cgi.path_info;
    urlParts = listToArray(pathInfo, "/");
    
    // Find the ID after 'edit' in the URL path
    postId = "";
    for (i = 1; i <= arrayLen(urlParts); i++) {
        if (urlParts[i] == "edit" && i < arrayLen(urlParts)) {
            postId = urlParts[i + 1];
            break;
        }
    }
    
    // Fallback to URL parameter if path parsing fails
    if (len(trim(postId)) == 0) {
        param name="url.id" default="";
        postId = url.id;
    }
    
    // Set type to page
    url.type = "page";
    
    // Include the editor
    include "/var/www/sites/cloudcoder.dev/wwwroot/ghost/admin/post/edit/index.cfm";
</cfscript>