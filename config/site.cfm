<!--- Ghost Site Configuration --->
<!--- This file contains site-wide configuration settings --->

<cfscript>
// Site URL Configuration
// This replaces __GHOST_URL__ placeholders in content
// Update this when moving to a new server or domain
application.siteConfig = {
    // Base URL for the site (no trailing slash)
    ghostUrl: "https://clitools.app/ghost",
    
    // Content paths
    contentPath: "/content",
    imagesPath: "/content/images",
    filesPath: "/content/files",
    audioPath: "/content/audio",
    videoPath: "/content/videos",
    
    // Upload settings
    maxImageSize: 10485760, // 10MB in bytes
    maxFileSize: 52428800,  // 50MB in bytes
    maxVideoSize: 104857600, // 100MB in bytes
    maxAudioSize: 52428800,  // 50MB in bytes
    
    // Allowed file extensions
    allowedImageTypes: "jpg,jpeg,png,gif,webp,svg",
    allowedVideoTypes: "mp4,webm,mov",
    allowedAudioTypes: "mp3,wav,m4a",
    allowedFileTypes: "pdf,doc,docx,xls,xlsx,ppt,pptx,zip,txt",
    
    // Site metadata
    siteName: "Ghost CFML",
    siteDescription: "A Ghost CMS clone built with CFML",
    siteLanguage: "en",
    siteTimezone: "UTC",
    
    // Feature flags
    enableMembership: false,
    enableNewsletter: false,
    enableComments: false,
    
    // Debug settings
    debugMode: true,
    showErrors: true,
    logErrors: true,
    
    // Cache settings
    cacheEnabled: false,
    cacheTimeout: 3600 // 1 hour in seconds
};

// Helper function to replace __GHOST_URL__ in content
function replaceGhostUrl(content) {
    if (len(trim(content))) {
        return replace(content, "__GHOST_URL__", application.siteConfig.ghostUrl, "all");
    }
    return content;
}

// Helper function to get full content URL
function getContentUrl(path) {
    if (left(path, 1) == "/") {
        return application.siteConfig.ghostUrl & path;
    } else if (findNoCase("http", path) == 1) {
        return path;
    } else {
        return application.siteConfig.ghostUrl & "/" & path;
    }
}

// Helper function to get image URL
function getImageUrl(path) {
    if (len(trim(path))) {
        // Replace __GHOST_URL__ placeholder
        path = replaceGhostUrl(path);
        
        // Handle relative paths
        if (left(path, 1) == "/" && !findNoCase("/ghost", path)) {
            path = "/ghost" & path;
        }
        
        return path;
    }
    return "";
}
</cfscript>