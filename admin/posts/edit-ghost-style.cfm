<!--- Ghost-style Post Editor for CFGhost CMS --->
<!--- This implements the modern Ghost editor with card-based content blocks --->

<cfparam name="url.id" default="">
<cfset pageTitle = "Edit Post">

<!--- Check login status --->
<cfif not structKeyExists(session, "ISLOGGEDIN") or not session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login" addtoken="false">
</cfif>

<!--- Include the posts functions --->
<cfinclude template="../includes/posts-functions.cfm">

<!--- Get the post data --->
<cfscript>
postData = [];
postId = "";
errorMessage = "";

// Clean up the ID parameter
if (len(url.id)) {
    postId = trim(url.id);
    
    // Get the post data
    try {
        postResult = getPostById(postId);
        if (postResult.success and arrayLen(postResult.data) gt 0) {
            postData = postResult.data[1];
        } else {
            errorMessage = "Post not found";
        }
    } catch (any e) {
        errorMessage = "Error loading post: " & e.message;
    }
} else {
    // New post - Create Ghost-style ID (24 character hex string)
    postData = {
        id: lcase(left(replace(createUUID(), "-", "", "all"), 24)),
        title: "",
        html: "",
        plaintext: "",
        feature_image: "",
        featured: false,
        status: "draft",
        visibility: "public",
        slug: "",
        custom_excerpt: "",
        meta_title: "",
        meta_description: "",
        canonical_url: "",
        type: "post",
        published_at: "",
        created_at: now(),
        updated_at: now(),
        created_by: session.USERID ?: "1",
        updated_by: session.USERID ?: "1",
        tags: [],
        author: {
            id: session.USERID ?: "1",
            name: session.USERNAME ?: "Admin User",
            avatar: "",
            slug: ""
        }
    };
}

// Get all tags for the tags selector
tagsResult = getTags(1, 100);
allTags = tagsResult.success ? tagsResult.data : [];
</cfscript>

<!DOCTYPE html>
<html lang="en" dir="ltr" data-color-theme="Blue_Theme" class="light">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#pageTitle# - CFGhost Admin</cfoutput></title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" type="image/png" href="/ghost/admin/assets/images/logos/favicon.png">
    
    <!-- Core CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css">
    
    <!-- Tabler Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    
    <!-- TipTap Editor CSS -->
    <style>
        /* Ghost Editor Styles */
        .ghost-editor {
            min-height: 100vh;
            background: #ffffff;
        }
        
        .ghost-editor-header {
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            padding: 1rem 2rem;
            position: sticky;
            top: 0;
            z-index: 40;
        }
        
        .ghost-editor-title {
            font-size: 2.5rem;
            font-weight: 700;
            border: none;
            outline: none;
            width: 100%;
            padding: 0;
            margin: 0;
            line-height: 1.2;
            color: #171717;
            background: transparent;
            resize: none;
            overflow: hidden;
            min-height: 3rem;
            max-height: 6rem;
            font-family: inherit;
        }
        
        .ghost-editor-title::placeholder {
            color: #9ca3af;
            font-weight: 300;
        }
        
        .ghost-editor-content {
            max-width: 740px;
            margin: 0 auto;
            padding: 4rem 2rem;
        }
        
        .ghost-editor-body {
            min-height: 300px;
            font-size: 1.125rem;
            line-height: 1.75;
            color: #374151;
        }
        
        .ghost-editor-wordcount {
            position: fixed;
            bottom: 2rem;
            left: 2rem;
            background: #f3f4f6;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            color: #6b7280;
            z-index: 30;
        }
        
        .ghost-settings-toggle {
            position: fixed;
            top: 50%;
            right: 0;
            transform: translateY(-50%);
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-right: none;
            border-radius: 0.375rem 0 0 0.375rem;
            padding: 0.75rem;
            cursor: pointer;
            z-index: 30;
            transition: all 0.2s ease;
        }
        
        .ghost-settings-toggle:hover {
            background: #f9fafb;
        }
        
        .ghost-settings-panel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100vh;
            background: #ffffff;
            border-left: 1px solid #e5e7eb;
            transition: right 0.3s ease;
            z-index: 50;
            overflow-y: auto;
        }
        
        .ghost-settings-panel.active {
            right: 0;
        }
        
        .ghost-settings-header {
            padding: 1.5rem;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-settings-content {
            padding: 1.5rem;
        }
        
        /* Card Styles */
        .content-card {
            position: relative;
            margin: 1.5rem 0;
            padding: 1rem;
            border: 1px solid transparent;
            border-radius: 0.375rem;
            transition: all 0.2s ease;
        }
        
        .content-card:hover {
            border-color: #3b82f6;
            background: #f0f9ff;
        }
        
        .content-card-toolbar {
            position: absolute;
            top: -2.5rem;
            left: 0;
            display: none;
            background: #1f2937;
            border-radius: 0.375rem;
            padding: 0.25rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        
        .content-card:hover .content-card-toolbar {
            display: flex;
        }
        
        .add-card-button {
            position: relative;
            width: 100%;
            height: 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 1rem 0;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .add-card-button:hover {
            opacity: 1;
        }
        
        .add-card-button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: #e5e7eb;
        }
        
        .add-card-button-icon {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 50%;
            width: 2rem;
            height: 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1;
        }
        
        /* Feature Image Styles */
        .feature-image-container {
            position: relative;
            margin-bottom: 3rem;
            cursor: pointer;
            border-radius: 0.5rem;
            overflow: hidden;
            background: #f9fafb;
            border: 2px dashed #e5e7eb;
            transition: all 0.2s ease;
        }
        
        .feature-image-container:hover {
            border-color: #3b82f6;
            background: #f0f9ff;
        }
        
        .feature-image-placeholder {
            padding: 4rem 2rem;
            text-align: center;
        }
        
        .feature-image-preview {
            position: relative;
            max-height: 400px;
            overflow: hidden;
        }
        
        .feature-image-preview img {
            width: 100%;
            height: auto;
            display: block;
        }
        
        .feature-image-actions {
            position: absolute;
            top: 1rem;
            right: 1rem;
            display: flex;
            gap: 0.5rem;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .feature-image-container:hover .feature-image-actions {
            opacity: 1;
        }
        
        /* Autosave indicator */
        .autosave-indicator {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            background: #10b981;
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            opacity: 0;
            transform: translateY(1rem);
            transition: all 0.2s ease;
        }
        
        .autosave-indicator.show {
            opacity: 1;
            transform: translateY(0);
        }
        
        /* Card menu */
        .card-menu {
            position: absolute;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 0.5rem;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            padding: 0.5rem 0;
            min-width: 200px;
            max-height: 400px;
            overflow-y: auto;
            z-index: 100;
        }
        
        .card-menu-item {
            padding: 0.75rem 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        
        .card-menu-item:hover {
            background: #f3f4f6;
        }
        
        .card-menu-category {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            color: #6b7280;
            padding: 0.5rem 1rem;
            margin-top: 0.5rem;
        }
        
        .card-menu-category:first-child {
            margin-top: 0;
        }
        
        /* Formatting Popup Styles */
        .formatting-popup {
            position: fixed;
            background: #1e293b;
            border-radius: 6px;
            padding: 4px;
            display: flex;
            gap: 2px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10000;
            opacity: 0;
            visibility: hidden;
            transform: translateY(5px);
            transition: opacity 0.2s, transform 0.2s, visibility 0.2s;
        }
        
        .formatting-popup.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        
        .format-btn {
            width: 32px;
            height: 32px;
            border: none;
            background: transparent;
            color: white;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }
        
        .format-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .format-btn.active {
            background: rgba(255, 255, 255, 0.2);
        }
        
        .format-separator {
            width: 1px;
            height: 20px;
            background: rgba(255, 255, 255, 0.2);
            margin: 0 4px;
        }
        
        .format-select {
            padding: 4px 8px;
            border: none;
            background: transparent;
            color: white;
            font-size: 0.875rem;
            cursor: pointer;
            outline: none;
            min-width: 100px;
        }
        
        .format-select:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .format-select option {
            background: #374151;
            color: white;
        }
        
        .format-btn i {
            font-size: 18px;
        }
        
        /* Link Editor Popup Styles */
        .link-editor-popup {
            position: fixed;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            padding: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10001;
            opacity: 0;
            visibility: hidden;
            transform: translateY(5px);
            transition: opacity 0.2s, transform 0.2s, visibility 0.2s;
        }
        
        .link-editor-popup.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }
        
        .link-editor-input-wrapper {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .link-editor-input {
            width: 300px;
            padding: 6px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .link-editor-input:focus {
            border-color: #3b82f6;
        }
        
        .link-editor-btn {
            width: 32px;
            height: 32px;
            border: 1px solid #e5e7eb;
            background: white;
            color: #6b7280;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .link-editor-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .link-editor-btn i {
            font-size: 16px;
        }
        
        /* Link hover menu */
        .link-hover-menu {
            position: fixed;
            background: #1f2937;
            color: white;
            padding: 8px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            z-index: 10000;
            display: none;
            min-width: 200px;
            border: 1px solid #374151;
        }
        
        .link-hover-menu.show {
            display: block;
        }
        
        .link-hover-url {
            font-size: 12px;
            color: #9ca3af;
            margin-bottom: 8px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            padding: 0 4px;
        }
        
        .link-hover-actions {
            display: flex;
            gap: 4px;
        }
        
        .link-hover-btn {
            background: transparent;
            border: none;
            color: white;
            padding: 6px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .link-hover-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .link-hover-btn i {
            font-size: 16px;
        }
        
        /* Highlight links on hover */
        .card-content a {
            text-decoration: underline;
            color: inherit;
            position: relative;
            cursor: pointer;
        }
        
        .card-content a:hover {
            background: rgba(59, 130, 246, 0.1);
            border-radius: 2px;
        }
        
        /* Image card width styles */
        .image-card-content {
            position: relative;
        }
        
        .image-card-content .image-wrapper {
            position: relative;
            transition: all 0.3s ease;
        }
        
        /* Wide width */
        .image-card-content[data-card-width="wide"] .image-wrapper {
            margin-left: calc(-12.5vw + 50%);
            margin-right: calc(-12.5vw + 50%);
            max-width: none;
        }
        
        /* Full width */
        .image-card-content[data-card-width="full"] .image-wrapper {
            margin-left: calc(-50vw + 50%);
            margin-right: calc(-50vw + 50%);
            max-width: none;
        }
        
        /* Responsive adjustments */
        @media (max-width: 1024px) {
            .image-card-content[data-card-width="wide"] .image-wrapper,
            .image-card-content[data-card-width="full"] .image-wrapper {
                margin-left: -1rem;
                margin-right: -1rem;
            }
        }
        
        /* Ghost-style video settings */
        .ghost-video-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: #fafafa;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        .ghost-video-width-selector {
            display: flex;
            gap: 4px;
        }
        
        .ghost-video-separator {
            width: 1px;
            height: 20px;
            background: #e5e7eb;
        }
        
        .ghost-video-loop-btn {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            cursor: pointer;
            color: #374151;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .ghost-video-loop-btn:hover {
            background: #f3f4f6;
        }
        
        .ghost-video-loop-btn.active {
            background: #10b981;
            color: white;
            border-color: #10b981;
        }
        
        .ghost-video-loop-btn svg {
            width: 16px;
            height: 16px;
        }
        
        .ghost-replace-btn {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            cursor: pointer;
            color: #374151;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .ghost-replace-btn:hover {
            background: #f3f4f6;
        }
        
        .ghost-replace-btn svg {
            width: 16px;
            height: 16px;
        }
        
        /* Ghost-style audio settings */
        .ghost-audio-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: #fafafa;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        .audio-wrapper {
            padding: 16px;
            background: #f9fafb;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        .audio-wrapper audio {
            width: 100%;
            height: 40px;
        }
        
        .audio-duration {
            font-size: 12px;
            color: #6b7280;
            margin-top: 4px;
        }
        
        /* Ghost-style image settings */
        .ghost-image-settings {
            margin-top: 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
        }
        
        .ghost-image-settings.hidden {
            display: none;
        }
        
        .ghost-image-toolbar {
            display: flex;
            align-items: center;
            padding: 8px;
            gap: 4px;
            background: #fafafa;
        }
        
        .ghost-image-width-selector {
            display: flex;
            gap: 4px;
        }
        
        .ghost-width-btn, .ghost-video-toolbar .ghost-width-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            border: none;
            background: transparent;
            color: #6b7280;
            border-radius: 3px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .ghost-width-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .ghost-width-btn.active {
            background: #374151;
            color: white;
        }
        
        .ghost-width-btn svg {
            width: 24px;
            height: 18px;
        }
        
        .ghost-image-toolbar-divider {
            width: 1px;
            height: 24px;
            background: #e5e7eb;
            margin: 0 8px;
        }
        
        .ghost-image-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            border: none;
            background: transparent;
            color: #6b7280;
            border-radius: 3px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
            font-size: 18px;
        }
        
        .ghost-image-btn:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .ghost-image-btn.active {
            color: #10b981;
        }
        
        .ghost-alt-icon {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        
        .ghost-image-input-row {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-image-input-row.hidden {
            display: none;
        }
        
        .ghost-image-input-row:last-child {
            border-bottom: none;
        }
        
        .ghost-image-input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 3px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .ghost-image-input:focus {
            border-color: #10b981;
        }
        
        /* Image hover effect for settings */
        .image-card-content .image-wrapper img {
            transition: opacity 0.2s;
        }
        
        .image-card-content .image-wrapper:hover img {
            opacity: 0.9;
            cursor: pointer;
        }
    </style>
</head>
<body class="DEFAULT_THEME">
    <main>
        <div class="ghost-editor">
            <!-- Editor Header -->
            <header class="ghost-editor-header">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <!-- Back button -->
                        <a href="/ghost/admin/posts" class="flex items-center gap-2 text-gray-600 hover:text-gray-900">
                            <i class="ti ti-arrow-left text-xl"></i>
                            <span>Posts</span>
                        </a>
                        
                        <!-- Post status -->
                        <cfif len(postData.status)>
                            <cfswitch expression="#postData.status#">
                                <cfcase value="published">
                                    <span class="badge bg-success text-white">Published</span>
                                </cfcase>
                                <cfcase value="draft">
                                    <span class="badge bg-gray-200 text-gray-700">Draft</span>
                                </cfcase>
                                <cfcase value="scheduled">
                                    <span class="badge bg-info text-white">Scheduled</span>
                                </cfcase>
                            </cfswitch>
                        </cfif>
                        
                        <!-- Autosave status -->
                        <span id="saveStatus" class="text-sm text-gray-500"><cfif postData.status neq "published">Saved</cfif></span>
                    </div>
                    
                    <div class="flex items-center gap-3">
                        <!-- Preview button -->
                        <button type="button" class="btn btn-outline-secondary" onclick="previewPost()">
                            <i class="ti ti-eye me-2"></i>
                            Preview
                        </button>
                        
                        <!-- Publish/Update button -->
                        <cfif postData.status eq "published">
                            <button type="button" class="btn btn-primary" onclick="updatePost()">
                                <i class="ti ti-refresh me-2"></i>
                                Update
                            </button>
                        <cfelse>
                            <button type="button" class="btn btn-primary" onclick="publishPost()">
                                <i class="ti ti-send me-2"></i>
                                Publish
                            </button>
                        </cfif>
                    </div>
                </div>
            </header>
            
            <!-- Editor Content -->
            <div class="ghost-editor-content">
                <!-- Feature Image -->
                <div class="feature-image-container" id="featureImageContainer" onclick="selectFeatureImage()">
                    <cfif len(postData.feature_image)>
                        <div class="feature-image-preview">
                            <cfset imageUrl = postData.feature_image>
                            <cfif findNoCase("__GHOST_URL__", imageUrl)>
                                <cfset imageUrl = replace(imageUrl, "__GHOST_URL__", "", "all")>
                            </cfif>
                            <cfif not findNoCase("/ghost/", imageUrl) and findNoCase("/content/", imageUrl)>
                                <cfset imageUrl = "/ghost" & imageUrl>
                            </cfif>
                            <img src="<cfoutput>#imageUrl#</cfoutput>" alt="Feature image" id="featureImagePreview" onerror="removeFeatureImage()">
                            <div class="feature-image-actions">
                                <button type="button" class="btn btn-sm btn-light" onclick="event.stopPropagation(); changeFeatureImage()">
                                    <i class="ti ti-refresh"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-light" onclick="event.stopPropagation(); removeFeatureImage()">
                                    <i class="ti ti-trash"></i>
                                </button>
                            </div>
                        </div>
                    <cfelse>
                        <div class="feature-image-placeholder">
                            <i class="ti ti-photo-plus text-4xl text-gray-400 mb-2"></i>
                            <p class="text-gray-600">Add feature image</p>
                            <p class="text-sm text-gray-500">Click to upload or drag and drop</p>
                        </div>
                    </cfif>
                </div>
                
                <!-- Hidden file input for feature image -->
                <input type="file" id="featureImageInput" accept="image/*" style="display: none;" onchange="uploadFeatureImage(this)">
                
                <!-- Title -->
                <textarea id="postTitle" 
                          class="ghost-editor-title" 
                          placeholder="Post title" 
                          autocomplete="off"
                          rows="1"
                          oninput="autoResizeTitle(this)"><cfoutput>#htmlEditFormat(postData.title)#</cfoutput></textarea>
                
                <!-- Editor Body -->
                <div id="editorContainer" class="ghost-editor-body">
                    <!-- Content cards will be dynamically inserted here -->
                </div>
                
                <!-- Add card button (initially hidden, shown on hover) -->
                <div class="add-card-button" onclick="showCardMenu(this)">
                    <div class="add-card-button-icon">
                        <i class="ti ti-plus"></i>
                    </div>
                </div>
            </div>
            
            <!-- Word count -->
            <div class="ghost-editor-wordcount">
                <span id="wordCount">0</span> words
            </div>
            
            <!-- Settings toggle button -->
            <button type="button" class="ghost-settings-toggle" onclick="toggleSettings()">
                <i class="ti ti-settings text-xl"></i>
            </button>
            
            <!-- Settings panel -->
            <div class="ghost-settings-panel" id="settingsPanel">
                <div class="ghost-settings-header">
                    <div class="flex items-center justify-between">
                        <h3 class="text-lg font-semibold">Post Settings</h3>
                        <button type="button" class="btn btn-icon btn-sm" onclick="toggleSettings()">
                            <i class="ti ti-x"></i>
                        </button>
                    </div>
                </div>
                
                <div class="ghost-settings-content">
                    <!-- URL Slug -->
                    <div class="mb-6">
                        <label class="form-label font-semibold">URL Slug</label>
                        <div class="input-group">
                            <span class="input-group-text text-sm">/ghost/</span>
                            <input type="text" 
                                   id="postSlug" 
                                   class="form-control" 
                                   value="<cfoutput>#htmlEditFormat(postData.slug)#</cfoutput>"
                                   placeholder="post-url">
                        </div>
                        <small class="text-gray-500">The URL for this post</small>
                    </div>
                    
                    <!-- Publish Date -->
                    <div class="mb-6">
                        <label class="form-label font-semibold">Publish Date</label>
                        <input type="datetime-local" 
                               id="publishDate" 
                               class="form-control"
                               value="<cfif isDate(postData.published_at)><cfoutput>#dateFormat(postData.published_at, 'yyyy-mm-dd')#T#timeFormat(postData.published_at, 'HH:mm')#</cfoutput></cfif>">
                        <small class="text-gray-500">Set a future date to schedule this post</small>
                    </div>
                    
                    <!-- Tags -->
                    <div class="mb-6">
                        <label class="form-label font-semibold">Tags</label>
                        <div class="mb-2">
                            <div id="selectedTags" class="flex flex-wrap gap-2 mb-2">
                                <cfloop array="#postData.tags#" index="tag">
                                    <span class="badge bg-primary text-white">
                                        <cfoutput>#tag.name#</cfoutput>
                                        <button type="button" class="ms-2" onclick="removeTag('<cfoutput>#tag.id#</cfoutput>')">
                                            <i class="ti ti-x text-xs"></i>
                                        </button>
                                    </span>
                                </cfloop>
                            </div>
                            <select id="tagSelector" class="form-select" onchange="addTag()">
                                <option value="">Add a tag...</option>
                                <cfloop array="#allTags#" index="tag">
                                    <option value="<cfoutput>#tag.id#</cfoutput>" data-name="<cfoutput>#tag.name#</cfoutput>">
                                        <cfoutput>#tag.name#</cfoutput>
                                    </option>
                                </cfloop>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Excerpt -->
                    <div class="mb-6">
                        <label class="form-label font-semibold">Excerpt</label>
                        <textarea id="postExcerpt" 
                                  class="form-control" 
                                  rows="3"
                                  placeholder="A short description of your post"><cfoutput>#htmlEditFormat(postData.custom_excerpt)#</cfoutput></textarea>
                        <small class="text-gray-500">Excerpts are optional hand-crafted summaries of your content</small>
                    </div>
                    
                    <!-- SEO Settings -->
                    <div class="mb-6">
                        <h4 class="font-semibold mb-3">Search Engine Optimization</h4>
                        
                        <!-- Meta Title -->
                        <div class="mb-4">
                            <label class="form-label">Meta Title</label>
                            <input type="text" 
                                   id="metaTitle" 
                                   class="form-control" 
                                   value="<cfoutput>#htmlEditFormat(postData.meta_title)#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <small class="text-gray-500">Recommended: 60 characters</small>
                        </div>
                        
                        <!-- Meta Description -->
                        <div class="mb-4">
                            <label class="form-label">Meta Description</label>
                            <textarea id="metaDescription" 
                                      class="form-control" 
                                      rows="3"
                                      placeholder="A description of your post for search engines"><cfoutput>#htmlEditFormat(postData.meta_description)#</cfoutput></textarea>
                            <small class="text-gray-500">Recommended: 160 characters</small>
                        </div>
                    </div>
                    
                    <!-- Post Access -->
                    <div class="mb-6">
                        <label class="form-label font-semibold">Post Access</label>
                        <select id="postVisibility" class="form-select">
                            <option value="public" <cfif postData.visibility eq "public">selected</cfif>>Public</option>
                            <option value="members" <cfif postData.visibility eq "members">selected</cfif>>Members only</option>
                            <option value="paid" <cfif postData.visibility eq "paid">selected</cfif>>Paid members only</option>
                        </select>
                    </div>
                    
                    <!-- Featured Post -->
                    <div class="mb-6">
                        <div class="form-check">
                            <input type="checkbox" 
                                   id="featuredPost" 
                                   class="form-check-input"
                                   <cfif postData.featured>checked</cfif>>
                            <label class="form-check-label" for="featuredPost">
                                Feature this post
                            </label>
                        </div>
                        <small class="text-gray-500">Featured posts are displayed prominently on your site</small>
                    </div>
                    
                    <!-- Delete Post -->
                    <div class="pt-6 border-t">
                        <button type="button" class="btn btn-outline-danger w-full" onclick="confirmDeletePost()">
                            <i class="ti ti-trash me-2"></i>
                            Delete Post
                        </button>
                    </div>
                </div>
            </div>
            
        </div>
    </main>
    
    <!-- Global Formatting Popup -->
    <div class="formatting-popup" id="formattingPopup">
        <button type="button" class="format-btn" onclick="formatText('bold')" title="Bold (Cmd/Ctrl+B)">
            <i class="ti ti-bold"></i>
        </button>
        <button type="button" class="format-btn" onclick="formatText('italic')" title="Italic (Cmd/Ctrl+I)">
            <i class="ti ti-italic"></i>
        </button>
        <button type="button" class="format-btn" onclick="showLinkEditor()" title="Link (Cmd/Ctrl+K)">
            <i class="ti ti-link"></i>
        </button>
        <button type="button" class="format-btn" onclick="formatText('code')" title="Code">
            <i class="ti ti-code"></i>
        </button>
        <button type="button" class="format-btn" onclick="formatText('strikethrough')" title="Strikethrough">
            <i class="ti ti-strikethrough"></i>
        </button>
        <button type="button" class="format-btn" onclick="formatText('underline')" title="Underline">
            <i class="ti ti-underline"></i>
        </button>
        <button type="button" class="format-btn" onclick="formatText('removeFormat')" title="Clear formatting">
            <i class="ti ti-clear-formatting"></i>
        </button>
        <div class="format-separator"></div>
        <select class="format-select" onchange="formatHeading(this.value); this.value=''">
            <option value="">Text</option>
            <option value="h1">Large heading</option>
            <option value="h2">Medium heading</option>
            <option value="h3">Small heading</option>
            <option value="p">Paragraph</option>
        </select>
    </div>
    
    <!-- Link Editor Popup -->
    <div class="link-editor-popup" id="linkEditorPopup">
        <div class="link-editor-input-wrapper">
            <input type="text" 
                   id="linkUrlInput" 
                   class="link-editor-input" 
                   placeholder="Enter URL" 
                   onkeyup="handleLinkInputKeyup(event)">
            <button type="button" 
                    class="link-editor-btn" 
                    onclick="applyLink()"
                    title="Apply">
                <i class="ti ti-check"></i>
            </button>
            <button type="button" 
                    class="link-editor-btn" 
                    onclick="removeLink()"
                    title="Remove link">
                <i class="ti ti-unlink"></i>
            </button>
            <button type="button" 
                    class="link-editor-btn" 
                    onclick="closeLinkEditor()"
                    title="Cancel">
                <i class="ti ti-x"></i>
            </button>
        </div>
    </div>
    
    <!-- Link Hover Menu -->
    <div class="link-hover-menu" id="linkHoverMenu">
        <div class="link-hover-url" id="linkHoverUrl"></div>
        <div class="link-hover-actions">
            <button type="button" class="link-hover-btn" onclick="editExistingLink()" title="Edit link">
                <i class="ti ti-edit"></i>
            </button>
            <button type="button" class="link-hover-btn" onclick="removeExistingLink()" title="Remove link">
                <i class="ti ti-unlink"></i>
            </button>
            <button type="button" class="link-hover-btn" onclick="openLinkInNewTab()" title="Open link">
                <i class="ti ti-external-link"></i>
            </button>
        </div>
    </div>
    
    <!-- Unsaved Changes Modal -->
    <div class="fixed inset-0 bg-black bg-opacity-50 z-50 hidden" id="unsavedChangesModal">
        <div class="flex items-center justify-center h-full">
            <div class="bg-white rounded-lg shadow-xl max-w-sm w-full mx-4 border border-gray-200">
                <div class="p-5">
                    <div class="flex items-center justify-center w-10 h-10 mx-auto bg-yellow-100 rounded-full mb-3">
                        <i class="ti ti-alert-triangle text-yellow-600 text-lg"></i>
                    </div>
                    <h3 class="text-base font-semibold text-center text-gray-900 mb-2">
                        Are you sure you want to leave this page?
                    </h3>
                    <p class="text-sm text-gray-600 text-center mb-3">
                        Hey there! It looks like you're in the middle of writing something and you haven't saved all of your content.
                    </p>
                    <p class="text-sm font-medium text-orange-600 text-center mb-4">
                        Save before you go!
                    </p>
                    <div class="flex gap-2">
                        <button type="button" 
                                class="flex-1 btn btn-sm btn-primary" 
                                onclick="saveAndLeave()">
                            <i class="ti ti-device-floppy me-1"></i>
                            Save
                        </button>
                        <button type="button" 
                                class="flex-1 btn btn-sm btn-outline-danger" 
                                onclick="leaveWithoutSaving()">
                            Leave
                        </button>
                        <button type="button" 
                                class="flex-1 btn btn-sm btn-outline-secondary" 
                                onclick="cancelLeave()">
                            Stay
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Toast notification container -->
    <div id="toastContainer" class="fixed bottom-4 right-4 z-50 space-y-2"></div>
    
    <!-- Hidden form for data submission -->
    <form id="postForm" method="post" style="display: none;">
        <input type="hidden" name="postId" value="<cfoutput>#postData.id#</cfoutput>">
        <input type="hidden" name="title" id="formTitle">
        <input type="hidden" name="content" id="formContent">
        <input type="hidden" name="plaintext" id="formPlaintext">
        <input type="hidden" name="feature_image" id="formFeatureImage">
        <input type="hidden" name="slug" id="formSlug">
        <input type="hidden" name="excerpt" id="formExcerpt">
        <input type="hidden" name="meta_title" id="formMetaTitle">
        <input type="hidden" name="meta_description" id="formMetaDescription">
        <input type="hidden" name="visibility" id="formVisibility">
        <input type="hidden" name="featured" id="formFeatured">
        <input type="hidden" name="published_at" id="formPublishedAt">
        <input type="hidden" name="tags" id="formTags">
        <input type="hidden" name="status" id="formStatus">
    </form>
    
    <!-- Core JS -->
    <script src="/ghost/admin/assets/js/vendor.min.js"></script>
    <script src="/ghost/admin/assets/js/app.init.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/preline@2.0.2/dist/preline.js"></script>
    
    <!-- Editor JS -->
    <script>
    // Global variables
    let postData = <cfoutput>#serializeJSON(postData)#</cfoutput>;
    
    // Normalize postData keys to lowercase (ColdFusion returns uppercase)
    const normalizedPostData = {};
    for (let key in postData) {
        normalizedPostData[key.toLowerCase()] = postData[key];
    }
    postData = { ...postData, ...normalizedPostData };
    
    // Store original status
    let originalStatus = postData.status || postData.STATUS || 'draft';
    console.log('Original status:', originalStatus, 'PostData:', postData);
    
    // Fix feature image URL if it contains __GHOST_URL__
    const featureImage = postData.feature_image || postData.FEATURE_IMAGE;
    if (featureImage) {
        if (featureImage.includes('__GHOST_URL__')) {
            postData.feature_image = featureImage.replace('__GHOST_URL__', '');
        } else {
            postData.feature_image = featureImage;
        }
        // Ensure /ghost prefix for content images
        if (postData.feature_image.includes('/content/') && !postData.feature_image.includes('/ghost/')) {
            postData.feature_image = '/ghost' + postData.feature_image;
        }
    }
    
    let selectedTags = postData.tags || postData.TAGS || [];
    let contentCards = [];
    let autosaveTimer = null;
    let isDirty = false;
    let wordCount = 0;
    let saveResolve = null;
    let saveReject = null;
    let isInitializing = true; // Flag to prevent marking dirty during initialization
    let isProgrammaticChange = false; // Flag to prevent marking dirty when setting values programmatically
    let lastFocusedElement = null; // Track last focused element to detect real blur events
    let isCreatingCards = false; // Flag to track when cards are being created initially
    
    // Initialize editor with existing content
    // Auto-resize title textarea
    function autoResizeTitle(textarea, shouldMarkDirty = true) {
        textarea.style.height = 'auto';
        textarea.style.height = textarea.scrollHeight + 'px';
        if (shouldMarkDirty) {
            markDirtySafe();
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        // Initialize title auto-resize
        const titleElement = document.getElementById('postTitle');
        if (titleElement) {
            autoResizeTitle(titleElement, false); // Don't mark dirty on initial load
        }
        
        // Global text selection handler
        document.addEventListener('selectionchange', function() {
            checkTextSelection();
        });
        
        // Also check on mouseup for better responsiveness
        document.addEventListener('mouseup', function(e) {
            // Only check if mouseup is within a content editable area
            if (e.target.closest('.card-content')) {
                setTimeout(() => checkTextSelection(), 10);
            }
        });
        
        // Hide popup when clicking outside
        document.addEventListener('mousedown', function(e) {
            const popup = document.getElementById('formattingPopup');
            if (!popup.contains(e.target) && !e.target.closest('.card-content')) {
                popup.classList.remove('show');
            }
        });
        
        // Parse existing HTML content into cards
        console.log('PostData:', postData);
        console.log('PostData.html:', postData.html);
        console.log('PostData.HTML:', postData.HTML);
        
        // ColdFusion returns uppercase keys, so check both
        const htmlContent = postData.html || postData.HTML;
        
        if (htmlContent) {
            parseHtmlToCards(htmlContent, true); // true = initial load
        } else {
            // Add initial paragraph card for new posts
            addCardInternal('paragraph', {});
        }
        
        // Set up autosave
        setupAutosave();
        
        // Update word count
        updateWordCount();
        
        // Store initial values to compare later
        const initialValues = {
            title: document.getElementById('postTitle').value,
            slug: document.getElementById('postSlug').value,
            excerpt: document.getElementById('postExcerpt').value,
            publishDate: document.getElementById('postDate')?.value || '',
            publishTime: document.getElementById('postTime')?.value || ''
        };
        
        // Clear dirty flag after initial load
        setTimeout(() => {
            console.log('Clearing initialization flags - isDirty was:', isDirty);
            isDirty = false;
            isInitializing = false; // Allow marking dirty from now on
            console.log('Initialization complete - isDirty:', isDirty, 'isInitializing:', isInitializing);
            
            // Update save status based on original post status
            const saveStatus = document.getElementById('saveStatus');
            if (saveStatus) {
                if (originalStatus === 'published') {
                    saveStatus.textContent = '';
                    saveStatus.className = '';
                } else {
                    saveStatus.textContent = 'Draft';
                    saveStatus.className = 'text-sm text-gray-500';
                }
            }
            
            // Double-check that values haven't changed
            const currentValues = {
                title: document.getElementById('postTitle').value,
                slug: document.getElementById('postSlug').value,
                excerpt: document.getElementById('postExcerpt').value,
                publishDate: document.getElementById('postDate')?.value || '',
                publishTime: document.getElementById('postTime')?.value || ''
            };
            
            // If values are the same, ensure isDirty is false
            if (JSON.stringify(initialValues) === JSON.stringify(currentValues)) {
                isDirty = false;
                console.log('Values unchanged after init, ensuring isDirty is false');
            } else {
                console.log('Values changed during init:', initialValues, 'vs', currentValues);
            }
            
        }, 2000); // Increased timeout to ensure all initialization is complete including blur events
        
        // Auto-generate slug from title
        document.getElementById('postTitle').addEventListener('input', function() {
            if (!document.getElementById('postSlug').value) {
                const slug = generateSlug(this.value);
                isProgrammaticChange = true;
                document.getElementById('postSlug').value = slug;
                setTimeout(() => { isProgrammaticChange = false; }, 10);
            }
            markDirtySafe();
        });
        
        // Mark dirty on settings sidebar input changes only
        // Don't add listeners to all inputs as some may be programmatically set during init
        const settingsInputs = document.querySelectorAll('#postSettings input, #postSettings textarea, #postSettings select');
        settingsInputs.forEach(element => {
            element.addEventListener('input', function() {
                if (!isInitializing && !isProgrammaticChange) markDirtySafe();
            });
            element.addEventListener('change', function() {
                if (!isInitializing && !isProgrammaticChange) markDirtySafe();
            });
        });
        
        // Setup link hover detection
        setupLinkHoverDetection();
        
        // Add click handlers to make cards focusable
        document.addEventListener('click', function(e) {
            const link = e.target.closest('a');
            if (link && link.closest('.card-content')) {
                e.preventDefault();
                return;
            }
            
            // If clicking on a card, try to focus its contenteditable element
            const cardElement = e.target.closest('.content-card');
            if (cardElement) {
                const editableElement = cardElement.querySelector('[contenteditable="true"]');
                if (editableElement) {
                    console.log('Focusing card element:', editableElement.id);
                    editableElement.focus();
                }
            }
        });
    });
    
    // Parse HTML content into cards
    function parseHtmlToCards(html, isInitialLoad = false) {
        console.log('parseHtmlToCards called with:', html);
        
        // Set flag when creating cards initially
        if (isInitialLoad) {
            isCreatingCards = true;
        }
        
        if (!html || !html.trim()) {
            addCard('paragraph', {}, !isInitialLoad);
            if (isInitialLoad) {
                setTimeout(() => { isCreatingCards = false; }, 100);
            }
            return;
        }
        
        // Helper function to add cards without marking dirty during initial load
        const addCardInternal = (type, data = {}) => {
            addCard(type, data, !isInitialLoad);
        };
        
        // Create a temporary container to parse HTML
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = html;
        
        // Get all top-level elements
        const elements = tempDiv.children;
        console.log('Found elements:', elements.length);
        
        if (elements.length === 0) {
            // If no elements, treat as plain text
            addCardInternal('paragraph', { content: html });
            return;
        }
        
        // Track consecutive text content
        let consecutiveTextContent = [];
        
        // Define which tags should be treated as text content (includes headings like Ghost)
        const textTags = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'span', 'strong', 'b', 'em', 'i', 'u', 'a', 'code', 'small', 'mark', 'sub', 'sup'];
        
        // Define which tags should break text accumulation (non-text block elements)
        const blockTags = ['figure', 'img', 'hr', 'blockquote', 'pre', 'ul', 'ol', 'div', 'table'];
        
        // Parse each element
        for (let i = 0; i < elements.length; i++) {
            const element = elements[i];
            const tagName = element.tagName.toLowerCase();
            
            // Check if this is a block element that should break text accumulation
            if (blockTags.includes(tagName) && consecutiveTextContent.length > 0) {
                // Combine all consecutive text content into one card
                const combinedContent = consecutiveTextContent.join('<br><br>');
                addCardInternal('paragraph', { content: combinedContent });
                consecutiveTextContent = [];
            }
            
            switch(tagName) {
                case 'p':
                    const paragraphContent = element.innerHTML;
                    // Skip empty paragraphs or those with only whitespace/br tags
                    const cleanedContent = paragraphContent.replace(/<br\s*\/?>/gi, '').trim();
                    if (cleanedContent && cleanedContent !== '&nbsp;') {
                        // For paragraphs, just use inner HTML to preserve formatting
                        consecutiveTextContent.push(paragraphContent);
                    }
                    break;
                    
                case 'span':
                case 'strong':
                case 'b':
                case 'em':
                case 'i':
                case 'u':
                case 'a':
                case 'code':
                case 'small':
                case 'mark':
                case 'sub':
                case 'sup':
                    // For standalone inline elements, use outerHTML
                    const textContent = element.outerHTML;
                    if (textContent.trim()) {
                        consecutiveTextContent.push(textContent);
                    }
                    break;
                    
                case 'h1':
                case 'h2':
                case 'h3':
                case 'h4':
                case 'h5':
                case 'h6':
                    // Include headings in text content like Ghost does
                    const headingHtml = element.outerHTML;
                    if (headingHtml.trim()) {
                        consecutiveTextContent.push(headingHtml);
                    }
                    break;
                    
                case 'figure':
                    // Check if it's an image figure
                    const img = element.querySelector('img');
                    const video = element.querySelector('video');
                    
                    if (video) {
                        // Video card
                        let cardWidth = 'regular';
                        if (element.classList.contains('kg-width-wide')) {
                            cardWidth = 'wide';
                        } else if (element.classList.contains('kg-width-full')) {
                            cardWidth = 'full';
                        }
                        
                        addCardInternal('video', {
                            src: video.src,
                            caption: element.querySelector('figcaption')?.textContent || '',
                            cardWidth: cardWidth,
                            loop: video.hasAttribute('loop')
                        });
                    } else if (img) {
                        // Image card
                        let cardWidth = 'regular';
                        if (element.classList.contains('kg-width-wide')) {
                            cardWidth = 'wide';
                        } else if (element.classList.contains('kg-width-full')) {
                            cardWidth = 'full';
                        }
                        
                        // Check for link wrapper
                        const link = img.closest('a');
                        const href = link ? link.href : '';
                        
                        addCardInternal('image', {
                            src: img.src,
                            alt: img.alt || '',
                            caption: element.querySelector('figcaption')?.textContent || '',
                            cardWidth: cardWidth,
                            href: href
                        });
                    }
                    break;
                    
                case 'img':
                    addCardInternal('image', {
                        src: element.src,
                        alt: element.alt || '',
                        caption: ''
                    });
                    break;
                    
                case 'video':
                    addCardInternal('video', {
                        src: element.src,
                        caption: '',
                        loop: element.hasAttribute('loop')
                    });
                    break;
                    
                case 'audio':
                    addCardInternal('audio', {
                        src: element.src,
                        title: element.title || ''
                    });
                    break;
                    
                case 'hr':
                    addCardInternal('divider');
                    break;
                    
                case 'blockquote':
                    addCardInternal('callout', {
                        content: element.innerHTML,
                        emoji: '💡'
                    });
                    break;
                    
                case 'details':
                    const summary = element.querySelector('summary');
                    const content = element.innerHTML.replace(/<summary[^>]*>.*?<\/summary>/i, '').trim();
                    addCardInternal('toggle', {
                        title: summary ? summary.textContent : 'Toggle',
                        content: content,
                        isOpen: element.hasAttribute('open')
                    });
                    break;
                    
                case 'pre':
                    // Code block - use HTML card
                    addCardInternal('html', { content: element.outerHTML });
                    break;
                    
                case 'ul':
                case 'ol':
                    // Lists - convert to HTML card for now
                    addCardInternal('html', { content: element.outerHTML });
                    break;
                    
                case 'div':
                    // Skip empty divs or those with only whitespace/br tags
                    const divCleanedContent = element.innerHTML.replace(/<br\s*\/?>/gi, '').trim();
                    if (!divCleanedContent || divCleanedContent === '&nbsp;') {
                        break; // Skip empty divs
                    }
                    
                    // Check for special divs (buttons, etc)
                    if (element.classList.contains('kg-button-card')) {
                        const link = element.querySelector('a');
                        if (link) {
                            addCardInternal('button', {
                                text: link.textContent,
                                url: link.href,
                                alignment: 'center'
                            });
                        }
                    } else if (element.classList.contains('markdown')) {
                        addCardInternal('markdown', { content: element.innerHTML });
                    } else if (element.classList.contains('callout')) {
                        const type = element.className.match(/callout-(\w+)/)?.[1] || 'info';
                        addCardInternal('callout', { content: element.innerHTML, type: type });
                    } else if (element.classList.contains('kg-audio-card')) {
                        // Audio card
                        const audio = element.querySelector('audio');
                        const titleElement = element.querySelector('.kg-audio-title');
                        if (audio) {
                            addCardInternal('audio', {
                                src: audio.src,
                                title: titleElement?.textContent || ''
                            });
                        }
                    } else {
                        // Generic div - treat as HTML
                        addCardInternal('html', { content: element.innerHTML });
                    }
                    break;
                    
                default:
                    // For any other tags, use HTML card
                    addCardInternal('html', { content: element.outerHTML });
                    break;
            }
        }
        
        // Handle any remaining consecutive text content
        if (consecutiveTextContent.length > 0) {
            const combinedContent = consecutiveTextContent.join('<br><br>');
            addCardInternal('paragraph', { content: combinedContent });
        }
        
        // If no cards were added, add a paragraph
        if (contentCards.length === 0) {
            addCardInternal('paragraph', {});
        }
        
        // Reset flag after creating cards
        if (isInitialLoad) {
            setTimeout(() => { isCreatingCards = false; }, 100);
        }
    }
    
    // Add a new content card
    function addCard(type, data = {}, shouldMarkDirty = true) {
        const cardId = 'card-' + Date.now();
        const card = {
            id: cardId,
            type: type,
            data: data
        };
        
        contentCards.push(card);
        
        const cardElement = createCardElement(card);
        const container = document.getElementById('editorContainer');
        
        // Add the card
        container.appendChild(cardElement);
        
        // Add the "add card" button after this card
        const addButton = createAddButton();
        container.appendChild(addButton);
        
        // Focus the new card
        focusCard(cardElement);
        
        if (shouldMarkDirty) {
            markDirtySafe();
        }
    }
    
    // Create card element based on type
    function createCardElement(card) {
        const div = document.createElement('div');
        div.className = 'content-card';
        div.id = card.id;
        div.setAttribute('data-card-type', card.type);
        
        // Create toolbar
        const toolbar = document.createElement('div');
        toolbar.className = 'content-card-toolbar';
        toolbar.innerHTML = `
            <button type="button" class="btn btn-sm btn-dark" onclick="moveCard('${card.id}', 'up')">
                <i class="ti ti-arrow-up"></i>
            </button>
            <button type="button" class="btn btn-sm btn-dark" onclick="moveCard('${card.id}', 'down')">
                <i class="ti ti-arrow-down"></i>
            </button>
            <button type="button" class="btn btn-sm btn-dark" onclick="deleteCard('${card.id}')">
                <i class="ti ti-trash"></i>
            </button>
        `;
        div.appendChild(toolbar);
        
        // Create content based on type
        switch(card.type) {
            case 'paragraph':
                div.innerHTML += createParagraphCard(card);
                break;
            case 'heading':
                div.innerHTML += createHeadingCard(card);
                break;
            case 'image':
                div.innerHTML += createImageCard(card);
                break;
            case 'html':
                div.innerHTML += createHtmlCard(card);
                break;
            case 'markdown':
                div.innerHTML += createMarkdownCard(card);
                break;
            case 'divider':
                div.innerHTML += createDividerCard(card);
                break;
            case 'button':
                div.innerHTML += createButtonCard(card);
                break;
            case 'callout':
                div.innerHTML += createCalloutCard(card);
                break;
            case 'toggle':
                div.innerHTML += createToggleCard(card);
                break;
            case 'video':
                div.innerHTML += createVideoCard(card);
                break;
            case 'audio':
                div.innerHTML += createAudioCard(card);
                break;
            // Add more card types as needed
        }
        
        // Restore toolbar
        div.insertBefore(toolbar, div.firstChild);
        
        return div;
    }
    
    // Card creation functions
    function createParagraphCard(card) {
        return `<div contenteditable="true" 
                     class="card-content prose" 
                     id="content-${card.id}"
                     onblur="updateCard('${card.id}', this.innerHTML)"
                     oninput="markDirtySafe(); updateWordCount();"
                     placeholder="Start writing...">${card.data.content || ''}</div>`;
    }
    
    function createHeadingCard(card) {
        const level = card.data.level || 2;
        return `<h${level} contenteditable="true" 
                         class="card-content font-bold text-2xl" 
                         onblur="updateCard('${card.id}', this.innerHTML)"
                         oninput="markDirtySafe(); updateWordCount();"
                         placeholder="Heading...">${card.data.content || ''}</h${level}>`;
    }
    
    function createImageCard(card) {
        // Set default card width if not set
        if (!card.data.cardWidth) {
            card.data.cardWidth = 'regular';
        }
        
        if (card.data.src) {
            return `
                <div class="card-content image-card-content" data-card-width="${card.data.cardWidth}">
                    <div class="image-wrapper ${card.data.cardWidth === 'full' ? 'kg-width-full' : card.data.cardWidth === 'wide' ? 'kg-width-wide' : ''}">
                        <img src="${card.data.src}" 
                             alt="${card.data.alt || ''}" 
                             class="w-full rounded cursor-pointer" 
                             onclick="showImageSettings('${card.id}')">
                    </div>
                    <input type="text" 
                           class="form-control mt-2" 
                           placeholder="Type caption (optional)" 
                           value="${card.data.caption || ''}"
                           onblur="updateCardData('${card.id}', 'caption', this.value)"
                           oninput="markDirtySafe();">
                    
                    <!-- Ghost-style Image Settings Panel -->
                    <div class="ghost-image-settings hidden" id="imageSettings-${card.id}">
                        <div class="ghost-image-toolbar">
                            <!-- Width Options -->
                            <div class="ghost-image-width-selector">
                                <button type="button" 
                                        class="ghost-width-btn ${card.data.cardWidth === 'regular' ? 'active' : ''}"
                                        onclick="updateImageWidth('${card.id}', 'regular')"
                                        title="Regular width">
                                    <svg width="24" height="18" viewBox="0 0 24 18" fill="none">
                                        <rect x="5" y="2" width="14" height="14" stroke="currentColor" stroke-width="1.5" rx="1"/>
                                    </svg>
                                </button>
                                <button type="button" 
                                        class="ghost-width-btn ${card.data.cardWidth === 'wide' ? 'active' : ''}"
                                        onclick="updateImageWidth('${card.id}', 'wide')"
                                        title="Wide">
                                    <svg width="24" height="18" viewBox="0 0 24 18" fill="none">
                                        <rect x="2" y="4" width="20" height="10" stroke="currentColor" stroke-width="1.5" rx="1"/>
                                    </svg>
                                </button>
                                <button type="button" 
                                        class="ghost-width-btn ${card.data.cardWidth === 'full' ? 'active' : ''}"
                                        onclick="updateImageWidth('${card.id}', 'full')"
                                        title="Full width">
                                    <svg width="24" height="18" viewBox="0 0 24 18" fill="none">
                                        <rect x="0" y="5" width="24" height="8" stroke="currentColor" stroke-width="1.5" rx="1"/>
                                    </svg>
                                </button>
                            </div>
                            
                            <div class="ghost-image-toolbar-divider"></div>
                            
                            <!-- Replace Image -->
                            <button type="button" 
                                    class="ghost-image-btn"
                                    onclick="replaceImage('${card.id}')"
                                    title="Replace image">
                                <i class="ti ti-replace"></i>
                            </button>
                            
                            <!-- Alt Text -->
                            <button type="button" 
                                    class="ghost-image-btn ${card.data.alt ? 'active' : ''}"
                                    onclick="toggleAltTextInput('${card.id}')"
                                    title="Alt text">
                                <span class="ghost-alt-icon">ALT</span>
                            </button>
                            
                            <!-- Link -->
                            <button type="button" 
                                    class="ghost-image-btn ${card.data.href ? 'active' : ''}"
                                    onclick="toggleLinkInput('${card.id}')"
                                    title="Link">
                                <i class="ti ti-link"></i>
                            </button>
                        </div>
                        
                        <!-- Alt Text Input (hidden by default) -->
                        <div class="ghost-image-input-row hidden" id="altTextInput-${card.id}">
                            <input type="text" 
                                   class="ghost-image-input" 
                                   placeholder="Alt text"
                                   value="${card.data.alt || ''}"
                                   onblur="updateCardData('${card.id}', 'alt', this.value)"
                                   oninput="markDirtySafe();"
                                   onkeydown="if(event.key === 'Enter') toggleAltTextInput('${card.id}')">
                        </div>
                        
                        <!-- Link Input (hidden by default) -->
                        <div class="ghost-image-input-row hidden" id="linkInput-${card.id}">
                            <input type="url" 
                                   class="ghost-image-input" 
                                   placeholder="Paste or type a link"
                                   value="${card.data.href || ''}"
                                   onblur="updateCardData('${card.id}', 'href', this.value)"
                                   oninput="markDirtySafe();"
                                   onkeydown="if(event.key === 'Enter') toggleLinkInput('${card.id}')">
                        </div>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="card-content">
                    <div class="image-upload-placeholder bg-gray-100 rounded p-8 text-center cursor-pointer"
                         onclick="selectImage('${card.id}')">
                        <i class="ti ti-photo-plus text-4xl text-gray-400 mb-2"></i>
                        <p class="text-gray-600">Click to upload an image</p>
                    </div>
                    <input type="file" 
                           id="imageInput-${card.id}" 
                           accept="image/*" 
                           style="display: none;" 
                           onchange="uploadImage('${card.id}', this)">
                </div>
            `;
        }
    }
    
    function createHtmlCard(card) {
        return `
            <div class="card-content">
                <div class="mb-2 text-sm text-gray-600">
                    <i class="ti ti-code me-1"></i> HTML
                </div>
                <textarea class="form-control font-mono text-sm" 
                          rows="6"
                          onblur="updateCard('${card.id}', this.value)"
                          oninput="markDirtySafe();"
                          placeholder="<p>Enter HTML code...</p>">${card.data.content || ''}</textarea>
            </div>
        `;
    }
    
    function createMarkdownCard(card) {
        return `
            <div class="card-content">
                <div class="mb-2 text-sm text-gray-600">
                    <i class="ti ti-markdown me-1"></i> Markdown
                </div>
                <textarea class="form-control font-mono text-sm" 
                          rows="6"
                          onblur="updateCard('${card.id}', this.value)"
                          oninput="markDirtySafe(); updateWordCount();"
                          placeholder="# Enter markdown...">${card.data.content || ''}</textarea>
            </div>
        `;
    }
    
    function createDividerCard(card) {
        return `
            <div class="card-content">
                <hr class="my-4">
            </div>
        `;
    }
    
    function createButtonCard(card) {
        return `
            <div class="card-content">
                <div class="flex gap-4 items-end">
                    <div class="flex-1">
                        <label class="form-label text-sm">Button Text</label>
                        <input type="text" 
                               class="form-control" 
                               value="${card.data.text || ''}"
                               onblur="updateCardData('${card.id}', 'text', this.value)"
                               placeholder="Click me">
                    </div>
                    <div class="flex-1">
                        <label class="form-label text-sm">Button URL</label>
                        <input type="url" 
                               class="form-control" 
                               value="${card.data.url || ''}"
                               onblur="updateCardData('${card.id}', 'url', this.value)"
                               placeholder="https://example.com">
                    </div>
                </div>
                <div class="mt-4 text-center">
                    <a href="${card.data.url || '#'}" 
                       class="btn btn-primary" 
                       target="_blank">${card.data.text || 'Button'}</a>
                </div>
            </div>
        `;
    }
    
    function createCalloutCard(card) {
        const bgColors = {
            'info': 'bg-blue-50 border-blue-200',
            'success': 'bg-green-50 border-green-200',
            'warning': 'bg-yellow-50 border-yellow-200',
            'error': 'bg-red-50 border-red-200'
        };
        
        const iconColors = {
            'info': 'text-blue-500',
            'success': 'text-green-500',
            'warning': 'text-yellow-500',
            'error': 'text-red-500'
        };
        
        const type = card.data.type || 'info';
        
        return `
            <div class="card-content">
                <div class="mb-2">
                    <select class="form-select form-select-sm" 
                            onchange="updateCardData('${card.id}', 'type', this.value); refreshCard('${card.id}')">
                        <option value="info" ${type === 'info' ? 'selected' : ''}>Info</option>
                        <option value="success" ${type === 'success' ? 'selected' : ''}>Success</option>
                        <option value="warning" ${type === 'warning' ? 'selected' : ''}>Warning</option>
                        <option value="error" ${type === 'error' ? 'selected' : ''}>Error</option>
                    </select>
                </div>
                <div class="${bgColors[type]} border rounded-lg p-4">
                    <div class="flex items-start gap-3">
                        <i class="ti ti-info-circle ${iconColors[type]} text-xl mt-0.5"></i>
                        <div contenteditable="true" 
                             class="flex-1" 
                             onblur="updateCardData('${card.id}', 'content', this.innerHTML)"
                             oninput="markDirtySafe();"
                             placeholder="Enter callout text...">${card.data.content || ''}</div>
                    </div>
                </div>
            </div>
        `;
    }
    
    function createToggleCard(card) {
        const isOpen = card.data.isOpen || false;
        const title = card.data.title || '';
        const content = card.data.content || '';
        
        return `
            <div class="card-content">
                <div class="border rounded-lg overflow-hidden">
                    <div class="bg-gray-50 p-4 cursor-pointer hover:bg-gray-100 transition-colors"
                         onclick="toggleToggleCard('${card.id}')">
                        <div class="flex items-center gap-2">
                            <i class="ti ti-chevron-right text-gray-500 transition-transform ${isOpen ? 'rotate-90' : ''}" 
                               id="toggle-icon-${card.id}"></i>
                            <input type="text" 
                                   class="flex-1 bg-transparent border-none outline-none font-medium" 
                                   placeholder="Toggle heading..."
                                   value="${title}"
                                   onclick="event.stopPropagation();"
                                   onblur="updateCardData('${card.id}', 'title', this.value)"
                                   oninput="markDirtySafe();">
                        </div>
                    </div>
                    <div class="p-4 ${isOpen ? '' : 'hidden'}" id="toggle-content-${card.id}">
                        <div contenteditable="true" 
                             class="prose max-w-none" 
                             onblur="updateCardData('${card.id}', 'content', this.innerHTML)"
                             oninput="markDirtySafe();"
                             placeholder="Toggle content...">${content}</div>
                    </div>
                </div>
            </div>
        `;
    }
    
    function createVideoCard(card) {
        // Set default card width if not set
        if (!card.data.cardWidth) {
            card.data.cardWidth = 'regular';
        }
        
        if (card.data.src) {
            return `
                <div class="card-content video-card-content" data-card-width="${card.data.cardWidth}">
                    <div class="video-wrapper ${card.data.cardWidth === 'full' ? 'kg-width-full' : card.data.cardWidth === 'wide' ? 'kg-width-wide' : ''}">
                        <video src="${card.data.src}" 
                               controls
                               preload="metadata"
                               ${card.data.thumbnail ? `poster="${card.data.thumbnail}"` : ''}
                               ${card.data.loop ? 'loop autoplay muted playsinline' : ''}
                               style="width: 100%; max-width: 100%;">
                        </video>
                    </div>
                    <div class="mt-2">
                        <input type="text" 
                               class="form-control" 
                               placeholder="Add caption..."
                               value="${card.data.caption || ''}"
                               onblur="updateCardData('${card.id}', 'caption', this.value)"
                               oninput="markDirtySafe();">
                    </div>
                    <div class="ghost-video-settings mt-3" id="videoSettings-${card.id}">
                        <div class="ghost-video-toolbar">
                            <div class="ghost-video-width-selector">
                                <button type="button" class="ghost-width-btn ${card.data.cardWidth === 'regular' ? 'active' : ''}"
                                        onclick="updateCardData('${card.id}', 'cardWidth', 'regular'); refreshCard('${card.id}')"
                                        title="Regular width">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <rect x="6" y="5" width="12" height="14" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                    </svg>
                                </button>
                                <button type="button" class="ghost-width-btn ${card.data.cardWidth === 'wide' ? 'active' : ''}"
                                        onclick="updateCardData('${card.id}', 'cardWidth', 'wide'); refreshCard('${card.id}')"
                                        title="Wide">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <rect x="4" y="5" width="16" height="14" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                    </svg>
                                </button>
                                <button type="button" class="ghost-width-btn ${card.data.cardWidth === 'full' ? 'active' : ''}"
                                        onclick="updateCardData('${card.id}', 'cardWidth', 'full'); refreshCard('${card.id}')"
                                        title="Full width">
                                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                        <rect x="2" y="5" width="20" height="14" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                    </svg>
                                </button>
                            </div>
                            
                            <div class="ghost-video-separator"></div>
                            
                            <label class="ghost-video-loop-btn ${card.data.loop ? 'active' : ''}">
                                <input type="checkbox" 
                                       ${card.data.loop ? 'checked' : ''}
                                       onchange="updateCardData('${card.id}', 'loop', this.checked); refreshCard('${card.id}')"
                                       style="display: none;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M17 2l4 4-4 4"/>
                                    <path d="M3 11V9a4 4 0 014-4h14"/>
                                    <path d="M7 22l-4-4 4-4"/>
                                    <path d="M21 13v2a4 4 0 01-4 4H3"/>
                                </svg>
                                <span>Loop</span>
                            </label>
                            
                            <div class="ghost-video-separator"></div>
                            
                            <button type="button" 
                                    class="ghost-replace-btn"
                                    onclick="document.getElementById('video-replace-${card.id}').click()">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                                    <path d="M14 2v6h6"/>
                                    <path d="M12 12v6"/>
                                    <path d="M12 12l-2-2"/>
                                    <path d="M12 12l2-2"/>
                                </svg>
                                Replace
                            </button>
                            <input type="file" 
                                   id="video-replace-${card.id}" 
                                   accept="video/*" 
                                   style="display: none;"
                                   onchange="handleVideoReplace('${card.id}', this)">
                        </div>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="card-content text-center py-5">
                    <div class="mb-3">
                        <i class="ti ti-movie text-muted" style="font-size: 3rem;"></i>
                    </div>
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="document.getElementById('video-upload-${card.id}').click()">
                        <i class="ti ti-upload"></i> Upload video
                    </button>
                    <input type="file" 
                           id="video-upload-${card.id}" 
                           accept="video/*" 
                           style="display: none;"
                           onchange="handleVideoUpload('${card.id}', this)">
                </div>
            `;
        }
    }
    
    function createAudioCard(card) {
        if (card.data.src) {
            return `
                <div class="card-content audio-card-content">
                    <div class="audio-wrapper">
                        <audio src="${card.data.src}" 
                               controls
                               preload="metadata"
                               style="width: 100%;">
                        </audio>
                        ${card.data.duration ? `<div class="audio-duration text-muted small mt-1">${formatDuration(card.data.duration)}</div>` : ''}
                    </div>
                    <div class="mt-2">
                        <input type="text" 
                               class="form-control" 
                               placeholder="Add title (optional)..."
                               value="${card.data.title || ''}"
                               onblur="updateCardData('${card.id}', 'title', this.value)"
                               oninput="markDirtySafe();">
                    </div>
                    <div class="ghost-audio-settings mt-3" id="audioSettings-${card.id}">
                        <div class="ghost-audio-toolbar">
                            <button type="button" 
                                    class="ghost-replace-btn"
                                    onclick="document.getElementById('audio-replace-${card.id}').click()">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                                    <path d="M14 2v6h6"/>
                                    <path d="M12 12v6"/>
                                    <path d="M12 12l-2-2"/>
                                    <path d="M12 12l2-2"/>
                                </svg>
                                Replace
                            </button>
                            <input type="file" 
                                   id="audio-replace-${card.id}" 
                                   accept="audio/*" 
                                   style="display: none;"
                                   onchange="handleAudioReplace('${card.id}', this)">
                        </div>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="card-content text-center py-5">
                    <div class="mb-3">
                        <i class="ti ti-volume text-muted" style="font-size: 3rem;"></i>
                    </div>
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="document.getElementById('audio-upload-${card.id}').click()">
                        <i class="ti ti-upload"></i> Upload audio
                    </button>
                    <input type="file" 
                           id="audio-upload-${card.id}" 
                           accept="audio/*" 
                           style="display: none;"
                           onchange="handleAudioUpload('${card.id}', this)">
                </div>
            `;
        }
    }
    
    // Create add button
    function createAddButton() {
        const div = document.createElement('div');
        div.className = 'add-card-button';
        div.onclick = function() { showCardMenu(this); };
        div.innerHTML = `
            <div class="add-card-button-icon">
                <i class="ti ti-plus"></i>
            </div>
        `;
        return div;
    }
    
    // Show card menu
    function showCardMenu(button) {
        // Remove any existing menu
        const existingMenu = document.querySelector('.card-menu');
        if (existingMenu) {
            existingMenu.remove();
        }
        
        // Create menu
        const menu = document.createElement('div');
        menu.className = 'card-menu';
        menu.style.top = button.offsetTop + 'px';
        menu.style.left = button.offsetLeft + 'px';
        
        menu.innerHTML = `
            <div class="card-menu-category">Basic</div>
            <div class="card-menu-item" onclick="insertCard('paragraph', this)">
                <i class="ti ti-align-left"></i>
                <span>Paragraph</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('heading', this)">
                <i class="ti ti-h-1"></i>
                <span>Heading</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('image', this)">
                <i class="ti ti-photo"></i>
                <span>Image</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('divider', this)">
                <i class="ti ti-minus"></i>
                <span>Divider</span>
            </div>
            
            <div class="card-menu-category">Formatting</div>
            <div class="card-menu-item" onclick="insertCard('html', this)">
                <i class="ti ti-code"></i>
                <span>HTML</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('markdown', this)">
                <i class="ti ti-markdown"></i>
                <span>Markdown</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('callout', this)">
                <i class="ti ti-info-square"></i>
                <span>Callout</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('button', this)">
                <i class="ti ti-rectangle"></i>
                <span>Button</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('toggle', this)">
                <i class="ti ti-chevron-right"></i>
                <span>Toggle</span>
            </div>
            
            <div class="card-menu-category">Media</div>
            <div class="card-menu-item" onclick="insertCard('video', this)">
                <i class="ti ti-movie"></i>
                <span>Video</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('audio', this)">
                <i class="ti ti-volume"></i>
                <span>Audio</span>
            </div>
        `;
        
        // Store reference to the button that opened this menu
        menu.setAttribute('data-button', button.id || 'temp-' + Date.now());
        if (!button.id) {
            button.id = menu.getAttribute('data-button');
        }
        
        document.body.appendChild(menu);
        
        // Close menu on click outside
        setTimeout(() => {
            document.addEventListener('click', closeCardMenu);
        }, 100);
    }
    
    // Insert card from menu
    function insertCard(type, menuItem) {
        const menu = menuItem.closest('.card-menu');
        const buttonId = menu.getAttribute('data-button');
        const button = document.getElementById(buttonId);
        
        // Create new card
        const cardId = 'card-' + Date.now();
        const card = {
            id: cardId,
            type: type,
            data: {}
        };
        
        contentCards.push(card);
        
        const cardElement = createCardElement(card);
        
        // Insert card before the button
        button.parentNode.insertBefore(cardElement, button);
        
        // Focus the new card
        focusCard(cardElement);
        
        // Close menu
        closeCardMenu();
        
        // Only mark dirty if we're not initializing
        if (!isInitializing && !isCreatingCards) {
            markDirtySafe();
        }
    }
    
    // Close card menu
    function closeCardMenu() {
        const menu = document.querySelector('.card-menu');
        if (menu) {
            menu.remove();
        }
        document.removeEventListener('click', closeCardMenu);
    }
    
    // Focus card for editing
    function focusCard(cardElement) {
        const editable = cardElement.querySelector('[contenteditable="true"], input[type="text"], textarea');
        if (editable) {
            editable.focus();
        }
    }
    
    // Update card content
    function updateCard(cardId, content) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            // Only mark dirty if content actually changed
            if (card.data.content !== content) {
                card.data.content = content;
                markDirtySafe();
            }
        }
    }
    
    // Update card data property
    function updateCardData(cardId, property, value) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            // Only mark dirty if value actually changed
            if (card.data[property] !== value) {
                card.data[property] = value;
                markDirtySafe();
            }
            
            // Update button active states based on property changed
            if (property === 'href') {
                const linkBtn = document.querySelector(`#imageSettings-${cardId} .ghost-image-btn[onclick*="toggleLinkInput"]`);
                if (linkBtn) {
                    if (value) {
                        linkBtn.classList.add('active');
                    } else {
                        linkBtn.classList.remove('active');
                    }
                }
            } else if (property === 'alt') {
                const altBtn = document.querySelector(`#imageSettings-${cardId} .ghost-image-btn[onclick*="toggleAltTextInput"]`);
                if (altBtn) {
                    if (value) {
                        altBtn.classList.add('active');
                    } else {
                        altBtn.classList.remove('active');
                    }
                }
            }
        }
    }
    
    // Refresh card display
    function refreshCard(cardId) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            const oldElement = document.getElementById(cardId);
            const newElement = createCardElement(card);
            oldElement.parentNode.replaceChild(newElement, oldElement);
        }
    }
    
    // Move card up or down
    function moveCard(cardId, direction) {
        const index = contentCards.findIndex(c => c.id === cardId);
        if (index === -1) return;
        
        if (direction === 'up' && index > 0) {
            // Swap with previous card
            [contentCards[index], contentCards[index - 1]] = [contentCards[index - 1], contentCards[index]];
        } else if (direction === 'down' && index < contentCards.length - 1) {
            // Swap with next card
            [contentCards[index], contentCards[index + 1]] = [contentCards[index + 1], contentCards[index]];
        }
        
        // Rebuild the editor
        rebuildEditor();
        markDirtySafe();
    }
    
    // Delete card
    function deleteCard(cardId) {
        // Create inline confirmation for card deletion
        const card = document.getElementById(cardId);
        
        // Check if confirmation already exists
        if (card.querySelector('.card-delete-confirm')) {
            return;
        }
        
        // Create confirmation overlay
        const confirmDiv = document.createElement('div');
        confirmDiv.className = 'card-delete-confirm absolute inset-0 bg-white bg-opacity-95 rounded flex items-center justify-center z-10';
        confirmDiv.innerHTML = `
            <div class="bg-white rounded-md shadow-lg border border-gray-200 p-3 max-w-xs">
                <p class="text-xs text-gray-700 mb-2">Delete this card?</p>
                <div class="flex gap-1">
                    <button type="button" 
                            class="btn btn-xs btn-outline-secondary" 
                            onclick="cancelDeleteCard('${cardId}')">
                        Cancel
                    </button>
                    <button type="button" 
                            class="btn btn-xs btn-danger" 
                            onclick="executeDeleteCard('${cardId}')">
                        Delete
                    </button>
                </div>
            </div>
        `;
        
        card.appendChild(confirmDiv);
    }
    
    // Cancel card deletion
    function cancelDeleteCard(cardId) {
        const card = document.getElementById(cardId);
        const confirmDiv = card.querySelector('.card-delete-confirm');
        if (confirmDiv) {
            confirmDiv.remove();
        }
    }
    
    // Delete card directly without confirmation (for keyboard shortcuts)
    function deleteCardDirectly(cardId) {
        console.log('deleteCardDirectly called with cardId:', cardId);
        console.log('Current contentCards length:', contentCards.length);
        console.log('Current state - isDirty:', isDirty, 'isInitializing:', isInitializing);
        
        // Don't delete if it's the only card
        if (contentCards.length <= 1) {
            console.log('Not deleting - only one card left');
            return;
        }
        
        const element = document.getElementById(cardId);
        const cardIndex = contentCards.findIndex(c => c.id === cardId);
        
        console.log('Card element found:', element);
        console.log('Card index in array:', cardIndex);
        
        if (!element) {
            console.log('Card element not found in DOM, aborting deletion');
            return;
        }
        
        if (cardIndex === -1) {
            console.log('Card not found in contentCards array, aborting deletion');
            return;
        }
        
        // Focus the previous or next card before deletion
        let targetCard = null;
        if (cardIndex > 0) {
            // Focus previous card
            targetCard = contentCards[cardIndex - 1];
        } else if (cardIndex < contentCards.length - 1) {
            // Focus next card
            targetCard = contentCards[cardIndex + 1];
        }
        
        // Remove from array
        contentCards = contentCards.filter(c => c.id !== cardId);
        
        // Remove the add button after this card
        const nextSibling = element.nextElementSibling;
        if (nextSibling && nextSibling.classList.contains('add-card-button')) {
            nextSibling.remove();
        }
        
        // Remove the element
        element.remove();
        
        // Focus the target card
        if (targetCard) {
            setTimeout(() => {
                const targetElement = document.getElementById(`content-${targetCard.id}`);
                if (targetElement) {
                    targetElement.focus();
                    // Place cursor at the end
                    const range = document.createRange();
                    const selection = window.getSelection();
                    range.selectNodeContents(targetElement);
                    range.collapse(false);
                    selection.removeAllRanges();
                    selection.addRange(range);
                }
            }, 10);
        }
        
        markDirtySafe();
        updateWordCount();
    }
    
    // Execute card deletion
    function executeDeleteCard(cardId) {
        contentCards = contentCards.filter(c => c.id !== cardId);
        const element = document.getElementById(cardId);
        
        // Remove the add button after this card
        const nextSibling = element.nextElementSibling;
        if (nextSibling && nextSibling.classList.contains('add-card-button')) {
            nextSibling.remove();
        }
        
        element.remove();
        markDirtySafe();
    }
    
    // Rebuild editor display
    function rebuildEditor() {
        const container = document.getElementById('editorContainer');
        container.innerHTML = '';
        
        contentCards.forEach((card, index) => {
            const cardElement = createCardElement(card);
            container.appendChild(cardElement);
            
            // Add "add card" button after each card
            const addButton = createAddButton();
            container.appendChild(addButton);
        });
    }
    
    // Generate slug from title
    function generateSlug(title) {
        return title.toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '');
    }
    
    
    // Mark content as dirty (needs saving)
    function markDirty() {
        // Don't mark dirty during initialization
        if (isInitializing) {
            console.log('markDirty called during initialization - ignoring');
            return;
        }
        
        // Don't mark dirty during programmatic changes
        if (isProgrammaticChange) {
            console.log('markDirty called during programmatic change - ignoring');
            return;
        }
        
        // Don't mark dirty when creating cards initially
        if (isCreatingCards) {
            console.log('markDirty called during card creation - ignoring');
            return;
        }
        
        // Don't mark dirty if content hasn't been initialized yet
        if (contentCards.length === 0 && !document.getElementById('postTitle').value.trim()) {
            console.log('markDirty called with no content - ignoring');
            return;
        }
        
        console.log('markDirty called - setting isDirty to true', new Error().stack);
        isDirty = true;
        
        // Show unsaved changes for all posts
        document.getElementById('saveStatus').textContent = 'Unsaved changes';
        document.getElementById('saveStatus').className = 'text-sm text-orange-600';
        
        // Reset autosave timer for draft posts only
        if (originalStatus !== 'published') {
            if (autosaveTimer) {
                clearTimeout(autosaveTimer);
            }
            autosaveTimer = setTimeout(autosave, 3000); // 3 seconds
        }
    }
    
    // Safe wrapper for markDirty that respects initialization state
    function markDirtySafe() {
        if (!isInitializing) {
            markDirty();
        }
    }
    
    // Navigation handling
    let pendingNavigation = null;
    
    // Setup autosave and navigation handling
    function setupAutosave() {
        // Auto-save is handled by the autosave timer
        
        // Handle navigation with custom modal
        window.addEventListener('beforeunload', function(e) {
            if (isDirty) {
                // Show custom modal instead of browser popup
                e.preventDefault();
                // For modern browsers
                e.returnValue = '';
                // We'll handle this with our custom modal
                return '';
            }
        });
        
        // Intercept link clicks
        document.addEventListener('click', function(e) {
            const link = e.target.closest('a');
            if (link && !link.target) {
                console.log('Link clicked:', link.href, 'isDirty:', isDirty, 'isInitializing:', isInitializing);
                if (isDirty && !isInitializing) {
                    e.preventDefault();
                    pendingNavigation = link.href;
                    showUnsavedChangesModal();
                }
            }
        });
    }
    
    // Show unsaved changes modal
    function showUnsavedChangesModal() {
        document.getElementById('unsavedChangesModal').classList.remove('hidden');
    }
    
    // Hide unsaved changes modal
    function hideUnsavedChangesModal() {
        document.getElementById('unsavedChangesModal').classList.add('hidden');
        pendingNavigation = null;
    }
    
    // Save and leave
    function saveAndLeave() {
        // Hide modal immediately
        hideUnsavedChangesModal();
        
        // Show saving message
        showMessage('Saving...', 'info');
        
        // Save as draft for unpublished posts, or maintain status for published posts
        const saveStatus = originalStatus === 'published' ? 'published' : 'draft';
        savePost(saveStatus, false).then(() => {
            isDirty = false;
            if (pendingNavigation) {
                window.location.href = pendingNavigation;
            }
        }).catch(error => {
            showMessage('Save failed: ' + error.message, 'error');
            // Re-show the modal if save fails
            showUnsavedChangesModal();
        });
    }
    
    // Leave without saving
    function leaveWithoutSaving() {
        isDirty = false;
        if (pendingNavigation) {
            window.location.href = pendingNavigation;
        }
        hideUnsavedChangesModal();
    }
    
    // Cancel navigation
    function cancelLeave() {
        hideUnsavedChangesModal();
    }
    
    // Toggle the toggle card open/closed
    function toggleToggleCard(cardId) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.isOpen = !card.data.isOpen;
            
            // Update UI
            const icon = document.getElementById(`toggle-icon-${cardId}`);
            const content = document.getElementById(`toggle-content-${cardId}`);
            
            if (card.data.isOpen) {
                icon.classList.add('rotate-90');
                content.classList.remove('hidden');
            } else {
                icon.classList.remove('rotate-90');
                content.classList.add('hidden');
            }
            
            markDirtySafe();
        }
    }
    
    // Autosave function
    function autosave() {
        if (!isDirty) return;
        
        // Only autosave draft posts (don't autosave published posts)
        if (originalStatus !== 'published') {
            savePost('draft', true);
        }
    }
    
    // Update word count
    function updateWordCount() {
        let text = document.getElementById('postTitle').value + ' ';
        
        // Collect text from all cards
        contentCards.forEach(card => {
            if (card.data.content) {
                // Strip HTML tags for word count
                const temp = document.createElement('div');
                temp.innerHTML = card.data.content;
                text += temp.textContent + ' ';
            }
        });
        
        // Count words
        wordCount = text.trim().split(/\s+/).filter(word => word.length > 0).length;
        document.getElementById('wordCount').textContent = wordCount;
    }
    
    // Toggle settings panel
    function toggleSettings() {
        const panel = document.getElementById('settingsPanel');
        panel.classList.toggle('active');
    }
    
    // Tag management
    function addTag() {
        const selector = document.getElementById('tagSelector');
        const selectedOption = selector.options[selector.selectedIndex];
        
        if (selectedOption.value) {
            const tagId = selectedOption.value;
            const tagName = selectedOption.getAttribute('data-name');
            
            // Check if tag already selected
            if (!selectedTags.find(t => t.id === tagId)) {
                selectedTags.push({
                    id: tagId,
                    name: tagName
                });
                
                // Add tag badge
                const tagsContainer = document.getElementById('selectedTags');
                const badge = document.createElement('span');
                badge.className = 'badge bg-primary text-white';
                badge.innerHTML = `
                    ${tagName}
                    <button type="button" class="ms-2" onclick="removeTag('${tagId}')">
                        <i class="ti ti-x text-xs"></i>
                    </button>
                `;
                tagsContainer.appendChild(badge);
                
                markDirtySafe();
            }
            
            // Reset selector
            selector.value = '';
        }
    }
    
    function removeTag(tagId) {
        selectedTags = selectedTags.filter(t => t.id !== tagId);
        
        // Rebuild tags display
        const tagsContainer = document.getElementById('selectedTags');
        tagsContainer.innerHTML = '';
        
        selectedTags.forEach(tag => {
            const badge = document.createElement('span');
            badge.className = 'badge bg-primary text-white';
            badge.innerHTML = `
                ${tag.name}
                <button type="button" class="ms-2" onclick="removeTag('${tag.id}')">
                    <i class="ti ti-x text-xs"></i>
                </button>
            `;
            tagsContainer.appendChild(badge);
        });
        
        markDirtySafe();
    }
    
    // Feature image handling
    function selectFeatureImage() {
        document.getElementById('featureImageInput').click();
    }
    
    function changeFeatureImage() {
        selectFeatureImage();
    }
    
    function uploadFeatureImage(input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            
            // Validate file
            if (!file.type.match('image.*')) {
                showMessage('Please select an image file', 'error');
                return;
            }
            
            if (file.size > 5 * 1024 * 1024) {
                showMessage('Image must be less than 5MB', 'error');
                return;
            }
            
            // Create FormData
            const formData = new FormData();
            formData.append('file', file);
            formData.append('type', 'feature');
            
            // Show loading
            showMessage('Uploading image...', 'info');
            
            // Upload image
            fetch('/ghost/admin/ajax/upload-image.cfm', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.text();
            })
            .then(text => {
                console.log('Upload response:', text);
                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('JSON parse error:', e);
                    throw new Error('Server returned invalid response');
                }
            })
            .then(data => {
                if (data.success || data.SUCCESS) {
                    let imageUrl = data.url || data.URL;
                    
                    // Remove __GHOST_URL__ placeholder if present
                    if (imageUrl.includes('__GHOST_URL__')) {
                        imageUrl = imageUrl.replace('__GHOST_URL__', '');
                    }
                    
                    // Ensure /ghost prefix for content images
                    if (imageUrl.includes('/content/') && !imageUrl.includes('/ghost/')) {
                        imageUrl = '/ghost' + imageUrl;
                    }
                    
                    // Update preview
                    const container = document.getElementById('featureImageContainer');
                    container.innerHTML = `
                        <div class="feature-image-preview">
                            <img src="${imageUrl}" alt="Feature image" id="featureImagePreview">
                            <div class="feature-image-actions">
                                <button type="button" class="btn btn-sm btn-light" onclick="event.stopPropagation(); changeFeatureImage()">
                                    <i class="ti ti-refresh"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-light" onclick="event.stopPropagation(); removeFeatureImage()">
                                    <i class="ti ti-trash"></i>
                                </button>
                            </div>
                        </div>
                    `;
                    
                    postData.feature_image = imageUrl;
                    markDirtySafe();
                    showMessage('Feature image uploaded', 'success');
                } else {
                    showMessage(data.message || data.MESSAGE || 'Upload failed', 'error');
                }
            })
            .catch(error => {
                showMessage('Upload failed: ' + error.message, 'error');
            });
        }
    }
    
    // Handle video upload
    function handleVideoUpload(cardId, input) {
        const file = input.files[0];
        if (!file) return;
        
        // Check file type
        if (!file.type.startsWith('video/')) {
            alert('Please select a video file');
            return;
        }
        
        // Show conversion options for non-WebM videos
        if (file.type !== 'video/webm') {
            showVideoConversionDialog(cardId, file);
            return;
        }
        
        // For WebM files, generate thumbnail and upload
        generateVideoThumbnail(file).then(thumbnail => {
            uploadVideoFile(cardId, file, thumbnail);
        }).catch(error => {
            console.error('Thumbnail generation failed:', error);
            // Upload without thumbnail
            uploadVideoFile(cardId, file);
        });
    }
    
    // Show video conversion dialog
    function showVideoConversionDialog(cardId, file) {
        const card = document.getElementById(cardId);
        const contentDiv = card.querySelector('.card-content');
        
        // Calculate file size in MB
        const fileSizeMB = (file.size / (1024 * 1024)).toFixed(1);
        
        contentDiv.innerHTML = `
            <div class="text-center py-4">
                <div class="mb-3">
                    <i class="ti ti-movie text-muted" style="font-size: 3rem;"></i>
                </div>
                <h5>Video Optimization Recommended</h5>
                <p class="text-muted mb-3">
                    Your video is ${fileSizeMB}MB and in ${file.type} format.<br>
                    Converting to WebM will reduce file size and improve loading speed.
                </p>
                <div class="mb-3">
                    <label class="form-label">Video Quality:</label>
                    <select id="videoQuality-${cardId}" class="form-select form-select-sm" style="max-width: 200px; margin: 0 auto;">
                        <option value="low">Low (< 5MB)</option>
                        <option value="medium" selected>Medium (< 10MB)</option>
                        <option value="high">High (Original)</option>
                    </select>
                </div>
                <div class="d-flex gap-2 justify-content-center">
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="convertAndUploadVideo('${cardId}', this)"
                            data-file-index="0">
                        <i class="ti ti-transform"></i> Convert & Upload
                    </button>
                    <button type="button" 
                            class="btn btn-outline-secondary"
                            onclick="const contentDiv = document.getElementById('${cardId}').querySelector('.card-content'); uploadVideoFile('${cardId}', contentDiv.files[0])">
                        Upload Original
                    </button>
                </div>
                <p class="text-sm text-muted mt-3">
                    Note: Conversion happens in your browser for privacy.
                </p>
            </div>
        `;
        
        // Store the file reference
        contentDiv.files = [file];
    }
    
    // Convert video to WebM using browser APIs
    async function convertAndUploadVideo(cardId, button) {
        const card = document.getElementById(cardId);
        const contentDiv = card.querySelector('.card-content');
        const file = contentDiv.files[0];
        const qualitySelect = document.getElementById(`videoQuality-${cardId}`);
        const quality = qualitySelect ? qualitySelect.value : 'medium';
        
        if (!file) return;
        
        // Show conversion progress
        contentDiv.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary mb-3" role="status">
                    <span class="visually-hidden">Converting...</span>
                </div>
                <p class="mt-2">Converting to WebM (${quality} quality)...</p>
                <div class="progress mt-3" style="max-width: 300px; margin: 0 auto;">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" 
                         role="progressbar" 
                         style="width: 0%"
                         id="conversionProgress">0%</div>
                </div>
                <p class="text-sm text-muted mt-2">This may take a few moments...</p>
            </div>
        `;
        
        try {
            // Convert using video element and MediaRecorder API
            const webmBlob = await convertVideoToWebM(file, quality, (progress) => {
                const progressBar = document.getElementById('conversionProgress');
                if (progressBar) {
                    progressBar.style.width = progress + '%';
                    progressBar.textContent = progress + '%';
                }
            });
            
            // Create a new File object from the blob
            const webmFile = new File([webmBlob], file.name.replace(/\.[^/.]+$/, '.webm'), {
                type: 'video/webm'
            });
            
            // Generate thumbnail from video
            const thumbnail = await generateVideoThumbnail(file);
            
            // Upload the converted file with thumbnail
            uploadVideoFile(cardId, webmFile, thumbnail);
            
        } catch (error) {
            console.error('Video conversion error:', error);
            alert('Failed to convert video. Please try uploading a smaller file or use an external converter.');
            refreshCard(cardId);
        }
    }
    
    // Generate thumbnail from video
    async function generateVideoThumbnail(videoFile) {
        return new Promise((resolve, reject) => {
            const video = document.createElement('video');
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            
            video.src = URL.createObjectURL(videoFile);
            video.muted = true;
            
            video.addEventListener('loadedmetadata', () => {
                // Seek to 10% of the video duration for a better thumbnail
                video.currentTime = video.duration * 0.1;
            });
            
            video.addEventListener('seeked', () => {
                // Set canvas size to video dimensions (max 1280px wide)
                const maxWidth = 1280;
                if (video.videoWidth > maxWidth) {
                    canvas.width = maxWidth;
                    canvas.height = Math.round(maxWidth * (video.videoHeight / video.videoWidth));
                } else {
                    canvas.width = video.videoWidth;
                    canvas.height = video.videoHeight;
                }
                
                // Draw the current frame
                ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
                
                // Convert to blob
                canvas.toBlob((blob) => {
                    URL.revokeObjectURL(video.src);
                    resolve(blob);
                }, 'image/jpeg', 0.8);
            });
            
            video.addEventListener('error', () => {
                URL.revokeObjectURL(video.src);
                reject(new Error('Failed to load video for thumbnail'));
            });
        });
    }
    
    // Convert video to WebM using MediaRecorder
    async function convertVideoToWebM(file, quality, onProgress) {
        return new Promise((resolve, reject) => {
            const video = document.createElement('video');
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            
            video.src = URL.createObjectURL(file);
            video.muted = true;
            
            video.addEventListener('loadedmetadata', async () => {
                // Set resolution based on quality
                let maxWidth, bitrate, fps;
                switch(quality) {
                    case 'low':
                        maxWidth = 640;
                        bitrate = 250000; // 250 Kbps
                        fps = 24;
                        break;
                    case 'medium':
                        maxWidth = 854; // 480p width
                        bitrate = 500000; // 500 Kbps
                        fps = 30;
                        break;
                    case 'high':
                        maxWidth = 1280;
                        bitrate = 1000000; // 1 Mbps
                        fps = 30;
                        break;
                    default:
                        maxWidth = 854;
                        bitrate = 500000;
                        fps = 30;
                }
                
                canvas.width = Math.min(video.videoWidth, maxWidth);
                canvas.height = Math.round(canvas.width * (video.videoHeight / video.videoWidth));
                
                const stream = canvas.captureStream(fps);
                
                // Add audio if present (only for medium/high quality)
                if (quality !== 'low') {
                    try {
                        const audioContext = new AudioContext();
                        const source = audioContext.createMediaElementSource(video);
                        const destination = audioContext.createMediaStreamDestination();
                        source.connect(destination);
                        
                        if (destination.stream.getAudioTracks().length > 0) {
                            stream.addTrack(destination.stream.getAudioTracks()[0]);
                        }
                    } catch (e) {
                        console.log('No audio track or audio processing failed');
                    }
                }
                
                const mediaRecorder = new MediaRecorder(stream, {
                    mimeType: 'video/webm;codecs=vp9',
                    videoBitsPerSecond: bitrate
                });
                
                const chunks = [];
                
                mediaRecorder.ondataavailable = (e) => {
                    if (e.data.size > 0) {
                        chunks.push(e.data);
                    }
                };
                
                mediaRecorder.onstop = () => {
                    const blob = new Blob(chunks, { type: 'video/webm' });
                    URL.revokeObjectURL(video.src);
                    resolve(blob);
                };
                
                mediaRecorder.onerror = (e) => {
                    URL.revokeObjectURL(video.src);
                    reject(e);
                };
                
                // Start recording
                mediaRecorder.start();
                video.play();
                
                // Draw video frames to canvas
                const drawFrame = () => {
                    if (!video.paused && !video.ended) {
                        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
                        
                        // Update progress
                        const progress = Math.round((video.currentTime / video.duration) * 100);
                        onProgress(progress);
                        
                        requestAnimationFrame(drawFrame);
                    } else {
                        mediaRecorder.stop();
                    }
                };
                
                video.addEventListener('play', drawFrame);
            });
            
            video.addEventListener('error', () => {
                URL.revokeObjectURL(video.src);
                reject(new Error('Failed to load video'));
            });
        });
    }
    
    // Upload video file
    function uploadVideoFile(cardId, file, thumbnailBlob) {
        // Check file size - reduced due to server limits
        const maxSize = 5 * 1024 * 1024; // 5MB in bytes
        if (file.size > maxSize) {
            // Show alternative options
            const card = document.getElementById(cardId);
            const contentDiv = card.querySelector('.card-content');
            contentDiv.innerHTML = `
                <div class="text-center py-4">
                    <div class="mb-3">
                        <i class="ti ti-alert-circle text-warning" style="font-size: 3rem;"></i>
                    </div>
                    <h5>Video Too Large</h5>
                    <p class="text-muted mb-3">
                        Your video is ${(file.size / (1024 * 1024)).toFixed(1)}MB, but the server limit is 5MB.
                    </p>
                    <div class="alert alert-info text-start">
                        <p class="mb-2"><strong>Try these options:</strong></p>
                        <ul class="mb-0">
                            <li>Use "Low" quality setting when converting</li>
                            <li>Upload a shorter video clip (under 30 seconds)</li>
                            <li>Use external hosting (YouTube, Vimeo) with Embed card</li>
                            <li>Or paste a video URL instead of uploading</li>
                        </ul>
                    </div>
                    <div class="mt-3">
                        <button type="button" 
                                class="btn btn-primary"
                                onclick="refreshCard('${cardId}')">
                            Try Again
                        </button>
                        <button type="button" 
                                class="btn btn-outline-secondary"
                                onclick="showVideoUrlInput('${cardId}')">
                            Use Video URL
                        </button>
                    </div>
                </div>
            `;
            return;
        }
        
        // Show loading state
        const card = document.getElementById(cardId);
        const contentDiv = card.querySelector('.card-content');
        contentDiv.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Uploading...</span>
                </div>
                <p class="mt-2">Uploading video and thumbnail...</p>
                <p class="text-sm text-muted">This may take a moment...</p>
            </div>
        `;
        
        // Create FormData
        const formData = new FormData();
        formData.append('file', file);
        formData.append('type', 'video');
        
        // Add thumbnail if provided
        if (thumbnailBlob) {
            const thumbnailFile = new File([thumbnailBlob], 
                file.name.replace(/\.[^/.]+$/, '_thumbnail.jpg'), 
                { type: 'image/jpeg' }
            );
            formData.append('thumbnail', thumbnailFile);
        }
        
        // Upload video
        fetch('/ghost/admin/ajax/upload-video.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success || data.SUCCESS) {
                // Update card data
                const cardData = contentCards.find(c => c.id === cardId);
                if (cardData) {
                    cardData.data.src = data.url || data.URL;
                    cardData.data.duration = data.duration || data.DURATION || 0;
                    cardData.data.thumbnail = data.thumbnailUrl || data.THUMBNAILURL || '';
                    
                    // Refresh card display
                    refreshCard(cardId);
                    markDirtySafe();
                }
            } else {
                alert('Failed to upload video: ' + (data.message || data.MESSAGE || 'Unknown error'));
                // Reset card
                refreshCard(cardId);
            }
        })
        .catch(error => {
            console.error('Video upload error:', error);
            alert('Failed to upload video');
            refreshCard(cardId);
        });
    }
    
    // Handle video replacement
    function handleVideoReplace(cardId, input) {
        // Same as upload but preserves caption
        const card = contentCards.find(c => c.id === cardId);
        const caption = card?.data?.caption || '';
        
        handleVideoUpload(cardId, input);
        
        // Restore caption after upload
        setTimeout(() => {
            const updatedCard = contentCards.find(c => c.id === cardId);
            if (updatedCard && updatedCard.data.src) {
                updatedCard.data.caption = caption;
            }
        }, 100);
    }
    
    // Show video URL input
    function showVideoUrlInput(cardId) {
        const card = document.getElementById(cardId);
        const contentDiv = card.querySelector('.card-content');
        
        contentDiv.innerHTML = `
            <div class="text-center py-4">
                <div class="mb-3">
                    <i class="ti ti-link text-primary" style="font-size: 3rem;"></i>
                </div>
                <h5>Add Video URL</h5>
                <p class="text-muted mb-3">
                    Paste a direct link to a video file (.mp4, .webm, etc.)
                </p>
                <div class="mb-3">
                    <input type="url" 
                           class="form-control" 
                           id="videoUrl-${cardId}"
                           placeholder="https://example.com/video.mp4"
                           onkeypress="if(event.key === 'Enter') setVideoUrl('${cardId}')">
                </div>
                <div class="d-flex gap-2 justify-content-center">
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="setVideoUrl('${cardId}')">
                        Add Video
                    </button>
                    <button type="button" 
                            class="btn btn-outline-secondary"
                            onclick="refreshCard('${cardId}')">
                        Cancel
                    </button>
                </div>
                <p class="text-sm text-muted mt-3">
                    Note: Make sure you have permission to use the video.
                </p>
            </div>
        `;
        
        // Focus the input
        setTimeout(() => {
            document.getElementById(`videoUrl-${cardId}`)?.focus();
        }, 100);
    }
    
    // Set video URL
    function setVideoUrl(cardId) {
        const urlInput = document.getElementById(`videoUrl-${cardId}`);
        const url = urlInput?.value?.trim();
        
        if (!url) {
            alert('Please enter a video URL');
            return;
        }
        
        // Basic URL validation
        try {
            new URL(url);
        } catch (e) {
            alert('Please enter a valid URL');
            return;
        }
        
        // Update card data
        const cardData = contentCards.find(c => c.id === cardId);
        if (cardData) {
            cardData.data.src = url;
            
            // Try to generate thumbnail if it's a direct video URL
            if (url.match(/\.(mp4|webm|ogg|mov)$/i)) {
                generateVideoThumbnail({ src: url })
                    .then(thumbnail => {
                        // Convert blob to data URL for display
                        const reader = new FileReader();
                        reader.onloadend = () => {
                            cardData.data.thumbnail = reader.result;
                            refreshCard(cardId);
                        };
                        reader.readAsDataURL(thumbnail);
                    })
                    .catch(() => {
                        // If thumbnail fails, just show video
                        refreshCard(cardId);
                    });
            } else {
                refreshCard(cardId);
            }
            
            markDirtySafe();
        }
    }
    
    function removeFeatureImage() {
        // Create a small inline confirmation
        const container = document.getElementById('featureImageContainer');
        const preview = container.querySelector('.feature-image-preview');
        
        // Check if confirmation already exists
        if (preview.querySelector('.image-remove-confirm')) {
            return;
        }
        
        // Create confirmation overlay
        const confirmDiv = document.createElement('div');
        confirmDiv.className = 'image-remove-confirm absolute inset-0 bg-black bg-opacity-75 rounded flex items-center justify-center';
        confirmDiv.innerHTML = `
            <div class="text-center">
                <p class="text-white mb-4">Remove feature image?</p>
                <div class="flex gap-2 justify-center">
                    <button type="button" 
                            class="btn btn-sm btn-light" 
                            onclick="cancelRemoveImage()">
                        Cancel
                    </button>
                    <button type="button" 
                            class="btn btn-sm btn-danger" 
                            onclick="executeRemoveImage()">
                        Remove
                    </button>
                </div>
            </div>
        `;
        
        preview.appendChild(confirmDiv);
    }
    
    function cancelRemoveImage() {
        const confirmDiv = document.querySelector('.image-remove-confirm');
        if (confirmDiv) {
            confirmDiv.remove();
        }
    }
    
    function executeRemoveImage() {
        const container = document.getElementById('featureImageContainer');
        container.innerHTML = `
            <div class="feature-image-placeholder">
                <i class="ti ti-photo-plus text-4xl text-gray-400 mb-2"></i>
                <p class="text-gray-600">Add feature image</p>
                <p class="text-sm text-gray-500">Click to upload or drag and drop</p>
            </div>
        `;
        
        postData.feature_image = '';
        markDirtySafe();
    }
    
    // Image handling for content cards
    function selectImage(cardId) {
        document.getElementById('imageInput-' + cardId).click();
    }
    
    // Show image settings panel
    function showImageSettings(cardId) {
        const panel = document.getElementById('imageSettings-' + cardId);
        if (panel) {
            panel.classList.toggle('hidden');
        }
    }
    
    // Hide image settings panel
    function hideImageSettings(cardId) {
        const panel = document.getElementById('imageSettings-' + cardId);
        if (panel) {
            panel.classList.add('hidden');
        }
    }
    
    // Toggle alt text input
    function toggleAltTextInput(cardId) {
        const altInput = document.getElementById('altTextInput-' + cardId);
        const linkInput = document.getElementById('linkInput-' + cardId);
        
        if (altInput) {
            const isHidden = altInput.classList.contains('hidden');
            
            // Hide link input if open
            if (linkInput) {
                linkInput.classList.add('hidden');
            }
            
            // Toggle alt input
            altInput.classList.toggle('hidden');
            
            // Focus input if shown
            if (isHidden) {
                const input = altInput.querySelector('input');
                if (input) {
                    setTimeout(() => {
                        input.focus();
                        input.select();
                    }, 50);
                }
            }
        }
    }
    
    // Toggle link input
    function toggleLinkInput(cardId) {
        const linkInput = document.getElementById('linkInput-' + cardId);
        const altInput = document.getElementById('altTextInput-' + cardId);
        
        if (linkInput) {
            const isHidden = linkInput.classList.contains('hidden');
            
            // Hide alt input if open
            if (altInput) {
                altInput.classList.add('hidden');
            }
            
            // Toggle link input
            linkInput.classList.toggle('hidden');
            
            // Focus input if shown
            if (isHidden) {
                const input = linkInput.querySelector('input');
                if (input) {
                    setTimeout(() => {
                        input.focus();
                        input.select();
                    }, 50);
                }
            }
            
            // Update button active state
            const card = contentCards.find(c => c.id === cardId);
            const linkBtn = document.querySelector(`#imageSettings-${cardId} .ghost-image-btn[onclick*="toggleLinkInput"]`);
            if (linkBtn && card) {
                if (card.data.href) {
                    linkBtn.classList.add('active');
                } else {
                    linkBtn.classList.remove('active');
                }
            }
        }
    }
    
    // Update image width
    function updateImageWidth(cardId, width) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.cardWidth = width;
            
            // Update the card element
            const cardElement = document.getElementById(cardId);
            if (cardElement) {
                cardElement.innerHTML = createCardElement(card).innerHTML;
            }
            
            markDirtySafe();
        }
    }
    
    // Replace image
    function replaceImage(cardId) {
        hideImageSettings(cardId);
        selectImage(cardId);
    }
    
    function uploadImage(cardId, input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            
            // Validate file
            if (!file.type.match('image.*')) {
                showMessage('Please select an image file', 'error');
                return;
            }
            
            if (file.size > 5 * 1024 * 1024) {
                showMessage('Image must be less than 5MB', 'error');
                return;
            }
            
            // Create FormData
            const formData = new FormData();
            formData.append('file', file);
            formData.append('type', 'content');
            
            // Show loading
            showMessage('Uploading image...', 'info');
            
            // Upload image
            fetch('/ghost/admin/ajax/upload-image.cfm', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.text();
            })
            .then(text => {
                console.log('Upload response:', text);
                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('JSON parse error:', e);
                    throw new Error('Server returned invalid response');
                }
            })
            .then(data => {
                if (data.success || data.SUCCESS) {
                    const imageUrl = data.url || data.URL;
                    
                    // Update card data
                    updateCardData(cardId, 'src', imageUrl);
                    
                    // Refresh card display
                    refreshCard(cardId);
                    
                    showMessage('Image uploaded', 'success');
                } else {
                    showMessage(data.message || data.MESSAGE || 'Upload failed', 'error');
                }
            })
            .catch(error => {
                showMessage('Upload failed: ' + error.message, 'error');
            });
        }
    }
    
    // Handle audio upload
    function handleAudioUpload(cardId, input) {
        const file = input.files[0];
        if (!file) return;
        
        // Check file type
        if (!file.type.startsWith('audio/')) {
            alert('Please select an audio file');
            return;
        }
        
        // Check file size
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (file.size > maxSize) {
            const fileSizeMB = (file.size / (1024 * 1024)).toFixed(1);
            const card = document.getElementById(cardId);
            const contentDiv = card.querySelector('.card-content');
            contentDiv.innerHTML = `
                <div class="card-content text-center py-4">
                    <div class="mb-3">
                        <i class="ti ti-alert-circle text-warning" style="font-size: 3rem;"></i>
                    </div>
                    <h5>Audio File Too Large</h5>
                    <p class="text-muted mb-3">
                        Your audio file is ${fileSizeMB}MB, but the limit is 10MB.
                    </p>
                    <div class="alert alert-info text-start">
                        <strong>Options:</strong><br>
                        • Use an audio compression tool to reduce file size<br>
                        • Upload to a service like SoundCloud and embed the link<br>
                        • Convert to a lower bitrate MP3<br>
                        • Split into smaller segments if it's a long recording
                    </div>
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="document.getElementById('audio-upload-${cardId}').click()">
                        <i class="ti ti-upload"></i> Try Different File
                    </button>
                    <input type="file" 
                           id="audio-upload-${cardId}" 
                           accept="audio/*" 
                           style="display: none;"
                           onchange="handleAudioUpload('${cardId}', this)">
                </div>
            `;
            return;
        }
        
        // Show loading state
        const card = document.getElementById(cardId);
        const contentDiv = card.querySelector('.card-content');
        contentDiv.innerHTML = `
            <div class="text-center py-4">
                <div class="spinner-border text-primary" role="status">
                    <span class="sr-only">Uploading...</span>
                </div>
                <div class="mt-2">Uploading audio...</div>
            </div>
        `;
        
        // Create FormData
        const formData = new FormData();
        formData.append('file', file);
        
        // Upload audio
        fetch('/ghost/admin/ajax/upload-audio.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.text();
        })
        .then(text => {
            console.log('Audio upload response:', text);
            try {
                return JSON.parse(text);
            } catch (e) {
                console.error('JSON parse error:', e);
                throw new Error('Server returned invalid response');
            }
        })
        .then(data => {
            if (data.success || data.SUCCESS) {
                // Update card data
                const audioCard = contentCards.find(c => c.id === cardId);
                if (audioCard) {
                    audioCard.data.src = data.url || data.URL;
                    audioCard.data.duration = data.duration || data.DURATION || 0;
                    refreshCard(cardId);
                    markDirtySafe();
                }
            } else {
                throw new Error(data.message || data.MESSAGE || 'Upload failed');
            }
        })
        .catch(error => {
            console.error('Audio upload error:', error);
            
            // Handle specific server errors
            let errorMessage = error.message;
            let suggestions = '';
            
            if (error.message.includes('413') || error.message.includes('Content Too Large')) {
                errorMessage = 'File too large for server';
                suggestions = `
                    <div class="alert alert-info text-start mt-3">
                        <strong>Server Upload Limit Reached</strong><br>
                        • Try a smaller audio file (under 5MB)<br>
                        • Use audio compression to reduce file size<br>
                        • Upload to SoundCloud/Spotify and embed the link<br>
                        • Contact administrator to increase server limits
                    </div>
                `;
            } else if (error.message.includes('Server returned invalid response')) {
                errorMessage = 'Server configuration issue';
                suggestions = `
                    <div class="alert alert-warning text-start mt-3">
                        <strong>Server Issue:</strong> The server returned an invalid response.<br>
                        Please contact your administrator to check the server configuration.
                    </div>
                `;
            }
            
            // Show error state
            contentDiv.innerHTML = `
                <div class="card-content text-center py-5">
                    <div class="mb-3">
                        <i class="ti ti-alert-circle text-danger" style="font-size: 3rem;"></i>
                    </div>
                    <div class="alert alert-danger mb-3">
                        Upload Failed: ${errorMessage}
                    </div>
                    ${suggestions}
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="document.getElementById('audio-upload-${cardId}').click()">
                        <i class="ti ti-upload"></i> Try Different File
                    </button>
                    <input type="file" 
                           id="audio-upload-${cardId}" 
                           accept="audio/*" 
                           style="display: none;"
                           onchange="handleAudioUpload('${cardId}', this)">
                </div>
            `;
        });
    }
    
    // Handle audio replacement
    function handleAudioReplace(cardId, input) {
        // Same as upload but preserves title
        const card = contentCards.find(c => c.id === cardId);
        const title = card?.data?.title || '';
        
        handleAudioUpload(cardId, input);
        
        // Restore title after upload
        setTimeout(() => {
            const updatedCard = contentCards.find(c => c.id === cardId);
            if (updatedCard && updatedCard.data.src) {
                updatedCard.data.title = title;
            }
        }, 100);
    }
    
    // Format duration helper
    function formatDuration(seconds) {
        if (!seconds) return '';
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = Math.floor(seconds % 60);
        
        if (hours > 0) {
            return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
        } else {
            return `${minutes}:${secs.toString().padStart(2, '0')}`;
        }
    }
    
    // Save post
    function savePost(status, isAutosave = false) {
        return new Promise((resolve, reject) => {
            saveResolve = resolve;
            saveReject = reject;
            
            // Collect all data
            const title = document.getElementById('postTitle').value;
            const slug = document.getElementById('postSlug').value || generateSlug(title);
            const excerpt = document.getElementById('postExcerpt').value;
            const metaTitle = document.getElementById('metaTitle').value;
            const metaDescription = document.getElementById('metaDescription').value;
            const visibility = document.getElementById('postVisibility').value;
            const featured = document.getElementById('featuredPost').checked;
            const publishDate = document.getElementById('publishDate').value;
        
        // Build HTML content from cards
        let html = '';
        let plaintext = '';
        
        contentCards.forEach(card => {
            switch(card.type) {
                case 'paragraph':
                    html += '<p>' + (card.data.content || '') + '</p>\n';
                    plaintext += (card.data.content || '').replace(/<[^>]*>/g, '') + '\n\n';
                    break;
                case 'heading':
                    const level = card.data.level || 2;
                    html += `<h${level}>` + (card.data.content || '') + `</h${level}>\n`;
                    plaintext += (card.data.content || '').replace(/<[^>]*>/g, '') + '\n\n';
                    break;
                case 'image':
                    if (card.data.src) {
                        // Add appropriate class based on width
                        let figureClass = 'kg-card kg-image-card';
                        if (card.data.cardWidth && card.data.cardWidth !== 'regular') {
                            figureClass += ` kg-width-${card.data.cardWidth}`;
                        }
                        if (card.data.caption) {
                            figureClass += ' kg-card-hascaption';
                        }
                        
                        html += `<figure class="${figureClass}">`;
                        
                        // Wrap in anchor if href is provided
                        if (card.data.href) {
                            html += `<a href="${card.data.href}">`;
                        }
                        
                        html += `<img src="${card.data.src}" alt="${card.data.alt || ''}" class="kg-image" loading="lazy">`;
                        
                        if (card.data.href) {
                            html += '</a>';
                        }
                        
                        if (card.data.caption) {
                            html += `<figcaption>${card.data.caption}</figcaption>`;
                        }
                        html += '</figure>\n';
                    }
                    break;
                case 'html':
                    html += (card.data.content || '') + '\n';
                    break;
                case 'markdown':
                    // In a real implementation, this would convert markdown to HTML
                    html += '<div class="markdown">' + (card.data.content || '') + '</div>\n';
                    plaintext += (card.data.content || '') + '\n\n';
                    break;
                case 'divider':
                    html += '<hr>\n';
                    break;
                case 'button':
                    if (card.data.text && card.data.url) {
                        html += `<div class="button-wrapper"><a href="${card.data.url}" class="btn">${card.data.text}</a></div>\n`;
                    }
                    break;
                case 'callout':
                    const type = card.data.type || 'info';
                    html += `<div class="callout callout-${type}">${card.data.content || ''}</div>\n`;
                    plaintext += (card.data.content || '').replace(/<[^>]*>/g, '') + '\n\n';
                    break;
                case 'toggle':
                    if (card.data.title || card.data.content) {
                        html += `<details>\n`;
                        html += `<summary>${card.data.title || 'Toggle'}</summary>\n`;
                        html += `<div>${card.data.content || ''}</div>\n`;
                        html += `</details>\n`;
                        plaintext += (card.data.title || 'Toggle') + '\n';
                        plaintext += (card.data.content || '').replace(/<[^>]*>/g, '') + '\n\n';
                    }
                    break;
                case 'video':
                    if (card.data.src) {
                        // Add appropriate class based on width
                        let figureClass = 'kg-card kg-video-card';
                        if (card.data.cardWidth && card.data.cardWidth !== 'regular') {
                            figureClass += ` kg-width-${card.data.cardWidth}`;
                        }
                        if (card.data.caption) {
                            figureClass += ' kg-card-hascaption';
                        }
                        
                        html += `<figure class="${figureClass}">`;
                        html += '<div class="kg-video-container">';
                        html += `<video src="${card.data.src}" controls preload="metadata"`;
                        if (card.data.loop) {
                            html += ' loop autoplay muted playsinline';
                        }
                        html += '></video>';
                        html += '</div>';
                        
                        if (card.data.caption) {
                            html += `<figcaption>${card.data.caption}</figcaption>`;
                        }
                        html += '</figure>\n';
                        
                        if (card.data.caption) {
                            plaintext += card.data.caption + '\n\n';
                        }
                    }
                    break;
                case 'audio':
                    if (card.data.src) {
                        html += `<div class="kg-card kg-audio-card">`;
                        html += `<audio src="${card.data.src}" controls preload="metadata"></audio>`;
                        if (card.data.title) {
                            html += `<div class="kg-audio-title">${card.data.title}</div>`;
                        }
                        html += `</div>\n`;
                        
                        if (card.data.title) {
                            plaintext += card.data.title + '\n\n';
                        }
                    }
                    break;
            }
        });
        
        // Prepare form data
        document.getElementById('formTitle').value = title;
        document.getElementById('formContent').value = html;
        document.getElementById('formPlaintext').value = plaintext.trim();
        document.getElementById('formFeatureImage').value = postData.feature_image || '';
        document.getElementById('formSlug').value = slug;
        document.getElementById('formExcerpt').value = excerpt;
        document.getElementById('formMetaTitle').value = metaTitle;
        document.getElementById('formMetaDescription').value = metaDescription;
        document.getElementById('formVisibility').value = visibility;
        document.getElementById('formFeatured').value = featured ? '1' : '0';
        document.getElementById('formPublishedAt').value = publishDate;
        document.getElementById('formTags').value = JSON.stringify(selectedTags);
        document.getElementById('formStatus').value = status;
        
        // Get form data
        const formData = new FormData(document.getElementById('postForm'));
        
        // Send AJAX request
        fetch('/ghost/admin/ajax/save-post.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success || data.SUCCESS) {
                isDirty = false;
                
                // Show appropriate status based on post type
                if (originalStatus !== 'published' && status !== 'published') {
                    // For draft posts, show "Saved"
                    document.getElementById('saveStatus').textContent = 'Saved';
                    document.getElementById('saveStatus').className = 'text-sm text-green-600';
                } else {
                    // For published posts, clear the status (remove "Unsaved changes")
                    document.getElementById('saveStatus').textContent = '';
                    document.getElementById('saveStatus').className = '';
                }
                
                // Update post data with returned values
                if (data.postId || data.POSTID) {
                    postData.id = data.postId || data.POSTID;
                    postId = postData.id;
                    // Update URL if this was a new post
                    if (window.location.pathname.includes('/new')) {
                        window.history.replaceState({}, '', '/ghost/admin/post/edit/' + postId);
                    }
                }
                
                // Update status display
                if (data.status || data.STATUS) {
                    const returnedStatus = (data.status || data.STATUS || '').toLowerCase();
                    // Status badge is static server-side rendered, would need page refresh to update
                    // For now, just track the status internally
                    originalStatus = returnedStatus;
                }
                
                if (!isAutosave) {
                    if (status === 'published') {
                        showMessage('Post published successfully', 'success');
                        setTimeout(() => {
                            window.location.href = '/ghost/admin/posts';
                        }, 1000);
                    } else {
                        showMessage('Post saved', 'success');
                    }
                }
                
                // Show autosave indicator only for draft posts
                if (isAutosave && originalStatus !== 'published') {
                    showQuickSave();
                }
                
                // Resolve promise
                if (saveResolve) {
                    saveResolve(data);
                    saveResolve = null;
                    saveReject = null;
                }
            } else {
                showMessage(data.message || data.MESSAGE || 'Save failed', 'error');
                
                // Reject promise
                if (saveReject) {
                    saveReject(new Error(data.message || data.MESSAGE || 'Save failed'));
                    saveResolve = null;
                    saveReject = null;
                }
            }
        })
        .catch(error => {
            showMessage('Save failed: ' + error.message, 'error');
            
            // Reject promise
            if (saveReject) {
                saveReject(error);
                saveResolve = null;
                saveReject = null;
            }
        });
        });
    }
    
    // Publish post
    function publishPost() {
        showPublishModal();
    }
    
    // Show publish confirmation modal
    function showPublishModal() {
        // Create modal backdrop
        const backdrop = document.createElement('div');
        backdrop.className = 'fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center';
        backdrop.id = 'publishModalBackdrop';
        
        // Create modal
        const modal = document.createElement('div');
        modal.className = 'bg-white rounded-lg shadow-xl max-w-sm w-full mx-4 transform transition-all border-2 border-gray-200';
        modal.innerHTML = `
            <div class="p-5">
                <div class="flex items-center justify-center w-10 h-10 mx-auto bg-green-100 rounded-full mb-3">
                    <i class="ti ti-send text-green-600 text-lg"></i>
                </div>
                <h3 class="text-base font-semibold text-center text-gray-900 mb-2">Ready to publish?</h3>
                <p class="text-sm text-gray-600 text-center mb-4">
                    Publishing will make this post visible to your audience.
                </p>
                <div class="flex gap-2">
                    <button type="button" 
                            class="flex-1 btn btn-sm btn-outline-secondary" 
                            onclick="closePublishModal()">
                        Cancel
                    </button>
                    <button type="button" 
                            class="flex-1 btn btn-sm btn-primary" 
                            onclick="executePublish()">
                        <i class="ti ti-send me-1"></i>
                        Publish now
                    </button>
                </div>
            </div>
        `;
        
        backdrop.appendChild(modal);
        document.body.appendChild(backdrop);
        
        // Animate in
        setTimeout(() => {
            modal.style.transform = 'scale(1)';
            modal.style.opacity = '1';
        }, 10);
        
        // Close on backdrop click
        backdrop.addEventListener('click', function(e) {
            if (e.target === backdrop) {
                closePublishModal();
            }
        });
    }
    
    // Close publish modal
    function closePublishModal() {
        const backdrop = document.getElementById('publishModalBackdrop');
        if (backdrop) {
            backdrop.remove();
        }
    }
    
    // Execute publish
    function executePublish() {
        closePublishModal();
        savePost('published');
    }
    
    // Update post
    function updatePost() {
        // Keep the original status for published posts
        console.log('updatePost called, originalStatus:', originalStatus);
        const statusToSave = originalStatus === 'published' ? 'published' : 'draft';
        console.log('Saving with status:', statusToSave);
        savePost(statusToSave);
    }
    
    // Preview post
    function previewPost() {
        // Save draft first
        savePost('draft', true);
        
        // Open preview in new window
        window.open('/ghost/preview/' + postData.id, '_blank');
    }
    
    // Delete post
    function confirmDeletePost() {
        // Show custom delete modal
        showDeleteModal();
    }
    
    // Show delete confirmation modal
    function showDeleteModal() {
        // Create modal backdrop
        const backdrop = document.createElement('div');
        backdrop.className = 'fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center';
        backdrop.id = 'deleteModalBackdrop';
        
        // Create modal
        const modal = document.createElement('div');
        modal.className = 'bg-white rounded-lg shadow-xl max-w-sm w-full mx-4 transform transition-all border-2 border-gray-200';
        modal.innerHTML = `
            <div class="p-5">
                <div class="flex items-center justify-center w-10 h-10 mx-auto bg-red-100 rounded-full mb-3">
                    <i class="ti ti-trash text-red-600 text-lg"></i>
                </div>
                <h3 class="text-base font-semibold text-center text-gray-900 mb-2">Delete Post</h3>
                <p class="text-sm text-gray-600 text-center mb-4">
                    Are you sure you want to delete this post? This action cannot be undone.
                </p>
                <div class="flex gap-2">
                    <button type="button" 
                            class="flex-1 btn btn-sm btn-outline-secondary" 
                            onclick="closeDeleteModal()">
                        Cancel
                    </button>
                    <button type="button" 
                            class="flex-1 btn btn-sm btn-danger" 
                            onclick="deletePost()">
                        <i class="ti ti-trash me-1"></i>
                        Delete
                    </button>
                </div>
            </div>
        `;
        
        backdrop.appendChild(modal);
        document.body.appendChild(backdrop);
        
        // Animate in
        setTimeout(() => {
            modal.style.transform = 'scale(1)';
            modal.style.opacity = '1';
        }, 10);
        
        // Close on backdrop click
        backdrop.addEventListener('click', function(e) {
            if (e.target === backdrop) {
                closeDeleteModal();
            }
        });
    }
    
    // Close delete modal
    function closeDeleteModal() {
        const backdrop = document.getElementById('deleteModalBackdrop');
        if (backdrop) {
            backdrop.remove();
        }
    }
    
    // Actually delete the post
    function deletePost() {
        // Close modal first
        closeDeleteModal();
        
        // Show loading message
        showMessage('Deleting post...', 'info');
        
        // Send delete request
        fetch('/ghost/admin/ajax/delete-post.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'postId=' + encodeURIComponent(postData.id)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success || data.SUCCESS) {
                showMessage('Post deleted', 'success');
                setTimeout(() => {
                    window.location.href = '/ghost/admin/posts';
                }, 1000);
            } else {
                showMessage(data.message || data.MESSAGE || 'Delete failed', 'error');
            }
        })
        .catch(error => {
            showMessage('Delete failed: ' + error.message, 'error');
        });
    }
    
    // Global variable for currently focused element
    let currentFocusedElement = null;
    let currentHoveredLink = null;
    let linkHoverTimeout = null;
    
    // Text selection and formatting functions
    function checkTextSelection() {
        const selection = window.getSelection();
        const popup = document.getElementById('formattingPopup');
        
        if (selection.toString().length > 0 && selection.rangeCount > 0) {
            // Store the currently focused element
            const focusedEl = document.activeElement;
            if (focusedEl && focusedEl.classList.contains('card-content')) {
                currentFocusedElement = focusedEl;
            }
            
            // Show popup
            const range = selection.getRangeAt(0);
            const rect = range.getBoundingClientRect();
            
            // Position popup above selection
            popup.style.left = `${rect.left + (rect.width / 2) - 150}px`; // Center popup
            popup.style.top = `${rect.top - 50}px`; // Above selection
            
            // Ensure popup stays within viewport
            const popupRect = popup.getBoundingClientRect();
            if (popupRect.left < 10) {
                popup.style.left = '10px';
            }
            if (popupRect.right > window.innerWidth - 10) {
                popup.style.left = `${window.innerWidth - popupRect.width - 10}px`;
            }
            
            popup.classList.add('show');
            
            // Update active states
            updateToolbarStates(popup);
        } else {
            // Hide popup
            popup.classList.remove('show');
        }
    }
    
    function updateToolbarStates(toolbar) {
        const buttons = toolbar.querySelectorAll('.format-btn');
        buttons.forEach(btn => {
            const command = btn.getAttribute('data-command');
            if (command && document.queryCommandState(command)) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
    }
    
    function formatHeading(tag) {
        if (!tag || !currentFocusedElement) return;
        
        currentFocusedElement.focus();
        
        const selection = window.getSelection();
        if (!selection.rangeCount) return;
        
        const range = selection.getRangeAt(0);
        let container = range.commonAncestorContainer;
        
        // Get the contenteditable container
        if (container.nodeType === Node.TEXT_NODE) {
            container = container.parentElement;
        }
        
        // Get the current block element
        let blockElement = container;
        while (blockElement && blockElement !== currentFocusedElement && !['P', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'DIV'].includes(blockElement.tagName)) {
            blockElement = blockElement.parentElement;
        }
        
        if (!blockElement || blockElement === currentFocusedElement) {
            // If no block element found, wrap the selection
            const wrapper = document.createElement(tag);
            try {
                range.surroundContents(wrapper);
            } catch (e) {
                // If surroundContents fails, use insertHTML
                const html = selection.toString();
                document.execCommand('insertHTML', false, `<${tag}>${html}</${tag}>`);
            }
        } else {
            // Create new element with the same content
            const newElement = document.createElement(tag);
            newElement.innerHTML = blockElement.innerHTML;
            
            // Replace the old element
            blockElement.parentNode.replaceChild(newElement, blockElement);
            
            // Restore cursor position
            const newRange = document.createRange();
            newRange.selectNodeContents(newElement);
            newRange.collapse(false);
            selection.removeAllRanges();
            selection.addRange(newRange);
        }
        
        // Update the card content
        const cardContent = currentFocusedElement;
        const cardId = cardContent.id.replace('content-', '');
        updateCard(cardId, cardContent.innerHTML);
        markDirtySafe();
    }
    
    function formatText(command) {
        if (!currentFocusedElement) return;
        
        currentFocusedElement.focus();
        
        if (command === 'code') {
            // Wrap selection in code tags
            const selection = window.getSelection();
            if (selection.toString()) {
                document.execCommand('insertHTML', false, `<code>${selection.toString()}</code>`);
            }
        } else if (command === 'strikethrough') {
            document.execCommand('strikeThrough', false, null);
        } else {
            document.execCommand(command, false, null);
        }
        
        // Get card ID from element
        const cardId = currentFocusedElement.id.replace('content-', '');
        markDirtySafe();
        updateCard(cardId, currentFocusedElement.innerHTML);
        
        // Keep selection and popup visible
        setTimeout(() => checkTextSelection(), 10);
    }
    
    // Link editor functions
    let currentSelection = null;
    let currentRange = null;
    
    function showLinkEditor() {
        if (!currentFocusedElement) return;
        
        const selection = window.getSelection();
        const selectedText = selection.toString();
        
        if (!selectedText) {
            showMessage('Please select some text first', 'error');
            return;
        }
        
        // Store current selection
        currentSelection = selection;
        currentRange = selection.getRangeAt(0);
        
        // Hide formatting popup
        document.getElementById('formattingPopup').classList.remove('show');
        
        // Position link editor
        const linkEditor = document.getElementById('linkEditorPopup');
        const rect = currentRange.getBoundingClientRect();
        
        linkEditor.style.left = `${rect.left}px`;
        linkEditor.style.top = `${rect.bottom + 10}px`;
        
        // Check if selected text is already a link
        const parentLink = selection.anchorNode.parentElement.closest('a');
        const linkInput = document.getElementById('linkUrlInput');
        
        if (parentLink) {
            linkInput.value = parentLink.href;
        } else {
            linkInput.value = '';
        }
        
        // Show link editor
        linkEditor.classList.add('show');
        linkInput.focus();
        linkInput.select();
    }
    
    function applyLink() {
        const url = document.getElementById('linkUrlInput').value;
        
        if (!url) {
            showMessage('Please enter a URL', 'error');
            return;
        }
        
        // Restore selection
        if (currentRange) {
            const selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(currentRange);
        }
        
        // Apply link
        currentFocusedElement.focus();
        document.execCommand('createLink', false, url);
        
        
        const cardId = currentFocusedElement.id.replace('content-', '');
        markDirtySafe();
        updateCard(cardId, currentFocusedElement.innerHTML);
        
        closeLinkEditor();
    }
    
    function removeLink() {
        if (currentRange) {
            const selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(currentRange);
        }
        
        currentFocusedElement.focus();
        document.execCommand('unlink', false, null);
        
        const cardId = currentFocusedElement.id.replace('content-', '');
        markDirtySafe();
        updateCard(cardId, currentFocusedElement.innerHTML);
        
        closeLinkEditor();
    }
    
    function closeLinkEditor() {
        document.getElementById('linkEditorPopup').classList.remove('show');
        document.getElementById('linkUrlInput').value = '';
        currentSelection = null;
        currentRange = null;
    }
    
    // Open link in new tab
    function openLinkInNewTab() {
        if (!currentHoveredLink) return;
        window.open(currentHoveredLink.href, '_blank');
        hideLinkHoverMenu();
    }
    
    function handleLinkInputKeyup(event) {
        if (event.key === 'Enter') {
            applyLink();
        } else if (event.key === 'Escape') {
            closeLinkEditor();
        }
    }
    
    // Handle keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        console.log('Keydown event:', e.key, 'Active element:', document.activeElement);
        console.log('Current state - isDirty:', isDirty, 'isInitializing:', isInitializing);
        
        const activeElement = document.activeElement;
        
        // Find the card element - could be the activeElement itself or its closest parent
        let cardElement = null;
        let cardId = null;
        
        // Check if activeElement is a content-editable card element
        if (activeElement && activeElement.classList.contains('card-content') && activeElement.id.startsWith('content-')) {
            cardElement = activeElement;
            cardId = activeElement.id.replace('content-', '');
            console.log('Found contenteditable card:', cardId);
        }
        // Check if activeElement is inside a card (look for card with id starting with 'card-')
        else if (activeElement) {
            const parentCard = activeElement.closest('[id^="card-"]');
            if (parentCard) {
                cardElement = parentCard;
                cardId = parentCard.id;
                console.log('Found parent card:', cardId);
            }
        }
        
        console.log('Card detection result:', { cardElement, cardId });
        
        // Special case: if no card is focused but we pressed delete/backspace, 
        // try to find and delete empty cards more aggressively
        if (!cardElement && (e.key === 'Backspace' || e.key === 'Delete')) {
            console.log('No card focused, looking for empty cards to delete');
            
            // Find all truly empty cards
            const emptyCards = contentCards.filter(card => {
                const element = document.getElementById(`content-${card.id}`);
                if (!element) return false;
                
                const content = element.textContent || element.innerText || '';
                const innerHTML = element.innerHTML || '';
                const cleanContent = content.replace(/\s/g, '').replace(/\u00A0/g, '');
                const cleanHTML = innerHTML.replace(/<br\s*\/?>/gi, '').replace(/&nbsp;/g, '').trim();
                
                console.log(`Card ${card.id}: content="${content}", cleanContent="${cleanContent}", cleanHTML="${cleanHTML}"`);
                
                return cleanContent === '' && (cleanHTML === '' || cleanHTML === '<br>' || cleanHTML === '<br/>' || cleanHTML === '<br />');
            });
            
            console.log('Found empty cards:', emptyCards.length);
            
            // If we have empty cards and more than one card total, delete the first empty one
            if (emptyCards.length > 0 && contentCards.length > 1) {
                console.log('Deleting first empty card:', emptyCards[0].id);
                e.preventDefault();
                deleteCardDirectly(emptyCards[0].id);
                return;
            }
        }
        
        if (cardElement && cardId) {
            // Handle card deletion with Backspace or Delete
            if ((e.key === 'Backspace' || e.key === 'Delete') && !e.ctrlKey && !e.metaKey) {
                
                // For contenteditable elements, check if they're empty or cursor is at specific positions
                if (activeElement.contentEditable === 'true') {
                    const content = activeElement.textContent || activeElement.innerText || '';
                    const innerHTML = activeElement.innerHTML || '';
                    const selection = window.getSelection();
                    
                    // Debug logging
                    console.log('Delete key pressed on contenteditable:', e.key);
                    console.log('CardId:', cardId);
                    console.log('Content:', content);
                    console.log('Content trimmed:', content.trim());
                    console.log('InnerHTML:', innerHTML);
                    
                    // Check if content is effectively empty (including <br> tags and &nbsp;)
                    const cleanContent = content.replace(/\s/g, '').replace(/\u00A0/g, ''); // Remove all whitespace and &nbsp;
                    const cleanHTML = innerHTML.replace(/<br\s*\/?>/gi, '').replace(/&nbsp;/g, '').trim();
                    
                    console.log('Clean content:', cleanContent);
                    console.log('Clean HTML:', cleanHTML);
                    
                    // Case 1: Delete if content is empty
                    if (cleanContent === '' || cleanHTML === '' || content.trim() === '') {
                        console.log('Deleting empty card:', cardId);
                        e.preventDefault();
                        deleteCardDirectly(cardId);
                        return;
                    }
                    
                    // Also check for common empty content patterns
                    if (innerHTML === '<br>' || innerHTML === '<br/>' || innerHTML === '<br />') {
                        console.log('Deleting card with only br tag:', cardId);
                        e.preventDefault();
                        deleteCardDirectly(cardId);
                        return;
                    }
                    
                    // Case 2: For Ctrl/Cmd + Backspace or Ctrl/Cmd + Delete - show confirmation for card with content
                    if ((e.ctrlKey || e.metaKey) && (e.key === 'Backspace' || e.key === 'Delete')) {
                        console.log('Ctrl/Cmd + Delete pressed on card with content:', cardId);
                        e.preventDefault();
                        deleteCard(cardId); // Use the regular delete function with confirmation
                        return;
                    }
                    
                    // Case 3: For Backspace at the beginning of content - delete empty card or merge with previous
                    if (e.key === 'Backspace' && selection.rangeCount > 0) {
                        const range = selection.getRangeAt(0);
                        if (range.collapsed && range.startOffset === 0) {
                            // We're at the very beginning - delete empty card or merge with previous
                            if (content.trim() === '') {
                                console.log('Deleting empty card at beginning:', cardId);
                                e.preventDefault();
                                deleteCardDirectly(cardId);
                                return;
                            }
                        }
                    }
                    
                    // Case 4: For Delete at the end of content - delete empty card or merge with next
                    if (e.key === 'Delete' && selection.rangeCount > 0) {
                        const range = selection.getRangeAt(0);
                        if (range.collapsed && range.startOffset >= content.length) {
                            // We're at the very end - delete empty card or merge with next
                            if (content.trim() === '') {
                                console.log('Deleting empty card at end:', cardId);
                                e.preventDefault();
                                deleteCardDirectly(cardId);
                                return;
                            }
                        }
                    }
                }
                // For non-editable cards (like image, video, audio without content), delete them directly
                else {
                    // Check if it's an empty media card or similar
                    const card = contentCards.find(c => c.id === cardId);
                    if (card) {
                        console.log('Delete key pressed on non-editable card:', cardId, card.type);
                        // For image/video/audio cards without content, allow deletion
                        if ((card.type === 'image' && !card.data.src) || 
                            (card.type === 'video' && !card.data.src) || 
                            (card.type === 'audio' && !card.data.src) ||
                            card.type === 'divider') {
                            console.log('Deleting empty media card:', cardId);
                            e.preventDefault();
                            deleteCardDirectly(cardId);
                            return;
                        }
                    }
                }
            }
            
            // Handle formatting shortcuts for contenteditable elements
            if ((e.ctrlKey || e.metaKey) && activeElement.contentEditable === 'true') {
                switch(e.key.toLowerCase()) {
                    case 'b':
                        e.preventDefault();
                        formatText('bold', cardId);
                        break;
                    case 'i':
                        e.preventDefault();
                        formatText('italic', cardId);
                        break;
                    case 'k':
                        e.preventDefault();
                        showLinkEditor();
                        break;
                    case 'u':
                        e.preventDefault();
                        formatText('underline', cardId);
                        break;
                }
            }
        }
    });
    
    // Setup link hover detection
    function setupLinkHoverDetection() {
        // Use event delegation for dynamically created links
        document.addEventListener('mouseover', function(e) {
            const link = e.target.closest('a');
            if (link && link.closest('.card-content')) {
                e.preventDefault(); // Prevent default hover behavior
                e.stopPropagation(); // Stop event bubbling
                showLinkHoverMenu(link);
            }
        });
        
        document.addEventListener('mouseout', function(e) {
            const link = e.target.closest('a');
            if (link && link === currentHoveredLink) {
                // Delay hiding to allow moving to the menu
                linkHoverTimeout = setTimeout(() => {
                    const menu = document.getElementById('linkHoverMenu');
                    if (!menu.matches(':hover')) {
                        hideLinkHoverMenu();
                    }
                }, 300);
            }
        });
        
        // Keep menu open when hovering over it
        const menu = document.getElementById('linkHoverMenu');
        menu.addEventListener('mouseenter', function() {
            if (linkHoverTimeout) {
                clearTimeout(linkHoverTimeout);
            }
        });
        
        menu.addEventListener('mouseleave', function() {
            hideLinkHoverMenu();
        });
    }
    
    // Show link hover menu
    function showLinkHoverMenu(link) {
        currentHoveredLink = link;
        const menu = document.getElementById('linkHoverMenu');
        const urlDisplay = document.getElementById('linkHoverUrl');
        
        // Clear any existing timeout
        if (linkHoverTimeout) {
            clearTimeout(linkHoverTimeout);
        }
        
        // Update URL display
        urlDisplay.textContent = link.href;
        
        // Position the menu above the link (fixed positioning)
        const rect = link.getBoundingClientRect();
        
        menu.style.left = rect.left + 'px';
        menu.style.top = (rect.top - 70) + 'px'; // Position above the link
        
        // Show the menu using inline style instead of class
        menu.style.display = 'block';
        
        // Ensure menu is within viewport
        setTimeout(() => {
            const menuRect = menu.getBoundingClientRect();
            if (menuRect.top < 0) {
                menu.style.top = (rect.bottom + 5) + 'px'; // Show below if no room above
            }
            if (menuRect.left < 0) {
                menu.style.left = '10px';
            }
            if (menuRect.right > window.innerWidth) {
                menu.style.left = (window.innerWidth - menuRect.width - 10) + 'px';
            }
        }, 0);
        
    }
    
    // Hide link hover menu
    function hideLinkHoverMenu() {
        const menu = document.getElementById('linkHoverMenu');
        menu.style.display = 'none';
        // Don't clear currentHoveredLink immediately - let the click handlers use it first
        setTimeout(() => {
            currentHoveredLink = null;
        }, 100);
    }
    
    // Edit existing link
    function editExistingLink() {
        if (!currentHoveredLink) {
            console.error('No link is currently hovered');
            return;
        }
        
        // Store link reference before hiding menu
        const linkToEdit = currentHoveredLink;
        
        // Hide hover menu
        hideLinkHoverMenu();
        
        // Ensure the link still exists in the DOM
        if (!linkToEdit.parentNode) {
            console.error('Link no longer exists in DOM');
            return;
        }
        
        // Select the link
        try {
            const range = document.createRange();
            range.selectNodeContents(linkToEdit);
            const selection = window.getSelection();
            selection.removeAllRanges();
            selection.addRange(range);
            
            // Focus the contenteditable
            const contentEditable = linkToEdit.closest('[contenteditable="true"]');
            if (contentEditable) {
                contentEditable.focus();
                currentFocusedElement = contentEditable;
            }
            
            // Show link editor with the current URL
            const linkUrl = linkToEdit.href || linkToEdit.getAttribute('href');
            showLinkEditor();
            
            // Pre-fill the link input with current URL
            setTimeout(() => {
                const linkInput = document.getElementById('linkUrlInput');
                if (linkInput && linkUrl) {
                    linkInput.value = linkUrl;
                }
            }, 50);
        } catch (error) {
            console.error('Error editing link:', error);
        }
    }
    
    // Remove existing link
    function removeExistingLink() {
        if (!currentHoveredLink) {
            console.error('No link is currently hovered');
            return;
        }
        
        // Store link reference before hiding menu
        const linkToRemove = currentHoveredLink;
        
        // Hide hover menu
        hideLinkHoverMenu();
        
        // Ensure the link still exists in the DOM
        if (!linkToRemove.parentNode) {
            console.error('Link no longer exists in DOM');
            return;
        }
        
        try {
            // Get link text
            const linkText = linkToRemove.textContent;
            
            // Replace link with plain text
            const textNode = document.createTextNode(linkText);
            linkToRemove.parentNode.replaceChild(textNode, linkToRemove);
            
            // Update card content
            const contentEditable = textNode.parentNode.closest('[contenteditable="true"]');
            if (contentEditable) {
                const cardId = contentEditable.id.replace('content-', '');
                updateCard(cardId, contentEditable.innerHTML);
            }
            
            markDirtySafe();
        } catch (error) {
            console.error('Error removing link:', error);
        }
    }
    
    // Open link in new tab
    function openLinkInNewTab() {
        if (currentHoveredLink) {
            window.open(currentHoveredLink.href, '_blank');
        }
    }
    
    // Show message function
    function showMessage(message, type) {
        // Create toast notification
        const toast = document.createElement('div');
        toast.className = 'bg-white rounded-lg shadow-lg p-4 max-w-sm transform transition-all duration-300 translate-x-full border';
        
        if (type === 'success') {
            toast.className += ' border-green-200';
            toast.innerHTML = `
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <i class="ti ti-check-circle text-green-500 text-xl"></i>
                    </div>
                    <div class="ml-3">
                        <p class="text-sm text-gray-700">${message}</p>
                    </div>
                    <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                        <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                    </button>
                </div>
            `;
        } else if (type === 'error') {
            toast.className += ' border-red-200';
            toast.innerHTML = `
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <i class="ti ti-alert-circle text-red-500 text-xl"></i>
                    </div>
                    <div class="ml-3">
                        <p class="text-sm text-gray-700">${message}</p>
                    </div>
                    <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                        <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                    </button>
                </div>
            `;
        } else {
            toast.className += ' border-blue-200';
            toast.innerHTML = `
                <div class="flex items-center">
                    <div class="flex-shrink-0">
                        <i class="ti ti-info-circle text-blue-500 text-xl"></i>
                    </div>
                    <div class="ml-3">
                        <p class="text-sm text-gray-700">${message}</p>
                    </div>
                    <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                        <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                    </button>
                </div>
            `;
        }
        
        const container = document.getElementById('toastContainer');
        container.appendChild(toast);
        
        // Animate in
        setTimeout(() => {
            toast.classList.remove('translate-x-full');
        }, 100);
        
        // Remove after 3 seconds
        setTimeout(() => {
            toast.classList.add('translate-x-full');
            setTimeout(() => {
                toast.remove();
            }, 300);
        }, 3000);
    }
    
    // Show quick save indicator
    function showQuickSave() {
        const indicator = document.createElement('div');
        indicator.style.cssText = 'position: fixed; bottom: 1rem; right: 1rem; background-color: #10b981; color: white; padding: 0.5rem 1rem; border-radius: 0.375rem; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); display: flex; align-items: center; gap: 0.5rem; transition: all 0.3s; transform: translateY(5rem); z-index: 50;';
        indicator.innerHTML = `
            <i class="ti ti-check" style="font-size: 1rem;"></i>
            <span style="font-size: 0.875rem; font-weight: 500;">Saved</span>
        `;
        
        document.body.appendChild(indicator);
        
        // Animate in
        setTimeout(() => {
            indicator.style.transform = 'translateY(0)';
        }, 10);
        
        // Remove after 2 seconds
        setTimeout(() => {
            indicator.style.transform = 'translateY(5rem)';
            setTimeout(() => {
                indicator.remove();
            }, 300);
        }, 2000);
    }
    </script>
</body>
</html>