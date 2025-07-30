<!--- Ghost-style Post Editor for CFGHOST CMS --->
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

// Extract first paragraph for placeholder text
firstParagraphText = "";
if (len(postData.html)) {
    firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
    if (arrayLen(firstP) gt 0) {
        // Strip HTML tags from first paragraph
        firstParagraphText = reReplace(firstP[1], "<[^>]*>", "", "all");
        firstParagraphText = replace(firstParagraphText, "&nbsp;", " ", "all");
        firstParagraphText = replace(firstParagraphText, "&amp;", "&", "all");
        firstParagraphText = replace(firstParagraphText, "&lt;", "<", "all");
        firstParagraphText = replace(firstParagraphText, "&gt;", ">", "all");
        firstParagraphText = replace(firstParagraphText, "&quot;", '"', "all");
        firstParagraphText = trim(firstParagraphText);
    }
}
</cfscript>

<!DOCTYPE html>
<html lang="en" dir="ltr" data-color-theme="Blue_Theme" class="light">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#pageTitle# - CFGHOST</cfoutput></title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="/favicon.ico?v=ghost" type="image/x-icon">
    <link rel="icon" href="/favicon.ico?v=ghost" type="image/x-icon">
    <link rel="icon" type="image/svg+xml" href="/ghost/favicon.svg?v=ghost">
    <link rel="apple-touch-icon" href="/ghost/admin/assets/images/logos/favicon-ghost.png?v=ghost">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/styles.min.css">
    
    <!-- Core CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css">
    
    <!-- Ghost Publish Modal CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/ghost-publish-modal.css?v=<cfoutput>#dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'HHmmss')#</cfoutput>" />
    
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
            padding: 4rem 2rem 4rem 5rem;
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
            top: 50%;
            left: -50px;
            transform: translateY(-50%);
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            opacity: 0;
            transition: opacity 0.2s;
        }
        
        .content-card:hover .content-card-toolbar {
            opacity: 1;
        }
        
        .toolbar-icon {
            width: 32px;
            height: 32px;
            padding: 0;
            border: 1px solid #e5e7eb;
            background: #ffffff;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            color: #6b7280;
            transition: all 0.2s;
            margin: 0;
        }
        
        .toolbar-icon:hover {
            border-color: #d1d5db;
            background: #f9fafb;
            color: #374151;
        }
        
        .toolbar-icon-delete:hover {
            border-color: #fecaca;
            background: #fee2e2;
            color: #dc2626;
        }
        
        .toolbar-icon svg {
            width: 16px;
            height: 16px;
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
        
        /* File card styles */
        .file-card-content {
            position: relative;
        }
        
        .file-wrapper {
            transition: all 0.2s ease;
            border: 1px solid #e5e7eb !important;
        }
        
        .file-wrapper:hover {
            border-color: #d1d5db !important;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .file-icon {
            flex-shrink: 0;
        }
        
        .file-info {
            min-width: 0;
        }
        
        .file-name a {
            color: #374151;
            font-weight: 500;
        }
        
        .file-name a:hover {
            color: #059669;
            text-decoration: underline !important;
        }
        
        .file-size {
            font-size: 0.875rem;
            color: #6b7280;
        }
        
        .ghost-file-toolbar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px;
            background: #fafafa;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        /* Ghost Product Card Styles */
        .ghost-product-card {
            background: #fff;
            border: 1px solid #e6e9eb;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .ghost-product-card-inner {
            display: flex;
            min-height: 180px;
        }
        
        .ghost-product-image-container {
            width: 40%;
            background: #f7f8f9;
            position: relative;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .ghost-product-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .ghost-product-image-placeholder {
            color: #c5c7c9;
            text-align: center;
        }
        
        .ghost-product-image-placeholder svg {
            width: 48px;
            height: 48px;
        }
        
        .ghost-product-content {
            flex: 1;
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .ghost-product-title {
            font-size: 18px;
            font-weight: 600;
            line-height: 1.3;
            color: #15171a;
            border: none;
            background: transparent;
            padding: 0;
            margin: 0;
            width: 100%;
            outline: none;
        }
        
        .ghost-product-title:focus {
            outline: none;
        }
        
        .ghost-product-description {
            font-size: 14px;
            line-height: 1.5;
            color: #626d79;
            border: none;
            background: transparent;
            padding: 0;
            margin: 0;
            width: 100%;
            resize: none;
            outline: none;
        }
        
        .ghost-product-rating {
            display: flex;
            gap: 2px;
            color: #f97316;
        }
        
        .ghost-product-rating .ti {
            font-size: 16px;
        }
        
        .ghost-product-rating .ti:not(.ti-star-filled) {
            color: #e6e9eb;
        }
        
        .ghost-product-button {
            display: inline-block;
            padding: 8px 16px;
            font-size: 14px;
            font-weight: 500;
            border-radius: 4px;
            text-decoration: none !important;
            transition: all 0.2s ease;
            margin-top: auto;
            align-self: flex-start;
        }
        
        .ghost-product-button.primary {
            background: #14b8ff;
            color: white;
            border: 1px solid #14b8ff;
        }
        
        .ghost-product-button.primary:hover {
            background: #0ea5e9;
            border-color: #0ea5e9;
            text-decoration: none !important;
        }
        
        .ghost-product-button.secondary {
            background: #626d79;
            color: white;
            border: 1px solid #626d79;
        }
        
        .ghost-product-button.secondary:hover {
            background: #505863;
            border-color: #505863;
            text-decoration: none !important;
        }
        
        .ghost-product-button.outline {
            background: transparent;
            color: #15171a;
            border: 1px solid #e6e9eb;
        }
        
        .ghost-product-button.outline:hover {
            border-color: #c5c7c9;
            text-decoration: none !important;
        }
        
        .ghost-product-button.link {
            background: transparent;
            color: #14b8ff;
            border: none;
            text-decoration: none !important;
            padding: 0;
        }
        
        .ghost-product-button.link:hover {
            color: #0ea5e9;
            text-decoration: none !important;
        }
        
        /* Ghost Product Settings */
        .ghost-product-settings {
            background: #f7f8f9;
            border-top: 1px solid #e6e9eb;
            padding: 16px;
            margin: 0 -1px -1px -1px;
        }
        
        .ghost-product-settings-row {
            display: flex;
            gap: 16px;
            margin-bottom: 16px;
        }
        
        .ghost-product-settings-row:last-child {
            margin-bottom: 0;
        }
        
        /* General card settings panel styles */
        .ghost-card-settings {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            padding: 16px;
            margin-top: 10px;
            box-shadow: 0 1px 5px rgba(0,0,0,0.1);
            display: none;
        }
        
        /* Show settings panel when active */
        .ghost-card-settings.active {
            display: block;
        }
        
        /* Add margin to cards when settings are open */
        .content-card:has(.ghost-card-settings.active) {
            margin-bottom: 20px;
        }
        
        .toolbar-icon-settings {
            border-color: #14b8ff;
            color: #14b8ff;
        }
        
        .toolbar-icon-settings:hover {
            background: #f0feff;
            border-color: #0ea5e9;
            color: #0ea5e9;
        }
        
        .ghost-setting-group {
            flex: 1;
        }
        
        .ghost-setting-group.full-width {
            flex: 1 0 100%;
        }
        
        .ghost-setting-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #15171a;
            margin-bottom: 8px;
        }
        
        .ghost-input {
            width: 100%;
            padding: 8px 12px;
            font-size: 14px;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            background: white;
            color: #15171a;
            outline: none;
        }
        
        .ghost-input:focus {
            border-color: #14b8ff;
        }
        
        .ghost-button-style-group {
            display: flex;
            gap: 8px;
        }
        
        .ghost-style-button {
            flex: 1;
            padding: 8px;
            background: white;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .ghost-style-button:hover {
            border-color: #c5c7c9;
        }
        
        .ghost-style-button.active {
            border-color: #14b8ff;
            background: #f0feff;
        }
        
        .ghost-button-preview {
            display: block;
            padding: 4px 12px;
            font-size: 13px;
            font-weight: 500;
            border-radius: 3px;
            text-align: center;
        }
        
        .ghost-button-preview.primary {
            background: #14b8ff;
            color: white;
            border: none;
        }
        
        .ghost-button-preview.secondary {
            background: #626d79;
            color: white;
            border: none;
        }
        
        .ghost-button-preview.outline {
            background: transparent;
            color: #15171a;
            border: 1px solid #15171a;
        }
        
        .ghost-button-preview.link {
            background: transparent;
            color: #14b8ff;
            text-decoration: none;
            border: none;
        }
        
        .ghost-rating-selector {
            display: flex;
            gap: 4px;
        }
        
        .ghost-rating-toggle {
            padding: 6px 12px;
            background: white;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 500;
            color: #626d79;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .ghost-rating-toggle:hover {
            border-color: #c5c7c9;
        }
        
        .ghost-rating-toggle.active {
            border-color: #14b8ff;
            background: #f0feff;
            color: #14b8ff;
        }
        
        /* Ghost Bookmark Card Styles */
        .kg-bookmark-card,
        .kg-bookmark-card * {
            box-sizing: border-box;
        }
        
        .kg-bookmark-card a.kg-bookmark-container,
        .kg-bookmark-card a.kg-bookmark-container:hover {
            display: flex;
            background: #fff;
            text-decoration: none;
            border-radius: 6px;
            border: 1px solid rgb(124 139 154 / 25%);
            overflow: hidden;
            color: #222;
            min-height: 148px;
        }
        
        .kg-bookmark-content {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            flex-basis: 100%;
            align-items: flex-start;
            justify-content: flex-start;
            padding: 20px;
            overflow: hidden;
        }
        
        .kg-bookmark-title {
            font-size: 15px;
            line-height: 1.4em;
            font-weight: 600;
        }
        
        .kg-bookmark-description {
            display: -webkit-box;
            font-size: 14px;
            line-height: 1.5em;
            margin-top: 3px;
            font-weight: 400;
            max-height: 44px;
            overflow-y: hidden;
            opacity: 0.7;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        
        .kg-bookmark-metadata {
            display: flex;
            align-items: center;
            margin-top: 22px;
            width: 100%;
            font-size: 14px;
            font-weight: 500;
            white-space: nowrap;
        }
        
        .kg-bookmark-metadata > *:not(img) {
            opacity: 0.7;
        }
        
        .ghost-bookmark-publisher {
            font-weight: 500;
        }
        
        .ghost-bookmark-author::before {
            content: "•";
            margin-right: 8px;
        }
        
        .ghost-bookmark-thumbnail {
            width: 180px;
            background: #f7f8f9;
            flex-shrink: 0;
        }
        
        .ghost-bookmark-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .kg-bookmark-icon {
            width: 20px;
            height: 20px;
            margin-right: 6px;
        }
        
        .kg-bookmark-author,
        .kg-bookmark-publisher {
            display: inline;
        }
        
        .kg-bookmark-publisher {
            text-overflow: ellipsis;
            overflow: hidden;
            max-width: 240px;
            white-space: nowrap;
            display: block;
            line-height: 1.65em;
        }
        
        .kg-bookmark-metadata > span:nth-of-type(2) {
            font-weight: 400;
        }
        
        .kg-bookmark-metadata > span:nth-of-type(2):before {
            content: "•";
            margin: 0 6px;
        }
        
        .kg-bookmark-metadata > span:last-of-type {
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .kg-bookmark-thumbnail {
            position: relative;
            flex-basis: 24rem;
            flex-grow: 1;
            min-width: 33%;
        }
        
        .kg-bookmark-thumbnail::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            display: block;
        }
        
        .kg-bookmark-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            position: absolute;
            top: 0;
            left: 0;
            border-radius: 0 4px 4px 0;
        }
        
        .bookmark-card-content {
            position: relative;
        }
        
        .ghost-bookmark-settings {
            background: #f7f8f9;
            border-top: 1px solid #e6e9eb;
            padding: 16px;
            margin: 0 -1px -1px -1px;
        }
        
        .ghost-bookmark-loading {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            color: #626d79;
            font-size: 14px;
        }
        
        .ghost-bookmark-error {
            text-align: center;
            padding: 40px 20px;
            color: #f56565;
            font-size: 14px;
        }
        
        /* Spinner animation */
        .spin {
            animation: spin 1s linear infinite;
        }
        
        /* Ghost Embed Card Styles */
        .ghost-embed-wrapper {
            position: relative;
            width: 100%;
            margin: 0;
        }
        
        .ghost-embed-wrapper iframe,
        .ghost-embed-wrapper embed,
        .ghost-embed-wrapper object {
            width: 100%;
            height: auto;
            aspect-ratio: 16/9;
            border: 0;
            border-radius: 8px;
        }
        
        .ghost-embed-wrapper twitter-widget {
            margin: 0 auto !important;
        }
        
        .embed-card-content {
            position: relative;
        }
        
        .ghost-embed-settings {
            background: #f7f8f9;
            border-top: 1px solid #e6e9eb;
            padding: 16px;
            margin: 0 -1px -1px -1px;
        }
        
        .ghost-embed-input {
            width: 100%;
            padding: 12px;
            font-size: 14px;
            border: 1px solid #dde1e5;
            border-radius: 6px;
            background: white;
            color: #15171a;
            outline: none;
            font-family: inherit;
        }
        
        .ghost-embed-input:focus {
            border-color: #14b8ff;
        }
        
        .ghost-embed-input::placeholder {
            color: #626d79;
        }
        
        .ghost-embed-caption {
            width: 100%;
            padding: 12px;
            font-size: 14px;
            border: 1px solid #dde1e5;
            border-radius: 6px;
            background: white;
            color: #15171a;
            outline: none;
            font-family: inherit;
            margin-top: 12px;
        }
        
        .ghost-embed-caption:focus {
            border-color: #14b8ff;
        }
        
        .ghost-embed-loading {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            color: #626d79;
            font-size: 14px;
        }
        
        .ghost-embed-error {
            text-align: center;
            padding: 40px 20px;
            color: #f56565;
            font-size: 14px;
        }
        
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        
        /* Post Selector Modal Styles */
        .post-selector-item {
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .post-selector-item:hover {
            background-color: #f8f9fa;
            border-color: #14b8ff !important;
        }
        
        /* Bootstrap modal fallback styles */
        .modal {
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1050;
            display: none;
            width: 100%;
            height: 100%;
            overflow-x: hidden;
            overflow-y: auto;
            outline: 0;
        }
        
        .modal.show {
            display: block;
        }
        
        .modal-dialog {
            position: relative;
            width: auto;
            margin: 1.75rem auto;
            max-width: 800px;
        }
        
        .modal-content {
            position: relative;
            display: flex;
            flex-direction: column;
            width: 100%;
            background-color: #fff;
            background-clip: padding-box;
            border: 1px solid rgba(0,0,0,.2);
            border-radius: .3rem;
            outline: 0;
            box-shadow: 0 0.5rem 1rem rgba(0,0,0,.5);
        }
        
        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem;
            border-bottom: 1px solid #dee2e6;
        }
        
        .modal-title {
            margin: 0;
            line-height: 1.5;
            font-size: 1.25rem;
            font-weight: 500;
        }
        
        .modal-body {
            position: relative;
            flex: 1 1 auto;
            padding: 1rem;
            max-height: 70vh;
            overflow-y: auto;
        }
        
        .btn-close {
            padding: .25rem .25rem;
            background: transparent;
            border: 0;
            font-size: 1.25rem;
            font-weight: 700;
            line-height: 1;
            color: #000;
            opacity: .5;
            cursor: pointer;
        }
        
        .btn-close:hover {
            opacity: .75;
        }
        
        .modal-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1040;
            width: 100vw;
            height: 100vh;
            background-color: #000;
            opacity: .5;
        }
        
        /* Ghost Callout Card Styles */
        .callout-card-content {
            padding: 0;
        }
        
        .ghost-callout-card {
            padding: 1.2em 1.6em;
            border-radius: 8px;
            margin: 0;
            position: relative;
            display: flex;
            gap: 0.8em;
        }
        
        /* Callout card color styles - matching Ghost exactly */
        .ghost-callout-card.kg-callout-card-grey {
            background: rgba(124, 139, 154, 0.13);
        }
        
        .ghost-callout-card.kg-callout-card-white {
            background: transparent;
            box-shadow: inset 0 0 0 1px rgba(124, 139, 154, 0.2);
        }
        
        .ghost-callout-card.kg-callout-card-blue {
            background: rgba(33, 172, 232, 0.12);
        }
        
        .ghost-callout-card.kg-callout-card-green {
            background: rgba(52, 183, 67, 0.12);
        }
        
        .ghost-callout-card.kg-callout-card-yellow {
            background: rgba(240, 165, 15, 0.13);
        }
        
        .ghost-callout-card.kg-callout-card-red {
            background: rgba(209, 46, 46, 0.11);
        }
        
        .ghost-callout-card.kg-callout-card-pink {
            background: rgba(225, 71, 174, 0.11);
        }
        
        .ghost-callout-card.kg-callout-card-purple {
            background: rgba(135, 85, 236, 0.12);
        }
        
        .ghost-callout-card.kg-callout-card-accent {
            background: #15171a;
            color: #fff;
        }
        
        .ghost-callout-card.kg-callout-card-accent .ghost-callout-text {
            color: #fff;
        }
        
        
        .ghost-callout-emoji {
            font-size: 1.15em;
            line-height: 1.25em;
            padding-right: 0.8em;
            flex-shrink: 0;
            cursor: pointer;
            user-select: none;
        }
        
        .ghost-callout-text {
            flex: 1;
            font-size: 0.95em;
            line-height: 1.5em;
            outline: none;
            min-height: 24px;
        }
        
        .ghost-callout-text:empty:before {
            content: attr(data-placeholder);
            color: #aaa;
        }
        
        .callout-card-content {
            cursor: pointer;
        }
        
        .ghost-callout-colors {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .ghost-color-button {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }
        
        .ghost-color-button:hover {
            transform: scale(1.1);
        }
        
        .ghost-color-button.active {
            border-color: #15171a;
            box-shadow: 0 0 0 2px white, 0 0 0 4px #15171a;
        }
        
        .ghost-callout-card.kg-callout-card-white {
            box-shadow: inset 0 0 0 1px rgba(124, 139, 154, 0.2);
        }
        
        .ghost-callout-card.kg-callout-card-accent .ghost-callout-text {
            color: white;
        }
        
        .ghost-callout-card.kg-callout-card-accent .ghost-callout-text:empty:before {
            color: rgba(255, 255, 255, 0.7);
        }
        
        /* Emoji picker styles */
        .ghost-emoji-picker {
            position: absolute;
            top: 100%;
            left: 0;
            z-index: 1000;
            background: white;
            border: 1px solid #e6e9eb;
            border-radius: 8px;
            padding: 12px;
            margin-top: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            display: none;
        }
        
        .ghost-emoji-picker.active {
            display: block;
        }
        
        .ghost-emoji-grid {
            display: grid;
            grid-template-columns: repeat(8, 1fr);
            gap: 4px;
        }
        
        .ghost-emoji-option {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            cursor: pointer;
            border-radius: 4px;
            transition: background-color 0.2s ease;
        }
        
        .ghost-emoji-option:hover {
            background-color: #f5f5f5;
        }
        
        .ghost-color-picker {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .ghost-color-button {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }
        
        .ghost-color-button:hover {
            transform: scale(1.1);
        }
        
        .ghost-color-button.active {
            box-shadow: 0 0 0 2px #fff, 0 0 0 4px #14b8ff;
        }
        
        .ghost-color-button:focus {
            outline: none;
            box-shadow: 0 0 0 2px #fff, 0 0 0 4px #14b8ff;
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
        
        /* Button card styles */
        .button-card-content {
            cursor: pointer;
        }
        
        .kg-button-card {
            margin: 1.5em 0;
            text-align: center;
        }
        
        .kg-button-card.kg-align-left {
            text-align: left;
        }
        
        .kg-button-card.kg-align-center {
            text-align: center;
        }
        
        .kg-btn {
            display: inline-block;
            padding: 8px 16px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none !important;
            border-radius: 5px;
            transition: all 0.2s ease;
            cursor: pointer;
        }
        
        /* Custom button class that doesn't inherit default styles */
        .kg-btn-custom {
            all: unset;
            cursor: pointer;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }
        
        .kg-btn-primary {
            background: #14b8ff;
            color: #fff;
        }
        
        .kg-btn-primary:hover {
            background: #0ea5e9;
            color: #fff;
        }
        
        .kg-btn-secondary {
            background: #626d79;
            color: #fff;
        }
        
        .kg-btn-secondary:hover {
            background: #515961;
            color: #fff;
        }
        
        .kg-btn-outline {
            background: transparent;
            color: #15171a;
            border: 1px solid #dde1e5;
        }
        
        .kg-btn-outline:hover {
            border-color: #c5c7c9;
            color: #15171a;
        }
        
        .kg-btn-link {
            background: transparent;
            color: #14b8ff;
            text-decoration: none;
        }
        
        .kg-btn-link:hover {
            color: #0ea5e9;
        }
        
        /* Ghost button settings panel */
        .ghost-button-settings {
            min-width: 300px;
        }
        
        /* Gallery card styles - matching Ghost exactly */
        .gallery-card-content {
            cursor: pointer;
        }
        
        .kg-gallery-card {
            margin: 0 0 1.5em;
        }
        
        .kg-gallery-card,
        .kg-gallery-card * {
            box-sizing: border-box;
        }
        
        .kg-gallery-card figcaption {
            margin: 1.0em 0 0;
            text-align: center;
            font-size: 0.85em;
            line-height: 1.4;
            color: rgba(0,0,0,0.5);
        }
        
        .kg-gallery-container {
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
        }
        
        .kg-gallery-row {
            display: flex;
            flex-direction: row;
            justify-content: center;
            gap: 1.2rem;
        }
        
        .kg-gallery-image {
            flex: 1 1 0;
            position: relative;
            overflow: hidden;
            border-radius: 3px;
            min-height: 100px;
            cursor: move;
        }
        
        .kg-gallery-image img {
            display: block;
            margin: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .kg-gallery-image:hover .kg-gallery-image-toolbar {
            opacity: 1;
        }
        
        .kg-gallery-image-toolbar {
            position: absolute;
            top: 8px;
            right: 8px;
            display: flex;
            gap: 4px;
            opacity: 0;
            transition: opacity 0.2s;
            background: rgba(0,0,0,0.3);
            border-radius: 3px;
            padding: 4px;
        }
        
        .kg-gallery-image-btn {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(0,0,0,0.5);
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            transition: background 0.2s;
        }
        
        .kg-gallery-image-btn:hover {
            background: rgba(0,0,0,0.7);
        }
        
        /* Ghost gallery settings */
        .ghost-gallery-settings {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 16px;
            margin-top: 12px;
            display: none;
        }
        
        .ghost-gallery-settings.active {
            display: block;
        }
        
        .ghost-gallery-toolbar {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
        }
        
        .ghost-gallery-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 12px;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .ghost-gallery-btn:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        
        .ghost-gallery-images-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
            gap: 12px;
            margin-top: 16px;
        }
        
        .ghost-gallery-image-item {
            position: relative;
            aspect-ratio: 1;
            border-radius: 6px;
            overflow: hidden;
            background: #f3f4f6;
        }
        
        .ghost-gallery-image-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .ghost-gallery-image-item:hover .ghost-gallery-image-actions {
            opacity: 1;
        }
        
        .ghost-gallery-image-actions {
            position: absolute;
            inset: 0;
            background: rgba(0,0,0,0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            opacity: 0;
            transition: opacity 0.2s;
        }
        
        .ghost-gallery-action-btn {
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255,255,255,0.9);
            border: none;
            border-radius: 6px;
            color: #374151;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .ghost-gallery-action-btn:hover {
            background: white;
            transform: scale(1.05);
        }
        
        .ghost-gallery-action-delete {
            color: #ef4444;
        }
        
        /* Empty gallery state */
        .kg-gallery-empty {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
            background: #f9fafb;
            border: 2px dashed #e5e7eb;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .kg-gallery-empty:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        
        .kg-gallery-empty i {
            font-size: 48px;
            color: #9ca3af;
            margin-bottom: 12px;
        }
        
        .kg-gallery-empty p {
            color: #6b7280;
            font-size: 16px;
            margin: 0;
        }
        
        /* Ghost modal styles */
        .ghost-modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }
        
        .ghost-modal {
            background: white;
            border-radius: 8px;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
            max-width: 500px;
            width: 90%;
            max-height: 90vh;
            display: flex;
            flex-direction: column;
        }
        
        .ghost-modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 24px;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-modal-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
            color: #111827;
        }
        
        .ghost-modal-close {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: transparent;
            border: none;
            border-radius: 6px;
            color: #6b7280;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .ghost-modal-close:hover {
            background: #f3f4f6;
            color: #374151;
        }
        
        .ghost-modal-body {
            padding: 24px;
            overflow-y: auto;
            flex: 1;
        }
        
        .ghost-modal-footer {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
            padding: 20px 24px;
            border-top: 1px solid #e5e7eb;
        }
        
        /* Ghost Button Styles */
        .ghost-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
            font-weight: 500;
            border-radius: 0.375rem;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all 0.15s ease-in-out;
            text-decoration: none;
            white-space: nowrap;
        }
        
        .ghost-btn span {
            display: inline-block;
        }
        
        .ghost-btn-link {
            background: transparent;
            color: #6b7280;
            border-color: transparent;
        }
        
        .ghost-btn-link:hover {
            color: #111827;
        }
        
        .ghost-btn-red {
            background-color: #dc2626;
            color: white;
        }
        
        .ghost-btn-red:hover {
            background-color: #b91c1c;
        }
        
        .ghost-btn-black {
            background-color: #111827;
            color: white;
        }
        
        .ghost-btn-black:hover {
            background-color: #000000;
        }
        
        /* Publish modal styles */
        .ghost-modal input[type="radio"] {
            flex-shrink: 0;
            width: 1rem;
            height: 1rem;
            margin-top: 0.125rem;
            cursor: pointer;
        }
        
        .ghost-modal input[type="date"],
        .ghost-modal input[type="time"] {
            padding: 0.5rem 0.75rem;
            border: 1px solid #e5e7eb;
            border-radius: 0.375rem;
            font-size: 0.875rem;
            transition: border-color 0.15s ease-in-out;
        }
        
        .ghost-modal input[type="date"]:focus,
        .ghost-modal input[type="time"]:focus {
            outline: none;
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        
        .ghost-modal label {
            display: flex;
            cursor: pointer;
        }
        
        .ghost-modal .form-control {
            display: block;
            width: 100%;
            padding: 0.5rem 0.75rem;
            font-size: 0.875rem;
            line-height: 1.25rem;
            color: #374151;
            background-color: #ffffff;
            background-clip: padding-box;
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }
        
        /* Header Card v2 Styles - Matching Ghost exactly */
        .header-card-content {
            position: relative;
            max-width: 100%;
            overflow: visible;
        }
        
        /* Settings button for header card */
        .ghost-card-settings-button {
            position: absolute;
            top: 8px;
            right: 8px;
            z-index: 10;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            opacity: 0;
            transition: all 0.2s;
        }
        
        .header-card-content:hover .ghost-card-settings-button {
            opacity: 1;
        }
        
        .ghost-card-settings-button:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }
        
        .ghost-card-settings-button i {
            font-size: 16px;
            color: #374151;
        }
        
        .kg-header-card.kg-v2 {
            position: relative;
            padding: 0;
            min-height: initial;
            text-align: initial;
            margin: 0 0 1.5em;
            cursor: pointer;
            transition: box-shadow 0.2s ease;
        }
        
        .kg-header-card.kg-v2:hover {
            box-shadow: 0 0 0 2px var(--ghost-accent-color);
        }
        
        .kg-header-card.kg-v2,
        .kg-header-card.kg-v2 * {
            box-sizing: border-box;
        }
        
        .kg-header-card.kg-v2 a,
        .kg-header-card.kg-v2 a span {
            color: currentColor;
        }
        
        .kg-header-card.kg-style-accent.kg-v2 {
            background-color: var(--ghost-accent-color);
        }
        
        .kg-header-card-content {
            width: 100%;
        }
        
        .kg-layout-split .kg-header-card-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            max-width: 100%;
        }
        
        /* Ensure split layout doesn't overflow */
        .kg-header-card.kg-layout-split {
            max-width: 100%;
            margin-left: 0;
            margin-right: 0;
        }
        
        .kg-header-card.kg-layout-split.kg-width-full {
            width: 100%;
            max-width: 100%;
        }
        
        .kg-header-card-text {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            justify-content: center;
            height: 100%;
            padding: min(6.4vmax, 120px) min(4vmax, 80px);
            background-size: cover;
            background-position: center;
            text-align: left;
        }
        
        .kg-width-wide .kg-header-card-text {
            padding: min(10vmax, 220px) min(6.4vmax, 140px);
        }
        
        .kg-width-full .kg-header-card-text {
            padding: min(12vmax, 260px) 0;
        }
        
        .kg-layout-split .kg-header-card-text {
            padding: min(12vmax, 260px) min(4vmax, 80px);
        }
        
        .kg-layout-split.kg-content-wide .kg-header-card-text {
            padding: min(10vmax, 220px) 0 min(10vmax, 220px) min(4vmax, 80px);
        }
        
        .kg-layout-split.kg-content-wide.kg-swapped .kg-header-card-text {
            padding: min(10vmax, 220px) min(4vmax, 80px) min(10vmax, 220px) 0;
        }
        
        .kg-swapped .kg-header-card-text {
            grid-row: 1;
        }
        
        .kg-header-card-text.kg-align-center {
            align-items: center;
            text-align: center;
        }
        
        .kg-header-card.kg-style-image h2.kg-header-card-heading,
        .kg-header-card.kg-style-image .kg-header-card-subheading,
        .kg-header-card.kg-style-image.kg-v2 .kg-header-card-button {
            z-index: 999;
        }
        
        /* Background image */
        .kg-header-card > picture > .kg-header-card-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
            background-color: #FFFFFF;
            pointer-events: none;
        }
        
        /* Split layout image */
        .kg-header-card-content .kg-header-card-image {
            width: 100%;
            height: 0;
            min-height: 100%;
            object-fit: cover;
            object-position: center;
        }
        
        .kg-layout-split .kg-header-card-image {
            max-width: 100%;
            overflow: hidden;
            cursor: pointer;
        }
        
        .kg-header-card-image-placeholder {
            background: #f3f4f6;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 400px;
        }
        
        .kg-header-image-upload-placeholder {
            text-align: center;
            color: #71717a;
        }
        
        .kg-header-image-upload-placeholder i {
            font-size: 48px;
            color: #a1a1aa;
            display: block;
            margin-bottom: 12px;
        }
        
        .kg-header-image-upload-placeholder p {
            margin: 0;
            font-size: 14px;
            font-weight: 500;
        }
        
        .kg-layout-split picture.kg-header-card-image {
            display: block;
            height: 100%;
            min-height: 400px;
        }
        
        .kg-layout-split picture.kg-header-card-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .kg-content-wide .kg-header-card-content .kg-header-card-image {
            height: 100%;
            padding: 5.6em 0;
            object-fit: contain;
        }
        
        /* Heading */
        .kg-header-card h2.kg-header-card-heading {
            margin: 0;
            font-size: clamp(1.7em, 4vw, 2.5em);
            font-weight: 700;
            line-height: 1.05em;
            letter-spacing: -0.01em;
        }
        
        .kg-header-card h2.kg-header-card-heading[contenteditable]:empty:before {
            content: attr(data-placeholder);
            color: currentColor;
            opacity: 0.3;
        }
        
        .kg-header-card.kg-width-wide h2.kg-header-card-heading {
            font-size: clamp(1.7em, 5vw, 3.3em);
        }
        
        .kg-header-card.kg-width-full h2.kg-header-card-heading {
            font-size: clamp(1.9em, 5.6vw, 4.2em);
        }
        
        .kg-header-card.kg-width-full.kg-layout-split h2.kg-header-card-heading {
            font-size: clamp(1.9em, 4vw, 3.3em);
        }
        
        /* Subheading */
        .kg-header-card-subheading {
            margin: 0 0 2em;
        }
        
        .kg-header-card .kg-header-card-subheading {
            max-width: 40em;
            margin: 0;
            font-size: clamp(1.05em, 2vw, 1.4em);
            font-weight: 500;
            line-height: 1.2em;
        }
        
        .kg-header-card .kg-header-card-subheading[contenteditable]:empty:before {
            content: attr(data-placeholder);
            color: currentColor;
            opacity: 0.3;
        }
        
        .kg-header-card h2 + .kg-header-card-subheading {
            margin: 0.6em 0 0;
        }
        
        .kg-header-card .kg-header-card-subheading strong {
            font-weight: 600;
        }
        
        .kg-header-card.kg-width-wide .kg-header-card-subheading {
            font-size: clamp(1.05em, 2vw, 1.55em);
        }
        
        .kg-header-card.kg-width-full .kg-header-card-subheading:not(.kg-layout-split .kg-header-card-subheading) {
            max-width: min(65vmax, 1200px);
            font-size: clamp(1.05em, 2vw, 1.7em);
        }
        
        .kg-header-card.kg-width-full.kg-layout-split .kg-header-card-subheading {
            font-size: clamp(1.05em, 2vw, 1.55em);
        }
        
        /* Button */
        .kg-header-card.kg-v2 .kg-header-card-button {
            display: flex;
            position: relative;
            align-items: center;
            height: 2.9em;
            min-height: 46px;
            padding: 0 1.2em;
            outline: none;
            border: none;
            font-size: 1em;
            font-weight: 600;
            line-height: 1em;
            text-align: center;
            text-decoration: none;
            letter-spacing: .2px;
            white-space: nowrap;
            text-overflow: ellipsis;
            border-radius: 3px;
            transition: opacity .2s ease;
            cursor: pointer;
        }
        
        .kg-header-card.kg-v2 .kg-header-card-button.kg-style-accent {
            background-color: var(--ghost-accent-color);
        }
        
        .kg-header-card.kg-v2 h2 + .kg-header-card-button,
        .kg-header-card.kg-v2 p + .kg-header-card-button {
            margin: 1.5em 0 0;
        }
        
        .kg-header-card.kg-v2 .kg-header-card-button:hover {
            opacity: 0.85;
        }
        
        .kg-header-card.kg-v2.kg-width-wide .kg-header-card-button {
            font-size: 1.05em;
        }
        
        .kg-header-card.kg-v2.kg-width-wide h2 + .kg-header-card-button,
        .kg-header-card.kg-v2.kg-width-wide p + .kg-header-card-button {
            margin-top: 1.75em;
        }
        
        .kg-header-card.kg-v2.kg-width-full .kg-header-card-button {
            font-size: 1.1em;
        }
        
        .kg-header-card.kg-v2.kg-width-full h2 + .kg-header-card-button,
        .kg-header-card.kg-v2.kg-width-full p + .kg-header-card-button {
            margin-top: 2em;
        }
        
        /* Header settings panel */
        .ghost-header-settings {
            margin: 16px auto;
            display: none;
            width: 100%;
            max-width: 680px;
        }
        
        .ghost-header-settings:not(.hidden) {
            display: block !important;
        }
        
        .ghost-header-settings .ghost-settings-panel {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 20px;
            width: 100%;
            max-height: 500px;
            overflow-y: auto;
            margin: 0 auto;
        }
        
        .ghost-settings-group {
            margin-bottom: 16px;
        }
        
        .ghost-settings-group:last-child {
            margin-bottom: 0;
        }
        
        .ghost-settings-label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 8px;
        }
        
        .ghost-button-group {
            display: flex;
            gap: 4px;
        }
        
        .ghost-button-small {
            padding: 6px 12px;
            font-size: 13px;
            border: 1px solid #e5e7eb;
            background: white;
            color: #374151;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .ghost-button-small:hover {
            background: #f3f4f6;
        }
        
        .ghost-button-small.active {
            background: #1f2937;
            color: white;
            border-color: #1f2937;
        }
        
        .ghost-color-picker-row {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .ghost-color-btn {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 2px solid transparent;
            cursor: pointer;
            position: relative;
            transition: all 0.2s;
        }
        
        .ghost-color-btn:hover {
            transform: scale(1.1);
        }
        
        .ghost-color-btn.active {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
        }
        
        .ghost-color-btn.ghost-color-custom {
            background: linear-gradient(45deg, #e5e7eb 25%, transparent 25%, transparent 75%, #e5e7eb 75%, #e5e7eb),
                        linear-gradient(45deg, #e5e7eb 25%, transparent 25%, transparent 75%, #e5e7eb 75%, #e5e7eb);
            background-size: 10px 10px;
            background-position: 0 0, 5px 5px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .ghost-input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.2s;
        }
        
        .ghost-input:focus {
            outline: none;
            border-color: #3b82f6;
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .kg-layout-split .kg-header-card-content {
                grid-template-columns: 1fr;
            }
            
            .kg-width-wide .kg-header-card-text {
                padding: min(6.4vmax, 120px) min(4vmax, 80px);
            }
            
            .kg-layout-split.kg-content-wide .kg-header-card-text,
            .kg-layout-split.kg-content-wide.kg-swapped .kg-header-card-text {
                padding: min(9.6vmax, 180px) 0;
            }
            
            .kg-header-card.kg-width-full .kg-header-card-subheading:not(.kg-layout-split .kg-header-card-subheading) {
                max-width: unset;
            }
            
            .kg-header-card-content .kg-header-card-image:not(.kg-content-wide .kg-header-card-content .kg-header-card-image) {
                height: auto;
                min-height: unset;
                aspect-ratio: 1 / 1;
            }
            
            .kg-content-wide .kg-header-card-content .kg-header-card-image {
                padding: 1.7em 0 0;
            }
            
            .kg-content-wide.kg-swapped .kg-header-card-content .kg-header-card-image {
                padding: 0 0 1.7em;
            }
            
            .kg-header-card.kg-v2 .kg-header-card-button {
                height: 2.9em;
            }
            
            .kg-header-card.kg-v2.kg-width-wide .kg-header-card-button,
            .kg-header-card.kg-v2.kg-width-full .kg-header-card-button {
                font-size: 1em;
            }
        }
        
        /* Ghost Settings Panel Styles (from koenig.css) */
        .kg-settings-panel {
            position: relative;
            margin: 1rem auto;
            padding: 1rem;
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            max-width: 680px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .kg-settings-panel-header {
            border-color: #dde1e7;
        }
        
        .kg-settings-panel-content {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        .kg-settings-panel-control {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        
        .kg-settings-panel-control-layout {
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 1.5rem;
        }
        
        .kg-settings-panel-control-label {
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 8px;
        }
        
        .kg-settings-panel-control-input .gh-input,
        .kg-settings-panel-control-input .gh-select {
            font-size: 1.0rem !important;
            padding: 5px 10px;
            font-weight: 500;
        }
        
        /* Ghost button groups */
        .gh-btn-group {
            display: inline-flex;
            border-radius: 4px;
            background: #f5f5f5;
        }
        
        .gh-btn-group.icons {
            background: transparent;
            gap: 0.5rem;
        }
        
        .gh-btn {
            position: relative;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.5rem 1rem;
            border: none;
            background: transparent;
            color: #15171a;
            font-size: 1.3rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            white-space: nowrap;
        }
        
        .gh-btn-icon {
            width: 32px;
            height: 32px;
            padding: 0;
        }
        
        .gh-btn-group .gh-btn:first-child {
            border-radius: 4px 0 0 4px;
        }
        
        .gh-btn-group .gh-btn:last-child {
            border-radius: 0 4px 4px 0;
        }
        
        .gh-btn-group .gh-btn-group-selected {
            background: #ffffff;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        
        .gh-btn-outline {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 4px;
        }
        
        /* Header style buttons */
        .kg-settings-headerstyle-btn-group {
            background: none !important;
        }
        
        .kg-settings-headerstyle-btn-group .gh-btn {
            background: var(--white) !important;
            width: 26px;
            height: 26px;
            border: 1px solid var(--whitegrey);
            border-radius: 50%;
            margin-right: 5px;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-dark {
            background: #08090c !important;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-light {
            background: #F9F9F9 !important;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-accent {
            background: var(--accent-color, #FF1A75) !important;
        }
        
        /* Remove old custom button styles since we're using image button now */
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-image {
            background-image: url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjYiIGhlaWdodD0iMjYiIHZpZXdCb3g9IjAgMCAyNiAyNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHJlY3Qgd2lkdGg9IjI2IiBoZWlnaHQ9IjI2IiByeD0iMTMiIGZpbGw9IiNFNUU3RUIiLz4KPHBhdGggZD0iTTE4LjUgMTguNVY5LjVDMTguNSA4LjM5NTQzIDE3LjYwNDYgNy41IDE2LjUgNy41SDkuNUM4LjM5NTQzIDcuNSA3LjUgOC4zOTU0MyA3LjUgOS41VjE4LjUiIHN0cm9rZT0iIzZCNzI4MCIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8Y2lyY2xlIGN4PSIxMS41IiBjeT0iMTEuNSIgcj0iMS41IiBmaWxsPSIjNkI3MjgwIi8+CjxwYXRoIGQ9Ik03LjUgMTguNUwxMSAxNUwxNS41IDE5LjUiIHN0cm9rZT0iIzZCNzI4MCIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8L3N2Zz4=') !important;
            background-size: cover !important;
            background-position: center !important;
            margin-right: 0;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-image.has-image {
            background-size: cover !important;
            background-position: center !important;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-custom {
            background: conic-gradient(from 0deg, #FF1A75, #F59E0B, #10B981, #0EA5E9, #8B5CF6, #FF1A75) !important;
            border-radius: 50% !important;
            margin-right: 0;
            position: relative;
            overflow: hidden;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-custom::after {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            right: 3px;
            bottom: 3px;
            background: white;
            border-radius: 50%;
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .kg-settings-headerstyle-btn-group .kg-headerstyle-btn-custom:not(.gh-btn-group-selected):hover::after {
            opacity: 0.2;
        }
        
        .kg-settings-headerstyle-btn-group .gh-btn-group-selected {
            position: relative;
        }
        
        .kg-settings-headerstyle-btn-group .gh-btn-group-selected::before {
            position: absolute;
            content: "";
            display: block;
            top: -4px;
            right: -4px;
            bottom: -4px;
            left: -4px;
            border: 2px solid var(--green, #30cf43);
            border-radius: 50%;
        }
        
        /* Fix button alignment in settings panel */
        .kg-settings-panel-control-input .gh-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            max-width: 100%;
            width: 100%;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            padding: 8px 12px;
            font-size: 13px;
        }
        
        .kg-settings-panel-control-input .gh-btn span {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            flex: 1;
            min-width: 0;
        }
        
        .kg-settings-panel-control-input .gh-btn svg {
            flex-shrink: 0;
            width: 14px;
            height: 14px;
        }
        
        /* Color picker styles - matching Ghost exactly */
        .kg-color-picker-swatch-group {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        
        .kg-color-swatch {
            width: 26px;
            height: 26px;
            border-radius: 50%;
            cursor: pointer;
            border: 1px solid var(--whitegrey);
            transition: all 0.2s ease;
            position: relative;
            box-sizing: border-box;
            padding: 0;
            background: none;
        }
        
        .kg-color-swatch:hover {
            transform: scale(1.1);
        }
        
        .kg-color-swatch.active {
            position: relative;
        }
        
        .kg-color-swatch.active::before {
            position: absolute;
            content: "";
            display: block;
            top: -4px;
            right: -4px;
            bottom: -4px;
            left: -4px;
            border: 2px solid var(--green);
            border-radius: 50%;
        }
        
        .kg-color-swatch-custom {
            background: transparent !important;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }
        
        .kg-color-swatch-custom svg {
            width: 12px;
            height: 12px;
            pointer-events: none;
            color: #737373;
        }
        
        .kg-color-swatch-custom svg path {
            stroke-width: 1.5;
        }
        
        .kg-color-picker-input {
            position: absolute;
            width: 100%;
            height: 100%;
            opacity: 0;
            cursor: pointer;
        }
        
        .ghost-color-picker-row {
            display: flex;
            gap: 12px;
            margin-top: 8px;
        }
        
        .ghost-color-input-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        
        .ghost-color-label {
            font-size: 12px;
            color: #626d79;
            font-weight: 500;
        }
        
        .ghost-color-picker {
            width: 100%;
            height: 36px;
            border: 1px solid #dde1e5;
            border-radius: 4px;
            cursor: pointer;
            padding: 2px;
        }
        
        .ghost-color-picker:hover {
            border-color: #c5c7c9;
        }
        
        .ghost-color-picker:focus {
            outline: none;
            border-color: #14b8ff;
            box-shadow: 0 0 0 2px rgba(20, 184, 255, 0.2);
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
        
        /* Video card width styles */
        .video-card-content {
            position: relative;
        }
        
        .video-card-content .video-wrapper {
            position: relative;
            transition: all 0.3s ease;
        }
        
        /* Wide width */
        .video-card-content[data-card-width="wide"] .video-wrapper {
            margin-left: calc(-12.5vw + 50%);
            margin-right: calc(-12.5vw + 50%);
            max-width: none;
        }
        
        /* Full width */
        .video-card-content[data-card-width="full"] .video-wrapper {
            margin-left: calc(-50vw + 50%);
            margin-right: calc(-50vw + 50%);
            max-width: none;
        }
        
        /* Responsive adjustments for video */
        @media (max-width: 1024px) {
            .video-card-content[data-card-width="wide"] .video-wrapper,
            .video-card-content[data-card-width="full"] .video-wrapper {
                margin-left: -1rem;
                margin-right: -1rem;
            }
        }
        
        /* Markdown card styles */
        .markdown-card-content {
            padding: 0;
        }
        
        .ghost-markdown-card {
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            overflow: hidden;
            background: #fafafa;
        }
        
        .ghost-markdown-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            background: #f5f5f5;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .ghost-markdown-label {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #666;
            font-size: 13px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }
        
        .ghost-markdown-label svg {
            color: #999;
        }
        
        .ghost-markdown-help-link {
            color: #999;
            text-decoration: none;
            font-size: 18px;
            transition: color 0.2s ease;
        }
        
        .ghost-markdown-help-link:hover {
            color: #666;
        }
        
        .ghost-markdown-editor {
            width: 100%;
            min-height: 200px;
            padding: 16px;
            border: none;
            background: transparent;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 14px;
            line-height: 1.6;
            color: #333;
            resize: none;
            outline: none;
        }
        
        .ghost-markdown-editor::placeholder {
            color: #999;
        }
        
        .editor-card.focused .ghost-markdown-card {
            border-color: #30a46c;
        }
        
        .editor-card.focused .ghost-markdown-header {
            background: #eef8f3;
            border-bottom-color: #30a46c;
        }
        
        /* Toggle card styles */
        .toggle-card-content {
            padding: 0;
        }
        
        .kg-toggle-card {
            background: transparent;
            box-shadow: inset 0 0 0 1px rgba(124, 139, 154, 0.25);
            border-radius: 4px;
            padding: 1.2em;
        }
        
        .kg-toggle-card[data-kg-toggle-state="close"] .kg-toggle-content {
            display: none;
        }
        
        .kg-toggle-content {
            height: auto;
            opacity: 1;
            transition: opacity 0.3s ease;
            position: relative;
            display: block;
        }
        
        .kg-toggle-card[data-kg-toggle-state="close"] svg {
            transform: unset;
        }
        
        .kg-toggle-heading {
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }
        
        .kg-toggle-card h4.kg-toggle-heading-text {
            font-size: 1.15em;
            font-weight: 700;
            line-height: 1.3em;
            margin: 0;
            flex: 1;
            outline: none;
        }
        
        .kg-toggle-heading-text:empty::before {
            content: attr(data-placeholder);
            color: #999;
        }
        
        .kg-toggle-content p:first-of-type {
            margin-top: 0.5em;
        }
        
        .kg-toggle-content > div {
            font-size: 0.95em;
            line-height: 1.5em;
            margin-top: 0.95em;
            outline: none;
            min-height: 30px;
            cursor: text;
        }
        
        .kg-toggle-content > div:empty::before {
            content: attr(data-placeholder);
            color: #999;
        }
        
        .kg-toggle-card-icon {
            height: 24px;
            width: 24px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-left: 1em;
            padding: 0;
            background: none;
            border: 0;
            cursor: pointer;
        }
        
        .kg-toggle-heading svg {
            width: 14px;
            color: rgba(124, 139, 154, 0.5);
            transition: all 0.3s;
            transform: rotate(-180deg);
        }
        
        .kg-toggle-heading path {
            fill: none;
            stroke: currentcolor;
            stroke-linecap: round;
            stroke-linejoin: round;
            stroke-width: 1.5;
            fill-rule: evenodd;
        }
        
        .editor-card.focused .kg-toggle-card {
            box-shadow: inset 0 0 0 1px #30a46c;
        }
        
        /* Product card button styles */
        .kg-product-card-button {
            text-decoration: none !important;
            display: inline-block;
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .kg-product-card-button:hover {
            text-decoration: none !important;
            opacity: 0.9;
        }
        
        .kg-product-button-primary {
            background: #30a46c;
            color: white !important;
        }
        
        .kg-product-button-secondary {
            background: #f0f2f5;
            color: #374151 !important;
        }
        
        .kg-product-button-outline {
            background: transparent;
            border: 1px solid #e5e7eb;
            color: #374151 !important;
        }
        
        .kg-product-button-link {
            background: transparent;
            color: #30a46c !important;
            padding: 0;
        }
    
    /* Apple HIG-inspired styles */
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
    
    :root {
        --apple-bg-primary: #ffffff;
        --apple-bg-secondary: #f5f5f7;
        --apple-bg-tertiary: #fafafa;
        --apple-text-primary: #1d1d1f;
        --apple-text-secondary: #86868b;
        --apple-text-tertiary: #515154;
        --apple-border: #d2d2d7;
        --apple-border-light: #e8e8ed;
        --apple-blue: #0071e3;
        --apple-blue-hover: #0077ed;
        --apple-green: #34c759;
        --apple-red: #ff3b30;
        --apple-yellow: #ffcc00;
        --apple-shadow-sm: 0 1px 3px rgba(0,0,0,0.06);
        --apple-shadow-md: 0 4px 16px rgba(0,0,0,0.08);
        --apple-shadow-lg: 0 10px 40px rgba(0,0,0,0.12);
        --apple-radius-sm: 8px;
        --apple-radius-md: 12px;
        --apple-radius-lg: 16px;
        --apple-transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    /* Settings panel - Apple style */
    .ghost-settings-panel {
        position: fixed;
        top: 0;
        right: -420px;
        width: 420px;
        height: 100vh;
        background: var(--apple-bg-primary);
        border-left: 1px solid var(--apple-border-light);
        transition: var(--apple-transition);
        z-index: 1050;
        display: flex;
        flex-direction: column;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
    }
    
    .ghost-settings-panel.active {
        right: 0;
    }
    
    .ghost-settings-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 20px 24px;
        background: var(--apple-bg-primary);
        border-bottom: 1px solid var(--apple-border-light);
        -webkit-backdrop-filter: blur(10px);
        backdrop-filter: blur(10px);
    }
    
    .ghost-settings-header h3 {
        font-size: 20px;
        font-weight: 600;
        color: var(--apple-text-primary);
        margin: 0;
        letter-spacing: -0.02em;
    }
    
    .ghost-settings-content {
        flex: 1;
        overflow-y: auto;
        padding: 24px;
        background: var(--apple-bg-secondary);
    }
    
    .ghost-settings-content::-webkit-scrollbar {
        width: 0;
    }
    
    /* Form sections */
    .settings-section {
        background: var(--apple-bg-primary);
        border-radius: var(--apple-radius-md);
        padding: 20px;
        margin-bottom: 16px;
        box-shadow: var(--apple-shadow-sm);
    }
    
    .settings-section-title {
        font-size: 13px;
        font-weight: 600;
        color: var(--apple-text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.02em;
        margin-bottom: 16px;
        padding: 0 4px;
    }
    
    /* Form controls */
    .apple-form-label {
        display: block;
        font-size: 15px;
        font-weight: 500;
        color: var(--apple-text-primary);
        margin-bottom: 8px;
        letter-spacing: -0.01em;
    }
    
    .apple-form-control {
        width: 100%;
        padding: 10px 12px;
        font-size: 15px;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
        background: var(--apple-bg-tertiary);
        border: 1px solid var(--apple-border);
        border-radius: var(--apple-radius-sm);
        color: var(--apple-text-primary);
        transition: var(--apple-transition);
        -webkit-appearance: none;
    }
    
    .apple-form-control:focus {
        outline: none;
        border-color: var(--apple-blue);
        box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
        background: var(--apple-bg-primary);
    }
    
    .apple-form-control::placeholder {
        color: var(--apple-text-tertiary);
    }
    
    .apple-form-helper {
        font-size: 13px;
        color: var(--apple-text-secondary);
        margin-top: 6px;
        line-height: 1.4;
    }
    
    /* Toggle switches - iOS style */
    .apple-switch {
        position: relative;
        display: inline-block;
        width: 51px;
        height: 31px;
    }
    
    .apple-switch input {
        opacity: 0;
        width: 0;
        height: 0;
    }
    
    .apple-switch-slider {
        position: absolute;
        cursor: pointer;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: #e9e9eb;
        transition: var(--apple-transition);
        border-radius: 31px;
    }
    
    .apple-switch-slider:before {
        position: absolute;
        content: "";
        height: 27px;
        width: 27px;
        left: 2px;
        bottom: 2px;
        background-color: white;
        transition: var(--apple-transition);
        border-radius: 50%;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    
    .apple-switch input:checked + .apple-switch-slider {
        background-color: var(--apple-green);
    }
    
    .apple-switch input:checked + .apple-switch-slider:before {
        transform: translateX(20px);
    }
    
    /* Segmented control */
    .apple-segmented-control {
        display: flex;
        background: var(--apple-bg-tertiary);
        border-radius: var(--apple-radius-sm);
        padding: 2px;
        gap: 2px;
    }
    
    .apple-segment {
        flex: 1;
        padding: 8px 16px;
        font-size: 14px;
        font-weight: 500;
        text-align: center;
        background: transparent;
        border: none;
        border-radius: 6px;
        color: var(--apple-text-primary);
        cursor: pointer;
        transition: var(--apple-transition);
    }
    
    .apple-segment.active {
        background: var(--apple-bg-primary);
        box-shadow: var(--apple-shadow-sm);
    }
    
    /* List items */
    .apple-list-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 12px 0;
        border-bottom: 1px solid var(--apple-border-light);
    }
    
    .apple-list-item:last-child {
        border-bottom: none;
    }
    
    .apple-list-item-content {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .apple-list-item-icon {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: var(--apple-bg-tertiary);
        border-radius: var(--apple-radius-sm);
        color: var(--apple-text-secondary);
    }
    
    .apple-list-item-text h4 {
        font-size: 15px;
        font-weight: 500;
        color: var(--apple-text-primary);
        margin: 0 0 2px 0;
    }
    
    .apple-list-item-text p {
        font-size: 13px;
        color: var(--apple-text-secondary);
        margin: 0;
    }
    
    /* Buttons */
    .apple-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 10px 20px;
        font-size: 15px;
        font-weight: 500;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
        border-radius: var(--apple-radius-sm);
        border: none;
        cursor: pointer;
        transition: var(--apple-transition);
        gap: 6px;
    }
    
    .apple-btn-primary {
        background: var(--apple-blue);
        color: white;
    }
    
    .apple-btn-primary:hover {
        background: var(--apple-blue-hover);
        transform: translateY(-1px);
    }
    
    .apple-btn-secondary {
        background: var(--apple-bg-tertiary);
        color: var(--apple-text-primary);
        border: 1px solid var(--apple-border);
    }
    
    .apple-btn-secondary:hover {
        background: var(--apple-bg-secondary);
    }
    
    .apple-btn-danger {
        background: transparent;
        color: var(--apple-red);
        border: 1px solid var(--apple-red);
    }
    
    .apple-btn-danger:hover {
        background: var(--apple-red);
        color: white;
    }
    
    /* Icon buttons */
    .apple-icon-btn {
        width: 32px;
        height: 32px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: transparent;
        border: none;
        border-radius: 50%;
        color: var(--apple-text-secondary);
        cursor: pointer;
        transition: var(--apple-transition);
    }
    
    .apple-icon-btn:hover {
        background: var(--apple-bg-tertiary);
        color: var(--apple-text-primary);
    }
    
    /* Subview panel styles */
    .subview-panel {
        position: fixed;
        top: 0;
        right: -420px;
        width: 420px;
        height: 100vh;
        background: var(--apple-bg-primary);
        border-left: 1px solid var(--apple-border-light);
        transition: var(--apple-transition);
        z-index: 1060;
        display: flex;
        flex-direction: column;
        font-family: -apple-system, BlinkMacSystemFont, 'Inter', sans-serif;
    }
    
    .subview-panel.active {
        right: 0;
    }
    
    .subview-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 20px 24px;
        background: var(--apple-bg-primary);
        border-bottom: 1px solid var(--apple-border-light);
        -webkit-backdrop-filter: blur(10px);
        backdrop-filter: blur(10px);
    }
    
    .subview-content {
        flex: 1;
        overflow-y: auto;
        padding: 24px;
        background: var(--apple-bg-secondary);
    }
    
    /* Character counter */
    .char-counter {
        font-size: 13px;
        font-weight: 500;
        margin-top: 6px;
        display: flex;
        align-items: center;
        gap: 4px;
    }
    
    .char-counter-good {
        color: var(--apple-green);
    }
    
    .char-counter-warning {
        color: var(--apple-yellow);
    }
    
    .char-counter-danger {
        color: var(--apple-red);
    }
    
    /* Social preview cards */
    .social-preview {
        border: 1px solid var(--apple-border);
        border-radius: var(--apple-radius-md);
        overflow: hidden;
        margin-top: 16px;
        background: var(--apple-bg-primary);
        box-shadow: var(--apple-shadow-sm);
    }
    
    .social-preview-image {
        height: 200px;
        background: var(--apple-bg-tertiary);
        background-size: cover;
        background-position: center;
    }
    
    .social-preview-content {
        padding: 16px;
    }
    
    .social-preview-domain {
        font-size: 12px;
        color: var(--apple-text-secondary);
        text-transform: uppercase;
        letter-spacing: 0.02em;
        margin-bottom: 4px;
    }
    
    .social-preview-title {
        font-size: 16px;
        font-weight: 600;
        color: var(--apple-text-primary);
        margin-bottom: 4px;
        line-height: 1.3;
    }
    
    .social-preview-description {
        font-size: 14px;
        color: var(--apple-text-secondary);
        line-height: 1.4;
    }
    
    /* Tags */
    .apple-tag {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: var(--apple-blue);
        color: white;
        border-radius: 20px;
        font-size: 14px;
        font-weight: 500;
    }
    
    .apple-tag-remove {
        background: none;
        border: none;
        color: white;
        opacity: 0.7;
        cursor: pointer;
        padding: 0;
        transition: opacity 0.2s;
    }
    
    .apple-tag-remove:hover {
        opacity: 1;
    }
    
    /* Animations */
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
    
    .animate-slide-in {
        animation: slideIn 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .animate-fade-in {
        animation: fadeIn 0.3s ease-in-out;
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
                        <cfif postData.status eq "published">
                            <!-- Unpublish button for published posts -->
                            <button type="button" class="btn btn-outline-secondary" onclick="unpublishPost()">
                                <i class="ti ti-eye-off me-2"></i>
                                Unpublish
                            </button>
                            
                            <!-- Update button for published posts -->
                            <button type="button" class="btn btn-primary" onclick="updatePost()">
                                <i class="ti ti-refresh me-2"></i>
                                Update
                            </button>
                        <cfelseif postData.status eq "scheduled">
                            <!-- Unpublish button for scheduled posts -->
                            <button type="button" class="btn btn-outline-secondary" onclick="unpublishPost()">
                                <i class="ti ti-eye-off me-2"></i>
                                Unschedule
                            </button>
                            
                            <!-- Update button for scheduled posts -->
                            <button type="button" class="btn btn-primary" onclick="updatePost()">
                                <i class="ti ti-refresh me-2"></i>
                                Update
                            </button>
                        <cfelse>
                            <!-- Preview button for non-published posts -->
                            <button type="button" class="btn btn-outline-secondary" onclick="previewPost()">
                                <i class="ti ti-eye me-2"></i>
                                Preview
                            </button>
                            
                            <!-- Publish button -->
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
                    <h3>Post Settings</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                
                <div class="ghost-settings-content">
                    <!-- Post Details Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Post Details</div>
                        
                        <!-- URL Slug -->
                        <div class="mb-4">
                            <label class="apple-form-label">Post URL</label>
                            <div class="flex items-center gap-2">
                                <span class="text-sm text-gray-500">/ghost/</span>
                                <input type="text" 
                                       id="postSlug" 
                                       class="apple-form-control" 
                                       value="<cfoutput>#htmlEditFormat(postData.slug)#</cfoutput>"
                                       placeholder="post-url">
                            </div>
                            <p class="apple-form-helper">The URL for this post</p>
                        </div>
                    
                        <!-- Publish Date -->
                        <div class="mb-4">
                            <label class="apple-form-label">Publish date</label>
                            <input type="datetime-local" 
                                   id="publishDate" 
                                   class="apple-form-control"
                                   value="<cfif isDate(postData.published_at)><cfoutput>#dateFormat(postData.published_at, 'yyyy-mm-dd')#T#timeFormat(postData.published_at, 'HH:mm')#</cfoutput></cfif>">
                            <p class="apple-form-helper">Set a future date to schedule this post</p>
                        </div>
                    </div>
                    
                    <!-- Tags & Metadata Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Tags & Metadata</div>
                        
                        <!-- Tags -->
                        <div class="mb-4">
                            <label class="apple-form-label">Tags</label>
                            <div class="mb-3">
                                <div id="selectedTags" class="flex flex-wrap gap-2 mb-3">
                                    <cfloop array="#postData.tags#" index="tag">
                                        <span class="apple-tag">
                                            <cfoutput>#tag.name#</cfoutput>
                                            <button type="button" class="apple-tag-remove" onclick="removeTag('<cfoutput>#tag.id#</cfoutput>')">
                                                <i class="ti ti-x text-sm"></i>
                                            </button>
                                        </span>
                                    </cfloop>
                                </div>
                                <select id="tagSelector" class="apple-form-control" onchange="addTag()">
                                    <option value="">Add a tag...</option>
                                    <cfloop array="#allTags#" index="tag">
                                        <option value="<cfoutput>#tag.id#</cfoutput>" data-name="<cfoutput>#tag.name#</cfoutput>">
                                            <cfoutput>#tag.name#</cfoutput>
                                        </option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                    
                        <!-- Post Access -->
                        <div class="mb-4">
                            <label class="apple-form-label">Post access</label>
                            <div class="apple-segmented-control">
                                <button type="button" class="apple-segment <cfif postData.visibility eq 'public'>active</cfif>" onclick="setVisibility('public')">
                                    Public
                                </button>
                                <button type="button" class="apple-segment <cfif postData.visibility eq 'members'>active</cfif>" onclick="setVisibility('members')">
                                    Members
                                </button>
                                <button type="button" class="apple-segment <cfif postData.visibility eq 'paid'>active</cfif>" onclick="setVisibility('paid')">
                                    Paid only
                                </button>
                            </div>
                            <p class="apple-form-helper">Control who can see this post</p>
                        </div>
                    
                        <!-- Excerpt -->
                        <div>
                            <label class="apple-form-label">Excerpt</label>
                            <textarea id="postExcerpt" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="A short description of your post"><cfoutput>#htmlEditFormat(postData.custom_excerpt)#</cfoutput></textarea>
                            <p class="apple-form-helper">Excerpts are optional hand-crafted summaries of your content</p>
                        </div>
                    </div>
                    
                    <!-- Publishing Options Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Publishing Options</div>
                        
                        <!-- Authors -->
                        <div class="mb-4">
                            <label class="apple-form-label">Authors</label>
                            <div class="mb-3">
                                <div id="selectedAuthors" class="flex flex-wrap gap-2 mb-3">
                                    <!--- Show current author(s) from posts_authors table --->
                                    <cfquery name="postAuthors" datasource="#request.dsn#">
                                        SELECT u.id, u.name 
                                        FROM posts_authors pa
                                        INNER JOIN users u ON pa.author_id = u.id
                                        WHERE pa.post_id = <cfqueryparam value="#postData.id#" cfsqltype="cf_sql_varchar">
                                        ORDER BY pa.sort_order
                                    </cfquery>
                                    
                                    <cfif postAuthors.recordCount gt 0>
                                        <cfloop query="postAuthors">
                                            <span class="apple-tag" data-author-id="<cfoutput>#postAuthors.id#</cfoutput>">
                                                <cfoutput>#postAuthors.name#</cfoutput>
                                                <button type="button" class="apple-tag-remove" onclick="removeAuthor('<cfoutput>#postAuthors.id#</cfoutput>')">
                                                    <i class="ti ti-x text-sm"></i>
                                                </button>
                                            </span>
                                        </cfloop>
                                    <cfelse>
                                        <!--- If no authors, use the created_by user --->
                                        <cfquery name="defaultAuthor" datasource="#request.dsn#">
                                            SELECT id, name FROM users WHERE id = <cfqueryparam value="#postData.created_by#" cfsqltype="cf_sql_varchar">
                                        </cfquery>
                                        <cfif defaultAuthor.recordCount gt 0>
                                            <span class="apple-tag" data-author-id="<cfoutput>#defaultAuthor.id#</cfoutput>">
                                                <cfoutput>#defaultAuthor.name#</cfoutput>
                                                <button type="button" class="apple-tag-remove" onclick="removeAuthor('<cfoutput>#defaultAuthor.id#</cfoutput>')">
                                                    <i class="ti ti-x text-sm"></i>
                                                </button>
                                            </span>
                                        </cfif>
                                    </cfif>
                                </div>
                                <select id="authorSelector" class="apple-form-control" onchange="addAuthor()">
                                    <option value="">Add an author...</option>
                                    <cfquery name="allUsers" datasource="#request.dsn#">
                                        SELECT id, name FROM users WHERE status = 'active' ORDER BY name
                                    </cfquery>
                                    <cfloop query="allUsers">
                                        <option value="<cfoutput>#allUsers.id#</cfoutput>" 
                                                data-name="<cfoutput>#allUsers.name#</cfoutput>"
                                                class="author-option-<cfoutput>#allUsers.id#</cfoutput>"
                                                <cfif postAuthors.recordCount gt 0>
                                                    <cfloop query="postAuthors">
                                                        <cfif postAuthors.id eq allUsers.id>style="display: none;"</cfif>
                                                    </cfloop>
                                                <cfelseif defaultAuthor.recordCount gt 0 and defaultAuthor.id eq allUsers.id>
                                                    style="display: none;"
                                                </cfif>>
                                            <cfoutput>#allUsers.name#</cfoutput>
                                        </option>
                                    </cfloop>
                                </select>
                            </div>
                            <p class="apple-form-helper">Add multiple authors to this post</p>
                        </div>
                    
                        <!-- Post Template -->
                        <div class="mb-4">
                            <label class="apple-form-label">Template</label>
                            <select id="postTemplate" class="apple-form-control">
                                <option value="">Default</option>
                                <option value="custom" <cfif structKeyExists(postData, "custom_template") and postData.custom_template eq "custom">selected</cfif>>Custom</option>
                                <option value="page" <cfif structKeyExists(postData, "custom_template") and postData.custom_template eq "page">selected</cfif>>Page</option>
                            </select>
                            <p class="apple-form-helper">Select a custom template for this post</p>
                        </div>
                    
                        <!-- Feature Options -->
                        <cfif postData.type eq "page">
                        <div class="apple-list-item">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-eye"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Show title and feature image</h4>
                                </div>
                            </div>
                            <label class="apple-switch">
                                <input type="checkbox" 
                                       id="showTitleAndFeatureImage"
                                       <cfif not structKeyExists(postData, "show_title_and_feature_image") or postData.show_title_and_feature_image>checked</cfif>>
                                <span class="apple-switch-slider"></span>
                            </label>
                        </div>
                        </cfif>
                        
                        <div class="apple-list-item">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-star"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Feature this post</h4>
                                    <p>Display prominently on your site</p>
                                </div>
                            </div>
                            <label class="apple-switch">
                                <input type="checkbox" 
                                       id="featuredPost"
                                       <cfif postData.featured>checked</cfif>>
                                <span class="apple-switch-slider"></span>
                            </label>
                        </div>
                    </div>
                    
                    <!-- Advanced Settings Section -->
                    <div class="settings-section">
                        <div class="settings-section-title">Advanced Settings</div>
                        
                        <div class="apple-list-item" onclick="showSubview('postHistory')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-history"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Post history</h4>
                                    <p>View and restore previous versions</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('codeInjection')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-code"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Code injection</h4>
                                    <p>Add custom code to this post</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('metaData')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-search"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Meta data</h4>
                                    <p>SEO title, description and URL</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('twitterData')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-brand-x"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>X card</h4>
                                    <p>Customize X/Twitter preview</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                        
                        <div class="apple-list-item" onclick="showSubview('facebookData')" style="cursor: pointer;">
                            <div class="apple-list-item-content">
                                <div class="apple-list-item-icon">
                                    <i class="ti ti-brand-facebook"></i>
                                </div>
                                <div class="apple-list-item-text">
                                    <h4>Facebook card</h4>
                                    <p>Customize Facebook preview</p>
                                </div>
                            </div>
                            <i class="ti ti-chevron-right text-gray-400"></i>
                        </div>
                    </div>
                    
                    <!-- Delete Post Button -->
                    <div class="settings-section">
                        <button type="button" class="apple-btn apple-btn-danger w-100" onclick="confirmDeletePost()">
                            <i class="ti ti-trash"></i>
                            Delete post
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Subview Panels -->
            <!-- Code Injection Subview -->
            <div class="subview-panel" id="codeInjectionSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('codeInjection')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Code injection</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <div class="settings-section">
                        <div class="mb-4">
                            <label class="apple-form-label">Post header</label>
                            <textarea id="codeinjectionHead" 
                                      class="apple-form-control" 
                                      style="font-family: 'SF Mono', Monaco, monospace; font-size: 13px;"
                                      rows="10"
                                      placeholder="Code injected into the header of this post"><cfoutput>#htmlEditFormat(structKeyExists(postData, "codeinjection_head") ? postData.codeinjection_head : "")#</cfoutput></textarea>
                            <p class="apple-form-helper">Code here will be injected into the <code style="background: var(--apple-bg-tertiary); padding: 2px 6px; border-radius: 4px;">&lt;head&gt;</code> tag</p>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div>
                            <label class="apple-form-label">Post footer</label>
                            <textarea id="codeinjectionFoot" 
                                      class="apple-form-control" 
                                      style="font-family: 'SF Mono', Monaco, monospace; font-size: 13px;"
                                      rows="10"
                                      placeholder="Code injected into the footer of this post"><cfoutput>#htmlEditFormat(structKeyExists(postData, "codeinjection_foot") ? postData.codeinjection_foot : "")#</cfoutput></textarea>
                            <p class="apple-form-helper">Code here will be injected before the closing <code style="background: var(--apple-bg-tertiary); padding: 2px 6px; border-radius: 4px;">&lt;/body&gt;</code> tag</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Meta Data Subview -->
            <div class="subview-panel" id="metaDataSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('metaData')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Meta data</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <div class="settings-section">
                        <div class="settings-section-title">Search Engine Optimization</div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Meta title</label>
                            <input type="text" 
                                   id="metaTitle" 
                                   class="apple-form-control" 
                                   value="<cfoutput>#htmlEditFormat(postData.meta_title)#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <div class="char-counter" id="metaTitleCounter">
                                <span class="text-gray-500">Recommended: 60 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="metaTitleCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Meta description</label>
                            <textarea id="metaDescription" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="A description of your post for search engines"><cfoutput>#htmlEditFormat(postData.meta_description)#</cfoutput></textarea>
                            <div class="char-counter" id="metaDescriptionCounter">
                                <span class="text-gray-500">Recommended: 160 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="metaDescriptionCount">0</strong></span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div>
                            <label class="apple-form-label">Canonical URL</label>
                            <input type="url" 
                                   id="canonicalUrl" 
                                   class="apple-form-control"
                                   value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "canonical_url") ? postData.canonical_url : "")#</cfoutput>"
                                   placeholder="https://example.com/original-post">
                            <p class="apple-form-helper">Set a canonical URL if this post was first published elsewhere</p>
                            <div id="canonicalUrlPreview" class="mt-2 text-sm text-blue-600" style="display: none;">
                                <i class="ti ti-link"></i> <span id="canonicalUrlText"></span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Search Preview -->
                    <div class="settings-section">
                        <div class="settings-section-title">Search Result Preview</div>
                        <div class="p-4 bg-white rounded-lg border">
                            <h4 class="text-blue-600 text-lg mb-1" id="searchPreviewTitle"><cfoutput>#postData.title#</cfoutput></h4>
                            <p class="text-green-700 text-sm mb-1">clitools.app/ghost/<span id="searchPreviewSlug"><cfoutput>#postData.slug#</cfoutput></span></p>
                            <p class="text-gray-600 text-sm" id="searchPreviewDesc"><cfoutput><cfscript>
                                // Search preview description fallback logic
                                searchDesc = "";
                                if (len(postData.meta_description)) {
                                    searchDesc = postData.meta_description;
                                } else if (len(postData.custom_excerpt)) {
                                    searchDesc = postData.custom_excerpt;
                                } else if (len(postData.html)) {
                                    // Extract first paragraph from HTML content
                                    firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
                                    if (arrayLen(firstP) gt 0) {
                                        // Strip HTML tags from first paragraph
                                        searchDesc = reReplace(firstP[1], "<[^>]*>", "", "all");
                                        searchDesc = replace(searchDesc, "&nbsp;", " ", "all");
                                        searchDesc = replace(searchDesc, "&amp;", "&", "all");
                                        searchDesc = replace(searchDesc, "&lt;", "<", "all");
                                        searchDesc = replace(searchDesc, "&gt;", ">", "all");
                                        searchDesc = replace(searchDesc, "&quot;", '"', "all");
                                        searchDesc = trim(searchDesc);
                                    }
                                }
                                writeOutput(left(searchDesc, 160));
                            </cfscript></cfoutput></p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Twitter/X Card Subview -->
            <div class="subview-panel" id="twitterDataSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('twitterData')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>X card</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <!-- Twitter Preview -->
                    <div class="settings-section">
                        <div class="settings-section-title">Preview</div>
                        <div class="social-preview">
                            <div id="twitterPreviewImage" class="social-preview-image"></div>
                            <div class="social-preview-content">
                                <p class="social-preview-domain">CLITOOLS.APP</p>
                                <h4 id="twitterPreviewTitle" class="social-preview-title"><cfoutput>#len(postData.twitter_title) ? postData.twitter_title : postData.title#</cfoutput></h4>
                                <p id="twitterPreviewDesc" class="social-preview-description"><cfoutput><cfscript>
                                    // Twitter/X description fallback logic
                                    twitterDesc = "";
                                    if (len(postData.twitter_description)) {
                                        twitterDesc = postData.twitter_description;
                                    } else if (len(postData.meta_description)) {
                                        twitterDesc = postData.meta_description;
                                    } else if (len(postData.custom_excerpt)) {
                                        twitterDesc = postData.custom_excerpt;
                                    } else if (len(postData.html)) {
                                        // Extract first paragraph from HTML content
                                        firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
                                        if (arrayLen(firstP) gt 0) {
                                            // Strip HTML tags from first paragraph
                                            twitterDesc = reReplace(firstP[1], "<[^>]*>", "", "all");
                                            twitterDesc = replace(twitterDesc, "&nbsp;", " ", "all");
                                            twitterDesc = replace(twitterDesc, "&amp;", "&", "all");
                                            twitterDesc = replace(twitterDesc, "&lt;", "<", "all");
                                            twitterDesc = replace(twitterDesc, "&gt;", ">", "all");
                                            twitterDesc = replace(twitterDesc, "&quot;", '"', "all");
                                            twitterDesc = trim(twitterDesc);
                                        }
                                    }
                                    writeOutput(left(twitterDesc, 125));
                                </cfscript></cfoutput></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div class="settings-section-title">X/Twitter Settings</div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">X title</label>
                            <input type="text" 
                                   id="twitterTitle" 
                                   class="apple-form-control"
                                   value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "twitter_title") ? postData.twitter_title : "")#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <div class="char-counter" id="twitterTitleCounter">
                                <span class="text-gray-500">Recommended: 70 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="twitterTitleCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">X description</label>
                            <textarea id="twitterDescription" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="<cfoutput>#htmlEditFormat(len(postData.meta_description) ? postData.meta_description : (len(postData.custom_excerpt) ? postData.custom_excerpt : left(firstParagraphText, 125)))#</cfoutput>"><cfoutput>#htmlEditFormat(structKeyExists(postData, "twitter_description") ? postData.twitter_description : "")#</cfoutput></textarea>
                            <div class="char-counter" id="twitterDescriptionCounter">
                                <span class="text-gray-500">Recommended: 125 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="twitterDescriptionCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div>
                            <label class="apple-form-label">X image</label>
                            <div class="mb-2">
                                <input type="url" 
                                       id="twitterImage" 
                                       class="apple-form-control"
                                       value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "twitter_image") ? postData.twitter_image : "")#</cfoutput>"
                                       placeholder="URL of image for X/Twitter card">
                            </div>
                            <button type="button" class="apple-btn apple-btn-secondary">
                                <i class="ti ti-upload"></i>
                                Upload image
                            </button>
                    </div>
                </div>
            </div>
            
            <!-- Facebook Card Subview -->
            <div class="subview-panel" id="facebookDataSubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('facebookData')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Facebook card</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <!-- Facebook Preview -->
                    <div class="settings-section">
                        <div class="settings-section-title">Preview</div>
                        <div class="social-preview">
                            <div id="fbPreviewImage" class="social-preview-image"></div>
                            <div class="social-preview-content">
                                <p class="social-preview-domain">CLITOOLS.APP</p>
                                <h4 id="fbPreviewTitle" class="social-preview-title"><cfoutput>#len(postData.og_title) ? postData.og_title : postData.title#</cfoutput></h4>
                                <p id="fbPreviewDesc" class="social-preview-description"><cfoutput><cfscript>
                                    // Facebook description fallback logic
                                    fbDesc = "";
                                    if (len(postData.og_description)) {
                                        fbDesc = postData.og_description;
                                    } else if (len(postData.meta_description)) {
                                        fbDesc = postData.meta_description;
                                    } else if (len(postData.custom_excerpt)) {
                                        fbDesc = postData.custom_excerpt;
                                    } else if (len(postData.html)) {
                                        // Extract first paragraph from HTML content
                                        firstP = reMatch("<p[^>]*>(.*?)</p>", postData.html);
                                        if (arrayLen(firstP) gt 0) {
                                            // Strip HTML tags from first paragraph
                                            fbDesc = reReplace(firstP[1], "<[^>]*>", "", "all");
                                            fbDesc = replace(fbDesc, "&nbsp;", " ", "all");
                                            fbDesc = replace(fbDesc, "&amp;", "&", "all");
                                            fbDesc = replace(fbDesc, "&lt;", "<", "all");
                                            fbDesc = replace(fbDesc, "&gt;", ">", "all");
                                            fbDesc = replace(fbDesc, "&quot;", '"', "all");
                                            fbDesc = trim(fbDesc);
                                        }
                                    }
                                    writeOutput(left(fbDesc, 160));
                                </cfscript></cfoutput></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="settings-section">
                        <div class="settings-section-title">Facebook Settings</div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Facebook title</label>
                            <input type="text" 
                                   id="facebookTitle" 
                                   class="apple-form-control"
                                   value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "og_title") ? postData.og_title : "")#</cfoutput>"
                                   placeholder="<cfoutput>#htmlEditFormat(postData.title)#</cfoutput>">
                            <div class="char-counter" id="facebookTitleCounter">
                                <span class="text-gray-500">Recommended: 60 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="facebookTitleCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="apple-form-label">Facebook description</label>
                            <textarea id="facebookDescription" 
                                      class="apple-form-control" 
                                      rows="3"
                                      placeholder="<cfoutput>#htmlEditFormat(len(postData.meta_description) ? postData.meta_description : (len(postData.custom_excerpt) ? postData.custom_excerpt : left(firstParagraphText, 160)))#</cfoutput>"><cfoutput>#htmlEditFormat(structKeyExists(postData, "og_description") ? postData.og_description : "")#</cfoutput></textarea>
                            <div class="char-counter" id="facebookDescriptionCounter">
                                <span class="text-gray-500">Recommended: 160 characters</span>
                                <span class="ms-2">•</span>
                                <span class="ms-2">You've used <strong id="facebookDescriptionCount">0</strong></span>
                            </div>
                        </div>
                        
                        <div>
                            <label class="apple-form-label">Facebook image</label>
                            <div class="mb-2">
                                <input type="url" 
                                       id="facebookImage" 
                                       class="apple-form-control"
                                       value="<cfoutput>#htmlEditFormat(structKeyExists(postData, "og_image") ? postData.og_image : "")#</cfoutput>"
                                       placeholder="URL of image for Facebook card">
                            </div>
                            <button type="button" class="apple-btn apple-btn-secondary">
                                <i class="ti ti-upload"></i>
                                Upload image
                            </button>
                            <p class="apple-form-helper mt-2">Recommended size: 1200x630px (1.91:1 ratio)</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Post History Subview -->
            <div class="subview-panel" id="postHistorySubview">
                <div class="subview-header">
                    <button type="button" class="apple-icon-btn" onclick="closeSubview('postHistory')">
                        <i class="ti ti-arrow-left text-xl"></i>
                    </button>
                    <h3>Post history</h3>
                    <button type="button" class="apple-icon-btn" onclick="toggleSettings()">
                        <i class="ti ti-x text-xl"></i>
                    </button>
                </div>
                <div class="subview-content">
                    <div class="settings-section">
                        <div class="text-center py-5">
                            <div class="w-20 h-20 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                                <i class="ti ti-history text-3xl text-gray-400"></i>
                            </div>
                            <h4 class="text-lg font-semibold text-gray-900 mb-2">Post history</h4>
                            <p class="text-gray-500 mb-1">Version history is coming soon</p>
                            <p class="text-sm text-gray-400">You'll be able to view and restore previous versions of this post</p>
                        </div>
                    </div>
                    
                    <!-- Placeholder for future history items -->
                    <div class="settings-section" style="display: none;">
                        <div class="settings-section-title">Recent Versions</div>
                        <div class="history-item">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h5 class="font-medium text-gray-900">Current version</h5>
                                    <p class="history-meta">Edited just now</p>
                                </div>
                                <span class="text-sm text-green-600">Current</span>
                            </div>
                        </div>
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
            <button type="button" class="link-hover-btn" onclick="if(currentHoveredLink) editExistingLink()" title="Edit link">
                <i class="ti ti-edit"></i>
            </button>
            <button type="button" class="link-hover-btn" onclick="if(currentHoveredLink) removeExistingLink()" title="Remove link">
                <i class="ti ti-unlink"></i>
            </button>
            <button type="button" class="link-hover-btn" onclick="openLinkInNewTab()" title="Open link">
                <i class="ti ti-external-link"></i>
            </button>
        </div>
    </div>
    
    <!-- Unsaved Changes Modal -->
    <div id="unsavedChangesModal" class="ghost-modal-backdrop" style="display: none;">
        <div class="ghost-modal">
            <div class="ghost-modal-header">
                <h3>Are you sure you want to leave this page?</h3>
                <button type="button" class="ghost-modal-close" onclick="hideUnsavedChangesModal()">
                    <i class="ti ti-x text-xl"></i>
                </button>
            </div>
            <div class="ghost-modal-body">
                <p class="text-gray-600 text-base">
                    You have unsaved changes. Do you want to save before leaving?
                </p>
            </div>
            <div class="ghost-modal-footer">
                <button type="button" class="ghost-btn ghost-btn-link" onclick="leaveWithoutSaving()">
                    <span>Leave without saving</span>
                </button>
                <button type="button" class="ghost-btn ghost-btn-link" onclick="saveAndStay()">
                    <span>Save & stay</span>
                </button>
                <button type="button" class="ghost-btn ghost-btn-black" onclick="saveAndLeave()">
                    <span>Save & leave</span>
                </button>
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
        <input type="hidden" id="postVisibility" value="<cfoutput>#postData.visibility#</cfoutput>">
        <input type="hidden" name="featured" id="formFeatured">
        <input type="hidden" name="published_at" id="formPublishedAt">
        <input type="hidden" name="tags" id="formTags">
        <input type="hidden" name="authors" id="formAuthors">
        <input type="hidden" name="status" id="formStatus">
        <input type="hidden" name="card_data" id="formCardData">
        
        <!--- Additional settings fields --->
        <input type="hidden" name="custom_template" id="formCustomTemplate">
        <input type="hidden" name="codeinjection_head" id="formCodeinjectionHead">
        <input type="hidden" name="codeinjection_foot" id="formCodeinjectionFoot">
        <input type="hidden" name="canonical_url" id="formCanonicalUrl">
        <input type="hidden" name="show_title_and_feature_image" id="formShowTitleAndFeatureImage">
        
        <!--- Social media fields --->
        <input type="hidden" name="og_title" id="formOgTitle">
        <input type="hidden" name="og_description" id="formOgDescription">
        <input type="hidden" name="og_image" id="formOgImage">
        <input type="hidden" name="twitter_title" id="formTwitterTitle">
        <input type="hidden" name="twitter_description" id="formTwitterDescription">
        <input type="hidden" name="twitter_image" id="formTwitterImage">
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
    // console.log('Original status:', originalStatus, 'PostData:', postData);
    
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
    
    // Toggle settings panel - defined early to be available for onclick handlers
    function toggleSettings() {
        const panel = document.getElementById('settingsPanel');
        panel.classList.toggle('active');
        if (panel.classList.contains('active')) {
            panel.classList.add('animate-slide-in');
        }
    }
    
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
        
        // Only enable text formatting popup on edit/new pages
        const currentPath = window.location.pathname;
        const isEditPage = currentPath.includes('/posts/edit') || currentPath.includes('/posts/new') || 
                          currentPath.includes('/pages/edit') || currentPath.includes('/pages/new');
        
        if (isEditPage) {
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
        }
        
        // Hide popup when clicking outside
        document.addEventListener('mousedown', function(e) {
            const popup = document.getElementById('formattingPopup');
            if (!popup.contains(e.target) && !e.target.closest('.card-content')) {
                popup.classList.remove('show');
            }
        });
        
        // Parse existing HTML content into cards
        // console.log('PostData:', postData);
        // console.log('PostData.html:', postData.html);
        // console.log('PostData.HTML:', postData.HTML);
        
        // ColdFusion returns uppercase keys, so check both
        const htmlContent = postData.html || postData.HTML;
        const cardData = postData.card_data || postData.CARD_DATA;
        
        // Try to load card data first
        if (cardData) {
            try {
                // Parse the card data if it's a string
                const parsedCardData = typeof cardData === 'string' ? JSON.parse(cardData) : cardData;
                if (Array.isArray(parsedCardData) && parsedCardData.length > 0) {
                    contentCards = parsedCardData;
                    
                    // Recreate the cards in the editor
                    isCreatingCards = true;
                    contentCards.forEach(card => {
                        const cardElement = createCardElement(card);
                        document.getElementById('editorContent').appendChild(cardElement);
                    });
                    isCreatingCards = false;
                    
                    // Add the add button at the end
                    const addButton = createAddButton();
                    document.getElementById('editorContent').appendChild(addButton);
                } else if (htmlContent) {
                    parseHtmlToCards(htmlContent, true); // true = initial load
                } else {
                    // Add initial paragraph card for new posts
                    addCardInternal('paragraph', {});
                }
            } catch (e) {
                console.error('Error parsing card data:', e);
                // Fall back to HTML parsing
                if (htmlContent) {
                    parseHtmlToCards(htmlContent, true);
                } else {
                    addCardInternal('paragraph', {});
                }
            }
        } else if (htmlContent) {
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
            
            // Update all previews now that content is loaded
            updateTwitterPreview();
            updateFacebookPreview();
            updateSearchPreview();
            updateCanonicalUrlPreview();
            
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
                // console.log('Values unchanged after init, ensuring isDirty is false');
            } else {
                // console.log('Values changed during init:', initialValues, 'vs', currentValues);
            }
            
            // Update all previews after content is loaded
            updateSearchPreview();
            updateTwitterPreview();
            updateFacebookPreview();
            
        }, 2000); // Increased timeout to ensure all initialization is complete including blur events
        
        // Auto-generate slug from title based on post status
        let slugGenerationTimer;
        document.getElementById('postTitle').addEventListener('input', function() {
            const titleValue = this.value;
            
            console.log('Title input event:', titleValue);
            
            // Clear previous timer
            if (slugGenerationTimer) {
                clearTimeout(slugGenerationTimer);
            }
            
            // Debounce slug generation
            slugGenerationTimer = setTimeout(() => {
                const currentSlug = document.getElementById('postSlug').value.trim();
                const trimmedTitle = titleValue.trim();
                
                // For draft posts, always auto-generate slug from title (or if slug is empty)
                // For published/scheduled posts, only if slug is manually cleared
                const shouldAutoGenerateSlug = (originalStatus === 'draft' && trimmedTitle) || 
                                              (!currentSlug && trimmedTitle && originalStatus !== 'published' && originalStatus !== 'scheduled');
                
                console.log('Slug generation check:', {
                    title: trimmedTitle,
                    currentSlug: currentSlug,
                    originalStatus: originalStatus,
                    shouldAutoGenerateSlug: shouldAutoGenerateSlug
                });
                
                if (shouldAutoGenerateSlug) {
                    const slug = generateSlug(trimmedTitle);
                    isProgrammaticChange = true;
                    document.getElementById('postSlug').value = slug;
                    setTimeout(() => { isProgrammaticChange = false; }, 10);
                    
                    console.log('Set slug field to:', slug);
                    
                    // Delay auto-save to allow for more typing
                    if (autosaveTimer) {
                        clearTimeout(autosaveTimer);
                    }
                    autosaveTimer = setTimeout(() => {
                        if (isDirty) {
                            autosave();
                        }
                    }, 2000);
                    
                    markDirtySafe();
                }
            }, 300); // 300ms debounce
            
            // Update search preview when title changes (immediate)
            updateSearchPreview();
            updateTwitterPreview();
            updateFacebookPreview();
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
                    // console.log('Focusing card element:', editableElement.id);
                    editableElement.focus();
                }
            }
            
            // Close settings panels when clicking outside, unless actively editing
            const clickedOnSettings = e.target.closest('.ghost-card-settings');
            const clickedOnCard = e.target.closest('.card-content');
            
            if (!clickedOnSettings && !clickedOnCard) {
                // Close all settings panels if clicked outside any card
                document.querySelectorAll('.ghost-card-settings.active').forEach(panel => {
                    // Check if any input/button in this panel has focus
                    const hasFocus = panel.contains(document.activeElement);
                    if (!hasFocus) {
                        panel.classList.remove('active');
                    }
                });
            }
        });
    });
    
    // Parse HTML content into cards
    function parseHtmlToCards(html, isInitialLoad = false) {
        // console.log('parseHtmlToCards called with:', html);
        
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
        // console.log('Found elements:', elements.length);
        
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
                    // Check for gallery card
                    if (element.classList.contains('kg-gallery-card')) {
                        // Gallery card
                        const galleryContainer = element.querySelector('.kg-gallery-container');
                        if (galleryContainer) {
                            const images = [];
                            const galleryImages = galleryContainer.querySelectorAll('.kg-gallery-image img');
                            
                            galleryImages.forEach(img => {
                                // Clean up image URL
                                let imgSrc = img.src;
                                if (imgSrc.includes('__GHOST_URL__')) {
                                    imgSrc = imgSrc.replace('__GHOST_URL__', '');
                                }
                                // Ensure /ghost prefix for content images
                                if (imgSrc.includes('/content/') && !imgSrc.includes('/ghost/')) {
                                    imgSrc = '/ghost' + imgSrc;
                                }
                                
                                images.push({
                                    src: imgSrc,
                                    alt: img.alt || '',
                                    width: img.getAttribute('width') || '',
                                    height: img.getAttribute('height') || ''
                                });
                            });
                            
                            if (images.length > 0) {
                                addCardInternal('gallery', { images: images });
                            }
                        }
                        break;
                    }
                    
                    // Check for bookmark card
                    if (element.classList.contains('kg-bookmark-card')) {
                        // console.log('Found bookmark card in figure element');
                        // Bookmark card
                        const linkElement = element.querySelector('.kg-bookmark-container');
                        const titleElement = element.querySelector('.kg-bookmark-title');
                        const descriptionElement = element.querySelector('.kg-bookmark-description');
                        const authorElement = element.querySelector('.kg-bookmark-author');
                        const publisherElement = element.querySelector('.kg-bookmark-publisher');
                        const thumbnailElement = element.querySelector('.kg-bookmark-thumbnail img');
                        const iconElement = element.querySelector('.kg-bookmark-icon');
                        
                        if (linkElement) {
                            const bookmarkData = {
                                url: linkElement.href,
                                title: titleElement?.textContent || '',
                                description: descriptionElement?.textContent || '',
                                author: authorElement?.textContent || '',
                                publisher: publisherElement?.textContent || '',
                                thumbnail: thumbnailElement?.src || '',
                                icon: iconElement?.src || ''
                            };
                            // console.log('Bookmark data:', bookmarkData);
                            addCardInternal('bookmark', bookmarkData);
                        }
                        break;
                    }
                    
                    // Check if it's an image or video figure
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
                        
                        // Clean up image URL
                        let imageSrc = img.src;
                        if (imageSrc.includes('__GHOST_URL__')) {
                            imageSrc = imageSrc.replace('__GHOST_URL__', '');
                        }
                        // Ensure /ghost prefix for content images
                        if (imageSrc.includes('/content/') && !imageSrc.includes('/ghost/')) {
                            imageSrc = '/ghost' + imageSrc;
                        }
                        
                        addCardInternal('image', {
                            src: imageSrc,
                            alt: img.alt || '',
                            caption: element.querySelector('figcaption')?.textContent || '',
                            cardWidth: cardWidth,
                            href: href
                        });
                    }
                    break;
                    
                case 'img':
                    // Clean up image URL
                    let imgSrc = element.src;
                    if (imgSrc.includes('__GHOST_URL__')) {
                        imgSrc = imgSrc.replace('__GHOST_URL__', '');
                    }
                    // Ensure /ghost prefix for content images
                    if (imgSrc.includes('/content/') && !imgSrc.includes('/ghost/')) {
                        imgSrc = '/ghost' + imgSrc;
                    }
                    
                    addCardInternal('image', {
                        src: imgSrc,
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
                    // Check for header card
                    if (element.classList.contains('kg-header-card')) {
                        const textContainer = element.querySelector('.kg-header-card-text');
                        const headingElement = element.querySelector('.kg-header-card-heading');
                        const subheadingElement = element.querySelector('.kg-header-card-subheading');
                        const buttonElement = element.querySelector('.kg-header-card-button');
                        const backgroundImage = element.querySelector('.kg-header-card-image') || element.querySelector('img.kg-header-card-image');
                        
                        // Determine size and layout based on classes
                        let size = 'small';
                        let layout = 'regular';
                        
                        if (element.classList.contains('kg-layout-split')) {
                            layout = 'split';
                        } else if (element.classList.contains('kg-width-wide')) {
                            size = 'medium';
                        } else if (element.classList.contains('kg-width-full')) {
                            size = 'large';
                        }
                        
                        // Determine style (background type)
                        let style = 'light';
                        let backgroundColor = '#F9F9F9';
                        let backgroundImageSrc = '';
                        let splitImageSrc = '';
                        
                        // For split layout, the image is part of the layout, not background
                        if (layout === 'split' && backgroundImage) {
                            splitImageSrc = backgroundImage.src || '';
                        }
                        
                        if (element.classList.contains('kg-style-accent')) {
                            style = 'accent';
                            backgroundColor = 'accent';
                        } else if (element.classList.contains('kg-style-image') && layout !== 'split') {
                            style = 'image';
                            backgroundImageSrc = backgroundImage?.src || '';
                            // Check for background image in style attribute
                            const bgImageMatch = element.style.backgroundImage?.match(/url\(["']?([^"']+)["']?\)/);
                            if (bgImageMatch) {
                                backgroundImageSrc = bgImageMatch[1];
                            }
                            backgroundColor = element.dataset.backgroundColor || '#000000';
                        } else if (element.dataset.backgroundColor || element.style.backgroundColor) {
                            backgroundColor = element.dataset.backgroundColor || element.style.backgroundColor;
                            // Determine style based on background color
                            if (backgroundColor === '#08090c' || backgroundColor === '#000000') {
                                style = 'dark';
                            } else if (backgroundColor === '#F9F9F9' || backgroundColor === '#FFFFFF') {
                                style = 'light';
                            } else {
                                style = 'custom';
                            }
                        }
                        
                        // Get alignment
                        const alignment = textContainer?.classList.contains('kg-align-center') ? 'center' : 'left';
                        
                        // Get text color
                        const textColor = headingElement?.dataset.textColor || headingElement?.style.color || '#15171A';
                        
                        // Check for swapped layout
                        const swapped = element.classList.contains('kg-swapped');
                        
                        // Button data
                        let buttonEnabled = false;
                        let buttonText = '';
                        let buttonUrl = '';
                        let buttonColor = '#ffffff';
                        let buttonTextColor = '#000000';
                        
                        if (buttonElement) {
                            buttonEnabled = true;
                            buttonText = buttonElement.textContent || '';
                            buttonUrl = buttonElement.href || '#';
                            buttonColor = buttonElement.dataset.buttonColor || (buttonElement.classList.contains('kg-style-accent') ? 'accent' : '#ffffff');
                            buttonTextColor = buttonElement.dataset.buttonTextColor || buttonElement.style.color || '#000000';
                        }
                        
                        addCardInternal('header', {
                            version: 2,
                            header: headingElement?.textContent || '',
                            subheader: subheadingElement?.textContent || '',
                            size: size,
                            style: style,
                            layout: layout,
                            backgroundColor: backgroundColor,
                            backgroundImageSrc: backgroundImageSrc,
                            splitImageSrc: splitImageSrc,
                            backgroundSize: 'cover',
                            swapped: swapped,
                            alignment: alignment,
                            textColor: textColor,
                            buttonEnabled: buttonEnabled,
                            buttonText: buttonText,
                            buttonUrl: buttonUrl,
                            buttonColor: buttonColor,
                            buttonTextColor: buttonTextColor
                        });
                        break;
                    }
                    
                    // Skip empty divs or those with only whitespace/br tags
                    const divCleanedContent = element.innerHTML.replace(/<br\s*\/?>/gi, '').trim();
                    if (!divCleanedContent || divCleanedContent === '&nbsp;') {
                        break; // Skip empty divs
                    }
                    
                    // Check for markdown card
                    if (element.classList.contains('markdown')) {
                        addCardInternal('markdown', { 
                            content: element.textContent || '',
                            initialized: true
                        });
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
                    } else if (element.classList.contains('kg-callout-card')) {
                        // New Ghost-style callout card
                        const color = element.className.match(/kg-callout-card-(\w+)/)?.[1] || 'blue';
                        const emojiElement = element.querySelector('.kg-callout-emoji');
                        const textElement = element.querySelector('.kg-callout-text');
                        addCardInternal('callout', { 
                            content: textElement?.innerHTML || '', 
                            color: color,
                            emoji: emojiElement?.textContent || '💡'
                        });
                    } else if (element.classList.contains('kg-audio-card')) {
                        // Audio card
                        const audio = element.querySelector('audio');
                        const titleElement = element.querySelector('.kg-audio-title');
                        const captionElement = element.querySelector('.kg-audio-caption');
                        if (audio) {
                            addCardInternal('audio', {
                                src: audio.src,
                                title: titleElement?.textContent || '',
                                caption: captionElement?.textContent || '',
                                loop: audio.hasAttribute('loop'),
                                showDownload: element.querySelector('.kg-audio-download') !== null
                            });
                        }
                    } else if (element.classList.contains('kg-product-card')) {
                        // Product card
                        const imageElement = element.querySelector('.kg-product-card-image img');
                        const titleElement = element.querySelector('.kg-product-card-title');
                        const descriptionElement = element.querySelector('.kg-product-card-description');
                        const priceElement = element.querySelector('.kg-product-card-price');
                        const ratingElement = element.querySelector('.kg-product-card-rating');
                        const buttonElement = element.querySelector('.kg-product-card-button');
                        
                        let rating = null;
                        if (ratingElement) {
                            const filledStars = ratingElement.querySelectorAll('.rating-star.filled').length;
                            rating = filledStars > 0 ? filledStars : null;
                        }
                        
                        let buttonStyle = 'primary';
                        if (buttonElement) {
                            if (buttonElement.classList.contains('kg-product-button-secondary')) buttonStyle = 'secondary';
                            else if (buttonElement.classList.contains('kg-product-button-outline')) buttonStyle = 'outline';
                            else if (buttonElement.classList.contains('kg-product-button-link')) buttonStyle = 'link';
                        }
                        
                        addCardInternal('product', {
                            image: imageElement?.src || '',
                            title: titleElement?.textContent || '',
                            description: descriptionElement?.textContent || '',
                            price: priceElement?.textContent || '',
                            rating: rating,
                            url: buttonElement?.href || '',
                            buttonText: buttonElement?.textContent || '',
                            buttonStyle: buttonStyle,
                            initialized: true
                        });
                    } else if (element.classList.contains('kg-file-card')) {
                        // File card
                        const linkElement = element.querySelector('.kg-file-card-container');
                        const titleElement = element.querySelector('.kg-file-card-title');
                        const descriptionElement = element.querySelector('.kg-file-card-caption');
                        const sizeElement = element.querySelector('.kg-file-card-filesize');
                        const nameElement = element.querySelector('.kg-file-card-filename');
                        
                        if (linkElement) {
                            addCardInternal('file', {
                                src: linkElement.href,
                                fileName: nameElement?.textContent || titleElement?.textContent || 'file',
                                title: titleElement?.textContent || '',
                                description: descriptionElement?.textContent || '',
                                size: sizeElement ? parseFloat(sizeElement.textContent) * 1024 * 1024 : 0 // Convert MB to bytes
                            });
                        }
                    } else if (element.classList.contains('kg-embed-card')) {
                        // Embed card
                        const figcaptionElement = element.querySelector('figcaption');
                        const embedContent = element.innerHTML.replace(/<figcaption>.*?<\/figcaption>/s, '');
                        
                        // Try to extract URL from the embed HTML
                        let embedUrl = '';
                        
                        // Check for YouTube
                        const youtubeMatch = embedContent.match(/youtube\.com\/embed\/([a-zA-Z0-9_-]+)/);
                        if (youtubeMatch) {
                            embedUrl = `https://www.youtube.com/watch?v=${youtubeMatch[1]}`;
                        }
                        
                        // Check for Vimeo
                        const vimeoMatch = embedContent.match(/player\.vimeo\.com\/video\/(\d+)/);
                        if (vimeoMatch) {
                            embedUrl = `https://vimeo.com/${vimeoMatch[1]}`;
                        }
                        
                        // Check for Twitter/X blockquote
                        const twitterLink = element.querySelector('blockquote.twitter-tweet a[href*="twitter.com"], blockquote.twitter-tweet a[href*="x.com"]');
                        if (twitterLink) {
                            embedUrl = twitterLink.href;
                        }
                        
                        // Check for Instagram blockquote
                        const instagramLink = element.querySelector('blockquote.instagram-media');
                        if (instagramLink) {
                            embedUrl = instagramLink.getAttribute('data-instgrm-permalink') || '';
                        }
                        
                        addCardInternal('embed', {
                            html: embedContent.trim(),
                            url: embedUrl,
                            caption: figcaptionElement?.textContent || ''
                        });
                    } else if (element.classList.contains('kg-toggle-card')) {
                        // Toggle card
                        const headingElement = element.querySelector('.kg-toggle-heading-text');
                        const contentElement = element.querySelector('.kg-toggle-content');
                        const isOpen = element.getAttribute('data-kg-toggle-state') !== 'close';
                        
                        addCardInternal('toggle', {
                            heading: headingElement?.textContent || '',
                            content: contentElement?.innerHTML || '',
                            isOpen: isOpen,
                            initialized: true
                        });
                    } else if (element.classList.contains('kg-toggle-heading')) {
                        // Toggle card - partial HTML (heading followed by content)
                        const headingElement = element.querySelector('.kg-toggle-heading-text');
                        let nextElement = element.nextElementSibling;
                        let content = '';
                        
                        // Check if next element is the toggle content
                        if (nextElement && nextElement.classList.contains('kg-toggle-content')) {
                            content = nextElement.innerHTML || '';
                            // Skip the next element since we've processed it
                            i++; // This will skip the content div in the main loop
                        }
                        
                        addCardInternal('toggle', {
                            heading: headingElement?.textContent || '',
                            content: content,
                            isOpen: true,
                            initialized: true
                        });
                    } else {
                        // Generic div - treat as HTML
                        addCardInternal('html', { content: element.innerHTML });
                    }
                    break;
                    
                default:
                    // Check if this element contains a header card as a child
                    const childHeaderCard = element.querySelector('.kg-header-card');
                    if (childHeaderCard) {
                        // Process the header card
                        const textContainer = childHeaderCard.querySelector('.kg-header-card-text');
                        const headingElement = childHeaderCard.querySelector('.kg-header-card-heading');
                        const subheadingElement = childHeaderCard.querySelector('.kg-header-card-subheading');
                        const buttonElement = childHeaderCard.querySelector('.kg-header-card-button');
                        const backgroundImage = childHeaderCard.querySelector('.kg-header-card-image') || childHeaderCard.querySelector('img.kg-header-card-image');
                        
                        // Determine layout based on classes
                        let layout = 'regular';
                        if (childHeaderCard.classList.contains('kg-layout-split')) {
                            layout = 'split';
                        } else if (childHeaderCard.classList.contains('kg-width-wide')) {
                            layout = 'wide';
                        } else if (childHeaderCard.classList.contains('kg-width-full')) {
                            layout = 'full';
                        }
                        
                        // Determine background
                        let background = 'transparent';
                        let backgroundColor = '#FFFFFF';
                        let backgroundImageSrc = '';
                        
                        if (childHeaderCard.classList.contains('kg-style-accent')) {
                            background = 'accent';
                            backgroundColor = 'accent';
                        } else if (childHeaderCard.classList.contains('kg-style-image') && backgroundImage) {
                            background = 'image';
                            backgroundImageSrc = backgroundImage.src || '';
                            // Also get background color if it exists
                            if (childHeaderCard.dataset.backgroundColor || childHeaderCard.style.backgroundColor) {
                                backgroundColor = childHeaderCard.dataset.backgroundColor || childHeaderCard.style.backgroundColor || '#FFFFFF';
                            }
                        } else if (childHeaderCard.dataset.backgroundColor || childHeaderCard.style.backgroundColor) {
                            background = 'color';
                            backgroundColor = childHeaderCard.dataset.backgroundColor || childHeaderCard.style.backgroundColor || '#FFFFFF';
                        }
                        
                        // Get alignment
                        const alignment = textContainer?.classList.contains('kg-align-center') ? 'center' : 'left';
                        
                        // Get text color
                        const textColor = headingElement?.dataset.textColor || '#FFFFFF';
                        
                        // Button data
                        let buttonEnabled = false;
                        let buttonText = '';
                        let buttonUrl = '';
                        let buttonColor = '#000000';
                        let buttonTextColor = '#FFFFFF';
                        
                        if (buttonElement) {
                            buttonEnabled = true;
                            buttonText = buttonElement.textContent || '';
                            buttonUrl = buttonElement.href || '#';
                            buttonColor = buttonElement.dataset.buttonColor || (buttonElement.classList.contains('kg-style-accent') ? 'accent' : '#000000');
                            buttonTextColor = buttonElement.dataset.buttonTextColor || '#FFFFFF';
                        }
                        
                        // Reprocess with the same logic for consistency
                        let childSize = 'small';
                        let childLayout = 'regular';
                        
                        if (childHeaderCard.classList.contains('kg-layout-split')) {
                            childLayout = 'split';
                        } else if (childHeaderCard.classList.contains('kg-width-wide')) {
                            childSize = 'medium';
                        } else if (childHeaderCard.classList.contains('kg-width-full')) {
                            childSize = 'large';
                        }
                        
                        let childStyle = 'light';
                        if (childHeaderCard.classList.contains('kg-style-accent')) {
                            childStyle = 'accent';
                        } else if (childHeaderCard.classList.contains('kg-style-image') && backgroundImageSrc) {
                            childStyle = 'image';
                        } else if (backgroundColor === '#08090c' || backgroundColor === '#000000') {
                            childStyle = 'dark';
                        }
                        
                        addCardInternal('header', {
                            version: 2,
                            header: headingElement?.textContent || '',
                            subheader: subheadingElement?.textContent || '',
                            size: childSize,
                            style: childStyle,
                            layout: childLayout,
                            backgroundColor: backgroundColor,
                            backgroundImageSrc: backgroundImageSrc,
                            backgroundSize: 'cover',
                            swapped: childHeaderCard.classList.contains('kg-swapped'),
                            alignment: alignment,
                            textColor: textColor,
                            buttonEnabled: buttonEnabled,
                            buttonText: buttonText,
                            buttonUrl: buttonUrl,
                            buttonColor: buttonColor,
                            buttonTextColor: buttonTextColor
                        });
                        break;
                    }
                    
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
            setTimeout(() => { 
                isCreatingCards = false;
                // Update previews after content is parsed
                updateTwitterPreview();
                updateFacebookPreview();
                updateSearchPreview();
                updateCanonicalUrlPreview();
            }, 100);
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
            <button type="button" class="toolbar-icon" onclick="moveCard('${card.id}', 'up')" title="Move up">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 19V5M5 12l7-7 7 7"/>
                </svg>
            </button>
            <button type="button" class="toolbar-icon" onclick="moveCard('${card.id}', 'down')" title="Move down">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 5v14M19 12l-7 7-7-7"/>
                </svg>
            </button>
            <button type="button" class="toolbar-icon toolbar-icon-delete" onclick="deleteCard('${card.id}')" title="Delete">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2m3 0v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6h14M10 11v6M14 11v6"/>
                </svg>
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
            case 'header':
                div.innerHTML += createHeaderCard(card);
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
            case 'file':
                div.innerHTML += createFileCard(card);
                break;
            case 'product':
                div.innerHTML += createProductCard(card);
                break;
            case 'bookmark':
                div.innerHTML += createBookmarkCard(card);
                break;
            case 'embed':
                div.innerHTML += createEmbedCard(card);
                break;
            case 'gallery':
                div.innerHTML += createGalleryCard(card);
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
    
    function createHeaderCard(card) {
        // Initialize with Ghost Header Card v2 defaults based on test data
        const defaults = {
            version: 2,
            header: '',
            subheader: '',
            size: 'small',
            style: 'light',
            alignment: 'center',
            backgroundColor: '#F9F9F9',
            textColor: '#15171A',
            buttonEnabled: false,
            buttonText: 'Add button text',
            buttonUrl: '',
            buttonColor: '#ffffff',
            buttonTextColor: '#000000',
            backgroundImageSrc: '',
            splitImageSrc: '', // Separate image for split layout
            backgroundImageWidth: null,
            backgroundImageHeight: null,
            backgroundSize: 'cover',
            layout: 'regular',
            swapped: false,
            accentColor: '#FF1A75'
        };
        
        // Merge defaults with card data
        card.data = { ...defaults, ...card.data };
        
        // Determine the style and apply proper defaults
        if (card.data.style === 'dark') {
            card.data.backgroundColor = '#08090c';
            card.data.textColor = '#FFFFFF';
        } else if (card.data.style === 'light') {
            card.data.backgroundColor = '#F9F9F9';
            card.data.textColor = '#15171A';
        } else if (card.data.style === 'accent') {
            card.data.backgroundColor = 'accent';
            card.data.textColor = '#FFFFFF';
        } else if (card.data.style === 'image' && card.data.backgroundImageSrc) {
            card.data.backgroundColor = '#000000';
            card.data.textColor = '#FFFFFF';
        }
        
        // Build card classes based on Ghost's exact structure
        let cardClasses = ['kg-card', 'kg-header-card', 'kg-v2'];
        
        // Add width class based on size/layout
        if (card.data.size === 'small' && card.data.layout !== 'split') {
            // Default width for small
        } else if (card.data.size === 'medium' && card.data.layout !== 'split') {
            cardClasses.push('kg-width-wide');
        } else if (card.data.size === 'large' && card.data.layout !== 'split') {
            cardClasses.push('kg-width-full');
        }
        
        // Add layout classes for split
        if (card.data.layout === 'split') {
            cardClasses.push('kg-layout-split');
            cardClasses.push('kg-width-full');
            if (card.data.swapped) {
                cardClasses.push('kg-swapped');
            }
        }
        
        // Add content-wide for full layouts
        if ((card.data.size === 'large' || card.data.layout === 'split') && card.data.layout !== 'regular') {
            cardClasses.push('kg-content-wide');
        }
        
        // Apply style class
        if (card.data.style === 'accent') {
            cardClasses.push('kg-style-accent');
        }
        
        // Add image style class if background image is present (not for split layout)
        if (card.data.backgroundImageSrc && card.data.layout !== 'split') {
            cardClasses.push('kg-style-image');
        }
        
        // Build background style - handle both image and color
        let backgroundStyle = '';
        if (card.data.backgroundImageSrc && card.data.layout !== 'split') {
            backgroundStyle = `background-image: url(${card.data.backgroundImageSrc}); background-size: ${card.data.backgroundSize || 'cover'}; background-position: center;`;
            // Add background color as fallback
            if (card.data.style !== 'accent') {
                backgroundStyle += ` background-color: ${card.data.backgroundColor};`;
            }
        } else if (card.data.style !== 'accent') {
            backgroundStyle = `background-color: ${card.data.backgroundColor};`;
        }
        
        return `
            <div class="card-content header-card-content">
                <div class="${cardClasses.join(' ')}" 
                     id="headerCard-${card.id}"
                     style="${backgroundStyle}"
                     data-background-color="${card.data.backgroundColor}"
                     onclick="event.preventDefault(); showHeaderSettings('${card.id}')">
                    ${card.data.backgroundImageSrc && card.data.layout !== 'split' ? `
                        <picture>
                            <img class="kg-header-card-image" 
                                 src="${card.data.backgroundImageSrc}" 
                                 loading="lazy" 
                                 alt="" />
                        </picture>
                    ` : ''}
                    <div class="kg-header-card-content">
                        ${card.data.layout === 'split' ? `
                            <div class="kg-header-card-text kg-align-${card.data.alignment}">
                                <h2 class="kg-header-card-heading" 
                                    contenteditable="true"
                                    style="color: ${card.data.textColor};"
                                    data-text-color="${card.data.textColor}"
                                    onblur="updateCardData('${card.id}', 'header', this.innerText)"
                                    oninput="markDirtySafe(); updateWordCount();"
                                    onclick="event.stopPropagation();"
                                    data-placeholder="Add header text">${card.data.header}</h2>
                                <p class="kg-header-card-subheading" 
                                   contenteditable="true"
                                   style="color: ${card.data.textColor};"
                                   data-text-color="${card.data.textColor}"
                                   onblur="updateCardData('${card.id}', 'subheader', this.innerText)"
                                   oninput="markDirtySafe(); updateWordCount();"
                                   onclick="event.stopPropagation();"
                                   data-placeholder="Add subheading text">${card.data.subheader}</p>
                                ${card.data.buttonEnabled ? `
                                    <a href="${card.data.buttonUrl || '#'}" 
                                       class="kg-header-card-button${card.data.buttonColor === 'accent' ? ' kg-style-accent' : ''}"
                                       style="${card.data.buttonColor !== 'accent' ? `background-color: ${card.data.buttonColor}; color: ${card.data.buttonTextColor};` : ''}"
                                       data-button-color="${card.data.buttonColor}"
                                       data-button-text-color="${card.data.buttonTextColor}"
                                       onclick="event.preventDefault(); event.stopPropagation();">
                                       ${card.data.buttonText}
                                    </a>
                                ` : ''}
                            </div>
                            ${card.data.splitImageSrc ? `
                                <img class="kg-header-card-image" src="${card.data.splitImageSrc}" alt="" onclick="event.stopPropagation(); selectHeaderSplitImage('${card.id}')" style="cursor: pointer;">
                            ` : `
                                <div class="kg-header-card-image kg-header-card-image-placeholder" onclick="event.stopPropagation(); selectHeaderSplitImage('${card.id}')">
                                    <div class="kg-header-image-upload-placeholder">
                                        <i class="ti ti-photo-plus"></i>
                                        <p>Click to add image</p>
                                    </div>
                                </div>
                            `}
                        ` : `
                            <div class="kg-header-card-text kg-align-${card.data.alignment}">
                                <h2 class="kg-header-card-heading" 
                                    contenteditable="true"
                                    style="color: ${card.data.textColor};"
                                    data-text-color="${card.data.textColor}"
                                    onblur="updateCardData('${card.id}', 'header', this.innerText)"
                                    oninput="markDirtySafe(); updateWordCount();"
                                    onclick="event.stopPropagation();"
                                    data-placeholder="Add header text">${card.data.header}</h2>
                                <p class="kg-header-card-subheading" 
                                   contenteditable="true"
                                   style="color: ${card.data.textColor};"
                                   data-text-color="${card.data.textColor}"
                                   onblur="updateCardData('${card.id}', 'subheader', this.innerText)"
                                   oninput="markDirtySafe(); updateWordCount();"
                                   onclick="event.stopPropagation();"
                                   data-placeholder="Add subheading text">${card.data.subheader}</p>
                                ${card.data.buttonEnabled ? `
                                    <a href="${card.data.buttonUrl || '#'}" 
                                       class="kg-header-card-button${card.data.buttonColor === 'accent' ? ' kg-style-accent' : ''}"
                                       style="${card.data.buttonColor !== 'accent' ? `background-color: ${card.data.buttonColor}; color: ${card.data.buttonTextColor};` : ''}"
                                       data-button-color="${card.data.buttonColor}"
                                       data-button-text-color="${card.data.buttonTextColor}"
                                       onclick="event.preventDefault(); event.stopPropagation();">
                                       ${card.data.buttonText}
                                    </a>
                                ` : ''}
                            </div>
                        `}
                    </div>
                </div>
            </div>
            
            <!-- Ghost Header Card Settings Panel -->
            <div class="kg-settings-panel kg-settings-panel-header" id="headerSettings-${card.id}" style="display: none;">
                <div class="kg-settings-panel-content">
                    <!-- Size/Layout Options -->
                    <div class="kg-settings-panel-control kg-settings-panel-control-layout">
                        <label class="kg-settings-panel-control-label">Size</label>
                        <div class="kg-settings-panel-control-input">
                            <div class="gh-btn-group icons" role="group">
                                <button type="button" class="gh-btn gh-btn-icon ${card.data.size === 'small' && card.data.layout !== 'split' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderSize('${card.id}', 'small')" title="Small">
                                    <span>S</span>
                                </button>
                                <button type="button" class="gh-btn gh-btn-icon ${card.data.size === 'medium' && card.data.layout !== 'split' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderSize('${card.id}', 'medium')" title="Medium">
                                    <span>M</span>
                                </button>
                                <button type="button" class="gh-btn gh-btn-icon ${card.data.size === 'large' && card.data.layout !== 'split' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderSize('${card.id}', 'large')" title="Large">
                                    <span>L</span>
                                </button>
                                <button type="button" class="gh-btn gh-btn-icon ${card.data.layout === 'split' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderLayout('${card.id}', 'split')" title="Split">
                                    <span>Split</span>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Background Options -->
                    <div class="kg-settings-panel-control">
                        <label class="kg-settings-panel-control-label">Background style</label>
                        <div class="kg-settings-panel-control-input">
                            <div class="gh-btn-group kg-settings-headerstyle-btn-group" role="group">
                                <button type="button" class="gh-btn gh-btn-icon kg-headerstyle-btn-light ${card.data.style === 'light' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderStyle('${card.id}', 'light')" title="Light"></button>
                                <button type="button" class="gh-btn gh-btn-icon kg-headerstyle-btn-dark ${card.data.style === 'dark' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderStyle('${card.id}', 'dark')" title="Dark"></button>
                                <button type="button" class="gh-btn gh-btn-icon kg-headerstyle-btn-accent ${card.data.style === 'accent' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderStyle('${card.id}', 'accent')" title="Accent"></button>
                                <button type="button" class="gh-btn gh-btn-icon kg-headerstyle-btn-image ${card.data.style === 'image' ? 'gh-btn-group-selected' : ''} ${card.data.backgroundImageSrc ? 'has-image' : ''}" 
                                        onclick="updateHeaderStyle('${card.id}', 'image')" 
                                        title="Image"
                                        ${card.data.backgroundImageSrc ? `style="background-image: url('${card.data.backgroundImageSrc}');"` : ''}></button>
                                <button type="button" class="gh-btn gh-btn-icon kg-headerstyle-btn-custom ${card.data.style === 'custom' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderStyle('${card.id}', 'custom')" title="Custom"></button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Background Image Upload (shown when image style is selected) -->
                    ${card.data.style === 'image' && card.data.layout !== 'split' ? `
                        <div class="kg-settings-panel-control">
                            <div class="kg-settings-panel-control-input">
                                <button type="button" class="gh-btn gh-btn-outline gh-btn-icon" onclick="selectHeaderBackgroundImage('${card.id}')">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M17 8l-5-5-5 5M12 3v12"/>
                                    </svg>
                                    <span>${card.data.backgroundImageSrc ? 'Replace' : 'Upload'}</span>
                                </button>
                            </div>
                        </div>
                    ` : ''}
                    
                    <!-- Custom Colors (shown for custom style) -->
                    ${card.data.style === 'custom' ? `
                        <div class="kg-settings-panel-control">
                            <label class="kg-settings-panel-control-label">Background color</label>
                            <div class="kg-settings-panel-control-input">
                                <div class="kg-color-picker-swatch-group">
                                    <!-- Preset colors -->
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#FFFFFF' ? 'active' : ''}"
                                            style="background-color: #FFFFFF;"
                                            onclick="updateHeaderBackground('${card.id}', '#FFFFFF', '#15171A')"
                                            title="White"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#F9F9F9' ? 'active' : ''}"
                                            style="background-color: #F9F9F9;"
                                            onclick="updateHeaderBackground('${card.id}', '#F9F9F9', '#15171A')"
                                            title="Light Gray"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#15171A' ? 'active' : ''}"
                                            style="background-color: #15171A;"
                                            onclick="updateHeaderBackground('${card.id}', '#15171A', '#FFFFFF')"
                                            title="Dark"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#FF1A75' ? 'active' : ''}"
                                            style="background-color: #FF1A75;"
                                            onclick="updateHeaderBackground('${card.id}', '#FF1A75', '#FFFFFF')"
                                            title="Pink"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#0EA5E9' ? 'active' : ''}"
                                            style="background-color: #0EA5E9;"
                                            onclick="updateHeaderBackground('${card.id}', '#0EA5E9', '#FFFFFF')"
                                            title="Blue"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#10B981' ? 'active' : ''}"
                                            style="background-color: #10B981;"
                                            onclick="updateHeaderBackground('${card.id}', '#10B981', '#FFFFFF')"
                                            title="Green"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#F59E0B' ? 'active' : ''}"
                                            style="background-color: #F59E0B;"
                                            onclick="updateHeaderBackground('${card.id}', '#F59E0B', '#FFFFFF')"
                                            title="Amber"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.backgroundColor === '#8B5CF6' ? 'active' : ''}"
                                            style="background-color: #8B5CF6;"
                                            onclick="updateHeaderBackground('${card.id}', '#8B5CF6', '#FFFFFF')"
                                            title="Purple"></button>
                                    
                                    <!-- Custom color picker -->
                                    <button type="button" class="kg-color-swatch kg-color-swatch-custom ${!['#FFFFFF', '#F9F9F9', '#15171A', '#FF1A75', '#0EA5E9', '#10B981', '#F59E0B', '#8B5CF6'].includes(card.data.backgroundColor) ? 'active' : ''}">
                                        <input type="color" 
                                               class="kg-color-picker-input"
                                               value="${card.data.backgroundColor !== 'accent' ? card.data.backgroundColor : '#FF1A75'}"
                                               onchange="updateHeaderBackground('${card.id}', this.value, null)"
                                               title="Custom color">
                                        <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                                            <path d="M1 11L11 1M6 1H11V6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="kg-settings-panel-control">
                            <label class="kg-settings-panel-control-label">Text color</label>
                            <div class="kg-settings-panel-control-input">
                                <div class="kg-color-picker-swatch-group">
                                    <!-- Text color presets -->
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.textColor === '#FFFFFF' ? 'active' : ''}"
                                            style="background-color: #FFFFFF; border: 1px solid #e5e7eb;"
                                            onclick="updateHeaderTextColor('${card.id}', '#FFFFFF')"
                                            title="White"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.textColor === '#F9F9F9' ? 'active' : ''}"
                                            style="background-color: #F9F9F9;"
                                            onclick="updateHeaderTextColor('${card.id}', '#F9F9F9')"
                                            title="Light Gray"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.textColor === '#71717A' ? 'active' : ''}"
                                            style="background-color: #71717A;"
                                            onclick="updateHeaderTextColor('${card.id}', '#71717A')"
                                            title="Gray"></button>
                                    <button type="button" 
                                            class="kg-color-swatch ${card.data.textColor === '#15171A' ? 'active' : ''}"
                                            style="background-color: #15171A;"
                                            onclick="updateHeaderTextColor('${card.id}', '#15171A')"
                                            title="Black"></button>
                                    
                                    <!-- Custom text color picker -->
                                    <button type="button" class="kg-color-swatch kg-color-swatch-custom ${!['#FFFFFF', '#F9F9F9', '#71717A', '#15171A'].includes(card.data.textColor) ? 'active' : ''}">
                                        <input type="color" 
                                               class="kg-color-picker-input"
                                               value="${card.data.textColor}"
                                               onchange="updateHeaderTextColor('${card.id}', this.value)"
                                               title="Custom color">
                                        <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                                            <path d="M1 11L11 1M6 1H11V6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    ` : ''}
                    
                    <!-- Alignment Options -->
                    <div class="kg-settings-panel-control">
                        <label class="kg-settings-panel-control-label">Alignment</label>
                        <div class="kg-settings-panel-control-input">
                            <div class="gh-btn-group icons" role="group">
                                <button type="button" class="gh-btn gh-btn-icon ${card.data.alignment === 'left' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderAlignment('${card.id}', 'left')">
                                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                        <path d="M2 4h12M2 8h8M2 12h10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                                    </svg>
                                </button>
                                <button type="button" class="gh-btn gh-btn-icon ${card.data.alignment === 'center' ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderAlignment('${card.id}', 'center')">
                                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                        <path d="M4 4h8M2 8h12M3 12h10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Button Settings -->
                    <div class="kg-settings-panel-control">
                        <label class="kg-settings-panel-control-label">Button</label>
                        <div class="kg-settings-panel-control-input">
                            <div class="gh-btn-group" role="group">
                                <button type="button" class="gh-btn ${!card.data.buttonEnabled ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderButton('${card.id}', false)">Hide</button>
                                <button type="button" class="gh-btn ${card.data.buttonEnabled ? 'gh-btn-group-selected' : ''}" 
                                        onclick="updateHeaderButton('${card.id}', true)">Show</button>
                            </div>
                        </div>
                    </div>
                    
                    ${card.data.buttonEnabled ? `
                        <div class="kg-settings-panel-control">
                            <label class="kg-settings-panel-control-label">Button text</label>
                            <div class="kg-settings-panel-control-input">
                                <input type="text" class="gh-input" value="${card.data.buttonText || ''}" 
                                       onclick="event.stopPropagation();"
                                       onchange="updateCardData('${card.id}', 'buttonText', this.value);"
                                       oninput="markDirtySafe();" />
                            </div>
                        </div>
                        <div class="kg-settings-panel-control">
                            <label class="kg-settings-panel-control-label">Button URL</label>
                            <div class="kg-settings-panel-control-input">
                                <input type="url" class="gh-input" value="${card.data.buttonUrl || ''}" 
                                       onclick="event.stopPropagation();"
                                       onchange="updateCardData('${card.id}', 'buttonUrl', this.value);"
                                       oninput="markDirtySafe();" />
                            </div>
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
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
        // Auto-expand textarea based on content
        setTimeout(() => {
            const textarea = document.querySelector(`#card-${card.id} .ghost-markdown-editor`);
            if (textarea) {
                adjustMarkdownHeight(textarea);
                // Focus if new card
                if (!card.data.content && !card.data.initialized) {
                    textarea.focus();
                    updateCardData(card.id, 'initialized', true);
                }
            }
        }, 50);
        
        return `
            <div class="card-content markdown-card-content">
                <div class="ghost-markdown-card">
                    <div class="ghost-markdown-header">
                        <div class="ghost-markdown-label">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M16 3h5v18h-5M3 3h5l6 9-6 9H3"/>
                            </svg>
                            <span>Markdown</span>
                        </div>
                        <div class="ghost-markdown-help">
                            <a href="https://ghost.org/help/writing-with-ghost/" target="_blank" class="ghost-markdown-help-link">
                                <i class="ti ti-help-circle"></i>
                            </a>
                        </div>
                    </div>
                    <textarea class="ghost-markdown-editor" 
                              onblur="updateCardData('${card.id}', 'content', this.value)"
                              oninput="markDirtySafe(); updateWordCount(); adjustMarkdownHeight(this);"
                              onkeydown="handleMarkdownTab(event)"
                              placeholder="Enter markdown content...">${card.data.content || ''}</textarea>
                </div>
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
        // Set defaults
        if (!card.data.buttonAlignment) {
            card.data.buttonAlignment = 'center';
        }
        if (!card.data.buttonStyle) {
            card.data.buttonStyle = 'primary';
        }
        if (!card.data.text) {
            card.data.text = '';
        }
        if (!card.data.url) {
            card.data.url = '';
        }
        // Set default colors based on button style
        if (!card.data.backgroundColor) {
            switch(card.data.buttonStyle) {
                case 'secondary':
                    card.data.backgroundColor = '#626d79';
                    break;
                case 'outline':
                case 'link':
                    card.data.backgroundColor = '#15171a';
                    break;
                default:
                    card.data.backgroundColor = '#14b8ff';
            }
        }
        if (!card.data.textColor) {
            card.data.textColor = '#ffffff';
        }

        // Get button class and style based on button style
        let buttonClass = 'kg-btn kg-btn-custom';
        let buttonStyle = '';
        
        // Apply custom styles based on button style
        switch(card.data.buttonStyle) {
            case 'primary':
                buttonStyle = `
                    background-color: ${card.data.backgroundColor} !important; 
                    color: ${card.data.textColor} !important; 
                    border: 2px solid ${card.data.backgroundColor} !important;
                    padding: 8px 16px !important;
                    font-size: 16px !important;
                    font-weight: 600 !important;
                    text-decoration: none !important;
                    border-radius: 5px !important;
                    display: inline-block !important;
                    transition: all 0.2s ease !important;
                `;
                break;
            case 'secondary': 
                buttonStyle = `
                    background-color: ${card.data.backgroundColor} !important; 
                    color: ${card.data.textColor} !important; 
                    border: 2px solid ${card.data.backgroundColor} !important;
                    padding: 8px 16px !important;
                    font-size: 16px !important;
                    font-weight: 600 !important;
                    text-decoration: none !important;
                    border-radius: 5px !important;
                    display: inline-block !important;
                    transition: all 0.2s ease !important;
                `;
                break;
            case 'outline':
                buttonStyle = `
                    border: 2px solid ${card.data.backgroundColor} !important; 
                    color: ${card.data.backgroundColor} !important; 
                    background-color: transparent !important;
                    padding: 8px 16px !important;
                    font-size: 16px !important;
                    font-weight: 600 !important;
                    text-decoration: none !important;
                    border-radius: 5px !important;
                    display: inline-block !important;
                    transition: all 0.2s ease !important;
                `;
                break;
            case 'link':
                buttonStyle = `
                    color: ${card.data.backgroundColor} !important; 
                    background-color: transparent !important; 
                    border: none !important;
                    text-decoration: none !important;
                    padding: 8px 16px !important;
                    font-size: 16px !important;
                    font-weight: 600 !important;
                    display: inline-block !important;
                    transition: all 0.2s ease !important;
                `;
                break;
            default:
                buttonStyle = `
                    background-color: ${card.data.backgroundColor} !important; 
                    color: ${card.data.textColor} !important; 
                    border: 2px solid ${card.data.backgroundColor} !important;
                    padding: 8px 16px !important;
                    font-size: 16px !important;
                    font-weight: 600 !important;
                    text-decoration: none !important;
                    border-radius: 5px !important;
                    display: inline-block !important;
                    transition: all 0.2s ease !important;
                `;
        }

        // Focus on text input for new cards
        if (!card.data.text && !card.data.initialized) {
            setTimeout(() => {
                const textInput = document.querySelector(`#card-${card.id} .ghost-button-text-input`);
                if (textInput) {
                    textInput.focus();
                }
                updateCardData(card.id, 'initialized', true);
            }, 50);
        }

        return `
            <div class="card-content button-card-content" onclick="toggleCardSettings('${card.id}')">
                <div class="kg-card kg-button-card kg-align-${card.data.buttonAlignment}">
                    <a href="${card.data.url || '#'}" 
                       class="${buttonClass}" 
                       id="button-${card.id}"
                       style="${buttonStyle}"
                       onclick="event.stopPropagation();"
                       onmouseover="handleButtonHover('${card.id}', true)"
                       onmouseout="handleButtonHover('${card.id}', false)"
                       ${card.data.url ? 'target="_blank"' : ''}>${card.data.text || 'Button'}</a>
                </div>
                
                <!-- Ghost-style Button Settings Panel -->
                <div class="ghost-card-settings ghost-button-settings" id="buttonSettings-${card.id}" onclick="event.stopPropagation();">
                    <div class="ghost-setting-group">
                        <input type="text" 
                               class="ghost-input ghost-button-text-input" 
                               value="${card.data.text || ''}"
                               onclick="event.stopPropagation();"
                               onblur="updateCardData('${card.id}', 'text', this.value); refreshCard('${card.id}')"
                               oninput="markDirtySafe();"
                               placeholder="Button text">
                    </div>
                    
                    <div class="ghost-setting-group">
                        <input type="url" 
                               class="ghost-input" 
                               value="${card.data.url || ''}"
                               onclick="event.stopPropagation();"
                               onblur="updateCardData('${card.id}', 'url', this.value); refreshCard('${card.id}')"
                               oninput="markDirtySafe();"
                               placeholder="Button URL">
                    </div>
                    
                    <div class="ghost-setting-group">
                        <label>Button style</label>
                        <div class="ghost-button-style-group">
                            <button type="button" 
                                    class="ghost-style-button ${card.data.buttonStyle === 'primary' ? 'active' : ''}"
                                    onclick="event.stopPropagation(); updateButtonStyle('${card.id}', 'primary');">
                                <span class="ghost-button-preview primary">Button</span>
                            </button>
                            <button type="button" 
                                    class="ghost-style-button ${card.data.buttonStyle === 'secondary' ? 'active' : ''}"
                                    onclick="event.stopPropagation(); updateButtonStyle('${card.id}', 'secondary');">
                                <span class="ghost-button-preview secondary">Button</span>
                            </button>
                            <button type="button" 
                                    class="ghost-style-button ${card.data.buttonStyle === 'outline' ? 'active' : ''}"
                                    onclick="event.stopPropagation(); updateButtonStyle('${card.id}', 'outline');">
                                <span class="ghost-button-preview outline">Button</span>
                            </button>
                            <button type="button" 
                                    class="ghost-style-button ${card.data.buttonStyle === 'link' ? 'active' : ''}"
                                    onclick="event.stopPropagation(); updateButtonStyle('${card.id}', 'link');">
                                <span class="ghost-button-preview link">Button</span>
                            </button>
                        </div>
                    </div>
                    
                    <div class="ghost-setting-group">
                        <label>Alignment</label>
                        <div class="ghost-alignment-selector">
                            <button type="button" 
                                    class="ghost-alignment-btn ${card.data.buttonAlignment === 'left' ? 'active' : ''}"
                                    onclick="event.stopPropagation(); updateCardData('${card.id}', 'buttonAlignment', 'left'); refreshCard('${card.id}')"
                                    title="Align left">
                                <i class="ti ti-align-left"></i>
                            </button>
                            <button type="button" 
                                    class="ghost-alignment-btn ${card.data.buttonAlignment === 'center' ? 'active' : ''}"
                                    onclick="event.stopPropagation(); updateCardData('${card.id}', 'buttonAlignment', 'center'); refreshCard('${card.id}')"
                                    title="Align center">
                                <i class="ti ti-align-center"></i>
                            </button>
                        </div>
                    </div>
                    
                    <div class="ghost-setting-group">
                        <label>Colors</label>
                        <div class="ghost-color-picker-row">
                            <div class="ghost-color-input-group">
                                <label class="ghost-color-label">Background</label>
                                <input type="color" 
                                       class="ghost-color-picker" 
                                       value="${card.data.backgroundColor || '#14b8ff'}"
                                       onclick="event.stopPropagation();"
                                       onchange="updateCardData('${card.id}', 'backgroundColor', this.value); refreshCard('${card.id}')">
                            </div>
                            <div class="ghost-color-input-group">
                                <label class="ghost-color-label">Text</label>
                                <input type="color" 
                                       class="ghost-color-picker" 
                                       value="${card.data.textColor || '#ffffff'}"
                                       onclick="event.stopPropagation();"
                                       onchange="updateCardData('${card.id}', 'textColor', this.value); refreshCard('${card.id}')">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    function createGalleryCard(card) {
        // Initialize gallery data if not present
        if (!card.data.images) {
            card.data.images = [];
        }
        if (!card.data.caption) {
            card.data.caption = '';
        }
        
        return `
            <div class="card-content gallery-card-content" onclick="toggleCardSettings('${card.id}')">
                <div class="kg-card kg-gallery-card kg-width-wide">
                    <div class="kg-gallery-container" id="gallery-container-${card.id}">
                        ${renderGalleryImages(card)}
                    </div>
                    ${card.data.caption ? `<figcaption>${card.data.caption}</figcaption>` : ''}
                </div>
                
                <!-- Ghost-style Gallery Settings Panel -->
                <div class="ghost-card-settings ghost-gallery-settings" id="gallerySettings-${card.id}" onclick="event.stopPropagation();">
                    <div class="ghost-gallery-toolbar">
                        <button type="button" 
                                class="ghost-gallery-btn"
                                onclick="event.stopPropagation(); document.getElementById('galleryImages-${card.id}').click();"
                                title="Add images">
                            <i class="ti ti-photo-plus"></i>
                            <span>Add images</span>
                        </button>
                        <input type="file" 
                               id="galleryImages-${card.id}" 
                               accept="image/*" 
                               multiple
                               style="display: none;" 
                               onchange="uploadGalleryImages('${card.id}', this)">
                    </div>
                    
                    <div class="ghost-setting-group">
                        <input type="text" 
                               class="ghost-input" 
                               value="${card.data.caption || ''}"
                               onclick="event.stopPropagation();"
                               onblur="updateCardData('${card.id}', 'caption', this.value); refreshGalleryCard('${card.id}')"
                               oninput="markDirtySafe();"
                               placeholder="Type caption for gallery (optional)">
                    </div>
                    
                    ${card.data.images.length > 0 ? `
                        <div class="ghost-gallery-images-list">
                            ${card.data.images.map((image, index) => `
                                <div class="ghost-gallery-image-item" data-index="${index}">
                                    <img src="${image.src}" alt="${image.alt || ''}">
                                    <div class="ghost-gallery-image-actions">
                                        <button type="button" 
                                                class="ghost-gallery-action-btn"
                                                onclick="event.stopPropagation(); editGalleryImage('${card.id}', ${index})"
                                                title="Edit">
                                            <i class="ti ti-pencil"></i>
                                        </button>
                                        <button type="button" 
                                                class="ghost-gallery-action-btn ghost-gallery-action-delete"
                                                onclick="event.stopPropagation(); removeGalleryImage('${card.id}', ${index})"
                                                title="Remove">
                                            <i class="ti ti-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
    }
    
    function createCalloutCard(card) {
        const colors = {
            'grey': { bg: 'rgba(124, 139, 154, 0.13)', emoji: '💡' },
            'white': { bg: 'transparent', border: 'rgba(124, 139, 154, 0.2)', emoji: '💡' },
            'blue': { bg: 'rgba(33, 172, 232, 0.12)', emoji: '💙' },
            'green': { bg: 'rgba(52, 183, 67, 0.12)', emoji: '💚' },
            'yellow': { bg: 'rgba(240, 165, 15, 0.13)', emoji: '💛' },
            'red': { bg: 'rgba(209, 46, 46, 0.11)', emoji: '🚨' },
            'pink': { bg: 'rgba(225, 71, 174, 0.11)', emoji: '💕' },
            'purple': { bg: 'rgba(135, 85, 236, 0.12)', emoji: '💜' },
            'accent': { bg: '#15171a', text: '#ffffff', emoji: '✨' }
        };
        
        const color = card.data.color || 'grey';
        const emoji = card.data.emoji || colors[color].emoji;
        const colorStyle = colors[color] || colors.grey;
        
        // Set focus to text field after render if this is a new card
        if (!card.data.content && !card.data.initialized) {
            setTimeout(() => {
                const textElement = document.querySelector(`#card-${card.id} .ghost-callout-text`);
                if (textElement) {
                    textElement.focus();
                    // Place cursor at the beginning
                    const range = document.createRange();
                    const sel = window.getSelection();
                    range.setStart(textElement, 0);
                    range.collapse(true);
                    sel.removeAllRanges();
                    sel.addRange(range);
                }
                updateCardData(card.id, 'initialized', true);
            }, 50);
        }
        
        return `
            <div class="card-content callout-card-content" onclick="toggleCardSettings('${card.id}')">
                <div class="ghost-callout-card kg-callout-card-${color}">
                    <div class="ghost-callout-emoji" onclick="event.stopPropagation(); showEmojiPicker('${card.id}')">${emoji}</div>
                    <div class="ghost-callout-text" 
                         contenteditable="true" 
                         onblur="updateCardData('${card.id}', 'content', this.innerHTML)"
                         oninput="markDirtySafe(); updateWordCount();"
                         data-placeholder="Add a callout message..."
                         onclick="event.stopPropagation();">${card.data.content || ''}</div>
                </div>
                <div class="ghost-callout-settings" id="calloutSettings-${card.id}" onclick="event.stopPropagation();">
                    <div class="ghost-callout-colors">
                        ${Object.entries(colors).map(([key, value]) => `
                            <button type="button" 
                                    class="ghost-color-button ${color === key ? 'active' : ''}"
                                    style="background-color: ${value.bg}; ${key === 'white' ? `box-shadow: inset 0 0 0 1px ${value.border};` : ''}"
                                    onclick="updateCardData('${card.id}', 'color', '${key}'); refreshCard('${card.id}')"
                                    title="${key.charAt(0).toUpperCase() + key.slice(1)}">
                            </button>
                        `).join('')}
                    </div>
                </div>
            </div>
        `;
    }
    
    function createToggleCard(card) {
        const isOpen = card.data.isOpen !== false; // Default to open
        const heading = card.data.heading || card.data.title || '';
        const content = card.data.content || '';
        
        // Set focus to heading if new card
        if (!heading && !card.data.initialized) {
            setTimeout(() => {
                const headingElement = document.querySelector(`#card-${card.id} .kg-toggle-heading-text`);
                if (headingElement) {
                    headingElement.focus();
                    // Place cursor at the end
                    const range = document.createRange();
                    const sel = window.getSelection();
                    range.selectNodeContents(headingElement);
                    range.collapse(false);
                    sel.removeAllRanges();
                    sel.addRange(range);
                }
                updateCardData(card.id, 'initialized', true);
            }, 50);
        }
        
        return `
            <div class="card-content toggle-card-content">
                <div class="kg-toggle-card" data-kg-toggle-state="${isOpen ? 'open' : 'close'}">
                    <div class="kg-toggle-heading" onclick="toggleToggleCard('${card.id}')">
                        <h4 class="kg-toggle-heading-text" 
                            contenteditable="true"
                            onclick="event.stopPropagation();"
                            onblur="updateCardData('${card.id}', 'heading', this.textContent)"
                            oninput="markDirtySafe();"
                            data-placeholder="Toggle heading...">${heading}</h4>
                        <button class="kg-toggle-card-icon" aria-label="Toggle content">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                <path d="M23.25,7.311,12.53,18.03a.749.749,0,0,1-1.06,0L.75,7.311"></path>
                            </svg>
                        </button>
                    </div>
                    <div class="kg-toggle-content" id="toggle-content-${card.id}">
                        <div contenteditable="true" 
                             onclick="event.stopPropagation();"
                             onblur="updateCardData('${card.id}', 'content', this.innerHTML)"
                             oninput="markDirtySafe(); updateWordCount();"
                             data-placeholder="Toggle content...">${content}</div>
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
                               ${card.data.loop ? 'loop' : ''}
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
                    <div class="mt-2">
                        <textarea class="form-control" 
                                  rows="2"
                                  placeholder="Add caption (optional)..."
                                  onblur="updateCardData('${card.id}', 'caption', this.value)"
                                  oninput="markDirtySafe();">${card.data.caption || ''}</textarea>
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
                            <div class="ghost-audio-options d-flex align-items-center gap-3 ms-3">
                                <label class="d-flex align-items-center gap-2 mb-0">
                                    <input type="checkbox" 
                                           ${card.data.loop ? 'checked' : ''}
                                           onchange="updateCardData('${card.id}', 'loop', this.checked); renderCard('${card.id}');">
                                    <span class="text-sm">Loop</span>
                                </label>
                                <label class="d-flex align-items-center gap-2 mb-0">
                                    <input type="checkbox" 
                                           ${card.data.showDownload ? 'checked' : ''}
                                           onchange="updateCardData('${card.id}', 'showDownload', this.checked);">
                                    <span class="text-sm">Show download</span>
                                </label>
                            </div>
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
    
    function createFileCard(card) {
        if (card.data.src) {
            const fileIcon = getFileIcon(card.data.fileName || '');
            const fileSize = card.data.size ? formatFileSize(card.data.size) : '';
            const displayName = card.data.title || card.data.fileName || 'Download file';
            
            return `
                <div class="card-content file-card-content">
                    <div class="file-wrapper bg-light rounded p-4">
                        <div class="d-flex align-items-center">
                            <div class="file-icon me-3">
                                <i class="ti ${fileIcon}" style="font-size: 2.5rem; color: #6b7280;"></i>
                            </div>
                            <div class="file-info flex-grow-1">
                                <div class="file-name fw-medium text-truncate">
                                    <a href="${card.data.src}" target="_blank" class="text-decoration-none">
                                        ${displayName}
                                    </a>
                                </div>
                                ${fileSize ? `<div class="file-size text-muted small">${fileSize}</div>` : ''}
                                ${card.data.fileName && card.data.title ? `<div class="file-original text-muted small">${card.data.fileName}</div>` : ''}
                            </div>
                            <div class="file-download">
                                <a href="${card.data.src}" 
                                   class="btn btn-outline-primary btn-sm"
                                   download="${card.data.fileName || 'file'}"
                                   target="_blank">
                                    <i class="ti ti-download"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="mt-2">
                        <input type="text" 
                               class="form-control" 
                               placeholder="Add title (optional)..."
                               value="${card.data.title || ''}"
                               onblur="updateCardData('${card.id}', 'title', this.value); renderCard('${card.id}');"
                               oninput="markDirtySafe();">
                    </div>
                    <div class="mt-2">
                        <textarea class="form-control" 
                                  rows="2"
                                  placeholder="Add description (optional)..."
                                  onblur="updateCardData('${card.id}', 'description', this.value)"
                                  oninput="markDirtySafe();">${card.data.description || ''}</textarea>
                    </div>
                    <div class="ghost-file-settings mt-3" id="fileSettings-${card.id}">
                        <div class="ghost-file-toolbar">
                            <button type="button" 
                                    class="ghost-replace-btn"
                                    onclick="document.getElementById('file-replace-${card.id}').click()">
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
                                   id="file-replace-${card.id}" 
                                   style="display: none;"
                                   onchange="handleFileReplace('${card.id}', this)">
                        </div>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="card-content text-center py-5">
                    <div class="mb-3">
                        <i class="ti ti-file text-muted" style="font-size: 3rem;"></i>
                    </div>
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="document.getElementById('file-upload-${card.id}').click()">
                        <i class="ti ti-upload"></i> Upload file
                    </button>
                    <input type="file" 
                           id="file-upload-${card.id}" 
                           style="display: none;"
                           onchange="handleFileUpload('${card.id}', this)">
                </div>
            `;
        }
    }
    
    function createProductCard(card) {
        const hasContent = card.data.title || card.data.description || card.data.price || card.data.image || card.data.initialized;
        
        if (hasContent) {
            return `
                <div class="card-content product-card-content">
                    <div class="ghost-product-card">
                        <div class="ghost-product-card-inner">
                            <div class="ghost-product-image-container" onclick="showProductImageUpload('${card.id}')">
                                ${card.data.image ? 
                                    `<img src="${card.data.image}" alt="${card.data.title || 'Product image'}" class="ghost-product-image">` :
                                    `<div class="ghost-product-image-placeholder">
                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                                            <circle cx="8.5" cy="8.5" r="1.5" fill="currentColor"/>
                                            <polyline points="21 15 16 10 5 21" stroke="currentColor" stroke-width="2"/>
                                        </svg>
                                    </div>`
                                }
                                <input type="file" 
                                       id="product-image-${card.id}" 
                                       accept="image/*" 
                                       style="display: none;"
                                       onchange="handleProductImageUpload('${card.id}', this)">
                            </div>
                            <div class="ghost-product-content">
                                <input type="text" 
                                       class="ghost-product-title" 
                                       placeholder="Product name"
                                       value="${card.data.title || ''}"
                                       onblur="updateCardData('${card.id}', 'title', this.value)"
                                       oninput="markDirtySafe();">
                                <textarea class="ghost-product-description" 
                                          rows="2"
                                          placeholder="Product description"
                                          onblur="updateCardData('${card.id}', 'description', this.value)"
                                          oninput="markDirtySafe();">${card.data.description || ''}</textarea>
                                ${card.data.rating ? `
                                    <div class="ghost-product-rating">
                                        ${[1,2,3,4,5].map(star => `
                                            <i class="ti ti-star${(card.data.rating || 0) >= star ? '-filled' : ''}"></i>
                                        `).join('')}
                                    </div>
                                ` : ''}
                                ${card.data.url && (card.data.buttonText || 'Check it out') ? `
                                    <a href="${card.data.url}" target="_blank" class="ghost-product-button ${card.data.buttonStyle || 'primary'}">
                                        ${card.data.buttonText || 'Check it out'}
                                    </a>
                                ` : ''}
                            </div>
                        </div>
                        
                        <div class="ghost-product-settings" id="productSettings-${card.id}">
                            <div class="ghost-product-settings-row">
                                <div class="ghost-setting-group">
                                    <label>Button URL</label>
                                    <input type="url" 
                                           class="ghost-input" 
                                           placeholder="https://example.com/product"
                                           value="${card.data.url || ''}"
                                           onblur="updateCardData('${card.id}', 'url', this.value)"
                                           oninput="markDirtySafe();">
                                </div>
                                <div class="ghost-setting-group">
                                    <label>Button text</label>
                                    <input type="text" 
                                           class="ghost-input" 
                                           placeholder="Check it out"
                                           value="${card.data.buttonText || ''}"
                                           onblur="updateCardData('${card.id}', 'buttonText', this.value)"
                                           oninput="markDirtySafe();">
                                </div>
                            </div>
                            
                            <div class="ghost-product-settings-row">
                                <div class="ghost-setting-group full-width">
                                    <label>Button style</label>
                                    <div class="ghost-button-style-group">
                                        <button type="button" 
                                                class="ghost-style-button ${(card.data.buttonStyle || 'primary') === 'primary' ? 'active' : ''}"
                                                onclick="updateCardData('${card.id}', 'buttonStyle', 'primary'); refreshCard('${card.id}')">
                                            <span class="ghost-button-preview primary">Button</span>
                                        </button>
                                        <button type="button" 
                                                class="ghost-style-button ${card.data.buttonStyle === 'secondary' ? 'active' : ''}"
                                                onclick="updateCardData('${card.id}', 'buttonStyle', 'secondary'); refreshCard('${card.id}')">
                                            <span class="ghost-button-preview secondary">Button</span>
                                        </button>
                                        <button type="button" 
                                                class="ghost-style-button ${card.data.buttonStyle === 'outline' ? 'active' : ''}"
                                                onclick="updateCardData('${card.id}', 'buttonStyle', 'outline'); refreshCard('${card.id}')">
                                            <span class="ghost-button-preview outline">Button</span>
                                        </button>
                                        <button type="button" 
                                                class="ghost-style-button ${card.data.buttonStyle === 'link' ? 'active' : ''}"
                                                onclick="updateCardData('${card.id}', 'buttonStyle', 'link'); refreshCard('${card.id}')">
                                            <span class="ghost-button-preview link">Button</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="ghost-product-settings-row">
                                <div class="ghost-setting-group">
                                    <label>Star rating</label>
                                    <div class="ghost-rating-selector">
                                        <button type="button" 
                                                class="ghost-rating-toggle ${!card.data.rating ? 'active' : ''}"
                                                onclick="updateProductRating('${card.id}', 0)">
                                            <span>None</span>
                                        </button>
                                        ${[1,2,3,4,5].map(star => `
                                            <button type="button" 
                                                    class="ghost-rating-toggle ${card.data.rating === star ? 'active' : ''}"
                                                    onclick="updateProductRating('${card.id}', ${star})">
                                                <span>${star}</span>
                                            </button>
                                        `).join('')}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="card-content text-center py-5">
                    <div class="mb-3">
                        <i class="ti ti-shopping-cart text-muted" style="font-size: 3rem;"></i>
                    </div>
                    <h5>Product Card</h5>
                    <p class="text-muted mb-3">
                        Showcase a product with image, title, description, and pricing.
                    </p>
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="initializeProductCard('${card.id}')">
                        <i class="ti ti-plus"></i> Set up product
                    </button>
                </div>
            `;
        }
    }
    
    function createBookmarkCard(card) {
        if (card.data.url) {
            const hasMetadata = card.data.title || card.data.description || card.data.author || card.data.publisher;
            
            if (hasMetadata) {
                return `
                    <div class="card-content bookmark-card-content">
                        <figure class="kg-card kg-bookmark-card">
                            <a class="kg-bookmark-container" href="${escapeHtml(card.data.url)}" target="_blank">
                                <div class="kg-bookmark-content">
                                    <div class="kg-bookmark-title">${escapeHtml(card.data.title || 'Untitled')}</div>
                                    ${card.data.description ? `<div class="kg-bookmark-description">${escapeHtml(card.data.description)}</div>` : ''}
                                    <div class="kg-bookmark-metadata">
                                        ${card.data.icon ? `<img class="kg-bookmark-icon" src="${escapeHtml(card.data.icon)}" alt="" onerror="this.style.display='none'">` : ''}
                                        ${card.data.publisher ? `<span class="kg-bookmark-author">${escapeHtml(card.data.publisher)}</span>` : ''}
                                        ${card.data.author ? `<span class="kg-bookmark-publisher">${escapeHtml(card.data.author)}</span>` : ''}
                                    </div>
                                </div>
                                ${card.data.thumbnail ? `
                                    <div class="kg-bookmark-thumbnail">
                                        <img src="${escapeHtml(card.data.thumbnail)}" alt="" onerror="this.style.display='none'">
                                    </div>
                                ` : ''}
                            </a>
                        </figure>
                        <div class="ghost-bookmark-settings" id="bookmarkSettings-${card.id}">
                            <div class="text-center py-3">
                                <button type="button" class="btn btn-sm btn-primary" onclick="showPostSelector('${card.id}')">
                                    <i class="ti ti-file-text me-2"></i>Change published post
                                </button>
                            </div>
                        </div>
                    </div>
                `;
            } else {
                // If we have a URL but no metadata, still show the bookmark
                return `
                    <div class="card-content bookmark-card-content">
                        <figure class="kg-card kg-bookmark-card">
                            <a class="kg-bookmark-container" href="${card.data.url}" target="_blank">
                                <div class="kg-bookmark-content">
                                    <div class="kg-bookmark-title">${card.data.url}</div>
                                    <div class="kg-bookmark-metadata">
                                        <span class="kg-bookmark-author">Loading...</span>
                                    </div>
                                </div>
                            </a>
                        </figure>
                        <div class="ghost-bookmark-settings" id="bookmarkSettings-${card.id}">
                            <div class="text-center py-3">
                                <button type="button" class="btn btn-sm btn-primary" onclick="showPostSelector('${card.id}')">
                                    <i class="ti ti-file-text me-2"></i>Change published post
                                </button>
                            </div>
                        </div>
                    </div>
                `;
            }
        } else {
            return `
                <div class="card-content bookmark-card-content">
                    <div class="text-center py-5">
                        <div class="mb-3">
                            <i class="ti ti-bookmark text-muted" style="font-size: 3rem;"></i>
                        </div>
                        <h5>Bookmark Card</h5>
                        <p class="text-muted mb-3">
                            Select a published post to create an internal bookmark.
                        </p>
                        <button type="button" class="btn btn-primary" onclick="showPostSelector('${card.id}')">
                            <i class="ti ti-file-text me-2"></i>Select from published posts
                        </button>
                    </div>
                </div>
            `;
        }
    }
    
    function createEmbedCard(card) {
        if (card.data.html) {
            // Show the embedded content
            return `
                <div class="card-content embed-card-content">
                    <div class="ghost-embed-wrapper">
                        ${card.data.html}
                    </div>
                    <div class="ghost-embed-settings" id="embedSettings-${card.id}">
                        <input type="url" 
                               class="ghost-embed-input" 
                               placeholder="Paste URL to embed content"
                               value="${card.data.url || ''}"
                               onblur="handleEmbedUrlChange('${card.id}', this.value)"
                               onkeypress="if(event.key==='Enter') handleEmbedUrlChange('${card.id}', this.value)"
                               oninput="markDirtySafe();">
                        ${card.data.caption ? `
                            <input type="text" 
                                   class="ghost-embed-caption" 
                                   placeholder="Type caption for embed (optional)"
                                   value="${card.data.caption || ''}"
                                   onblur="updateCardData('${card.id}', 'caption', this.value)"
                                   oninput="markDirtySafe();">
                        ` : ''}
                    </div>
                </div>
            `;
        } else if (card.data.url) {
            // Loading or error state
            if (card.data.loading) {
                return `
                    <div class="card-content embed-card-content">
                        <div class="ghost-embed-loading">
                            <i class="ti ti-loader-2 spin me-2"></i>
                            Fetching embed...
                        </div>
                        <div class="ghost-embed-settings" id="embedSettings-${card.id}">
                            <input type="url" 
                                   class="ghost-embed-input" 
                                   placeholder="Paste URL to embed content"
                                   value="${card.data.url || ''}"
                                   onblur="handleEmbedUrlChange('${card.id}', this.value)"
                                   onkeypress="if(event.key==='Enter') handleEmbedUrlChange('${card.id}', this.value)"
                                   oninput="markDirtySafe();">
                        </div>
                    </div>
                `;
            } else {
                return `
                    <div class="card-content embed-card-content">
                        <div class="ghost-embed-error">
                            <i class="ti ti-alert-circle mb-2" style="font-size: 2rem;"></i>
                            <div>Unable to embed this URL</div>
                            <div class="text-sm mt-1">Try YouTube, Twitter, Instagram, Vimeo, SoundCloud, Spotify, or CodePen</div>
                        </div>
                        <div class="ghost-embed-settings" id="embedSettings-${card.id}">
                            <input type="url" 
                                   class="ghost-embed-input" 
                                   placeholder="Paste URL to embed content"
                                   value="${card.data.url || ''}"
                                   onblur="handleEmbedUrlChange('${card.id}', this.value)"
                                   onkeypress="if(event.key==='Enter') handleEmbedUrlChange('${card.id}', this.value)"
                                   oninput="markDirtySafe();">
                        </div>
                    </div>
                `;
            }
        } else {
            // Empty state
            return `
                <div class="card-content embed-card-content">
                    <div class="text-center py-5">
                        <div class="mb-3">
                            <i class="ti ti-code text-muted" style="font-size: 3rem;"></i>
                        </div>
                        <h5>Embed Card</h5>
                        <p class="text-muted mb-3">
                            Embed content from YouTube, Twitter, Instagram, Vimeo, SoundCloud, Spotify, CodePen, and more.
                        </p>
                    </div>
                    <div class="ghost-embed-settings" id="embedSettings-${card.id}">
                        <input type="url" 
                               class="ghost-embed-input" 
                               placeholder="Paste URL to embed content"
                               value="${card.data.url || ''}"
                               onblur="handleEmbedUrlChange('${card.id}', this.value)"
                               onkeypress="if(event.key==='Enter') handleEmbedUrlChange('${card.id}', this.value)"
                               oninput="markDirtySafe();"
                               autofocus>
                    </div>
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
            <div class="card-menu-item" onclick="insertCard('header', this)">
                <i class="ti ti-heading"></i>
                <span>Header</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('gallery', this)">
                <i class="ti ti-layout-grid"></i>
                <span>Gallery</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('video', this)">
                <i class="ti ti-movie"></i>
                <span>Video</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('audio', this)">
                <i class="ti ti-volume"></i>
                <span>Audio</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('file', this)">
                <i class="ti ti-file"></i>
                <span>File</span>
            </div>
            <div class="card-menu-category">Links</div>
            <div class="card-menu-item" onclick="insertCard('bookmark', this)">
                <i class="ti ti-bookmark"></i>
                <span>Bookmark</span>
            </div>
            <div class="card-menu-item" onclick="insertCard('embed', this)">
                <i class="ti ti-code"></i>
                <span>Embed</span>
            </div>
            <div class="card-menu-category">Commerce</div>
            <div class="card-menu-item" onclick="insertCard('product', this)">
                <i class="ti ti-shopping-cart"></i>
                <span>Product</span>
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
        
        // Initialize data based on card type
        if (type === 'header') {
            card.data = {
                version: 2,
                header: '',
                subheader: '',
                size: 'small',
                style: 'light',
                alignment: 'center',
                backgroundColor: '#F9F9F9',
                textColor: '#15171A',
                buttonEnabled: false,
                buttonText: 'Add button text',
                buttonUrl: '',
                buttonColor: '#ffffff',
                buttonTextColor: '#000000',
                backgroundImageSrc: '',
                backgroundImageWidth: null,
                backgroundImageHeight: null,
                backgroundSize: 'cover',
                layout: 'regular',
                swapped: false,
                accentColor: '#FF1A75'
            };
        } else if (type === 'gallery') {
            card.data = {
                images: []
            };
        }
        
        contentCards.push(card);
        
        const cardElement = createCardElement(card);
        
        // Insert card before the button
        button.parentNode.insertBefore(cardElement, button);
        
        // Focus the new card
        focusCard(cardElement);
        
        // Close menu
        closeCardMenu();
        
        // For header cards, automatically show the settings panel
        if (type === 'header') {
            setTimeout(() => {
                showHeaderSettings(card.id);
            }, 100);
        }
        
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
                
                // Update social previews if this is the first paragraph
                if (card.type === 'paragraph') {
                    const firstPara = contentCards.find(c => c.type === 'paragraph' && c.data.content);
                    if (firstPara && firstPara.id === cardId) {
                        // Update all previews
                        updateSearchPreview();
                        updateTwitterPreview();
                        updateFacebookPreview();
                    }
                }
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
                
                // Update previews if content changed and it's a paragraph card
                if (property === 'content' && card.type === 'paragraph') {
                    // Update social previews in case this is the first paragraph
                    setTimeout(() => {
                        updateTwitterPreview();
                        updateFacebookPreview();
                    }, 100);
                }
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
            
            // Check if header settings panel was visible
            let headerSettingsWasVisible = false;
            if (card.type === 'header') {
                const headerSettings = document.getElementById('headerSettings-' + cardId);
                headerSettingsWasVisible = headerSettings && headerSettings.style.display === 'block';
            }
            
            // Check if other settings panels were active
            const settingsPanel = oldElement.querySelector('.ghost-card-settings');
            const wasSettingsActive = settingsPanel && settingsPanel.classList.contains('active');
            
            const newElement = createCardElement(card);
            oldElement.parentNode.replaceChild(newElement, oldElement);
            
            // Restore header settings panel state
            if (headerSettingsWasVisible) {
                setTimeout(() => {
                    showHeaderSettings(cardId);
                }, 50);
            }
            
            // Restore other settings panel state if it was active
            if (wasSettingsActive) {
                const newSettingsPanel = newElement.querySelector('.ghost-card-settings');
                if (newSettingsPanel) {
                    newSettingsPanel.classList.add('active');
                }
            }
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
        // console.log('deleteCardDirectly called with cardId:', cardId);
        // console.log('Current contentCards length:', contentCards.length);
        // console.log('Current state - isDirty:', isDirty, 'isInitializing:', isInitializing);
        
        // Don't delete if it's the only card
        if (contentCards.length <= 1) {
            // console.log('Not deleting - only one card left');
            return;
        }
        
        const element = document.getElementById(cardId);
        const cardIndex = contentCards.findIndex(c => c.id === cardId);
        
        // console.log('Card element found:', element);
        // console.log('Card index in array:', cardIndex);
        
        if (!element) {
            // console.log('Card element not found in DOM, aborting deletion');
            return;
        }
        
        if (cardIndex === -1) {
            // console.log('Card not found in contentCards array, aborting deletion');
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
        console.log('generateSlug called with title:', title);
        
        if (!title || title.trim() === '') {
            console.log('Empty title, returning default slug');
            return 'untitled-' + Date.now().toString().slice(-6);
        }
        
        let slug = title.toLowerCase()
            .trim()
            .replace(/[^a-z0-9\s-]/g, '') // Remove special characters except spaces and hyphens
            .replace(/\s+/g, '-') // Replace spaces with hyphens
            .replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
            .replace(/^-+|-+$/g, ''); // Remove leading/trailing hyphens
        
        console.log('Processed slug before length check:', slug);
        
        // Ensure minimum length
        if (slug.length < 3) {
            slug = slug + '-' + Date.now().toString().slice(-6);
            console.log('Short slug, extended to:', slug);
        }
        
        console.log('Final slug:', slug);
        return slug;
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
        
        console.log('markDirty called - setting isDirty to true');
        isDirty = true;
        
        // Show unsaved changes for all posts
        document.getElementById('saveStatus').textContent = 'Unsaved changes';
        document.getElementById('saveStatus').className = 'text-sm text-orange-600';
        
        // Reset autosave timer for all posts (autosave will maintain the correct status)
        if (autosaveTimer) {
            clearTimeout(autosaveTimer);
        }
        autosaveTimer = setTimeout(autosave, 3000); // 3 seconds
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
        console.log('showUnsavedChangesModal called');
        const modal = document.getElementById('unsavedChangesModal');
        if (modal) {
            modal.classList.remove('hidden');
            modal.style.display = 'flex';
            console.log('Modal shown');
        } else {
            console.error('Unsaved changes modal not found!');
        }
    }
    
    // Hide unsaved changes modal
    function hideUnsavedChangesModal() {
        const modal = document.getElementById('unsavedChangesModal');
        if (modal) {
            modal.style.display = 'none';
        }
        pendingNavigation = null;
    }
    window.hideUnsavedChangesModal = hideUnsavedChangesModal;
    
    // Save and leave
    function saveAndLeave() {
        console.log('saveAndLeave called, pendingNavigation:', pendingNavigation);
        // Store the navigation URL before hiding modal clears it
        const navigateToUrl = pendingNavigation;
        
        // Hide modal immediately
        hideUnsavedChangesModal();
        
        // Show saving message
        showMessage('Saving...', 'info');
        
        // Maintain the original status for published/scheduled posts, or save as draft for unpublished posts
        const saveStatus = (originalStatus === 'published' || originalStatus === 'scheduled') ? originalStatus : 'draft';
        savePost(saveStatus, false).then(() => {
            console.log('Save successful, navigateToUrl:', navigateToUrl);
            isDirty = false;
            if (navigateToUrl) {
                console.log('Navigating to:', navigateToUrl);
                window.location.href = navigateToUrl;
            } else {
                console.log('No navigation URL available');
            }
        }).catch(error => {
            showMessage('Save failed: ' + error.message, 'error');
            // Re-show the modal if save fails
            showUnsavedChangesModal();
        });
    }
    window.saveAndLeave = saveAndLeave;
    
    // Save and stay on page
    function saveAndStay() {
        console.log('saveAndStay called');
        // Hide modal immediately
        hideUnsavedChangesModal();
        
        // Show saving message
        showMessage('Saving...', 'info');
        
        // Maintain the original status for published/scheduled posts, or save as draft for unpublished posts
        const saveStatus = (originalStatus === 'published' || originalStatus === 'scheduled') ? originalStatus : 'draft';
        savePost(saveStatus, false).then(() => {
            isDirty = false;
            showMessage('Post saved successfully', 'success');
            // Stay on the page, clear pending navigation
            pendingNavigation = null;
        }).catch(error => {
            showMessage('Save failed: ' + error.message, 'error');
        });
    }
    window.saveAndStay = saveAndStay;
    
    // Leave without saving
    function leaveWithoutSaving() {
        console.log('leaveWithoutSaving called, pendingNavigation:', pendingNavigation);
        isDirty = false;
        if (pendingNavigation) {
            window.location.href = pendingNavigation;
        }
        hideUnsavedChangesModal();
    }
    window.leaveWithoutSaving = leaveWithoutSaving;
    
    // Cancel navigation
    function cancelLeave() {
        hideUnsavedChangesModal();
    }
    
    // Toggle the toggle card open/closed
    // Show emoji picker for callout card
    function showEmojiPicker(cardId) {
        // Find the card element
        const card = document.getElementById(cardId);
        if (!card) {
            console.error('Card not found:', cardId);
            return;
        }
        
        // Check if picker already exists
        let emojiPicker = card.querySelector('.ghost-emoji-picker');
        
        if (!emojiPicker) {
            const emojis = ['💡', '💙', '💚', '💛', '🚨', '💕', '💜', '✨', '🔥', '⭐', '✅', '❓', '❗', '💬', '📝', '🎯', '🚀', '💪', '👍', '⚡', '🌟', '🎉', '🔑', '📌'];
            
            const picker = document.createElement('div');
            picker.className = 'ghost-emoji-picker';
            picker.innerHTML = `
                <div class="ghost-emoji-grid">
                    ${emojis.map(emoji => `
                        <div class="ghost-emoji-option" onclick="selectEmoji('${cardId}', '${emoji}')">${emoji}</div>
                    `).join('')}
                </div>
            `;
            
            const calloutCard = card.querySelector('.ghost-callout-card');
            if (calloutCard) {
                calloutCard.style.position = 'relative';
                calloutCard.appendChild(picker);
            } else {
                console.error('Callout card container not found');
                return;
            }
        }
        
        // Toggle picker visibility
        const picker = card.querySelector('.ghost-emoji-picker');
        picker.classList.toggle('active');
        
        // Close picker when clicking outside
        if (picker.classList.contains('active')) {
            setTimeout(() => {
                document.addEventListener('click', function closeEmojiPicker(e) {
                    if (!picker.contains(e.target) && !e.target.classList.contains('ghost-callout-emoji')) {
                        picker.classList.remove('active');
                        document.removeEventListener('click', closeEmojiPicker);
                    }
                });
            }, 100);
        }
    }
    
    // Select emoji for callout card
    function selectEmoji(cardId, emoji) {
        updateCardData(cardId, 'emoji', emoji);
        refreshCard(cardId);
        const card = document.getElementById(cardId);
        if (card) {
            const picker = card.querySelector('.ghost-emoji-picker');
            if (picker) {
                picker.classList.remove('active');
            }
        }
    }
    
    function toggleToggleCard(cardId) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.isOpen = !card.data.isOpen;
            updateCardData(cardId, 'isOpen', card.data.isOpen);
            
            // Update UI
            const toggleCard = document.querySelector(`#card-${cardId} .kg-toggle-card`);
            if (toggleCard) {
                toggleCard.setAttribute('data-kg-toggle-state', card.data.isOpen ? 'open' : 'close');
            }
            
            markDirtySafe();
        }
    }
    
    // Autosave function
    function autosave() {
        if (!isDirty) return;
        
        // Autosave with the current status (maintain published/scheduled/draft status)
        if (originalStatus !== 'published' && originalStatus !== 'scheduled') {
            // Only save as draft if it's currently a draft
            savePost('draft', true);
        } else {
            // Maintain the current status for published and scheduled posts
            savePost(originalStatus, true);
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
    
    // Adjust markdown textarea height
    function adjustMarkdownHeight(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = Math.max(200, textarea.scrollHeight) + 'px';
    }
    
    // Handle tab key in markdown editor
    function handleMarkdownTab(event) {
        if (event.key === 'Tab') {
            event.preventDefault();
            const textarea = event.target;
            const start = textarea.selectionStart;
            const end = textarea.selectionEnd;
            
            // Insert tab character
            textarea.value = textarea.value.substring(0, start) + '    ' + textarea.value.substring(end);
            
            // Move cursor
            textarea.selectionStart = textarea.selectionEnd = start + 4;
        }
    }
    
    // Set post visibility
    function setVisibility(visibility) {
        // Update segmented control
        document.querySelectorAll('.apple-segment').forEach(btn => {
            btn.classList.remove('active');
        });
        event.target.classList.add('active');
        
        // Update hidden field value
        document.getElementById('postVisibility').value = visibility;
        markDirty();
        
        // Trigger auto-save for visibility changes
        if (autosaveTimer) {
            clearTimeout(autosaveTimer);
        }
        autosaveTimer = setTimeout(autosave, 500); // Quick save for visibility
    }
    
    // Settings panel subview functions
    window.showSubview = function(viewName) {
        const subview = document.getElementById(viewName + 'Subview');
        if (subview) {
            subview.classList.add('active');
            
            // Update previews when social media tabs are opened
            if (viewName === 'twitterData') {
                setTimeout(() => {
                    updateTwitterPreview();
                }, 100);
            } else if (viewName === 'facebookData') {
                setTimeout(() => {
                    updateFacebookPreview();
                }, 100);
            } else if (viewName === 'metaData') {
                setTimeout(() => {
                    updateSearchPreview();
                    updateCanonicalUrlPreview();
                }, 100);
            }
        }
    };
    
    window.closeSubview = function(viewName) {
        const subview = document.getElementById(viewName + 'Subview');
        if (subview) {
            subview.classList.remove('active');
        }
    };
    
    // Character counter for meta fields
    function updateCharCount(inputId, counterId, maxLength) {
        const input = document.getElementById(inputId);
        const counter = document.getElementById(counterId);
        if (input && counter) {
            const remaining = maxLength - input.value.length;
            counter.textContent = remaining;
            counter.style.color = remaining < 0 ? '#e74c3c' : '#6c757d';
        }
    }
    
    // Get first paragraph from content
    function getFirstParagraph() {
        // First try to get from contentCards array
        if (contentCards && contentCards.length > 0) {
            for (let card of contentCards) {
                if (card.type === 'paragraph' && card.data && card.data.content) {
                    // Strip HTML tags and return plain text
                    const temp = document.createElement('div');
                    temp.innerHTML = card.data.content;
                    
                    // If content has <br><br>, it means multiple paragraphs were combined
                    // Split by <br><br> and get the first part
                    if (card.data.content.includes('<br><br>')) {
                        const parts = card.data.content.split('<br><br>');
                        temp.innerHTML = parts[0];
                    }
                    
                    const text = temp.textContent || temp.innerText || '';
                    if (text.trim()) {
                        return text.trim();
                    }
                }
            }
        }
        
        // If no cards yet, try to get from DOM directly
        const paragraphCards = document.querySelectorAll('[data-card-type="paragraph"] .card-content');
        for (let i = 0; i < paragraphCards.length; i++) {
            const content = paragraphCards[i].innerHTML;
            if (content) {
                const temp = document.createElement('div');
                temp.innerHTML = content;
                const text = temp.textContent || temp.innerText || '';
                if (text.trim()) {
                    return text.trim();
                }
            }
        }
        
        // If still no content, check if we have HTML content from postData
        const htmlContent = postData.html || postData.HTML;
        if (htmlContent) {
            const temp = document.createElement('div');
            temp.innerHTML = htmlContent;
            // Find first paragraph tag
            const firstP = temp.querySelector('p');
            if (firstP) {
                const text = firstP.textContent || firstP.innerText || '';
                if (text.trim()) {
                    return text.trim();
                }
            }
            // If no p tag, just get first text content
            const text = temp.textContent || temp.innerText || '';
            if (text.trim()) {
                // Return first 200 characters as a paragraph
                return text.trim().substring(0, 200);
            }
        }
        
        // If no paragraph found, return empty string
        return '';
    }
    
    // Update social media previews
    function updateTwitterPreview() {
        const titleEl = document.getElementById('twitterTitle');
        const descEl = document.getElementById('twitterDescription');
        const metaDescEl = document.getElementById('metaDescription');
        const excerptEl = document.getElementById('postExcerpt');
        const postTitleEl = document.getElementById('postTitle');
        
        // Update preview title
        const previewTitle = document.getElementById('twitterPreviewTitle');
        if (previewTitle) {
            previewTitle.textContent = titleEl.value || postTitleEl.value || 'Untitled';
        }
        
        // Update preview description
        const previewDesc = document.getElementById('twitterPreviewDesc');
        if (previewDesc) {
            let desc = descEl.value || metaDescEl.value || excerptEl.value;
            
            // If no description set, use first paragraph from content
            if (!desc || desc.trim() === '') {
                const firstParagraph = getFirstParagraph();
                desc = firstParagraph;
            }
            
            // Ensure we have something to show
            if (!desc || desc === 'No paragraph found') {
                desc = 'No description available';
            }
            
            previewDesc.textContent = desc.substring(0, 125);
        }
    }
    
    function updateFacebookPreview() {
        const titleEl = document.getElementById('facebookTitle');
        const descEl = document.getElementById('facebookDescription');
        const metaDescEl = document.getElementById('metaDescription');
        const excerptEl = document.getElementById('postExcerpt');
        const postTitleEl = document.getElementById('postTitle');
        
        // Update preview title
        const previewTitle = document.getElementById('fbPreviewTitle');
        if (previewTitle) {
            previewTitle.textContent = titleEl.value || postTitleEl.value || 'Untitled';
        }
        
        // Update preview description
        const previewDesc = document.getElementById('fbPreviewDesc');
        if (previewDesc) {
            let desc = descEl.value || metaDescEl.value || excerptEl.value;
            
            // If no description set, use first paragraph from content
            if (!desc || desc.trim() === '') {
                const firstParagraph = getFirstParagraph();
                desc = firstParagraph;
            }
            
            // Ensure we have something to show
            if (!desc || desc === 'No paragraph found') {
                desc = 'No description available';
            }
            
            previewDesc.textContent = desc.substring(0, 160);
        }
    }
    
    // Update search result preview
    function updateSearchPreview() {
        const metaTitleEl = document.getElementById('metaTitle');
        const metaDescEl = document.getElementById('metaDescription');
        const postTitleEl = document.getElementById('postTitle');
        const excerptEl = document.getElementById('postExcerpt');
        const slugEl = document.getElementById('postSlug');
        
        // Update preview title
        const previewTitle = document.getElementById('searchPreviewTitle');
        if (previewTitle) {
            previewTitle.textContent = metaTitleEl.value || postTitleEl.value || 'Untitled';
        }
        
        // Update preview description
        const previewDesc = document.getElementById('searchPreviewDesc');
        if (previewDesc) {
            let desc = metaDescEl.value || excerptEl.value;
            
            // If no description set, use first paragraph from content
            if (!desc) {
                const firstParagraph = getFirstParagraph();
                desc = firstParagraph;
            }
            
            previewDesc.textContent = desc.substring(0, 160);
        }
        
        // Update preview slug
        const previewSlug = document.getElementById('searchPreviewSlug');
        if (previewSlug && slugEl) {
            previewSlug.textContent = slugEl.value || 'untitled';
        }
    }
    
    // Update canonical URL preview
    function updateCanonicalUrlPreview() {
        const canonicalUrlEl = document.getElementById('canonicalUrl');
        const previewContainer = document.getElementById('canonicalUrlPreview');
        const previewText = document.getElementById('canonicalUrlText');
        
        if (canonicalUrlEl && previewContainer && previewText) {
            const url = canonicalUrlEl.value.trim();
            if (url) {
                previewText.textContent = url;
                previewContainer.style.display = 'block';
            } else {
                previewContainer.style.display = 'none';
            }
        }
    }
    
    // Initialize character counters when DOM is ready
    document.addEventListener('DOMContentLoaded', function() {
        // Meta title counter
        const metaTitle = document.getElementById('metaTitle');
        if (metaTitle) {
            metaTitle.addEventListener('input', function() {
                updateCharCount('metaTitle', 'metaTitleCount', 60);
                markDirty();
                // Update search preview
                updateSearchPreview();
                // Trigger auto-save with debounce
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 2000); // 2 second delay for typing
            });
            metaTitle.addEventListener('blur', function() {
                if (isDirty) {
                    autosave();
                }
            });
            updateCharCount('metaTitle', 'metaTitleCount', 60);
        }
        
        // Meta description counter
        const metaDescription = document.getElementById('metaDescription');
        if (metaDescription) {
            metaDescription.addEventListener('input', function() {
                updateCharCount('metaDescription', 'metaDescriptionCount', 160);
                markDirty();
                // Update all previews
                updateSearchPreview();
                updateTwitterPreview();
                updateFacebookPreview();
                // Trigger auto-save with debounce
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 2000); // 2 second delay for typing
            });
            metaDescription.addEventListener('blur', function() {
                if (isDirty) {
                    autosave();
                }
            });
            updateCharCount('metaDescription', 'metaDescriptionCount', 160);
        }
        
        // Twitter title counter
        const twitterTitle = document.getElementById('twitterTitle');
        if (twitterTitle) {
            twitterTitle.addEventListener('input', function() {
                updateCharCount('twitterTitle', 'twitterTitleCount', 70);
                markDirty();
                // Update Twitter preview
                updateTwitterPreview();
                // Trigger auto-save with debounce
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 2000); // 2 second delay for typing
            });
            twitterTitle.addEventListener('blur', function() {
                if (isDirty) {
                    autosave();
                }
            });
            updateCharCount('twitterTitle', 'twitterTitleCount', 70);
        }
        
        // Twitter description counter
        const twitterDescription = document.getElementById('twitterDescription');
        if (twitterDescription) {
            twitterDescription.addEventListener('input', function() {
                updateCharCount('twitterDescription', 'twitterDescriptionCount', 125);
                markDirty();
                // Update Twitter preview
                updateTwitterPreview();
                // Trigger auto-save with debounce
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 2000); // 2 second delay for typing
            });
            twitterDescription.addEventListener('blur', function() {
                if (isDirty) {
                    autosave();
                }
            });
            updateCharCount('twitterDescription', 'twitterDescriptionCount', 125);
        }
        
        // Facebook title counter
        const facebookTitle = document.getElementById('facebookTitle');
        if (facebookTitle) {
            facebookTitle.addEventListener('input', function() {
                updateCharCount('facebookTitle', 'facebookTitleCount', 60);
                markDirty();
                // Update Facebook preview
                updateFacebookPreview();
                // Trigger auto-save with debounce
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 2000); // 2 second delay for typing
            });
            facebookTitle.addEventListener('blur', function() {
                if (isDirty) {
                    autosave();
                }
            });
            updateCharCount('facebookTitle', 'facebookTitleCount', 60);
        }
        
        // Facebook description counter
        const facebookDescription = document.getElementById('facebookDescription');
        if (facebookDescription) {
            facebookDescription.addEventListener('input', function() {
                updateCharCount('facebookDescription', 'facebookDescriptionCount', 160);
                markDirty();
                // Update Facebook preview
                updateFacebookPreview();
                // Trigger auto-save with debounce
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 2000); // 2 second delay for typing
            });
            facebookDescription.addEventListener('blur', function() {
                if (isDirty) {
                    autosave();
                }
            });
            updateCharCount('facebookDescription', 'facebookDescriptionCount', 160);
        }
        
        // Initialize all settings field handlers
        const settingsFields = [
            'postSlug', 'publishDate', 'postAccess', 'postExcerpt', 
            'postTemplate', 'codeinjectionHead', 'codeinjectionFoot',
            'canonicalUrl', 'twitterImage', 'facebookImage'
        ];
        
        settingsFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            if (field) {
                field.addEventListener('change', function() {
                    markDirty();
                    // Update previews if excerpt changed
                    if (fieldId === 'postExcerpt') {
                        updateSearchPreview();
                        updateTwitterPreview();
                        updateFacebookPreview();
                    }
                    // Update search preview if slug changed
                    if (fieldId === 'postSlug') {
                        updateSearchPreview();
                    }
                    // Trigger auto-save after change
                    if (autosaveTimer) {
                        clearTimeout(autosaveTimer);
                    }
                    autosaveTimer = setTimeout(autosave, 1000); // 1 second delay for settings
                });
                field.addEventListener('input', function() {
                    // Update previews on input for excerpt
                    if (fieldId === 'postExcerpt') {
                        updateSearchPreview();
                        updateTwitterPreview();
                        updateFacebookPreview();
                    }
                    // Update search preview on slug input
                    if (fieldId === 'postSlug') {
                        updateSearchPreview();
                    }
                    // Update canonical URL preview
                    if (fieldId === 'canonicalUrl') {
                        updateCanonicalUrlPreview();
                    }
                });
                field.addEventListener('blur', function() {
                    // Immediate save on blur
                    if (isDirty) {
                        autosave();
                    }
                });
            }
        });
        
        // Auto-save slug changes when manually edited
        document.getElementById('postSlug').addEventListener('input', function() {
            if (!isProgrammaticChange) {
                markDirty();
                // Auto-save slug changes with validation
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(() => {
                    // Validate slug before saving
                    const slug = this.value.trim();
                    if (slug.length >= 3) {
                        autosave();
                    }
                }, 2000); // Increased delay
            }
        });
        
        // Handle checkboxes
        const checkboxes = ['featuredPost', 'showTitleAndFeatureImage'];
        checkboxes.forEach(checkboxId => {
            const checkbox = document.getElementById(checkboxId);
            if (checkbox) {
                checkbox.addEventListener('change', function() {
                    markDirty();
                    // Trigger auto-save immediately for checkboxes
                    if (autosaveTimer) {
                        clearTimeout(autosaveTimer);
                    }
                    autosaveTimer = setTimeout(autosave, 500); // Quick save for checkboxes
                });
            }
        });
        
        // Initialize tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
        
        // Initialize canonical URL preview
        updateCanonicalUrlPreview();
        
        // Initialize all social previews
        updateSearchPreview();
        updateTwitterPreview();
        updateFacebookPreview();
        
        // Auto-generate slug on page load if needed
        setTimeout(() => {
            const titleField = document.getElementById('postTitle');
            const slugField = document.getElementById('postSlug');
            const titleValue = titleField ? titleField.value.trim() : '';
            const slugValue = slugField ? slugField.value.trim() : '';
            
            if (titleValue && !slugValue && originalStatus === 'draft') {
                console.log('Auto-generating slug on load for title:', titleValue);
                const slug = generateSlug(titleValue);
                isProgrammaticChange = true;
                slugField.value = slug;
                setTimeout(() => { isProgrammaticChange = false; }, 10);
                markDirtySafe();
            }
        }, 500);
    });
    
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
                badge.className = 'apple-tag';
                badge.innerHTML = `
                    ${tagName}
                    <button type="button" class="apple-tag-remove" onclick="removeTag('${tagId}')">
                        <i class="ti ti-x text-sm"></i>
                    </button>
                `;
                tagsContainer.appendChild(badge);
                
                markDirtySafe();
                
                // Trigger auto-save for tag changes
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 1000); // Quick save for tags
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
            badge.className = 'apple-tag';
            badge.innerHTML = `
                ${tag.name}
                <button type="button" class="apple-tag-remove" onclick="removeTag('${tag.id}')">
                    <i class="ti ti-x text-sm"></i>
                </button>
            `;
            tagsContainer.appendChild(badge);
        });
        
        markDirtySafe();
        
        // Trigger auto-save for tag changes
        if (autosaveTimer) {
            clearTimeout(autosaveTimer);
        }
        autosaveTimer = setTimeout(autosave, 1000); // Quick save for tags
    }
    
    // Author management
    let selectedAuthors = [];
    
    // Initialize selectedAuthors from existing data
    document.addEventListener('DOMContentLoaded', function() {
        // Get existing authors from the DOM
        const existingAuthors = document.querySelectorAll('#selectedAuthors .apple-tag');
        existingAuthors.forEach(authorTag => {
            const authorId = authorTag.getAttribute('data-author-id');
            const authorName = authorTag.textContent.trim();
            if (authorId) {
                selectedAuthors.push({
                    id: authorId,
                    name: authorName
                });
            }
        });
    });
    
    function addAuthor() {
        const selector = document.getElementById('authorSelector');
        const selectedOption = selector.options[selector.selectedIndex];
        
        if (selectedOption.value) {
            const authorId = selectedOption.value;
            const authorName = selectedOption.getAttribute('data-name');
            
            // Check if author already selected
            if (!selectedAuthors.find(a => a.id === authorId)) {
                selectedAuthors.push({
                    id: authorId,
                    name: authorName
                });
                
                // Add author badge
                const authorsContainer = document.getElementById('selectedAuthors');
                const badge = document.createElement('span');
                badge.className = 'apple-tag';
                badge.setAttribute('data-author-id', authorId);
                badge.innerHTML = `
                    ${authorName}
                    <button type="button" class="apple-tag-remove" onclick="removeAuthor('${authorId}')">
                        <i class="ti ti-x text-sm"></i>
                    </button>
                `;
                authorsContainer.appendChild(badge);
                
                // Hide this author from the dropdown
                const optionToHide = document.querySelector('.author-option-' + authorId);
                if (optionToHide) {
                    optionToHide.style.display = 'none';
                }
                
                markDirtySafe();
                
                // Trigger auto-save for author changes
                if (autosaveTimer) {
                    clearTimeout(autosaveTimer);
                }
                autosaveTimer = setTimeout(autosave, 1000); // Quick save for authors
            }
            
            // Reset selector
            selector.value = '';
        }
    }
    
    function removeAuthor(authorId) {
        selectedAuthors = selectedAuthors.filter(a => a.id !== authorId);
        
        // Rebuild authors display
        const authorsContainer = document.getElementById('selectedAuthors');
        authorsContainer.innerHTML = '';
        
        selectedAuthors.forEach(author => {
            const badge = document.createElement('span');
            badge.className = 'apple-tag';
            badge.setAttribute('data-author-id', author.id);
            badge.innerHTML = `
                ${author.name}
                <button type="button" class="apple-tag-remove" onclick="removeAuthor('${author.id}')">
                    <i class="ti ti-x text-sm"></i>
                </button>
            `;
            authorsContainer.appendChild(badge);
        });
        
        // Show this author back in the dropdown
        const optionToShow = document.querySelector('.author-option-' + authorId);
        if (optionToShow) {
            optionToShow.style.display = '';
        }
        
        markDirtySafe();
        
        // Trigger auto-save for author changes
        if (autosaveTimer) {
            clearTimeout(autosaveTimer);
        }
        autosaveTimer = setTimeout(autosave, 1000); // Quick save for authors
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
            
            // Add post title for SEO-friendly filename
            const postTitle = document.getElementById('postTitle') ? document.getElementById('postTitle').value : '';
            if (postTitle) {
                formData.append('postTitle', postTitle);
            }
            
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
                // console.log('Upload response:', text);
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
                        // console.log('No audio track or audio processing failed');
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
        let input = document.getElementById('imageInput-' + cardId);
        
        // If input doesn't exist, create it dynamically
        if (!input) {
            input = document.createElement('input');
            input.type = 'file';
            input.id = 'imageInput-' + cardId;
            input.accept = 'image/*';
            input.style.display = 'none';
            input.onchange = function() {
                uploadImage(cardId, this);
            };
            document.body.appendChild(input);
        }
        
        input.click();
    }
    
    // Handle button hover effects with custom colors
    function handleButtonHover(cardId, isHover) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        const button = document.getElementById('button-' + cardId);
        if (!button) return;
        
        const bgColor = card.data.backgroundColor || '#14b8ff';
        const textColor = card.data.textColor || '#ffffff';
        
        if (isHover) {
            // Darken background color for hover effect
            const darkerBg = darkenColor(bgColor, 0.1);
            
            switch(card.data.buttonStyle) {
                case 'primary':
                case 'secondary':
                    button.style.backgroundColor = darkerBg + ' !important';
                    button.style.borderColor = darkerBg + ' !important';
                    break;
                case 'outline':
                    button.style.borderColor = darkerBg + ' !important';
                    button.style.color = darkerBg + ' !important';
                    button.style.backgroundColor = 'rgba(0,0,0,0.05) !important';
                    break;
                case 'link':
                    const darkerLinkColor = darkenColor(bgColor, 0.2);
                    button.style.color = darkerLinkColor + ' !important';
                    break;
            }
        } else {
            // Restore original colors
            switch(card.data.buttonStyle) {
                case 'primary':
                case 'secondary':
                    button.style.backgroundColor = bgColor + ' !important';
                    button.style.color = textColor + ' !important';
                    button.style.borderColor = bgColor + ' !important';
                    break;
                case 'outline':
                    button.style.borderColor = bgColor + ' !important';
                    button.style.color = bgColor + ' !important';
                    button.style.backgroundColor = 'transparent !important';
                    break;
                case 'link':
                    button.style.color = bgColor + ' !important';
                    button.style.backgroundColor = 'transparent !important';
                    button.style.border = 'none !important';
                    break;
            }
        }
    }
    
    // Helper function to darken a color
    function darkenColor(color, percent) {
        const num = parseInt(color.replace("#",""), 16);
        const amt = Math.round(2.55 * percent * 100);
        const R = (num >> 16) - amt;
        const G = (num >> 8 & 0x00FF) - amt;
        const B = (num & 0x0000FF) - amt;
        return "#" + (0x1000000 + (R<255?R<1?0:R:255)*0x10000 + (G<255?G<1?0:G:255)*0x100 + (B<255?B<1?0:B:255)).toString(16).slice(1);
    }
    
    // Update button style and reset colors to defaults for that style
    function updateButtonStyle(cardId, newStyle) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        // Update the button style
        updateCardData(cardId, 'buttonStyle', newStyle);
        
        // Reset colors to defaults for the new style
        let newBgColor = '#14b8ff';
        let newTextColor = '#ffffff';
        
        switch(newStyle) {
            case 'secondary':
                newBgColor = '#626d79';
                break;
            case 'outline':
            case 'link':
                newBgColor = '#15171a';
                break;
        }
        
        updateCardData(cardId, 'backgroundColor', newBgColor);
        updateCardData(cardId, 'textColor', newTextColor);
        
        // Refresh the card
        refreshCard(cardId);
    }
    
    // Gallery card functions
    function renderGalleryImages(card) {
        if (!card.data.images || card.data.images.length === 0) {
            return `
                <div class="kg-gallery-empty" onclick="event.stopPropagation(); document.getElementById('galleryImages-${card.id}').click();">
                    <i class="ti ti-photo-plus"></i>
                    <p>Click to add images</p>
                </div>
            `;
        }
        
        // Build rows based on Ghost's algorithm (max 3 images per row)
        const rows = [];
        const images = card.data.images;
        const maxPerRow = 3;
        
        images.forEach((image, idx) => {
            let row = Math.floor(idx / maxPerRow);
            
            // Special case: if odd number of images and more than 1, put last 2 in their own row
            if (images.length > 1 && (images.length % maxPerRow === 1) && (idx === images.length - 2)) {
                row = row + 1;
            }
            
            if (!rows[row]) {
                rows[row] = [];
            }
            rows[row].push({...image, index: idx});
        });
        
        return rows.map(row => `
            <div class="kg-gallery-row">
                ${row.map(image => `
                    <div class="kg-gallery-image" data-index="${image.index}">
                        <img src="${image.src}" 
                             alt="${image.alt || ''}" 
                             loading="lazy"
                             ${image.width ? `width="${image.width}"` : ''}
                             ${image.height ? `height="${image.height}"` : ''}>
                        <div class="kg-gallery-image-toolbar">
                            <button type="button" 
                                    class="kg-gallery-image-btn"
                                    onclick="event.stopPropagation(); editGalleryImage('${card.id}', ${image.index})"
                                    title="Edit">
                                <i class="ti ti-pencil"></i>
                            </button>
                            <button type="button" 
                                    class="kg-gallery-image-btn"
                                    onclick="event.stopPropagation(); removeGalleryImage('${card.id}', ${image.index})"
                                    title="Remove">
                                <i class="ti ti-trash"></i>
                            </button>
                        </div>
                    </div>
                `).join('')}
            </div>
        `).join('');
    }
    
    function uploadGalleryImages(cardId, input) {
        const files = Array.from(input.files);
        if (!files.length) return;
        
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        let uploadedCount = 0;
        let totalFiles = files.length;
        
        showMessage(`Uploading ${totalFiles} image${totalFiles > 1 ? 's' : ''}...`, 'info');
        
        // Process each file
        files.forEach(file => {
            if (!file.type.match('image.*')) {
                showMessage(`${file.name} is not an image`, 'error');
                return;
            }
            
            if (file.size > 5 * 1024 * 1024) {
                showMessage(`${file.name} is too large (max 5MB)`, 'error');
                return;
            }
            
            const formData = new FormData();
            formData.append('file', file);
            formData.append('type', 'content');
            
            // Add post title for SEO-friendly filename
            const postTitle = document.getElementById('postTitle') ? document.getElementById('postTitle').value : '';
            if (postTitle) {
                formData.append('postTitle', postTitle);
            }
            
            fetch('/ghost/admin/ajax/upload-image.cfm', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success || data.SUCCESS) {
                    const imageUrl = data.url || data.URL;
                    
                    // Add image to gallery
                    if (!card.data.images) {
                        card.data.images = [];
                    }
                    
                    card.data.images.push({
                        src: imageUrl,
                        width: data.width || data.WIDTH || null,
                        height: data.height || data.HEIGHT || null,
                        fileName: file.name,
                        alt: '',
                        title: '',
                        row: 0 // Will be recalculated on render
                    });
                    
                    uploadedCount++;
                    
                    // Refresh card when all uploads complete
                    if (uploadedCount === totalFiles) {
                        refreshGalleryCard(cardId);
                        showMessage('Images uploaded successfully', 'success');
                    }
                } else {
                    showMessage(`Failed to upload ${file.name}`, 'error');
                }
            })
            .catch(error => {
                showMessage(`Failed to upload ${file.name}: ${error.message}`, 'error');
            });
        });
        
        // Clear input
        input.value = '';
    }
    
    function removeGalleryImage(cardId, index) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card || !card.data.images) return;
        
        // Remove image
        card.data.images.splice(index, 1);
        
        // Update card data
        updateCardData(cardId, 'images', card.data.images);
        
        // Refresh gallery
        refreshGalleryCard(cardId);
    }
    
    function editGalleryImage(cardId, index) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card || !card.data.images || !card.data.images[index]) return;
        
        const image = card.data.images[index];
        
        // Create edit modal
        const modal = document.createElement('div');
        modal.className = 'ghost-modal-backdrop';
        modal.innerHTML = `
            <div class="ghost-modal">
                <div class="ghost-modal-header">
                    <h3>Edit image</h3>
                    <button type="button" class="ghost-modal-close" onclick="closeGalleryImageModal()">
                        <i class="ti ti-x"></i>
                    </button>
                </div>
                <div class="ghost-modal-body">
                    <div class="form-group">
                        <label>Alt text</label>
                        <input type="text" 
                               id="galleryImageAlt" 
                               class="form-control" 
                               value="${image.alt || ''}"
                               placeholder="Description of image">
                    </div>
                    <div class="form-group">
                        <label>Link URL</label>
                        <input type="url" 
                               id="galleryImageHref" 
                               class="form-control" 
                               value="${image.href || ''}"
                               placeholder="https://example.com">
                    </div>
                </div>
                <div class="ghost-modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeGalleryImageModal()">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveGalleryImageEdit('${cardId}', ${index})">Save</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
    }
    
    function closeGalleryImageModal() {
        const modal = document.querySelector('.ghost-modal-backdrop');
        if (modal) modal.remove();
    }
    
    function saveGalleryImageEdit(cardId, index) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card || !card.data.images || !card.data.images[index]) return;
        
        const alt = document.getElementById('galleryImageAlt').value;
        const href = document.getElementById('galleryImageHref').value;
        
        // Update image data
        card.data.images[index].alt = alt;
        card.data.images[index].href = href;
        
        // Update card data
        updateCardData(cardId, 'images', card.data.images);
        
        // Close modal
        closeGalleryImageModal();
        
        // Refresh gallery
        refreshGalleryCard(cardId);
    }
    
    function refreshGalleryCard(cardId) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        const container = document.getElementById('gallery-container-' + cardId);
        if (container) {
            container.innerHTML = renderGalleryImages(card);
        }
        
        // Update caption if it exists
        const captionElement = document.querySelector(`#${cardId} .kg-gallery-card figcaption`);
        if (card.data.caption) {
            if (!captionElement) {
                const galleryCard = document.querySelector(`#${cardId} .kg-gallery-card`);
                if (galleryCard) {
                    const newCaption = document.createElement('figcaption');
                    newCaption.textContent = card.data.caption;
                    galleryCard.appendChild(newCaption);
                }
            } else {
                captionElement.textContent = card.data.caption;
            }
        } else if (captionElement) {
            captionElement.remove();
        }
        
        // Update images list in settings
        const imagesList = document.querySelector(`#gallerySettings-${cardId} .ghost-gallery-images-list`);
        if (imagesList && card.data.images.length > 0) {
            imagesList.innerHTML = card.data.images.map((image, index) => `
                <div class="ghost-gallery-image-item" data-index="${index}">
                    <img src="${image.src}" alt="${image.alt || ''}">
                    <div class="ghost-gallery-image-actions">
                        <button type="button" 
                                class="ghost-gallery-action-btn"
                                onclick="event.stopPropagation(); editGalleryImage('${cardId}', ${index})"
                                title="Edit">
                            <i class="ti ti-pencil"></i>
                        </button>
                        <button type="button" 
                                class="ghost-gallery-action-btn ghost-gallery-action-delete"
                                onclick="event.stopPropagation(); removeGalleryImage('${cardId}', ${index})"
                                title="Remove">
                            <i class="ti ti-trash"></i>
                        </button>
                    </div>
                </div>
            `).join('');
        }
        
        markDirtySafe();
    }
    
    // Toggle card settings panel
    function toggleCardSettings(cardId) {
        const card = document.getElementById(cardId);
        if (!card) return;
        
        // Find the settings panel within this card
        const settingsPanel = card.querySelector('.ghost-card-settings');
        if (!settingsPanel) return;
        
        // Check if we're currently editing within this settings panel
        const activeElement = document.activeElement;
        const isEditingSettings = settingsPanel.contains(activeElement);
        
        // If we're editing settings, don't close the panel
        if (isEditingSettings) {
            return;
        }
        
        // Toggle active class
        settingsPanel.classList.toggle('active');
        
        // Close all other settings panels
        document.querySelectorAll('.ghost-card-settings').forEach(panel => {
            if (panel !== settingsPanel) {
                panel.classList.remove('active');
            }
        });
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
    
    // Header Card Functions
    function updateHeaderCardInPlace(cardId) {
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        const headerCard = document.getElementById('headerCard-' + cardId);
        if (!headerCard) {
            // Fallback to full refresh if element not found
            refreshCard(cardId);
            return;
        }
        
        // Update classes
        let cardClasses = ['kg-card', 'kg-header-card', 'kg-v2'];
        
        // Add width class based on size/layout
        if (card.data.size === 'small' && card.data.layout !== 'split') {
            // Default width for small
        } else if (card.data.size === 'medium' && card.data.layout !== 'split') {
            cardClasses.push('kg-width-wide');
        } else if (card.data.size === 'large' && card.data.layout !== 'split') {
            cardClasses.push('kg-width-full');
        }
        
        // Add layout classes for split
        if (card.data.layout === 'split') {
            cardClasses.push('kg-layout-split', 'kg-width-full');
            if (card.data.swapped) {
                cardClasses.push('kg-swapped');
            }
        }
        
        // Add content-wide for full layouts
        if ((card.data.size === 'large' || card.data.layout === 'split') && card.data.layout !== 'regular') {
            cardClasses.push('kg-content-wide');
        }
        
        // Apply style class
        if (card.data.style === 'accent') {
            cardClasses.push('kg-style-accent');
        }
        
        // Add image style class if background image is present (not for split layout)
        if (card.data.backgroundImageSrc && card.data.layout !== 'split') {
            cardClasses.push('kg-style-image');
        }
        
        // Update the header card element
        headerCard.className = cardClasses.join(' ');
        
        // Update background style - handle both image and color
        if (card.data.backgroundImageSrc && card.data.layout !== 'split') {
            headerCard.style.backgroundImage = `url(${card.data.backgroundImageSrc})`;
            headerCard.style.backgroundSize = card.data.backgroundSize || 'cover';
            headerCard.style.backgroundPosition = 'center';
            // Still apply background color as fallback
            if (card.data.style !== 'accent') {
                headerCard.style.backgroundColor = card.data.backgroundColor;
            }
        } else if (card.data.style !== 'accent') {
            headerCard.style.backgroundColor = card.data.backgroundColor;
            headerCard.style.backgroundImage = '';
        } else {
            headerCard.style.backgroundColor = '';
            headerCard.style.backgroundImage = '';
        }
        
        // Update text colors
        const heading = headerCard.querySelector('.kg-header-card-heading');
        const subheading = headerCard.querySelector('.kg-header-card-subheading');
        const button = headerCard.querySelector('.kg-header-card-button');
        
        if (heading) {
            heading.style.color = card.data.textColor;
            heading.setAttribute('data-text-color', card.data.textColor);
        }
        
        if (subheading) {
            subheading.style.color = card.data.textColor;
            subheading.setAttribute('data-text-color', card.data.textColor);
        }
        
        // Update alignment
        const textContainer = headerCard.querySelector('.kg-header-card-text');
        if (textContainer) {
            textContainer.className = `kg-header-card-text kg-align-${card.data.alignment}`;
        }
        
        // Update button if needed
        if (button && card.data.buttonEnabled) {
            button.textContent = card.data.buttonText;
            button.href = card.data.buttonUrl || '#';
            
            if (card.data.buttonColor === 'accent') {
                button.className = 'kg-header-card-button kg-style-accent';
                button.style.backgroundColor = '';
                button.style.color = '';
            } else {
                button.className = 'kg-header-card-button';
                button.style.backgroundColor = card.data.buttonColor;
                button.style.color = card.data.buttonTextColor;
            }
            
            button.setAttribute('data-button-color', card.data.buttonColor);
            button.setAttribute('data-button-text-color', card.data.buttonTextColor);
        }
        
        // Handle split layout structure changes if needed
        if (card.data.layout === 'split' && !headerCard.querySelector('.kg-header-card-content > .kg-header-card-text')) {
            // Need to restructure for split layout
            refreshCard(cardId);
            return;
        } else if (card.data.layout !== 'split' && headerCard.querySelector('.kg-header-card-content > .kg-header-card-text')) {
            // Need to restructure from split layout
            refreshCard(cardId);
            return;
        }
        
        // Update split image if in split layout
        if (card.data.layout === 'split') {
            const splitImage = headerCard.querySelector('.kg-header-card-image');
            if (splitImage && card.data.splitImageSrc) {
                splitImage.src = card.data.splitImageSrc;
            }
        }
    }
    
    // Store active header settings handlers
    let activeHeaderSettingsHandlers = {};
    
    // Header Card Functions
    function showHeaderSettings(cardId) {
        // Close any other open settings panels
        document.querySelectorAll('.kg-settings-panel-header').forEach(panel => {
            if (panel.id !== 'headerSettings-' + cardId) {
                panel.style.display = 'none';
                // Remove handler for other panels
                const otherId = panel.id.replace('headerSettings-', '');
                if (activeHeaderSettingsHandlers[otherId]) {
                    document.removeEventListener('click', activeHeaderSettingsHandlers[otherId]);
                    delete activeHeaderSettingsHandlers[otherId];
                }
            }
        });
        
        const settings = document.getElementById('headerSettings-' + cardId);
        
        if (settings) {
            // Always show the settings panel when header is clicked
            settings.style.display = 'block';
            
            // Remove any existing handler for this card
            if (activeHeaderSettingsHandlers[cardId]) {
                document.removeEventListener('click', activeHeaderSettingsHandlers[cardId]);
            }
            
            // Add click outside listener to close settings when clicking outside
            setTimeout(() => {
                const closeHandler = (event) => {
                    const card = document.getElementById('card-' + cardId);
                    const settingsPanel = document.getElementById('headerSettings-' + cardId);
                    
                    // Skip if elements don't exist or panel is already hidden
                    if (!settingsPanel || settingsPanel.style.display === 'none') {
                        return;
                    }
                    
                    // Check if click is outside both the card and settings panel
                    const clickedInsideCard = card && card.contains(event.target);
                    const clickedInsideSettings = settingsPanel.contains(event.target);
                    const clickedColorPicker = event.target.closest('.kg-color-picker-input');
                    const clickedFileInput = event.target.closest('input[type="file"]');
                    
                    if (!clickedInsideCard && 
                        !clickedInsideSettings &&
                        !clickedColorPicker &&
                        !clickedFileInput) {
                        
                        settingsPanel.style.display = 'none';
                        document.removeEventListener('click', closeHandler);
                        delete activeHeaderSettingsHandlers[cardId];
                    }
                };
                
                activeHeaderSettingsHandlers[cardId] = closeHandler;
                document.addEventListener('click', closeHandler);
            }, 100);
        }
    }
    
    function hideHeaderSettings(cardId) {
        const settings = document.getElementById('headerSettings-' + cardId);
        if (settings) {
            settings.classList.add('hidden');
        }
    }
    
    function updateHeaderLayout(cardId, layout) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.layout = layout;
            
            // Preserve settings panel state
            const settingsPanel = document.getElementById('headerSettings-' + cardId);
            const wasVisible = settingsPanel && settingsPanel.style.display === 'block';
            
            // Need to refresh for structural changes
            refreshCard(cardId);
            
            if (wasVisible) {
                setTimeout(() => {
                    showHeaderSettings(cardId);
                }, 50);
            }
            
            markDirtySafe();
        }
    }
    
    function updateHeaderBackground(cardId, color, textColor) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.backgroundColor = color;
            if (textColor) {
                card.data.textColor = textColor;
            }
            
            // Set style to custom when manually changing colors
            if (card.data.style !== 'custom' && color !== 'accent') {
                card.data.style = 'custom';
            }
            
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    function updateHeaderAlignment(cardId, alignment) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.alignment = alignment;
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    function updateHeaderSwapped(cardId, swapped) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.swapped = swapped;
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    function updateHeaderButton(cardId, enabled) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.buttonEnabled = enabled;
            // Button toggle requires structural changes, so we need a full refresh
            // But preserve the settings panel state
            const settingsPanel = document.getElementById('headerSettings-' + cardId);
            const wasVisible = settingsPanel && settingsPanel.style.display === 'block';
            
            refreshCard(cardId);
            
            if (wasVisible) {
                setTimeout(() => {
                    showHeaderSettings(cardId);
                }, 50);
            }
            
            markDirtySafe();
        }
    }
    
    function updateHeaderButtonColor(cardId, color, textColor) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.buttonColor = color;
            card.data.buttonTextColor = textColor;
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    function showHeaderColorPicker(cardId) {
        document.getElementById('headerColorPicker-' + cardId).click();
    }
    
    function showHeaderButtonColorPicker(cardId) {
        document.getElementById('headerButtonColorPicker-' + cardId).click();
    }
    
    function selectHeaderBackgroundImage(cardId) {
        // Create input dynamically if it doesn't exist
        let input = document.getElementById('headerBgImageInput-' + cardId);
        if (!input) {
            input = document.createElement('input');
            input.type = 'file';
            input.id = 'headerBgImageInput-' + cardId;
            input.accept = 'image/*';
            input.style.display = 'none';
            input.onchange = function() {
                uploadHeaderBackgroundImage(cardId, this);
            };
            document.body.appendChild(input);
        }
        input.click();
    }
    
    function selectHeaderSplitImage(cardId) {
        // Create input dynamically if it doesn't exist
        let input = document.getElementById('headerSplitImageInput-' + cardId);
        if (!input) {
            input = document.createElement('input');
            input.type = 'file';
            input.id = 'headerSplitImageInput-' + cardId;
            input.accept = 'image/*';
            input.style.display = 'none';
            input.onchange = function() {
                uploadHeaderSplitImage(cardId, this);
            };
            document.body.appendChild(input);
        }
        input.click();
    }
    
    function updateHeaderSize(cardId, size) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.size = size;
            // Reset layout if changing size
            if (card.data.layout === 'split') {
                card.data.layout = 'regular';
            }
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    function updateHeaderStyle(cardId, style) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.style = style;
            
            // Apply style-specific defaults
            if (style === 'dark') {
                card.data.backgroundColor = '#08090c';
                card.data.textColor = '#FFFFFF';
            } else if (style === 'light') {
                card.data.backgroundColor = '#F9F9F9';
                card.data.textColor = '#15171A';
            } else if (style === 'accent') {
                card.data.backgroundColor = 'accent';
                card.data.textColor = '#FFFFFF';
            } else if (style === 'image') {
                // Image style - prompt for image if none exists
                card.data.backgroundColor = '#000000';
                card.data.textColor = '#FFFFFF';
                if (!card.data.backgroundImageSrc) {
                    setTimeout(() => {
                        selectHeaderBackgroundImage(cardId);
                    }, 100);
                }
            } else if (style === 'custom') {
                // Keep current colors or set defaults
                if (card.data.backgroundColor === 'accent' || !card.data.backgroundColor) {
                    card.data.backgroundColor = '#F9F9F9';
                }
                if (!card.data.textColor) {
                    card.data.textColor = '#15171A';
                }
            }
            
            // Always preserve settings panel state  
            const settingsPanel = document.getElementById('headerSettings-' + cardId);
            const wasVisible = settingsPanel && settingsPanel.style.display === 'block';
            
            refreshCard(cardId);
            
            if (wasVisible) {
                setTimeout(() => {
                    showHeaderSettings(cardId);
                }, 50);
            }
            
            markDirtySafe();
        }
    }
    
    function updateHeaderTextColor(cardId, color) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.textColor = color;
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    function toggleHeaderBackgroundImage(cardId, enabled) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            if (enabled && !card.data.backgroundImageSrc) {
                // Trigger image selection
                selectHeaderBackgroundImage(cardId);
            } else if (!enabled) {
                card.data.backgroundImageSrc = '';
                // Preserve settings panel state
                const settingsPanel = document.getElementById('headerSettings-' + cardId);
                const wasVisible = settingsPanel && settingsPanel.style.display === 'block';
                
                refreshCard(cardId);
                
                if (wasVisible) {
                    setTimeout(() => {
                        showHeaderSettings(cardId);
                    }, 50);
                }
                markDirtySafe();
            }
        }
    }
    
    function uploadHeaderBackgroundImage(cardId, input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            const reader = new FileReader();
            
            reader.onload = function(e) {
                const card = contentCards.find(c => c.id === cardId);
                if (card) {
                    card.data.backgroundImageSrc = e.target.result;
                    
                    // Preserve settings panel state
                    const settingsPanel = document.getElementById('headerSettings-' + cardId);
                    const wasVisible = settingsPanel && settingsPanel.style.display === 'block';
                    
                    refreshCard(cardId);
                    
                    if (wasVisible) {
                        setTimeout(() => {
                            showHeaderSettings(cardId);
                        }, 50);
                    }
                    
                    markDirtySafe();
                }
            };
            
            reader.readAsDataURL(file);
        }
    }
    
    function uploadHeaderSplitImage(cardId, input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            const reader = new FileReader();
            
            reader.onload = function(e) {
                const card = contentCards.find(c => c.id === cardId);
                if (card) {
                    card.data.splitImageSrc = e.target.result;
                    updateHeaderCardInPlace(cardId);
                    markDirtySafe();
                }
            };
            
            reader.readAsDataURL(file);
        }
    }
    
    function getContrastColor(hexcolor) {
        // Convert hex to RGB
        const r = parseInt(hexcolor.substr(1,2), 16);
        const g = parseInt(hexcolor.substr(3,2), 16);
        const b = parseInt(hexcolor.substr(5,2), 16);
        
        // Calculate luminance
        const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
        
        // Return black or white based on luminance
        return luminance > 0.5 ? '#000000' : '#FFFFFF';
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
            
            // Add post title for SEO-friendly filename
            const postTitle = document.getElementById('postTitle') ? document.getElementById('postTitle').value : '';
            if (postTitle) {
                formData.append('postTitle', postTitle);
            }
            
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
                // console.log('Upload response:', text);
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
            // console.log('Audio upload response:', text);
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
        // Same as upload but preserves metadata
        const card = contentCards.find(c => c.id === cardId);
        const title = card?.data?.title || '';
        const caption = card?.data?.caption || '';
        const loop = card?.data?.loop || false;
        const showDownload = card?.data?.showDownload || false;
        
        handleAudioUpload(cardId, input);
        
        // Restore metadata after upload
        setTimeout(() => {
            const updatedCard = contentCards.find(c => c.id === cardId);
            if (updatedCard && updatedCard.data.src) {
                updatedCard.data.title = title;
                updatedCard.data.caption = caption;
                updatedCard.data.loop = loop;
                updatedCard.data.showDownload = showDownload;
            }
        }, 100);
    }
    
    // Handle file upload
    function handleFileUpload(cardId, input) {
        const file = input.files[0];
        if (!file) return;
        
        // Check file size (50MB limit for files)
        const maxSize = 50 * 1024 * 1024; // 50MB
        if (file.size > maxSize) {
            const fileSizeMB = (file.size / (1024 * 1024)).toFixed(1);
            const card = document.getElementById(cardId);
            const contentDiv = card.querySelector('.card-content');
            contentDiv.innerHTML = `
                <div class="card-content text-center py-4">
                    <div class="mb-3">
                        <i class="ti ti-alert-circle text-warning" style="font-size: 3rem;"></i>
                    </div>
                    <h5>File Too Large</h5>
                    <p class="text-muted mb-3">
                        Your file is ${fileSizeMB}MB, but the limit is 50MB.
                    </p>
                    <div class="alert alert-info text-start">
                        <strong>Options:</strong><br>
                        • Use a file compression tool to reduce file size<br>
                        • Upload to a cloud service and share the link<br>
                        • Split large files into smaller parts<br>
                        • Contact administrator to increase limits
                    </div>
                    <button type="button" 
                            class="btn btn-primary"
                            onclick="document.getElementById('file-upload-${cardId}').click()">
                        <i class="ti ti-upload"></i> Try Different File
                    </button>
                    <input type="file" 
                           id="file-upload-${cardId}" 
                           style="display: none;"
                           onchange="handleFileUpload('${cardId}', this)">
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
                <div class="mt-2">Uploading file...</div>
            </div>
        `;
        
        // Create FormData
        const formData = new FormData();
        formData.append('file', file);
        
        // Upload file
        fetch('/ghost/admin/ajax/upload-file.cfm', {
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
            // console.log('File upload response:', text);
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
                const fileCard = contentCards.find(c => c.id === cardId);
                if (fileCard) {
                    fileCard.data.src = data.url || data.URL;
                    fileCard.data.fileName = data.fileName || data.FILENAME || file.name;
                    fileCard.data.size = data.size || data.SIZE || file.size;
                    refreshCard(cardId);
                    markDirtySafe();
                }
            } else {
                throw new Error(data.message || data.MESSAGE || 'Upload failed');
            }
        })
        .catch(error => {
            console.error('File upload error:', error);
            
            // Handle specific server errors
            let errorMessage = error.message;
            let suggestions = '';
            
            if (error.message.includes('413') || error.message.includes('Content Too Large')) {
                errorMessage = 'File too large for server';
                suggestions = `
                    <div class="alert alert-info text-start mt-3">
                        <strong>Server Upload Limit Reached</strong><br>
                        • Try a smaller file (under 25MB)<br>
                        • Use file compression to reduce size<br>
                        • Upload to cloud storage and share the link<br>
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
                            onclick="document.getElementById('file-upload-${cardId}').click()">
                        <i class="ti ti-upload"></i> Try Different File
                    </button>
                    <input type="file" 
                           id="file-upload-${cardId}" 
                           style="display: none;"
                           onchange="handleFileUpload('${cardId}', this)">
                </div>
            `;
        });
    }
    
    // Handle file replacement
    function handleFileReplace(cardId, input) {
        // Same as upload but preserves metadata
        const card = contentCards.find(c => c.id === cardId);
        const title = card?.data?.title || '';
        const description = card?.data?.description || '';
        
        handleFileUpload(cardId, input);
        
        // Restore metadata after upload
        setTimeout(() => {
            const updatedCard = contentCards.find(c => c.id === cardId);
            if (updatedCard && updatedCard.data.src) {
                updatedCard.data.title = title;
                updatedCard.data.description = description;
            }
        }, 100);
    }
    
    // Initialize product card with default content
    function initializeProductCard(cardId) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.title = '';
            card.data.description = '';
            card.data.price = '';
            card.data.url = '';
            card.data.initialized = true; // Flag to show the form
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    // Update product rating
    function updateProductRating(cardId, rating) {
        const card = contentCards.find(c => c.id === cardId);
        if (card) {
            card.data.rating = rating > 0 ? rating : null;
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }
    }
    
    // Get button class based on style
    function getButtonClass(style) {
        // This is no longer needed since we're using the style directly as a class
        return style || 'primary';
    }
    
    // Show product image upload
    function showProductImageUpload(cardId) {
        document.getElementById(`product-image-${cardId}`).click();
    }
    
    // Handle product image upload
    function handleProductImageUpload(cardId, input) {
        const file = input.files[0];
        if (!file) return;
        
        // Check file type
        if (!file.type.startsWith('image/')) {
            alert('Please select an image file');
            return;
        }
        
        // Check file size (10MB limit)
        const maxSize = 10 * 1024 * 1024;
        if (file.size > maxSize) {
            alert('Image file too large. Please select an image under 10MB.');
            return;
        }
        
        // Show loading state
        const card = document.getElementById(cardId);
        const imageContainer = card.querySelector('.ghost-product-image-container');
        imageContainer.innerHTML = `
            <div class="text-center">
                <div class="spinner-border text-primary" role="status">
                    <span class="sr-only">Uploading...</span>
                </div>
                <p class="text-muted mt-2">Uploading image...</p>
            </div>
        `;
        
        // Create FormData
        const formData = new FormData();
        formData.append('file', file);
        
        // Upload image
        fetch('/ghost/admin/ajax/upload-image.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(text => {
            try {
                return JSON.parse(text);
            } catch (e) {
                throw new Error('Server returned invalid response');
            }
        })
        .then(data => {
            if (data.success || data.SUCCESS) {
                // Update card data
                const productCard = contentCards.find(c => c.id === cardId);
                if (productCard) {
                    const imageUrl = data.url || data.URL;
                    productCard.data.image = imageUrl;
                    refreshCard(cardId);
                    markDirtySafe();
                }
            } else {
                throw new Error(data.message || data.MESSAGE || 'Upload failed');
            }
        })
        .catch(error => {
            console.error('Product image upload error:', error);
            alert('Failed to upload image: ' + error.message);
            
            // Reset image section
            const productCard = contentCards.find(c => c.id === cardId);
            if (productCard) {
                refreshCard(cardId);
            }
        });
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
    
    function getFileIcon(fileName) {
        const extension = fileName.toLowerCase().split('.').pop();
        
        // Document types
        if (['pdf'].includes(extension)) return 'ti-file-type-pdf';
        if (['doc', 'docx'].includes(extension)) return 'ti-file-type-doc';
        if (['xls', 'xlsx'].includes(extension)) return 'ti-file-type-xls';
        if (['ppt', 'pptx'].includes(extension)) return 'ti-file-type-ppt';
        if (['txt'].includes(extension)) return 'ti-file-text';
        
        // Archives
        if (['zip', 'rar', '7z', 'tar', 'gz'].includes(extension)) return 'ti-file-zip';
        
        // Code files
        if (['js', 'html', 'css', 'php', 'py', 'java', 'cpp', 'c'].includes(extension)) return 'ti-file-code';
        
        // Images (though these should probably use image card)
        if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg'].includes(extension)) return 'ti-photo';
        
        // Default file icon
        return 'ti-file';
    }
    
    // Helper function to escape HTML
    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    // Show post selector modal for bookmark card
    function showPostSelector(cardId) {
        // Fetch published posts via AJAX
        fetch('/ghost/admin/ajax/get-published-posts.cfm')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.text(); // Get text first to see what's returned
            })
            .then(text => {
                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('Raw response:', text);
                    throw new Error('Invalid JSON response');
                }
            })
            .then(data => {
                // console.log('Posts response:', data);
                if (data.success && data.posts && data.posts.length > 0) {
                    let modalHtml = `
                        <div class="modal fade" id="postSelectorModal" tabindex="-1">
                            <div class="modal-dialog modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Select a Published Post</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal">&times;</button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row g-3">
                    `;
                    
                    data.posts.forEach(post => {
                        const postUrl = window.location.origin + '/ghost/' + post.slug;
                        // Store post data in data attributes to avoid quote issues
                        const postData = {
                            url: postUrl,
                            title: post.title || '',
                            excerpt: post.excerpt || '',
                            thumbnail: post.feature_image || '',
                            id: post.id
                        };
                        
                        modalHtml += `
                            <div class="col-12">
                                <div class="post-selector-item p-3 border rounded cursor-pointer" 
                                     data-post='${JSON.stringify(postData).replace(/'/g, '&#39;')}'
                                     data-card-id="${cardId}">
                                    <div class="d-flex">
                                        ${post.feature_image ? `
                                            <div class="post-selector-thumbnail me-3">
                                                <img src="${post.feature_image}" alt="${escapeHtml(post.title)}" style="width: 100px; height: 70px; object-fit: cover; border-radius: 4px;">
                                            </div>
                                        ` : ''}
                                        <div class="flex-grow-1">
                                            <h6 class="mb-1">${escapeHtml(post.title)}</h6>
                                            ${post.excerpt ? `<p class="text-muted small mb-1">${escapeHtml(post.excerpt)}</p>` : ''}
                                            <small class="text-muted">${post.published_at ? new Date(post.published_at).toLocaleDateString() : ''}</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                    
                    modalHtml += `
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                    
                    // Remove existing modal if any
                    const existingModal = document.getElementById('postSelectorModal');
                    if (existingModal) {
                        existingModal.remove();
                    }
                    
                    // Add modal to page
                    document.body.insertAdjacentHTML('beforeend', modalHtml);
                    
                    // Show modal
                    try {
                        if (typeof bootstrap === 'undefined') {
                            console.error('Bootstrap is not loaded');
                            // Use basic modal display
                            const modalElement = document.getElementById('postSelectorModal');
                            modalElement.style.display = 'block';
                            modalElement.classList.add('show');
                            document.body.classList.add('modal-open');
                            
                            // Add backdrop
                            const backdrop = document.createElement('div');
                            backdrop.className = 'modal-backdrop fade show';
                            document.body.appendChild(backdrop);
                            
                            // Close button handler
                            modalElement.querySelector('.btn-close').addEventListener('click', function() {
                                modalElement.style.display = 'none';
                                modalElement.classList.remove('show');
                                document.body.classList.remove('modal-open');
                                backdrop.remove();
                            });
                        } else {
                            const modal = new bootstrap.Modal(document.getElementById('postSelectorModal'));
                            modal.show();
                        }
                    } catch (e) {
                        console.error('Error showing modal:', e);
                        // Fallback to simple display
                        document.getElementById('postSelectorModal').style.display = 'block';
                    }
                    
                    // Add click and hover handlers
                    document.querySelectorAll('.post-selector-item').forEach(item => {
                        item.addEventListener('click', function() {
                            const postData = JSON.parse(this.getAttribute('data-post'));
                            const cardId = this.getAttribute('data-card-id');
                            selectPostForBookmark(cardId, postData.url, postData.title, postData.excerpt, postData.thumbnail);
                        });
                        
                        item.addEventListener('mouseenter', function() {
                            this.style.backgroundColor = '#f0f0f0';
                        });
                        item.addEventListener('mouseleave', function() {
                            this.style.backgroundColor = '';
                        });
                    });
                } else {
                    alert('No published posts found. Please publish some posts first.');
                    // console.log('Response data:', data);
                }
            })
            .catch(error => {
                console.error('Error fetching posts:', error);
                console.error('Error stack:', error.stack);
                alert('Failed to load published posts: ' + error.message);
            });
    }
    
    // Select a post for bookmark
    function selectPostForBookmark(cardId, url, title, excerpt, thumbnail) {
        // Close modal
        try {
            if (typeof bootstrap !== 'undefined') {
                const modal = bootstrap.Modal.getInstance(document.getElementById('postSelectorModal'));
                if (modal) {
                    modal.hide();
                }
            } else {
                // Manual close
                const modalElement = document.getElementById('postSelectorModal');
                modalElement.style.display = 'none';
                modalElement.classList.remove('show');
                document.body.classList.remove('modal-open');
                const backdrop = document.querySelector('.modal-backdrop');
                if (backdrop) backdrop.remove();
                modalElement.remove();
            }
        } catch (e) {
            console.error('Error closing modal:', e);
            // Force remove
            const modalElement = document.getElementById('postSelectorModal');
            if (modalElement) modalElement.remove();
            const backdrop = document.querySelector('.modal-backdrop');
            if (backdrop) backdrop.remove();
            document.body.classList.remove('modal-open');
        }
        
        // Update card data
        updateCardData(cardId, 'url', url);
        updateCardData(cardId, 'title', title);
        updateCardData(cardId, 'description', excerpt || '');
        updateCardData(cardId, 'thumbnail', thumbnail || '');
        // For internal bookmarks, set the site name as publisher
        updateCardData(cardId, 'publisher', window.location.hostname);
        updateCardData(cardId, 'author', '');
        updateCardData(cardId, 'icon', '/favicon.ico');
        
        // Re-render card
        refreshCard(cardId);
        markDirtySafe();
    }
    
    // Handle bookmark URL change - Not used for internal bookmarks
    /*
    function handleBookmarkUrlChange(cardId, url) {
        if (!url.trim()) {
            updateCardData(cardId, 'url', '');
            return;
        }
        
        // Validate URL
        try {
            new URL(url);
        } catch {
            alert('Please enter a valid URL');
            return;
        }
        
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        // Update URL and show loading state
        updateCardData(cardId, 'url', url);
        updateCardData(cardId, 'loading', true);
        updateCardData(cardId, 'title', '');
        updateCardData(cardId, 'description', '');
        updateCardData(cardId, 'author', '');
        updateCardData(cardId, 'publisher', '');
        updateCardData(cardId, 'thumbnail', '');
        updateCardData(cardId, 'icon', '');
        
        // Re-render card to show loading state
        renderCard(cardId);
        
        // Fetch URL metadata
        fetchUrlMetadata(url)
            .then(metadata => {
                updateCardData(cardId, 'loading', false);
                updateCardData(cardId, 'title', metadata.title || '');
                updateCardData(cardId, 'description', metadata.description || '');
                updateCardData(cardId, 'author', metadata.author || '');
                updateCardData(cardId, 'publisher', metadata.publisher || '');
                updateCardData(cardId, 'thumbnail', metadata.image || '');
                updateCardData(cardId, 'icon', metadata.icon || '');
                
                // Re-render card with metadata
                renderCard(cardId);
                markDirtySafe();
            })
            .catch(error => {
                console.error('Failed to fetch URL metadata:', error);
                updateCardData(cardId, 'loading', false);
                // Re-render card to show error state
                renderCard(cardId);
            });
    }
    */
    
    // Fetch URL metadata (mock implementation) - Not used for internal bookmarks
    /*
    function fetchUrlMetadata(url) {
        return new Promise((resolve, reject) => {
            // In a real implementation, this would call a backend service
            // For now, we'll simulate extracting some basic metadata
            
            setTimeout(() => {
                try {
                    const urlObj = new URL(url);
                    const domain = urlObj.hostname.replace('www.', '');
                    
                    // Mock metadata based on common patterns
                    const metadata = {
                        title: `Link to ${domain}`,
                        description: `Visit ${url} for more information`,
                        publisher: domain.charAt(0).toUpperCase() + domain.slice(1),
                        author: '',
                        image: '',
                        icon: `https://www.google.com/s2/favicons?domain=${domain}`
                    };
                    
                    resolve(metadata);
                } catch (error) {
                    reject(error);
                }
            }, 1000); // Simulate network delay
        });
    }
    */
    
    // Handle embed URL change
    function handleEmbedUrlChange(cardId, url) {
        if (!url.trim()) {
            updateCardData(cardId, 'url', '');
            updateCardData(cardId, 'html', '');
            return;
        }
        
        // Validate URL
        try {
            new URL(url);
        } catch {
            alert('Please enter a valid URL');
            return;
        }
        
        const card = contentCards.find(c => c.id === cardId);
        if (!card) return;
        
        // Update URL and show loading state
        updateCardData(cardId, 'url', url);
        updateCardData(cardId, 'loading', true);
        updateCardData(cardId, 'html', '');
        
        // Re-render card to show loading state
        refreshCard(cardId);
        
        // Determine embed type and generate HTML
        const embedHtml = generateEmbedHtml(url);
        
        setTimeout(() => {
            updateCardData(cardId, 'loading', false);
            
            if (embedHtml) {
                updateCardData(cardId, 'html', embedHtml);
                updateCardData(cardId, 'caption', ''); // Enable caption field
            } else {
                // Show error state
                updateCardData(cardId, 'html', '');
            }
            
            // Re-render card with embed
            updateHeaderCardInPlace(cardId);
            markDirtySafe();
        }, 1000);
    }
    
    // Generate embed HTML based on URL
    function generateEmbedHtml(url) {
        const urlObj = new URL(url);
        const hostname = urlObj.hostname.toLowerCase();
        const pathname = urlObj.pathname;
        
        // YouTube
        if (hostname.includes('youtube.com') || hostname.includes('youtu.be')) {
            let videoId = '';
            if (hostname.includes('youtube.com')) {
                const params = new URLSearchParams(urlObj.search);
                videoId = params.get('v');
            } else {
                videoId = pathname.slice(1);
            }
            if (videoId) {
                return `<iframe width="560" height="315" src="https://www.youtube.com/embed/${videoId}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`;
            }
        }
        
        // Twitter/X
        if (hostname.includes('twitter.com') || hostname.includes('x.com')) {
            // Twitter embeds require oEmbed API, for now return a placeholder
            return `<blockquote class="twitter-tweet"><p>Loading tweet...</p><a href="${url}">${url}</a></blockquote>`;
        }
        
        // Instagram
        if (hostname.includes('instagram.com')) {
            return `<blockquote class="instagram-media" data-instgrm-permalink="${url}" data-instgrm-version="14"><a href="${url}">View on Instagram</a></blockquote>`;
        }
        
        // Vimeo
        if (hostname.includes('vimeo.com')) {
            const videoId = pathname.match(/\/(\d+)/)?.[1];
            if (videoId) {
                return `<iframe src="https://player.vimeo.com/video/${videoId}" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>`;
            }
        }
        
        // CodePen
        if (hostname.includes('codepen.io')) {
            const match = pathname.match(/\/([^\/]+)\/pen\/([^\/]+)/);
            if (match) {
                const [, user, id] = match;
                return `<iframe height="300" style="width: 100%;" scrolling="no" title="CodePen Embed" src="https://codepen.io/${user}/embed/${id}?default-tab=html%2Cresult" frameborder="no" loading="lazy" allowtransparency="true" allowfullscreen="true"></iframe>`;
            }
        }
        
        // SoundCloud (requires oEmbed API in production)
        if (hostname.includes('soundcloud.com')) {
            return `<iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=${encodeURIComponent(url)}&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe>`;
        }
        
        // Spotify
        if (hostname.includes('spotify.com')) {
            const match = pathname.match(/\/(track|album|playlist|artist)\/([a-zA-Z0-9]+)/);
            if (match) {
                const [, type, id] = match;
                return `<iframe style="border-radius:12px" src="https://open.spotify.com/embed/${type}/${id}" width="100%" height="352" frameBorder="0" allowfullscreen="" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>`;
            }
        }
        
        // No supported embed found
        return null;
    }
    
    // Save post
    function savePost(status, isAutosave = false, publishData = null) {
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
                case 'header':
                    // Build header card HTML using v2 structure - matching Ghost source
                    let headerClasses = ['kg-card', 'kg-header-card', 'kg-v2'];
                    
                    // Determine layout based on size and layout properties
                    const size = card.data.size || 'small';
                    const layout = card.data.layout || 'regular';
                    
                    if (size === 'small' && layout !== 'split') {
                        // Default width for small
                    } else if (size === 'medium' && layout !== 'split') {
                        headerClasses.push('kg-width-wide');
                    } else if (size === 'large' && layout !== 'split') {
                        headerClasses.push('kg-width-full');
                    }
                    
                    if (layout === 'split') {
                        headerClasses.push('kg-layout-split', 'kg-width-full');
                    }
                    
                    if (card.data.swapped && layout === 'split') {
                        headerClasses.push('kg-swapped');
                    }
                    
                    if ((size === 'large' || layout === 'split') && layout !== 'regular') {
                        headerClasses.push('kg-content-wide');
                    }
                    
                    // Apply style class
                    if (card.data.style === 'accent') {
                        headerClasses.push('kg-style-accent');
                    } else if (card.data.style === 'image' && card.data.backgroundImageSrc) {
                        headerClasses.push('kg-style-image');
                    }
                    
                    const headerClass = headerClasses.join(' ');
                    html += `<div class="${headerClass}"`;
                    
                    // Add background style
                    if (card.data.style === 'image' && card.data.backgroundImageSrc) {
                        html += ` style="background-image: url(${card.data.backgroundImageSrc}); background-size: ${card.data.backgroundSize || 'cover'}; background-position: center;"`;
                    } else if (card.data.style !== 'accent') {
                        html += ` style="background-color: ${card.data.backgroundColor};"`;
                    }
                    
                    html += ` data-background-color="${card.data.backgroundColor}">`;
                    
                    // Background image for non-split layouts
                    if (card.data.style === 'image' && card.data.backgroundImageSrc && layout !== 'split') {
                        html += `<picture><img class="kg-header-card-image" src="${card.data.backgroundImageSrc}" loading="lazy" alt="" /></picture>`;
                    }
                    
                    html += `<div class="kg-header-card-content">`;
                    
                    // For split layout, structure is different
                    if (layout === 'split') {
                        // Text content first
                        const alignmentClass = card.data.alignment === 'center' ? 'kg-align-center' : '';
                        html += `<div class="kg-header-card-text ${alignmentClass}">`;
                        
                        if (card.data.header) {
                            html += `<h2 class="kg-header-card-heading" style="color: ${card.data.textColor};" data-text-color="${card.data.textColor}">`;
                            html += card.data.header;
                            html += `</h2>`;
                            plaintext += card.data.header + '\n';
                        }
                        
                        if (card.data.subheader) {
                            html += `<p class="kg-header-card-subheading" style="color: ${card.data.textColor};" data-text-color="${card.data.textColor}">`;
                            html += card.data.subheader;
                            html += `</p>`;
                            plaintext += card.data.subheader + '\n';
                        }
                        
                        if (card.data.buttonEnabled && card.data.buttonText && card.data.buttonUrl) {
                            const buttonAccent = card.data.buttonColor === 'accent' ? ' kg-style-accent' : '';
                            const buttonStyle = card.data.buttonColor !== 'accent' ? `background-color: ${card.data.buttonColor}; color: ${card.data.buttonTextColor};` : '';
                            
                            html += `<a href="${card.data.buttonUrl}" class="kg-header-card-button${buttonAccent}" `;
                            html += `style="${buttonStyle}" `;
                            html += `data-button-color="${card.data.buttonColor}" data-button-text-color="${card.data.buttonTextColor}">`;
                            html += card.data.buttonText;
                            html += `</a>`;
                        }
                        
                        html += `</div>`;
                        
                        // Then image
                        if (card.data.backgroundImageSrc) {
                            html += `<img class="kg-header-card-image" src="${card.data.backgroundImageSrc}" alt="">`;
                        }
                    } else {
                        // Regular layout - text only
                        const alignmentClass = card.data.alignment === 'center' ? 'kg-align-center' : '';
                        html += `<div class="kg-header-card-text ${alignmentClass}">`;
                        
                        if (card.data.header) {
                            html += `<h2 class="kg-header-card-heading" style="color: ${card.data.textColor};" data-text-color="${card.data.textColor}">`;
                            html += card.data.header;
                            html += `</h2>`;
                            plaintext += card.data.header + '\n';
                        }
                        
                        if (card.data.subheader) {
                            html += `<p class="kg-header-card-subheading" style="color: ${card.data.textColor};" data-text-color="${card.data.textColor}">`;
                            html += card.data.subheader;
                            html += `</p>`;
                            plaintext += card.data.subheader + '\n';
                        }
                        
                        if (card.data.buttonEnabled && card.data.buttonText && card.data.buttonUrl) {
                            const buttonAccent = card.data.buttonColor === 'accent' ? ' kg-style-accent' : '';
                            const buttonStyle = card.data.buttonColor !== 'accent' ? `background-color: ${card.data.buttonColor}; color: ${card.data.buttonTextColor};` : '';
                            
                            html += `<a href="${card.data.buttonUrl}" class="kg-header-card-button${buttonAccent}" `;
                            html += `style="${buttonStyle}" `;
                            html += `data-button-color="${card.data.buttonColor}" data-button-text-color="${card.data.buttonTextColor}">`;
                            html += card.data.buttonText;
                            html += `</a>`;
                        }
                        
                        html += `</div>`;
                    }
                    
                    html += `</div>`;
                    html += `</div>\n`;
                    plaintext += '\n';
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
                        const buttonAlignment = card.data.buttonAlignment || 'center';
                        const buttonStyle = card.data.buttonStyle || 'primary';
                        let buttonClass = 'kg-btn';
                        
                        switch(buttonStyle) {
                            case 'primary':
                                buttonClass += ' kg-btn-accent';
                                break;
                            case 'secondary':
                                buttonClass += ' kg-btn-secondary';
                                break;
                            case 'outline':
                                buttonClass += ' kg-btn-outline';
                                break;
                            case 'link':
                                buttonClass += ' kg-btn-link';
                                break;
                        }
                        
                        html += `<div class="kg-card kg-button-card kg-align-${buttonAlignment}">`;
                        html += `<a href="${card.data.url}" class="${buttonClass}">${card.data.text}</a>`;
                        html += `</div>\n`;
                    }
                    break;
                case 'callout':
                    const calloutColor = card.data.color || 'blue';
                    const calloutEmoji = card.data.emoji || '💡';
                    html += `<div class="kg-card kg-callout-card kg-callout-card-${calloutColor}">`;
                    html += `<div class="kg-callout-emoji">${calloutEmoji}</div>`;
                    html += `<div class="kg-callout-text">${card.data.content || ''}</div>`;
                    html += `</div>\n`;
                    plaintext += (card.data.content || '').replace(/<[^>]*>/g, '') + '\n\n';
                    break;
                case 'toggle':
                    const toggleHeading = card.data.heading || card.data.title || '';
                    const toggleContent = card.data.content || '';
                    if (toggleHeading || toggleContent) {
                        html += `<div class="kg-card kg-toggle-card" data-kg-toggle-state="${card.data.isOpen !== false ? 'open' : 'close'}">`;
                        html += `<div class="kg-toggle-heading">`;
                        html += `<h4 class="kg-toggle-heading-text">${toggleHeading}</h4>`;
                        html += `<button class="kg-toggle-card-icon">`;
                        html += `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">`;
                        html += `<path d="M23.25,7.311,12.53,18.03a.749.749,0,0,1-1.06,0L.75,7.311"></path>`;
                        html += `</svg>`;
                        html += `</button>`;
                        html += `</div>`;
                        html += `<div class="kg-toggle-content">${toggleContent}</div>`;
                        html += `</div>\n`;
                        plaintext += toggleHeading + '\n';
                        plaintext += (toggleContent || '').replace(/<[^>]*>/g, '') + '\n\n';
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
                        html += `<audio src="${card.data.src}" controls preload="metadata"${card.data.loop ? ' loop' : ''}></audio>`;
                        if (card.data.title) {
                            html += `<div class="kg-audio-title">${card.data.title}</div>`;
                        }
                        if (card.data.caption) {
                            html += `<div class="kg-audio-caption">${card.data.caption}</div>`;
                        }
                        if (card.data.showDownload) {
                            html += `<a class="kg-audio-download" href="${card.data.src}" download>Download</a>`;
                        }
                        html += `</div>\n`;
                        
                        if (card.data.title) {
                            plaintext += card.data.title + '\n';
                        }
                        if (card.data.caption) {
                            plaintext += card.data.caption + '\n';
                        }
                        plaintext += '\n';
                    }
                    break;
                case 'file':
                    if (card.data.src) {
                        html += `<div class="kg-card kg-file-card">`;
                        html += `<a href="${card.data.src}" class="kg-file-card-container">`;
                        html += `<div class="kg-file-card-contents">`;
                        html += `<div class="kg-file-card-title">${card.data.title || card.data.fileName || 'Download file'}</div>`;
                        if (card.data.description) {
                            html += `<div class="kg-file-card-caption">${card.data.description}</div>`;
                        }
                        if (card.data.size || card.data.fileName) {
                            html += `<div class="kg-file-card-metadata">`;
                            if (card.data.fileName && card.data.title) {
                                html += `<div class="kg-file-card-filename">${card.data.fileName}</div>`;
                            }
                            if (card.data.size) {
                                html += `<div class="kg-file-card-filesize">${formatFileSize(card.data.size)}</div>`;
                            }
                            html += `</div>`;
                        }
                        html += `</div>`;
                        html += `</a>`;
                        html += `</div>\n`;
                        
                        plaintext += (card.data.fileName || 'File') + '\n';
                        if (card.data.description) {
                            plaintext += card.data.description + '\n';
                        }
                        plaintext += '\n';
                    }
                    break;
                case 'product':
                    if (card.data.title || card.data.description || card.data.price || card.data.image) {
                        html += `<div class="kg-card kg-product-card">`;
                        if (card.data.image) {
                            html += `<div class="kg-product-card-image">`;
                            html += `<img src="${card.data.image}" alt="${card.data.title || 'Product'}" />`;
                            html += `</div>`;
                        }
                        html += `<div class="kg-product-card-content">`;
                        if (card.data.title) {
                            html += `<h3 class="kg-product-card-title">${card.data.title}</h3>`;
                        }
                        if (card.data.description) {
                            html += `<p class="kg-product-card-description">${card.data.description}</p>`;
                        }
                        if (card.data.price) {
                            html += `<div class="kg-product-card-price">${card.data.price}</div>`;
                        }
                        if (card.data.rating) {
                            html += `<div class="kg-product-card-rating">`;
                            for (let i = 1; i <= 5; i++) {
                                html += `<span class="rating-star ${i <= card.data.rating ? 'filled' : ''}">★</span>`;
                            }
                            html += ` <span class="rating-text">${card.data.rating}/5</span>`;
                            html += `</div>`;
                        }
                        if (card.data.url) {
                            const buttonText = card.data.buttonText || 'View Product';
                            const buttonClass = card.data.buttonStyle ? `kg-product-button-${card.data.buttonStyle}` : 'kg-product-button-primary';
                            html += `<a href="${card.data.url}" class="kg-product-card-button ${buttonClass}" target="_blank">${buttonText}</a>`;
                        }
                        html += `</div>`;
                        html += `</div>\n`;
                        
                        plaintext += (card.data.title || 'Product') + '\n';
                        if (card.data.description) {
                            plaintext += card.data.description + '\n';
                        }
                        if (card.data.price) {
                            plaintext += 'Price: ' + card.data.price + '\n';
                        }
                        plaintext += '\n';
                    }
                    break;
                case 'bookmark':
                    if (card.data.url) {
                        html += `<figure class="kg-card kg-bookmark-card">`;
                        html += `<a class="kg-bookmark-container" href="${card.data.url}">`;
                        html += `<div class="kg-bookmark-content">`;
                        if (card.data.title) {
                            html += `<div class="kg-bookmark-title">${card.data.title}</div>`;
                        }
                        if (card.data.description) {
                            html += `<div class="kg-bookmark-description">${card.data.description}</div>`;
                        }
                        html += `<div class="kg-bookmark-metadata">`;
                        if (card.data.icon) {
                            html += `<img class="kg-bookmark-icon" src="${card.data.icon}" alt="">`;
                        }
                        if (card.data.publisher) {
                            // NOTE: Classes are reversed for theme backwards-compatibility
                            html += `<span class="kg-bookmark-author">${card.data.publisher}</span>`;
                        }
                        if (card.data.author) {
                            // NOTE: Classes are reversed for theme backwards-compatibility
                            html += `<span class="kg-bookmark-publisher">${card.data.author}</span>`;
                        }
                        html += `</div>`;
                        html += `</div>`;
                        if (card.data.thumbnail) {
                            html += `<div class="kg-bookmark-thumbnail">`;
                            html += `<img src="${card.data.thumbnail}" alt="" onerror="this.style.display='none'">`;
                            html += `</div>`;
                        }
                        html += `</a>`;
                        html += `</figure>\n`;
                        
                        plaintext += `${card.data.title || card.data.url}\n`;
                        if (card.data.description) {
                            plaintext += `${card.data.description}\n`;
                        }
                        plaintext += `${card.data.url}\n\n`;
                    }
                    break;
                case 'embed':
                    if (card.data.html) {
                        html += `<figure class="kg-card kg-embed-card">`;
                        html += card.data.html;
                        if (card.data.caption) {
                            html += `<figcaption>${card.data.caption}</figcaption>`;
                        }
                        html += `</figure>\n`;
                        
                        if (card.data.url) {
                            plaintext += `Embedded content from: ${card.data.url}\n`;
                        }
                        if (card.data.caption) {
                            plaintext += card.data.caption + '\n';
                        }
                        plaintext += '\n';
                    }
                    break;
                case 'gallery':
                    if (card.data.images && card.data.images.length > 0) {
                        html += `<figure class="kg-card kg-gallery-card kg-width-wide${card.data.caption ? ' kg-card-hascaption' : ''}">`;
                        html += `<div class="kg-gallery-container">`;
                        
                        // Build gallery structure using Ghost's algorithm
                        const images = card.data.images;
                        const rows = [];
                        const MAX_IMG_PER_ROW = 3;
                        const noOfImages = images.length;
                        
                        images.forEach((image, idx) => {
                            let row = Math.floor(idx / MAX_IMG_PER_ROW);
                            
                            // Special case: if we have an odd number of images and we're at the second-to-last image
                            if (noOfImages > 1 && (noOfImages % MAX_IMG_PER_ROW === 1) && (idx === (noOfImages - 2))) {
                                row = row + 1;
                            }
                            
                            if (!rows[row]) {
                                rows[row] = [];
                            }
                            rows[row].push(image);
                        });
                        
                        // Generate HTML for each row
                        rows.forEach(row => {
                            html += `<div class="kg-gallery-row">`;
                            row.forEach(image => {
                                html += `<div class="kg-gallery-image">`;
                                if (image.href) {
                                    html += `<a href="${image.href}">`;
                                }
                                html += `<img src="${image.src}" `;
                                if (image.width) html += `width="${image.width}" `;
                                if (image.height) html += `height="${image.height}" `;
                                html += `loading="lazy" `;
                                html += `alt="${image.alt || ''}"`;
                                if (image.title) {
                                    html += ` title="${image.title}"`;
                                }
                                html += `>`;
                                if (image.href) {
                                    html += `</a>`;
                                }
                                html += `</div>`;
                            });
                            html += `</div>`;
                        });
                        
                        html += `</div>`;
                        
                        if (card.data.caption) {
                            html += `<figcaption>${card.data.caption}</figcaption>`;
                        }
                        
                        html += `</figure>\n`;
                        
                        // Add to plaintext
                        plaintext += 'Gallery: ' + images.length + ' images\n';
                        if (card.data.caption) {
                            plaintext += card.data.caption + '\n';
                        }
                        plaintext += '\n';
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
        
        // Use scheduledAt from publishData if provided, otherwise use the publishDate field
        let publishedAt = publishDate;
        if (publishData && publishData.scheduledAt) {
            publishedAt = publishData.scheduledAt;
        }
        document.getElementById('formPublishedAt').value = publishedAt;
        
        document.getElementById('formTags').value = JSON.stringify(selectedTags);
        document.getElementById('formStatus').value = status;
        
        // Add authors to form data
        document.getElementById('formAuthors').value = JSON.stringify(selectedAuthors);
        
        // Add additional settings fields
        document.getElementById('formCustomTemplate').value = document.getElementById('postTemplate')?.value || '';
        document.getElementById('formCodeinjectionHead').value = document.getElementById('codeinjectionHead')?.value || '';
        document.getElementById('formCodeinjectionFoot').value = document.getElementById('codeinjectionFoot')?.value || '';
        document.getElementById('formCanonicalUrl').value = document.getElementById('canonicalUrl')?.value || '';
        document.getElementById('formShowTitleAndFeatureImage').value = document.getElementById('showTitleAndFeatureImage')?.checked ? '1' : '0';
        
        // Add social media fields
        document.getElementById('formOgTitle').value = document.getElementById('facebookTitle')?.value || '';
        document.getElementById('formOgDescription').value = document.getElementById('facebookDescription')?.value || '';
        document.getElementById('formOgImage').value = document.getElementById('facebookImage')?.value || '';
        document.getElementById('formTwitterTitle').value = document.getElementById('twitterTitle')?.value || '';
        document.getElementById('formTwitterDescription').value = document.getElementById('twitterDescription')?.value || '';
        document.getElementById('formTwitterImage').value = document.getElementById('twitterImage')?.value || '';
        
        // Save card data to preserve all card settings
        document.getElementById('formCardData').value = JSON.stringify(contentCards);
        
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
                    const postType = (postData.type || postData.TYPE || 'post').toLowerCase();
                    const redirectUrl = postType === 'page' ? '/ghost/admin/pages' : '/ghost/admin/posts';
                    
                    if (status === 'published') {
                        const itemType = postType === 'page' ? 'Page' : 'Post';
                        showMessage(`${itemType} published successfully`, 'success');
                        setTimeout(() => {
                            window.location.href = redirectUrl;
                        }, 1000);
                    } else if (status === 'scheduled') {
                        const itemType = postType === 'page' ? 'Page' : 'Post';
                        showMessage(`${itemType} scheduled successfully`, 'success');
                        setTimeout(() => {
                            window.location.href = redirectUrl;
                        }, 1000);
                    } else {
                        const itemType = postType === 'page' ? 'Page' : 'Post';
                        showMessage(`${itemType} saved`, 'success');
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
                
                // Note: callback functionality removed - use promise instead
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
            let errorMessage = 'Save failed: ' + error.message;
            
            // Handle specific error types
            if (error.message.includes('URL already exists')) {
                errorMessage = error.message;
                // Focus on slug field to help user fix it
                setTimeout(() => {
                    const slugField = document.getElementById('postSlug');
                    if (slugField) {
                        slugField.focus();
                        slugField.select();
                    }
                }, 100);
            }
            
            showMessage(errorMessage, 'error');
            
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
        // Use the new Ghost-style publish modal from editor-scripts.cfm
        if (typeof showPublishModal === 'function') {
            showPublishModal();
        } else {
            console.error('showPublishModal function not found. Make sure editor-scripts.cfm is included.');
        }
    }
    
    // Old publish modal functions commented out to avoid conflicts
    /*
    // Show publish confirmation modal
    function showPublishModal() {
        // Create modal backdrop
        const backdrop = document.createElement('div');
        backdrop.className = 'ghost-modal-backdrop';
        backdrop.id = 'publishModalBackdrop';
        backdrop.style.display = 'flex';
        
        // Create modal
        const modal = document.createElement('div');
        modal.className = 'ghost-modal ghost-publish-modal';
        modal.innerHTML = `
            <div class="ghost-modal-header">
                <h3>Ready to publish?</h3>
                <button type="button" class="ghost-modal-close" onclick="closePublishModal()">
                    <i class="ti ti-x text-xl"></i>
                </button>
            </div>
            <div class="ghost-modal-body p-0">
                <!-- Simplified Options -->
                <div class="publish-options">
                    <!-- Publish Settings -->
                    <div class="publish-setting-group">
                        <div class="publish-setting-item">
                            <div class="publish-setting-label">
                                <i class="ti ti-world text-gray-500 mr-3"></i>
                                <div>
                                    <div class="font-medium text-gray-900">Post visibility</div>
                                    <div class="text-sm text-gray-600">Public - visible to everyone</div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="publish-setting-item">
                            <div class="publish-setting-label">
                                <i class="ti ti-clock text-gray-500 mr-3"></i>
                                <div>
                                    <div class="font-medium text-gray-900">Publish time</div>
                                    <div class="text-sm text-gray-600">
                                        <button type="button" class="text-primary hover:text-primary-dark inline-flex items-center" onclick="toggleSchedule()">
                                            <span id="scheduleDisplayText">Right now</span>
                                            <i class="ti ti-chevron-down ml-1 text-xs"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Schedule Options (Hidden by default) -->
                        <div id="scheduleSection" class="publish-schedule-section hidden">
                            <div class="flex gap-3 mt-3">
                                <input type="date" id="scheduleDate" class="ghost-input flex-1" 
                                       min="${new Date().toISOString().split('T')[0]}"
                                       value="${new Date().toISOString().split('T')[0]}"
                                       onchange="updateScheduleDisplay()">
                                <input type="time" id="scheduleTime" class="ghost-input flex-1" 
                                       value="${new Date(Date.now() + 600000).toTimeString().slice(0,5)}"
                                       onchange="updateScheduleDisplay()">
                            </div>
                        </div>
                        
                        <!-- Email Options -->
                        <div class="publish-setting-item border-t border-gray-100 pt-4 mt-4">
                            <label class="flex items-start cursor-pointer">
                                <input type="checkbox" id="sendEmail" class="mt-1 mr-3" checked onchange="toggleEmailOptions()">
                                <div class="flex-1">
                                    <div class="font-medium text-gray-900">Send as email newsletter</div>
                                    <div class="text-sm text-gray-600">Deliver this post to <span id="subscriberCount">all subscribers</span></div>
                                </div>
                            </label>
                            
                            <!-- Email Recipients (shown when email is checked) -->
                            <div id="emailOptions" class="mt-4 pl-7">
                                <select id="emailRecipients" class="ghost-input w-full" onchange="updateSubscriberCount()">
                                    <option value="all">All subscribers</option>
                                    <option value="free">Free subscribers only</option>
                                    <option value="paid">Paid subscribers only</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="ghost-modal-footer">
                <button type="button" class="ghost-btn ghost-btn-link" onclick="closePublishModal()">
                    <span>Cancel</span>
                </button>
                <button type="button" class="ghost-btn ghost-btn-black" onclick="executePublishWithOptions()">
                    <span id="publishButtonText">Publish now</span>
                    <i class="ti ti-arrow-right ml-2"></i>
                </button>
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
    
    // Toggle schedule section
    function toggleSchedule() {
        const scheduleSection = document.getElementById('scheduleSection');
        const scheduleText = document.getElementById('scheduleDisplayText');
        
        if (scheduleSection.classList.contains('hidden')) {
            scheduleSection.classList.remove('hidden');
            updateScheduleDisplay();
        } else {
            scheduleSection.classList.add('hidden');
            scheduleText.textContent = 'Right now';
            updatePublishButton();
        }
    }
    
    // Update schedule display
    function updateScheduleDisplay() {
        const scheduleDate = document.getElementById('scheduleDate').value;
        const scheduleTime = document.getElementById('scheduleTime').value;
        const scheduleText = document.getElementById('scheduleDisplayText');
        
        if (scheduleDate && scheduleTime) {
            const scheduledDate = new Date(`${scheduleDate}T${scheduleTime}`);
            const now = new Date();
            
            // Format the display text
            if (scheduledDate.toDateString() === now.toDateString()) {
                scheduleText.textContent = `Today at ${formatTime(scheduleTime)}`;
            } else {
                scheduleText.textContent = `${formatDate(scheduledDate)} at ${formatTime(scheduleTime)}`;
            }
            
            updatePublishButton();
        }
    }
    
    // Toggle email options
    function toggleEmailOptions() {
        const sendEmail = document.getElementById('sendEmail').checked;
        const emailOptions = document.getElementById('emailOptions');
        
        if (sendEmail) {
            emailOptions.style.display = 'block';
        } else {
            emailOptions.style.display = 'none';
        }
        
        updatePublishButton();
    }
    
    // Update subscriber count display
    function updateSubscriberCount() {
        const recipients = document.getElementById('emailRecipients').value;
        const countSpan = document.getElementById('subscriberCount');
        
        switch(recipients) {
            case 'free':
                countSpan.textContent = 'free subscribers';
                break;
            case 'paid':
                countSpan.textContent = 'paid subscribers';
                break;
            default:
                countSpan.textContent = 'all subscribers';
        }
    }
    
    // Update publish button text
    function updatePublishButton() {
        const publishButton = document.getElementById('publishButtonText');
        const scheduleSection = document.getElementById('scheduleSection');
        const sendEmail = document.getElementById('sendEmail').checked;
        const isScheduled = !scheduleSection.classList.contains('hidden');
        
        if (isScheduled) {
            publishButton.textContent = sendEmail ? 'Schedule' : 'Schedule post';
        } else {
            publishButton.textContent = sendEmail ? 'Publish & send' : 'Publish now';
        }
    }
    
    // Format time helper
    function formatTime(timeString) {
        const [hours, minutes] = timeString.split(':');
        const hour = parseInt(hours);
        const ampm = hour >= 12 ? 'PM' : 'AM';
        const displayHour = hour % 12 || 12;
        return `${displayHour}:${minutes} ${ampm}`;
    }
    
    // Format date helper
    function formatDate(date) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`;
    }
    
    // Execute publish with options
    function executePublishWithOptions() {
        const scheduleSection = document.getElementById('scheduleSection');
        const isScheduled = !scheduleSection.classList.contains('hidden');
        const sendEmail = document.getElementById('sendEmail').checked;
        const emailRecipients = document.getElementById('emailRecipients').value;
        
        let scheduledAt = null;
        if (isScheduled) {
            const scheduleDate = document.getElementById('scheduleDate').value;
            const scheduleTime = document.getElementById('scheduleTime').value;
            
            if (!scheduleDate || !scheduleTime) {
                showMessage('Please select a date and time for scheduling', 'error');
                return;
            }
            
            scheduledAt = new Date(`${scheduleDate}T${scheduleTime}`);
            
            // Validate schedule time is at least 5 minutes in the future
            const minScheduleTime = new Date(Date.now() + 5 * 60 * 1000);
            if (scheduledAt < minScheduleTime) {
                showMessage('Scheduled time must be at least 5 minutes in the future', 'error');
                return;
            }
        }
        
        // Close modal
        closePublishModal();
        
        // Show appropriate message
        if (isScheduled) {
            showMessage('Scheduling post...', 'info');
        } else {
            showMessage('Publishing post...', 'info');
        }
        
        // Save post with publish status
        const publishData = {
            status: isScheduled ? 'scheduled' : 'published',
            sendEmail: sendEmail,
            emailRecipients: emailRecipients,
            scheduledAt: scheduledAt ? scheduledAt.toISOString() : null
        };
        
        // Save with the correct status (scheduled or published)
        const postStatus = isScheduled ? 'scheduled' : 'published';
        savePost(postStatus, true, publishData).then(() => {
            if (isScheduled) {
                showMessage('Post scheduled successfully', 'success');
            } else {
                let successMsg = 'Post published successfully';
                if (sendEmail) {
                    successMsg = 'Post published and email sent successfully';
                }
                showMessage(successMsg, 'success');
            }
            
            // Update UI to show published state
            updateUIAfterPublish();
        }).catch(error => {
            console.error('Publish error:', error);
            showMessage('Failed to publish post: ' + error.message, 'error');
        });
    }
    
    // Update UI after publishing
    function updateUIAfterPublish() {
        // Hide publish button, show update button by reloading the page
        // Since the buttons are rendered server-side based on post status
        window.location.reload();
    }
    
    // Execute publish (legacy - now redirects to new function)
    function executePublish() {
        executePublishWithOptions();
    }
    
    
    // Unpublish post
    function unpublishPost() {
        showUnpublishModal();
    }
    
    // Show unpublish confirmation modal
    function showUnpublishModal() {
        const backdrop = document.createElement('div');
        backdrop.className = 'ghost-modal-backdrop';
        backdrop.id = 'unpublishModalBackdrop';
        backdrop.style.display = 'flex';
        
        const modal = document.createElement('div');
        modal.className = 'ghost-modal';
        modal.innerHTML = `
            <div class="ghost-modal-header">
                <h3>${originalStatus === 'scheduled' ? 'Unschedule' : 'Unpublish'} this post?</h3>
                <button type="button" class="ghost-modal-close" onclick="closeUnpublishModal()">
                    <i class="ti ti-x text-xl"></i>
                </button>
            </div>
            <div class="ghost-modal-body">
                <p class="text-gray-600 text-base">
                    ${originalStatus === 'scheduled' 
                        ? 'This will cancel the scheduled publish and revert the post to draft status.' 
                        : 'This will revert the post to draft status and remove it from your site.'}
                </p>
            </div>
            <div class="ghost-modal-footer">
                <button type="button" class="ghost-btn ghost-btn-link" onclick="closeUnpublishModal()">
                    Cancel
                </button>
                <button type="button" class="ghost-btn ghost-btn-red" onclick="executeUnpublish()">
                    <i class="ti ti-eye-off me-2"></i>
                    ${originalStatus === 'scheduled' ? 'Unschedule' : 'Unpublish'}
                </button>
            </div>
        `;
        
        backdrop.appendChild(modal);
        document.body.appendChild(backdrop);
        
        // Close on backdrop click
        backdrop.addEventListener('click', function(e) {
            if (e.target === backdrop) {
                closeUnpublishModal();
            }
        });
    }
    
    // Close unpublish modal
    function closeUnpublishModal() {
        const backdrop = document.getElementById('unpublishModalBackdrop');
        if (backdrop) {
            backdrop.remove();
        }
    }
    
    // Execute unpublish
    function executeUnpublish() {
        closeUnpublishModal();
        
        // Show message
        showMessage('Reverting to draft...', 'info');
        
        // Save as draft
        savePost('draft', false).then(() => {
            showMessage('Post reverted to draft', 'success');
            // Reload page to update UI
            setTimeout(() => {
                window.location.reload();
            }, 500);
        }).catch(error => {
            console.error('Unpublish error:', error);
            showMessage('Failed to unpublish post: ' + error.message, 'error');
        });
    }
    
    // Preview post
    function previewPost() {
        // Save draft first
        savePost('draft', true).then(() => {
            // Show preview modal
            showPreviewModal();
        }).catch(error => {
            console.error('Preview error:', error);
            showMessage('Failed to save draft for preview: ' + error.message, 'error');
        });
    }
    */
    
    // Unpublish post - extracted from commented block
    function unpublishPost() {
        showUnpublishModal();
    }
    
    // Show unpublish confirmation modal
    function showUnpublishModal() {
        const backdrop = document.createElement('div');
        backdrop.className = 'ghost-modal-backdrop';
        backdrop.id = 'unpublishModalBackdrop';
        backdrop.style.display = 'flex';
        
        const modal = document.createElement('div');
        modal.className = 'ghost-modal';
        modal.innerHTML = `
            <div class="ghost-modal-header">
                <h3>${originalStatus === 'scheduled' ? 'Unschedule' : 'Unpublish'} this post?</h3>
                <button type="button" class="ghost-modal-close" onclick="closeUnpublishModal()">
                    <i class="ti ti-x text-xl"></i>
                </button>
            </div>
            <div class="ghost-modal-body">
                <p class="text-gray-600 text-base">
                    ${originalStatus === 'scheduled' 
                        ? 'This will cancel the scheduled publish and revert the post to draft status.' 
                        : 'This will revert the post to draft status and remove it from your site.'}
                </p>
            </div>
            <div class="ghost-modal-footer">
                <button type="button" class="ghost-btn ghost-btn-link" onclick="closeUnpublishModal()">
                    Cancel
                </button>
                <button type="button" class="ghost-btn ghost-btn-red" onclick="executeUnpublish()">
                    <i class="ti ti-eye-off me-2"></i>
                    ${originalStatus === 'scheduled' ? 'Unschedule' : 'Unpublish'}
                </button>
            </div>
        `;
        
        backdrop.appendChild(modal);
        document.body.appendChild(backdrop);
        
        // Close on backdrop click
        backdrop.addEventListener('click', function(e) {
            if (e.target === backdrop) {
                closeUnpublishModal();
            }
        });
    }
    
    // Close unpublish modal
    function closeUnpublishModal() {
        const backdrop = document.getElementById('unpublishModalBackdrop');
        if (backdrop) {
            backdrop.remove();
        }
    }
    
    // Execute unpublish
    function executeUnpublish() {
        closeUnpublishModal();
        
        // Show message
        showMessage('Reverting to draft...', 'info');
        
        // Save as draft
        savePost('draft', false).then(() => {
            showMessage('Post reverted to draft', 'success');
            // Reload page to update UI
            setTimeout(() => {
                window.location.reload();
            }, 500);
        }).catch(error => {
            console.error('Unpublish error:', error);
            showMessage('Failed to unpublish post: ' + error.message, 'error');
        });
    }
    
    // Update post - extracted from commented block
    function updatePost() {
        // Keep the original status for published/scheduled posts
        const statusToSave = originalStatus === 'published' ? 'published' : (originalStatus === 'scheduled' ? 'scheduled' : 'draft');
        showMessage('Updating post...', 'info');
        savePost(statusToSave, false).then(() => {
            showMessage('Post updated successfully', 'success');
            // Refresh any UI elements if needed
            if (typeof updateTwitterPreview === 'function') updateTwitterPreview();
            if (typeof updateFacebookPreview === 'function') updateFacebookPreview();
            if (typeof updateSearchPreview === 'function') updateSearchPreview();
        }).catch(error => {
            console.error('Update error:', error);
            showMessage('Failed to update post: ' + error.message, 'error');
        });
    }
    
    // Show preview modal - Ghost style with iframe
    function showPreviewModal() {
        const postId = '<cfoutput>#postData.id#</cfoutput>';
        
        console.log('showPreviewModal called with postId:', postId);
        
        if (!postId) {
            showMessage('Post ID not found. Please save the post first.', 'error');
            return;
        }
        
        // Create modal backdrop
        const backdrop = document.createElement('div');
        backdrop.className = 'preview-modal-backdrop';
        backdrop.style.cssText = `
            position: fixed;
            inset: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.6);
            z-index: 9998;
        `;
        
        // Create modal container
        const modal = document.createElement('div');
        modal.id = 'previewModal';
        modal.className = 'ghost-preview-modal';
        modal.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 9999;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
        `;
        
        // Create iframe for preview modal with loading state
        const iframeSrc = `/ghost/admin/preview-modal.cfm?id=${postId}`;
        console.log('Preview iframe src:', iframeSrc);
        
        modal.innerHTML = `
            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; z-index: 1;">
                <div style="width: 40px; height: 40px; border: 3px solid #f3f3f3; border-top: 3px solid #14b8ff; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
                <p style="margin-top: 10px; color: #666;">Loading preview...</p>
            </div>
            <iframe 
                src="${iframeSrc}" 
                style="width: 100%; height: 100%; border: none; display: block; flex: 1; opacity: 0; transition: opacity 0.3s ease;"
                id="previewFrame"
                onload="this.style.opacity = '1'; this.previousElementSibling.style.display = 'none';"
                onerror="console.error('Failed to load preview'); showMessage('Failed to load preview', 'error'); closePreviewModal();"
            ></iframe>
        `;
        
        // Add spinner animation
        if (!document.getElementById('previewSpinnerStyle')) {
            const style = document.createElement('style');
            style.id = 'previewSpinnerStyle';
            style.innerHTML = `
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            `;
            document.head.appendChild(style);
        }
        
        // Add to body
        document.body.appendChild(backdrop);
        document.body.appendChild(modal);
        
        // Prevent body scroll while modal is open
        document.body.style.overflow = 'hidden';
        
        // Listen for messages from iframe
        window.addEventListener('message', handlePreviewMessage);
    }
    
    // Handle messages from preview iframe
    function handlePreviewMessage(event) {
        if (event.data.action === 'closePreview') {
            closePreviewModal();
        } else if (event.data.action === 'openPublishModal') {
            closePreviewModal();
            // Show publish modal
            document.getElementById('publishModal').style.display = 'block';
        }
    }
    
    // Close preview modal
    function closePreviewModal() {
        const modal = document.getElementById('previewModal');
        const backdrop = document.querySelector('.preview-modal-backdrop');
        
        if (modal) {
            modal.remove();
        }
        if (backdrop) {
            backdrop.remove();
        }
        
        // Restore body styles
        document.body.style.overflow = '';
        document.body.style.height = '';
        document.body.style.position = '';
        
        window.removeEventListener('message', handlePreviewMessage);
    }
    
    // Legacy preview modal code (kept for reference)
    function showPreviewModalLegacy() {
        // Create full-screen preview modal like Ghost
        const modal = document.createElement('div');
        modal.id = 'previewModal';
        modal.className = 'ghost-preview-modal';
        modal.innerHTML = `
            <div class="ghost-preview-header">
                <div class="ghost-preview-header-content">
                    <div class="ghost-preview-title">
                        <h2>Preview</h2>
                    </div>
                    
                    <div class="ghost-preview-controls">
                        <!-- Format selector -->
                        <div class="ghost-preview-format">
                            <button type="button" class="ghost-preview-btn active" data-format="web" onclick="changePreviewFormat('web')">
                                Web
                            </button>
                            ${postData.status !== 'published' ? `
                            <button type="button" class="ghost-preview-btn" data-format="email" onclick="changePreviewFormat('email')">
                                Email
                            </button>` : ''}
                        </div>
                        
                        <div class="ghost-preview-divider"></div>
                        
                        <!-- Device selector -->
                        <div class="ghost-preview-device">
                            <button type="button" class="ghost-preview-btn active" data-device="desktop" onclick="changePreviewDevice('desktop')">
                                <i class="ti ti-device-desktop"></i>
                            </button>
                            <button type="button" class="ghost-preview-btn" data-device="mobile" onclick="changePreviewDevice('mobile')">
                                <i class="ti ti-device-mobile"></i>
                            </button>
                        </div>
                        
                        <div class="ghost-preview-divider"></div>
                        
                        <!-- Member status selector -->
                        <select class="ghost-preview-select" id="previewMemberStatus" onchange="updatePreview()">
                            <option value="public">Public visitor</option>
                            <option value="free">Free member</option>
                            <option value="paid">Paid member</option>
                        </select>
                    </div>
                    
                    <div class="ghost-preview-actions">
                        <button type="button" class="btn btn-secondary" onclick="closePreviewModal()">
                            Close
                        </button>
                        ${postData.status !== 'published' ? `
                        <button type="button" class="btn btn-primary" onclick="closePreviewModal(); publishPost()">
                            Publish
                        </button>` : ''}
                    </div>
                </div>
            </div>
            
            <div class="ghost-preview-content">
                <div class="ghost-preview-container" id="previewContainer">
                    <iframe id="previewFrame" class="ghost-preview-iframe"></iframe>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        document.body.style.overflow = 'hidden';
        
        // Add styles for Ghost-like preview
        if (!document.getElementById('ghostPreviewStyles')) {
            const style = document.createElement('style');
            style.id = 'ghostPreviewStyles';
            style.innerHTML = `
                .ghost-preview-modal {
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    width: 100vw;
                    height: 100vh;
                    background: #f5f5f5;
                    z-index: 9999;
                    display: flex;
                    flex-direction: column;
                    overflow: hidden;
                }
                
                .ghost-preview-modal iframe {
                    width: 100% !important;
                    height: 100% !important;
                    border: none !important;
                    flex: 1;
                }
                
                .ghost-preview-header {
                    background: #fff;
                    border-bottom: 1px solid #e5e7eb;
                    height: 64px;
                    flex-shrink: 0;
                }
                
                .ghost-preview-header-content {
                    height: 100%;
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 0 24px;
                }
                
                .ghost-preview-title h2 {
                    margin: 0;
                    font-size: 18px;
                    font-weight: 600;
                }
                
                .ghost-preview-controls {
                    display: flex;
                    align-items: center;
                    gap: 16px;
                }
                
                .ghost-preview-format,
                .ghost-preview-device {
                    display: flex;
                    background: #f5f5f5;
                    border-radius: 4px;
                    padding: 2px;
                }
                
                .ghost-preview-btn {
                    background: transparent;
                    border: none;
                    padding: 6px 12px;
                    font-size: 14px;
                    cursor: pointer;
                    border-radius: 3px;
                    transition: all 0.2s;
                }
                
                .ghost-preview-btn:hover {
                    background: rgba(0,0,0,0.05);
                }
                
                .ghost-preview-btn.active {
                    background: #fff;
                    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                }
                
                .ghost-preview-divider {
                    width: 1px;
                    height: 24px;
                    background: #e5e7eb;
                }
                
                .ghost-preview-select {
                    padding: 6px 12px;
                    border: 1px solid #e5e7eb;
                    border-radius: 4px;
                    font-size: 14px;
                    background: #fff;
                }
                
                .ghost-preview-actions {
                    display: flex;
                    gap: 12px;
                }
                
                .ghost-preview-content {
                    flex: 1;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 40px;
                    overflow: auto;
                }
                
                .ghost-preview-container {
                    width: 100%;
                    height: 100%;
                    max-width: 1200px;
                    background: #fff;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    overflow: hidden;
                    transition: all 0.3s ease;
                }
                
                .ghost-preview-container.mobile {
                    max-width: 375px;
                    max-height: 812px;
                    border: 12px solid #333;
                    border-radius: 36px;
                }
                
                .ghost-preview-iframe {
                    width: 100%;
                    height: 100%;
                    border: none;
                }
                
                .ghost-preview-loading {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100%;
                    font-size: 18px;
                    color: #666;
                }
            `;
            document.head.appendChild(style);
        }
        
        // Load initial preview
        updatePreview();
    }
    
    // Legacy update preview function - replaced by iframe implementation
    /*
    function updatePreview() {
        const memberStatus = document.getElementById('previewMemberStatus').value;
        const iframe = document.getElementById('previewFrame');
        const container = document.getElementById('previewContainer');
        
        // Show loading
        iframe.style.display = 'none';
        container.innerHTML = '<div class="ghost-preview-loading">Loading preview...</div>';
        
        // Load preview
        setTimeout(() => {
            container.innerHTML = '<iframe id="previewFrame" class="ghost-preview-iframe"></iframe>';
            const newIframe = document.getElementById('previewFrame');
            newIframe.src = `/ghost/preview-public.cfm?id=${postData.id}&member_status=${memberStatus}`;
            newIframe.onload = () => {
                newIframe.style.display = 'block';
            };
        }, 100);
    }
    */
    
    // Legacy preview functions - replaced by iframe implementation
    /*
    function changePreviewFormat(format) {
        document.querySelectorAll('.ghost-preview-format .ghost-preview-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.format === format);
        });
        
        if (format === 'email') {
            showMessage('Email preview coming soon', 'info');
        }
    }
    
    function changePreviewDevice(device) {
        document.querySelectorAll('.ghost-preview-device .ghost-preview-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.device === device);
        });
        
        const container = document.getElementById('previewContainer');
        container.classList.toggle('mobile', device === 'mobile');
        
        updatePreview();
    }
    */
    
    // Delete post
    function confirmDeletePost() {
        // Show custom delete modal
        showDeleteModal();
    }
    
    // Show delete confirmation modal
    function showDeleteModal() {
        // Create modal backdrop
        const backdrop = document.createElement('div');
        backdrop.className = 'ghost-modal-backdrop';
        backdrop.id = 'deleteModalBackdrop';
        backdrop.style.display = 'flex';
        
        // Create modal
        const modal = document.createElement('div');
        modal.className = 'ghost-modal';
        modal.innerHTML = `
            <div class="ghost-modal-header">
                <h3>Delete this post?</h3>
                <button type="button" class="ghost-modal-close" onclick="closeDeleteModal()">
                    <i class="ti ti-x text-xl"></i>
                </button>
            </div>
            <div class="ghost-modal-body">
                <p class="text-gray-600 text-base">
                    Are you sure you want to delete this post? This action cannot be undone.
                </p>
            </div>
            <div class="ghost-modal-footer">
                <button type="button" class="ghost-btn ghost-btn-link" onclick="closeDeleteModal()">
                    Cancel
                </button>
                <button type="button" class="ghost-btn ghost-btn-red" onclick="deletePost()">
                    <span>Delete</span>
                </button>
            </div>
        `;
        
        backdrop.appendChild(modal);
        document.body.appendChild(backdrop);
        
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
                const postType = (postData.type || postData.TYPE || 'post').toLowerCase();
                const itemType = postType === 'page' ? 'Page' : 'Post';
                const redirectUrl = postType === 'page' ? '/ghost/admin/pages' : '/ghost/admin/posts';
                
                showMessage(`${itemType} deleted`, 'success');
                setTimeout(() => {
                    window.location.href = redirectUrl;
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
        // Check if we're on an edit page
        const currentPath = window.location.pathname;
        const isEditPage = currentPath.includes('/posts/edit') || currentPath.includes('/posts/new') || 
                          currentPath.includes('/pages/edit') || currentPath.includes('/pages/new');
        
        if (!isEditPage) {
            return; // Don't show formatting popup on non-edit pages
        }
        
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
        // console.log('Keydown event:', e.key, 'Active element:', document.activeElement);
        // console.log('Current state - isDirty:', isDirty, 'isInitializing:', isInitializing);
        
        const activeElement = document.activeElement;
        
        // Find the card element - could be the activeElement itself or its closest parent
        let cardElement = null;
        let cardId = null;
        
        // Check if activeElement is a content-editable card element
        if (activeElement && activeElement.classList.contains('card-content') && activeElement.id.startsWith('content-')) {
            cardElement = activeElement;
            cardId = activeElement.id.replace('content-', '');
            // console.log('Found contenteditable card:', cardId);
        }
        // Check if activeElement is inside a card (look for card with id starting with 'card-')
        else if (activeElement) {
            const parentCard = activeElement.closest('[id^="card-"]');
            if (parentCard) {
                cardElement = parentCard;
                cardId = parentCard.id;
                // console.log('Found parent card:', cardId);
            }
        }
        
        // console.log('Card detection result:', { cardElement, cardId });
        
        // Special case: if no card is focused but we pressed delete/backspace, 
        // try to find and delete empty cards more aggressively
        if (!cardElement && (e.key === 'Backspace' || e.key === 'Delete')) {
            // console.log('No card focused, looking for empty cards to delete');
            
            // Find all truly empty cards
            const emptyCards = contentCards.filter(card => {
                const element = document.getElementById(`content-${card.id}`);
                if (!element) return false;
                
                const content = element.textContent || element.innerText || '';
                const innerHTML = element.innerHTML || '';
                const cleanContent = content.replace(/\s/g, '').replace(/\u00A0/g, '');
                const cleanHTML = innerHTML.replace(/<br\s*\/?>/gi, '').replace(/&nbsp;/g, '').trim();
                
                // console.log(`Card ${card.id}: content="${content}", cleanContent="${cleanContent}", cleanHTML="${cleanHTML}"`);
                
                return cleanContent === '' && (cleanHTML === '' || cleanHTML === '<br>' || cleanHTML === '<br/>' || cleanHTML === '<br />');
            });
            
            // console.log('Found empty cards:', emptyCards.length);
            
            // If we have empty cards and more than one card total, delete the first empty one
            if (emptyCards.length > 0 && contentCards.length > 1) {
                // console.log('Deleting first empty card:', emptyCards[0].id);
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
                    // console.log('Delete key pressed on contenteditable:', e.key);
                    // console.log('CardId:', cardId);
                    // console.log('Content:', content);
                    // console.log('Content trimmed:', content.trim());
                    // console.log('InnerHTML:', innerHTML);
                    
                    // Check if content is effectively empty (including <br> tags and &nbsp;)
                    const cleanContent = content.replace(/\s/g, '').replace(/\u00A0/g, ''); // Remove all whitespace and &nbsp;
                    const cleanHTML = innerHTML.replace(/<br\s*\/?>/gi, '').replace(/&nbsp;/g, '').trim();
                    
                    // console.log('Clean content:', cleanContent);
                    // console.log('Clean HTML:', cleanHTML);
                    
                    // Case 1: Delete if content is empty
                    if (cleanContent === '' || cleanHTML === '' || content.trim() === '') {
                        // console.log('Deleting empty card:', cardId);
                        e.preventDefault();
                        deleteCardDirectly(cardId);
                        return;
                    }
                    
                    // Also check for common empty content patterns
                    if (innerHTML === '<br>' || innerHTML === '<br/>' || innerHTML === '<br />') {
                        // console.log('Deleting card with only br tag:', cardId);
                        e.preventDefault();
                        deleteCardDirectly(cardId);
                        return;
                    }
                    
                    // Case 2: For Ctrl/Cmd + Backspace or Ctrl/Cmd + Delete - show confirmation for card with content
                    if ((e.ctrlKey || e.metaKey) && (e.key === 'Backspace' || e.key === 'Delete')) {
                        // console.log('Ctrl/Cmd + Delete pressed on card with content:', cardId);
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
                                // console.log('Deleting empty card at beginning:', cardId);
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
                                // console.log('Deleting empty card at end:', cardId);
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
                        // console.log('Delete key pressed on non-editable card:', cardId, card.type);
                        // For image/video/audio cards without content, allow deletion
                        if ((card.type === 'image' && !card.data.src) || 
                            (card.type === 'video' && !card.data.src) || 
                            (card.type === 'audio' && !card.data.src) ||
                            card.type === 'divider') {
                            // console.log('Deleting empty media card:', cardId);
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
    
    <!-- Include Ghost publish modal functions -->
    <cfinclude template="../includes/editor/publish-modal.cfm">
</body>
</html>