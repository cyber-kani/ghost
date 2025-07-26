component {
    // Application settings
    this.name = "GhostCFML";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0); // 1 day
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0); // 2 hours
    this.setClientCookies = true;
    this.setDomainCookies = false;
    
    // Database configuration
    this.datasource = "blog";
    
    // Debugging and development settings
    this.debuggingEnabled = true; // Will be configurable later
    this.enableRobustException = true;
    
    // File upload settings - increased for large media files
    this.requestTimeOut = 600; // 10 minutes for large file uploads
    this.postParametersLimit = 100; // Allow more form fields
    this.requestSize = 115343360; // 110MB in bytes (slightly larger than upload limit)
    
    // Set post size limits in onRequestStart
    this.customTagPaths = "";
    
    // Application mappings
    this.mappings["/components"] = expandPath("./components");
    this.mappings["/includes"] = expandPath("./includes");
    this.mappings["/admin"] = expandPath("./admin");
    this.mappings["/assets"] = expandPath("./assets");
    this.mappings["/themes"] = expandPath("./themes");
    
    // Application startup
    function onApplicationStart() {
        // Initialize application variables
        application.debugMode = true; // Will be configurable
        application.siteName = "Ghost CFML Blog";
        application.version = "1.0.0";
        application.startTime = now();
        
        // Log application start
        writeLog(
            file = "application", 
            text = "Ghost CFML Application started - Version #application.version#",
            type = "information"
        );
        
        return true;
    }
    
    // Session initialization
    function onSessionStart() {
        session.isLoggedIn = false;
        session.userRole = "";
        session.userId = "";
        
        writeLog(
            file = "application", 
            text = "New session started: #session.sessionId#",
            type = "information"
        );
    }
    
    // Request processing with URL routing
    function onRequestStart(requestName) {
        // Development: Reload application on every request if needed
        if (structKeyExists(url, "reinit") && application.debugMode) {
            onApplicationStart();
        }
        
        // Set request-specific variables
        request.startTime = getTickCount();
        request.requestId = createUUID();
        
        // Get current URL path for routing
        request.pathInfo = cgi.path_info ?: "";
        request.scriptName = cgi.script_name;
        request.requestURI = cgi.request_uri ?: "";
        
        // Handle Ghost URL routing - check if this is a Ghost request
        if (findNoCase("/ghost", request.requestURI)) {
            // Include router for all ghost requests
            include "/var/www/sites/clitools.app/wwwroot/ghost/router.cfm";
            return false; // Stop processing, route was handled
        }
        
        // Set default page title if not set
        param name="pageTitle" default="Ghost Admin";
        
        // Set request variables for database access
        request.dsn = this.datasource;
        request.siteName = application.siteName;
        request.baseURL = "/ghost";
        
        return true;
    }
    
    // Request completion
    function onRequestEnd(requestName) {
        // Calculate request processing time
        request.processingTime = getTickCount() - request.startTime;
        
        // Log slow requests if debug mode enabled
        if (application.debugMode && request.processingTime > 1000) {
            writeLog(
                file = "performance", 
                text = "Slow request: #requestName# took #request.processingTime#ms",
                type = "warning"
            );
        }
    }
    
    // Error handling - No try-catch as per requirements
    function onError(exception, eventName) {
        // Log error details
        local.errorInfo = {
            message: exception.message ?: "Unknown error",
            detail: exception.detail ?: "",
            type: exception.type ?: "Unknown",
            eventName: eventName,
            timestamp: now(),
            requestId: request.requestId ?: "",
            template: exception.template ?: "",
            line: exception.line ?: 0
        };
        
        // Write to error log
        writeLog(
            file = "error", 
            text = serializeJSON(local.errorInfo),
            type = "error"
        );
        
        // Display error if debug mode is on
        if (application.debugMode) {
            writeOutput("
                <div style='background: ##ffebee; border: 1px solid ##e57373; padding: 20px; margin: 20px; border-radius: 4px;'>
                    <h3 style='color: ##c62828; margin: 0 0 10px 0;'>Debug Error Information</h3>
                    <p><strong>Message:</strong> #local.errorInfo.message#</p>
                    <p><strong>Detail:</strong> #local.errorInfo.detail#</p>
                    <p><strong>Type:</strong> #local.errorInfo.type#</p>
                    <p><strong>Template:</strong> #local.errorInfo.template#</p>
                    <p><strong>Line:</strong> #local.errorInfo.line#</p>
                    <p><strong>Event:</strong> #local.errorInfo.eventName#</p>
                    <p><strong>Request ID:</strong> #local.errorInfo.requestId#</p>
                    <p><strong>Time:</strong> #dateTimeFormat(local.errorInfo.timestamp, 'yyyy-mm-dd HH:nn:ss')#</p>
                </div>
            ");
        } else {
            // Production error page
            writeOutput("
                <div style='text-align: center; padding: 50px;'>
                    <h2>Sorry, an error occurred</h2>
                    <p>Please try again later or contact support if the problem persists.</p>
                    <p><small>Error ID: #local.errorInfo.requestId#</small></p>
                </div>
            ");
        }
    }
    
    // Application shutdown
    function onApplicationEnd() {
        writeLog(
            file = "application", 
            text = "Ghost CFML Application ended after #dateDiff('s', application.startTime, now())# seconds",
            type = "information"
        );
    }
}