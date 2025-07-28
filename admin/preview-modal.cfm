<!--- Ghost-style Preview Modal --->
<cfparam name="url.id" default="0">
<cfparam name="url.initialFormat" default="browser">
<cfparam name="url.initialSize" default="desktop">
<cfparam name="url.initialSegment" default="public">

<!--- Check authentication --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Get post data --->
<cfquery name="postData" datasource="#request.dsn#">
    SELECT 
        p.id,
        p.title,
        p.slug,
        p.html as content,
        p.custom_excerpt as excerpt,
        p.feature_image,
        p.status,
        p.visibility,
        pm.meta_title,
        pm.meta_description,
        p.published_at,
        p.created_at,
        p.updated_at,
        u.name as author_name,
        u.email as author_email
    FROM posts p
    INNER JOIN users u ON p.created_by = u.id
    LEFT JOIN posts_meta pm ON p.id = pm.post_id
    WHERE p.id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif postData.recordCount eq 0>
    <cfheader statuscode="404" statustext="Not Found">
    <h1>404 - Post not found</h1>
    <cfabort>
</cfif>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Preview - <cfoutput>#postData.title#</cfoutput></title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="/favicon.ico?v=ghost" type="image/x-icon">
    <link rel="icon" href="/favicon.ico?v=ghost" type="image/x-icon">
    
    <!-- Include admin styles -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css">
    
    <!-- Ghost preview styles -->
    <style>
        /* Ensure full height */
        html, body {
            height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            overflow: hidden !important;
            min-height: 100vh !important;
        }
        
        /* Modal backdrop */
        .preview-modal-backdrop {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.6);
            z-index: 999;
        }
        
        /* Modal container */
        .gh-post-preview-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            display: flex;
            flex-direction: column;
            background: #f4f5f6;
            z-index: 1000;
            height: 100vh !important;
            width: 100vw !important;
            min-height: 100vh !important;
        }
        
        /* Header */
        .gh-post-preview-header {
            display: flex;
            justify-content: center;
            align-items: center;
            flex-shrink: 0;
            margin: 0;
            padding: 12px 20px;
            background: #fff;
            border-bottom: 1px solid #e5e7eb;
            position: relative;
        }
        
        .gh-post-preview-header .left {
            position: absolute;
            left: 20px;
            display: flex;
            align-items: center;
        }
        
        .gh-post-preview-header h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 600;
            color: #15171a;
        }
        
        .gh-post-preview-header .right {
            position: absolute;
            right: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        /* Button groups */
        .gh-post-preview-btn-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
        }
        
        .gh-contentfilter {
            display: flex;
            background: #f4f5f6;
            border-radius: 4px;
            padding: 2px;
        }
        
        .gh-contentfilter-divider {
            width: 1px;
            height: 24px;
            background: #e5e7eb;
            margin: 0 8px;
        }
        
        /* Mode buttons */
        .gh-post-preview-mode {
            padding: 6px 12px;
            border: none;
            background: transparent;
            color: #626d79;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            border-radius: 3px;
            transition: all 0.2s ease;
        }
        
        .gh-post-preview-mode:hover {
            background: #e5e7eb;
        }
        
        .gh-post-preview-mode.gh-btn-group-selected {
            background: #fff;
            color: #15171a;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        
        .gh-post-preview-mode svg {
            width: 18px;
            height: 18px;
            vertical-align: middle;
        }
        
        /* Visibility selector */
        .gh-web-preview-segment {
            position: relative;
        }
        
        .gh-preview-segment-trigger {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 6px 12px;
            border: none;
            background: transparent;
            color: #15171a;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            border-radius: 3px;
            transition: all 0.2s ease;
        }
        
        .gh-preview-segment-trigger:hover {
            background: #e5e7eb;
        }
        
        .gh-preview-segment-trigger svg {
            width: 12px;
            height: 12px;
        }
        
        /* Share button */
        .gh-btn-preview {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border: 1px solid #e5e7eb;
            background: #fff;
            color: #15171a;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            border-radius: 4px;
            transition: all 0.2s ease;
        }
        
        .gh-btn-preview:hover {
            background: #f4f5f6;
        }
        
        .gh-btn-preview svg {
            width: 16px;
            height: 16px;
        }
        
        /* Preview container */
        .gh-post-preview-container {
            flex: 1;
            overflow: hidden;
            position: relative;
            display: flex;
            flex-direction: column;
        }
        
        /* Browser preview */
        .gh-post-preview-browser-container {
            flex: 1;
            margin: 20px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }
        
        .gh-post-preview-browser-container iframe {
            width: 100%;
            height: 100%;
            border: none;
        }
        
        /* Mobile preview */
        .gh-pe-mobile-container {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            padding: 20px;
        }
        
        .gh-pe-mobile-bezel {
            width: 375px;
            height: 812px;
            background: #000;
            border-radius: 36px;
            padding: 8px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            position: relative;
        }
        
        .gh-pe-mobile-bezel::before {
            content: '';
            position: absolute;
            top: 28px;
            left: 50%;
            transform: translateX(-50%);
            width: 150px;
            height: 28px;
            background: #000;
            border-radius: 14px;
        }
        
        .gh-pe-mobile-screen {
            width: 100%;
            height: 100%;
            background: #fff;
            border-radius: 28px;
            overflow: hidden;
            position: relative;
        }
        
        .gh-pe-mobile-screen iframe {
            width: 100%;
            height: 100%;
            border: none;
        }
        
        /* Email preview */
        .gh-post-preview-email-container {
            display: flex;
            align-items: flex-start;
            justify-content: center;
            height: 100%;
            padding: 20px;
            overflow-y: auto;
        }
        
        .gh-post-preview-email-mockup {
            width: 100%;
            max-width: 740px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        
        .gh-post-preview-email-header {
            padding: 20px;
            border-bottom: 1px solid #e5e7eb;
            background: #f9fafb;
        }
        
        .gh-email-preview-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 8px;
            font-size: 13px;
            color: #626d79;
        }
        
        .gh-email-preview-meta strong {
            color: #15171a;
        }
        
        .gh-email-preview-subject {
            font-size: 18px;
            font-weight: 600;
            color: #15171a;
        }
        
        .gh-post-preview-email-content {
            height: calc(100% - 80px);
        }
        
        .gh-post-preview-email-content iframe {
            width: 100%;
            height: 100%;
            border: none;
        }
        
        /* Dropdown */
        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            margin-top: 4px;
            padding: 8px;
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            display: none;
            min-width: 200px;
            z-index: 1001;
        }
        
        .dropdown-menu.show {
            display: block;
        }
        
        .dropdown-menu button,
        .dropdown-menu a {
            display: flex;
            align-items: center;
            gap: 8px;
            width: 100%;
            padding: 8px 12px;
            border: none;
            background: transparent;
            color: #15171a;
            font-size: 14px;
            font-weight: 500;
            text-align: left;
            text-decoration: none;
            cursor: pointer;
            border-radius: 4px;
            transition: all 0.2s ease;
        }
        
        .dropdown-menu button:hover,
        .dropdown-menu a:hover {
            background: #f4f5f6;
        }
        
        .dropdown-menu svg {
            width: 16px;
            height: 16px;
        }
        
        /* Visibility dropdown */
        .visibility-dropdown {
            position: absolute;
            top: 100%;
            left: 0;
            margin-top: 4px;
            padding: 4px;
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            display: none;
            min-width: 160px;
            z-index: 1001;
        }
        
        .visibility-dropdown.show {
            display: block;
        }
        
        .visibility-option {
            display: block;
            width: 100%;
            padding: 8px 12px;
            border: none;
            background: transparent;
            color: #15171a;
            font-size: 14px;
            font-weight: 500;
            text-align: left;
            cursor: pointer;
            border-radius: 4px;
            transition: all 0.2s ease;
        }
        
        .visibility-option:hover {
            background: #f4f5f6;
        }
        
        .visibility-option.selected {
            background: #f4f5f6;
            color: #14b8ff;
        }
        
        /* Preview content */
        #previewContent {
            flex: 1;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        
        /* Animation */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.95);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
        
        .fade-in {
            animation: fadeIn 0.3s ease-out;
        }
        
        /* Loading spinner */
        .loading-container {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
        }
        
        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 3px solid #f4f5f6;
            border-top-color: #14b8ff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .gh-post-preview-header {
                padding: 12px;
            }
            
            .gh-post-preview-header h2 {
                font-size: 18px;
            }
            
            .gh-post-preview-btn-group {
                gap: 4px;
            }
            
            .gh-contentfilter-divider {
                margin: 0 4px;
            }
            
            .gh-web-preview-segment {
                display: none;
            }
        }
    </style>
</head>
<body>
    <cfoutput>
    <!-- Preview Modal -->
    <div class="gh-post-preview-modal">
        <!-- Header -->
        <header class="gh-post-preview-header">
            <div class="left">
                <h2>Preview</h2>
            </div>
            
            <!-- Center controls -->
            <div class="gh-post-preview-btn-group">
                <!-- Web/Email toggle -->
                <div class="gh-contentfilter gh-btn-group">
                    <button type="button" class="gh-post-preview-mode selected" data-format="browser" onclick="changePreviewFormat('browser')">
                        <span>Web</span>
                    </button>
                    <cfif postData.status neq "page">
                        <button type="button" class="gh-post-preview-mode" data-format="email" onclick="changePreviewFormat('email')">
                            <span>Email</span>
                        </button>
                    </cfif>
                </div>
                
                <div class="gh-contentfilter-divider"></div>
                
                <!-- Desktop/Mobile toggle -->
                <div class="gh-contentfilter gh-btn-group">
                    <button type="button" class="gh-post-preview-mode selected" data-size="desktop" onclick="changePreviewSize('desktop')">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                            <line x1="12" y1="19" x2="12" y2="21"></line>
                            <line x1="8" y1="21" x2="16" y2="21"></line>
                        </svg>
                    </button>
                    <button type="button" class="gh-post-preview-mode" data-size="mobile" onclick="changePreviewSize('mobile')">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="7" y="4" width="10" height="16" rx="1"></rect>
                            <line x1="11" y1="5" x2="13" y2="5"></line>
                            <line x1="12" y1="17" x2="12" y2="17.01"></line>
                        </svg>
                    </button>
                </div>
                
                <div class="gh-contentfilter-divider"></div>
                
                <!-- Visibility selector -->
                <div class="gh-web-preview-segment">
                    <button class="gh-preview-segment-trigger" onclick="toggleVisibilityDropdown()">
                        <span id="visibilityLabel">Public visitor</span>
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                    </button>
                    <div class="visibility-dropdown" id="visibilityDropdown">
                        <button class="visibility-option selected" data-value="anonymous" onclick="changeVisibility('anonymous', 'Public visitor')">Public visitor</button>
                        <button class="visibility-option" data-value="free" onclick="changeVisibility('free', 'Free member')">Free member</button>
                        <button class="visibility-option" data-value="paid" onclick="changeVisibility('paid', 'Paid member')">Paid member</button>
                    </div>
                </div>
            </div>
            
            <!-- Right controls -->
            <div class="right">
                <!-- Share button -->
                <div style="position: relative;">
                    <button class="gh-btn-preview" onclick="toggleShareDropdown()">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M6 12c0 1.657 -1.343 3 -3 3s-3 -1.343 -3 -3s1.343 -3 3 -3s3 1.343 3 3z"></path>
                            <path d="M18 6c0 1.657 -1.343 3 -3 3s-3 -1.343 -3 -3s1.343 -3 3 -3s3 1.343 3 3z"></path>
                            <path d="M18 18c0 1.657 -1.343 3 -3 3s-3 -1.343 -3 -3s1.343 -3 3 -3s3 1.343 3 3z"></path>
                            <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
                            <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
                        </svg>
                    </button>
                    <div class="dropdown-menu" id="shareDropdown">
                        <button onclick="copyPreviewLink()">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="8" y="8" width="12" height="12" rx="2"></rect>
                                <path d="M16 8v-2a2 2 0 0 0 -2 -2h-8a2 2 0 0 0 -2 2v8a2 2 0 0 0 2 2h2"></path>
                            </svg>
                            <span>Copy preview link</span>
                        </button>
                        <a href="/ghost/admin/preview-public.cfm?id=#postData.id#" target="_blank">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M11 7h-5a2 2 0 0 0 -2 2v9a2 2 0 0 0 2 2h9a2 2 0 0 0 2 -2v-5"></path>
                                <line x1="10" y1="14" x2="20" y2="4"></line>
                                <polyline points="15 4 20 4 20 9"></polyline>
                            </svg>
                            <span>Open in new tab</span>
                        </a>
                    </div>
                </div>
                
                <div class="gh-contentfilter-divider"></div>
                
                <!-- Close button -->
                <button class="gh-btn-preview" onclick="closePreview()">
                    <span>Close</span>
                </button>
                
                <!-- Publish button -->
                <cfif postData.status neq "published">
                    <button class="btn btn-primary btn-sm" onclick="publishPost()">
                        <span>Publish</span>
                    </button>
                </cfif>
            </div>
        </header>
        
        <!-- Preview container -->
        <div class="gh-post-preview-container">
            <div id="previewContent" class="fade-in">
                <!-- Content will be loaded here -->
            </div>
        </div>
    </div>
    </cfoutput>
    
    <!-- JavaScript -->
    <script>
        // State
        let currentFormat = 'browser';
        let currentSize = 'desktop';
        let currentVisibility = 'anonymous';
        const postId = '<cfoutput>#postData.id#</cfoutput>';
        
        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            loadPreview();
        });
        
        // Change preview format (web/email)
        function changePreviewFormat(format) {
            currentFormat = format;
            
            // Update button states
            document.querySelectorAll('[data-format]').forEach(btn => {
                btn.classList.toggle('selected', btn.dataset.format === format);
            });
            
            // Show/hide visibility selector for email
            const visibilitySelector = document.querySelector('.gh-web-preview-segment');
            if (format === 'email') {
                visibilitySelector.style.display = 'none';
                if (currentVisibility === 'anonymous') {
                    currentVisibility = 'free';
                    updateVisibilityLabel('Free member');
                }
            } else {
                visibilitySelector.style.display = 'block';
            }
            
            loadPreview();
        }
        
        // Change preview size (desktop/mobile)
        function changePreviewSize(size) {
            currentSize = size;
            
            // Update button states
            document.querySelectorAll('[data-size]').forEach(btn => {
                btn.classList.toggle('selected', btn.dataset.size === size);
            });
            
            loadPreview();
        }
        
        // Toggle visibility dropdown
        function toggleVisibilityDropdown() {
            const dropdown = document.getElementById('visibilityDropdown');
            const shareDropdown = document.getElementById('shareDropdown');
            
            // Close share dropdown
            shareDropdown.classList.remove('show');
            
            // Toggle visibility dropdown
            dropdown.classList.toggle('show');
            
            // Close on outside click
            if (dropdown.classList.contains('show')) {
                setTimeout(() => {
                    document.addEventListener('click', closeDropdowns);
                }, 100);
            }
        }
        
        // Change visibility
        function changeVisibility(value, label) {
            currentVisibility = value;
            updateVisibilityLabel(label);
            
            // Update selected state
            document.querySelectorAll('.visibility-option').forEach(opt => {
                opt.classList.toggle('selected', opt.dataset.value === value);
            });
            
            // Close dropdown
            document.getElementById('visibilityDropdown').classList.remove('show');
            
            // Reload preview if web format
            if (currentFormat === 'browser') {
                loadPreview();
            }
        }
        
        // Update visibility label
        function updateVisibilityLabel(label) {
            document.getElementById('visibilityLabel').textContent = label;
        }
        
        // Toggle share dropdown
        function toggleShareDropdown() {
            const dropdown = document.getElementById('shareDropdown');
            const visDropdown = document.getElementById('visibilityDropdown');
            
            // Close visibility dropdown
            visDropdown.classList.remove('show');
            
            // Toggle share dropdown
            dropdown.classList.toggle('show');
            
            // Close on outside click
            if (dropdown.classList.contains('show')) {
                setTimeout(() => {
                    document.addEventListener('click', closeDropdowns);
                }, 100);
            }
        }
        
        // Close dropdowns
        function closeDropdowns(e) {
            if (!e.target.closest('.gh-web-preview-segment') && !e.target.closest('[onclick*="toggleShareDropdown"]')) {
                document.getElementById('visibilityDropdown').classList.remove('show');
                document.getElementById('shareDropdown').classList.remove('show');
                document.removeEventListener('click', closeDropdowns);
            }
        }
        
        // Copy preview link
        function copyPreviewLink() {
            const url = window.location.origin + '/ghost/admin/preview-public.cfm?id=' + postId + '&member_status=' + currentVisibility;
            
            navigator.clipboard.writeText(url).then(() => {
                // Show success message
                const btn = event.target.closest('button');
                const originalText = btn.innerHTML;
                btn.innerHTML = '<i class="ti ti-check"></i><span>Copied!</span>';
                
                setTimeout(() => {
                    btn.innerHTML = originalText;
                }, 2000);
            });
            
            // Close dropdown
            document.getElementById('shareDropdown').classList.remove('show');
        }
        
        // Load preview
        function loadPreview() {
            const container = document.getElementById('previewContent');
            
            // Show loading
            container.innerHTML = '<div class="loading-container"><div class="loading-spinner"></div></div>';
            
            // Add fade-in effect
            container.classList.remove('fade-in');
            setTimeout(() => {
                container.classList.add('fade-in');
            }, 10);
            
            // Load appropriate preview
            setTimeout(() => {
                if (currentFormat === 'browser') {
                    loadBrowserPreview();
                } else {
                    loadEmailPreview();
                }
            }, 300);
        }
        
        // Load browser preview
        function loadBrowserPreview() {
            const container = document.getElementById('previewContent');
            const previewUrl = '/ghost/admin/preview-public.cfm?id=' + postId + '&member_status=' + currentVisibility;
            
            if (currentSize === 'desktop') {
                container.innerHTML = `
                    <div class="gh-post-preview-browser-container">
                        <iframe src="${previewUrl}" title="Desktop browser post preview"></iframe>
                    </div>
                `;
            } else {
                container.innerHTML = `
                    <div class="gh-pe-mobile-container">
                        <div class="gh-pe-mobile-bezel">
                            <div class="gh-pe-mobile-screen">
                                <iframe src="${previewUrl}" title="Mobile browser post preview"></iframe>
                            </div>
                        </div>
                    </div>
                `;
            }
        }
        
        // Load email preview
        function loadEmailPreview() {
            const container = document.getElementById('previewContent');
            const emailUrl = '/ghost/admin/preview-email.cfm?id=' + postId + '&member_status=' + currentVisibility;
            
            <cfoutput>
            const emailSubject = '#replace(postData.title, "'", "\'", "all")#';
            const authorName = '#postData.author_name#';
            const authorEmail = '#postData.author_email#';
            </cfoutput>
            
            container.innerHTML = `
                <div class="gh-post-preview-email-container">
                    <div class="gh-post-preview-email-mockup ${currentSize === 'mobile' ? 'gh-post-preview-email-mockup-mobile' : ''}">
                        <div class="gh-post-preview-email-header">
                            <div class="gh-email-preview-meta">
                                <strong>From:</strong> ${authorName} &lt;${authorEmail}&gt;
                            </div>
                            <div class="gh-email-preview-meta">
                                <strong>To:</strong> subscriber@example.com
                            </div>
                            <div class="gh-email-preview-subject">
                                ${emailSubject}
                            </div>
                        </div>
                        <div class="gh-post-preview-email-content">
                            <iframe src="${emailUrl}" title="Email preview"></iframe>
                        </div>
                    </div>
                </div>
            `;
        }
        
        // Close preview
        function closePreview() {
            // If in iframe, send message to parent
            if (window.parent !== window) {
                window.parent.postMessage({ action: 'closePreview' }, '*');
            } else {
                // Otherwise, go back to editor
                window.location.href = '/ghost/admin/posts/edit-ghost-style.cfm?id=' + postId;
            }
        }
        
        // Publish post
        function publishPost() {
            // Send message to parent to open publish modal
            if (window.parent !== window) {
                window.parent.postMessage({ action: 'openPublishModal' }, '*');
            }
        }
    </script>
</body>
</html>