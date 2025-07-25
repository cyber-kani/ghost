<cfsetting enablecfoutputonly="true">
<cfheader name="Content-Type" value="application/json">

<!--- Include posts functions instead of components --->
<cfinclude template="../includes/posts-functions.cfm">

<cfscript>
    // Initialize response structure
    response = {
        success: false,
        message: "",
        data: {}
    };
    
    try {
        // Check if this is a POST request
        if (cgi.request_method != "POST") {
            response.message = "Only POST requests are allowed";
            writeOutput(serializeJSON(response));
            cfabort;
        }
        
        // Get POST data
        param name="form.postId" default="";
        
        if (len(trim(form.postId)) == 0) {
            response.message = "Post ID is required";
            writeOutput(serializeJSON(response));
            cfabort;
        }
        
        // Delete the post using direct function call (no components needed)
        deleteResult = deletePost(form.postId);
        
        if (deleteResult.success) {
            response.success = true;
            response.message = deleteResult.message;
            response.data = deleteResult.data;
        } else {
            response.message = deleteResult.message;
        }
        
    } catch (any e) {
        response.message = "Server error: " & e.message;
        writeLog(type="error", text="Delete post error: " & e.message & " - " & e.detail, file="ghost-errors");
    }
    
    // Output JSON response
    writeOutput(serializeJSON(response));
</cfscript>

<cfsetting enablecfoutputonly="false">