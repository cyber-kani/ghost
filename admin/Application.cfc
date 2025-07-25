component {
    this.name = "GhostAdmin";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0); // 1 day
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0); // 2 hours
    this.setClientCookies = true;
    this.scriptProtect = "all";
    
    // URL rewriting for clean URLs
    public boolean function onRequestStart(string targetPage) {
        var requestPath = CGI.PATH_INFO;
        var scriptName = CGI.SCRIPT_NAME;
        
        // Handle clean URL routing for common admin pages
        if (structKeyExists(URL, "cleanurl") || len(requestPath) > 1) {
            var cleanPath = requestPath;
            if (len(cleanPath) == 0) {
                cleanPath = replace(scriptName, "/ghost/admin/", "");
                cleanPath = replace(cleanPath, ".cfm", "");
            }
            
            // Remove leading slash
            if (left(cleanPath, 1) == "/") {
                cleanPath = right(cleanPath, len(cleanPath) - 1);
            }
            
            // URL routing rules
            switch(cleanPath) {
                case "profile":
                    request.actualPage = "profile.cfm";
                    include "profile.cfm";
                    return false;
                    break;
                    
                case "dashboard":
                case "":
                    request.actualPage = "index.cfm";
                    include "index.cfm";
                    return false;
                    break;
                    
                case "posts":
                    request.actualPage = "posts.cfm";
                    include "posts.cfm";
                    return false;
                    break;
                    
                case "pages":
                    request.actualPage = "pages.cfm";
                    include "pages.cfm";
                    return false;
                    break;
                    
                case "tags":
                    request.actualPage = "tags.cfm";
                    include "tags.cfm";
                    return false;
                    break;
            }
        }
        
        return true;
    }
    
    public void function onError(exception, eventname) {
        // Basic error handling
        writeOutput("<h3>An error occurred:</h3>");
        writeOutput("<p>" & exception.message & "</p>");
        if (structKeyExists(exception, "detail") && len(exception.detail)) {
            writeOutput("<p>Detail: " & exception.detail & "</p>");
        }
    }
}