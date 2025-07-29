<!--- Ghost Design Settings Page --->
<cfparam name="request.dsn" default="blog">
<cfset pageTitle = "Design">

<!--- Include site configuration --->
<cfinclude template="/ghost/config/site.cfm">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login" addtoken="false">
</cfif>

<!--- Get active theme from settings --->
<cfquery name="qActiveTheme" datasource="#request.dsn#">
    SELECT value FROM settings 
    WHERE `key` = <cfqueryparam value="active_theme" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset activeTheme = qActiveTheme.recordCount ? qActiveTheme.value : "default">

<!--- Get other design settings --->
<cfquery name="qDesignSettings" datasource="#request.dsn#">
    SELECT * FROM settings 
    WHERE `key` IN ('accent_color', 'cover_image', 'logo', 'icon', 'navigation', 'secondary_navigation', 'codeinjection_head', 'codeinjection_foot', 
                     'heading_font', 'body_font', 'color_scheme', 'logo_dark', 'show_author', 'standard_load_more', 'navigation_right',
                     'show_authors_widget', 'show_tags_widget', 'tags_widget_slug', 'content_api_key', 'contact_form_endpoint', 'disqus_shortname',
                     'footer_copyright', 'homepage_title', 'special_section_tag')
</cfquery>

<!--- Convert to struct for easy access --->
<cfset designSettings = {}>
<cfloop query="qDesignSettings">
    <cfset designSettings[qDesignSettings.key] = qDesignSettings.value>
</cfloop>

<!--- Get available themes --->
<cfdirectory action="list" directory="#expandPath('/ghost/themes/')#" name="qThemes" type="dir">

<!--- Include header --->
<cfinclude template="includes/header.cfm">

<style>
/* Ghost Admin X Design System */
* {
    box-sizing: border-box;
}

/* Page Header */
.gh-page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24px 0;
    margin-bottom: 32px;
}

.gh-page-title {
    margin: 0;
    font-size: 28px;
    font-weight: 700;
    letter-spacing: -0.02em;
    color: #111827;
}

.gh-design-modal {
    display: flex;
    height: calc(100vh - 160px);
    background: #fff;
    margin: 0 -20px -20px;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Sidebar */
.gh-design-sidebar {
    width: 420px;
    background: #f9fafb;
    border-right: 1px solid #e5e7eb;
    display: flex;
    flex-direction: column;
}

.gh-design-sidebar-content {
    flex: 1;
    overflow-y: auto;
}

/* Preview */
.gh-design-preview {
    flex: 1;
    background: #f3f4f6;
    position: relative;
    overflow: hidden;
}

.gh-preview-container {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
}

.gh-preview-browser {
    width: 100%;
    max-width: 1400px;
    height: 100%;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
    overflow: hidden;
    display: flex;
    flex-direction: column;
}

.gh-preview-browser-header {
    height: 40px;
    background: #f3f4f6;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    align-items: center;
    padding: 0 16px;
    gap: 8px;
}

.gh-preview-browser-dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #d1d5db;
}

.gh-preview-browser-content {
    flex: 1;
    overflow: auto;
}

.gh-preview-iframe {
    width: 100%;
    height: 100%;
    border: none;
}

/* Tabs */
.gh-tabs-sticky {
    position: sticky;
    top: 0;
    background: #f9fafb;
    z-index: 10;
    padding: 24px 28px 0;
}

.gh-tabs {
    display: flex;
    gap: 32px;
    border-bottom: 1px solid #e5e7eb;
    margin: 0;
    padding: 0;
}

.gh-tab {
    padding: 12px 0;
    margin-bottom: -1px;
    border-bottom: 2px solid transparent;
    color: #6b7280;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.15s ease;
    white-space: nowrap;
    letter-spacing: -0.01em;
}

.gh-tab:hover {
    color: #111827;
}

.gh-tab.active {
    color: #111827;
    border-bottom-color: #111827;
}

/* Tab content */
.gh-tab-content {
    display: none;
}

.gh-tab-content.active {
    display: block;
}

/* Form sections */
.gh-form-section {
    padding: 24px 28px;
}

.gh-form-section-title {
    font-size: 13px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.03em;
    color: #6b7280;
    margin-bottom: 20px;
}

.gh-setting-group {
    margin-bottom: 24px;
}

.gh-setting-group:last-child {
    margin-bottom: 0;
}

.gh-setting-label {
    display: block;
    margin-bottom: 8px;
    color: #111827;
    font-size: 14px;
    font-weight: 500;
}

.gh-setting-desc {
    margin-bottom: 12px;
    color: #6b7280;
    font-size: 13px;
    line-height: 1.5;
}

/* Form controls */
.gh-input,
.gh-select,
.gh-textarea {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    font-size: 14px;
    line-height: 1.5;
    transition: all 0.15s ease;
    background: #fff;
}

.gh-input:focus,
.gh-select:focus,
.gh-textarea:focus {
    outline: none;
    border-color: #111827;
    box-shadow: 0 0 0 1px #111827;
}

.gh-textarea {
    min-height: 100px;
    resize: vertical;
    font-family: monospace;
}

/* Color picker */
.gh-color-picker-wrapper {
    display: flex;
    align-items: center;
    gap: 12px;
}

.gh-color-input {
    width: 50px;
    height: 40px;
    padding: 4px;
    cursor: pointer;
}

.gh-color-text {
    flex: 1;
    max-width: 120px;
}

/* Toggle switch */
.gh-toggle-group {
    display: flex;
    align-items: center;
    gap: 12px;
}

.gh-toggle-switch {
    position: relative;
    width: 44px;
    height: 24px;
}

.gh-toggle-switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

.gh-toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #e5e7eb;
    transition: 0.3s;
    border-radius: 24px;
}

.gh-toggle-slider:before {
    position: absolute;
    content: "";
    height: 16px;
    width: 16px;
    left: 4px;
    bottom: 4px;
    background-color: white;
    transition: 0.3s;
    border-radius: 50%;
}

input:checked + .gh-toggle-slider {
    background-color: #10b981;
}

input:checked + .gh-toggle-slider:before {
    transform: translateX(20px);
}

.gh-toggle-label {
    color: #111827;
    font-size: 14px;
    font-weight: 500;
}

/* Image upload */
.gh-image-uploader {
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.gh-image-preview {
    position: relative;
    max-width: 100%;
    border-radius: 6px;
    overflow: hidden;
    background: #f3f4f6;
    border: 1px solid #e5e7eb;
}

.gh-image-preview img {
    display: block;
    width: 100%;
    height: auto;
}

.gh-image-delete {
    position: absolute;
    top: 8px;
    right: 8px;
    width: 32px;
    height: 32px;
    background: rgba(0,0,0,0.7);
    color: white;
    border: none;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 400;
    line-height: 16px;
    padding: 0;
    text-align: center;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    transition: all 0.2s ease;
}


.gh-image-delete:hover {
    background: rgba(0,0,0,0.9);
    transform: scale(1.1);
}

.gh-upload-button {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: #fff;
    color: #111827;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    line-height: 1;
    cursor: pointer;
    transition: all 0.2s ease;
    white-space: nowrap;
}

.gh-upload-button:hover {
    background: #f9fafb;
    border-color: #111827;
}

/* Navigation editor */
.gh-navigation-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.gh-navigation-item {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 12px;
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
}

.gh-navigation-item input {
    flex: 1;
}

.gh-navigation-item button {
    padding: 8px;
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s ease;
    color: #dc2626;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.gh-navigation-item button:hover {
    background: #fee2e2;
    border-color: #dc2626;
}

.gh-add-navigation {
    margin-top: 12px;
}

.gh-add-navigation i {
    font-size: 14px;
}

/* Theme Grid */
.gh-themes-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 24px;
    padding: 28px;
}

.gh-theme-card {
    cursor: pointer;
    transition: all 0.2s ease;
}

.gh-theme-card:hover {
    transform: translateY(-4px);
}

.gh-theme-preview {
    position: relative;
    background: #f3f4f6;
    border-radius: 8px;
    overflow: hidden;
    aspect-ratio: 3/2;
    box-shadow: 0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px 0 rgba(0,0,0,0.06);
    transition: all 0.3s ease;
}

.gh-theme-card:hover .gh-theme-preview {
    box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);
}

.gh-theme-preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.gh-theme-preview .gh-theme-icon {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    font-size: 48px;
    color: #9ca3af;
}

.gh-theme-info {
    margin-top: 12px;
}

.gh-theme-name {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 4px;
}

.gh-theme-category {
    font-size: 14px;
    color: #6b7280;
}

.gh-theme-active {
    position: absolute;
    top: 12px;
    right: 12px;
    background: #10b981;
    color: white;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
}

/* Theme List */
.gh-themes-list {
    padding: 0;
}

.gh-theme-list-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 28px;
    border-bottom: 1px solid #e5e7eb;
    transition: background 0.15s ease;
}

.gh-theme-list-item:hover {
    background: #f9fafb;
}

.gh-theme-list-item:last-child {
    border-bottom: none;
}

.gh-theme-list-info {
    flex: 1;
}

.gh-theme-list-name {
    font-size: 14px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 4px;
}

.gh-theme-list-name .active {
    color: #10b981;
}

.gh-theme-list-version {
    font-size: 13px;
    color: #6b7280;
}

.gh-theme-list-actions {
    display: flex;
    align-items: center;
    gap: 12px;
}

.gh-theme-list-actions .gh-btn {
    padding: 6px 12px;
}

.gh-theme-list-actions .gh-btn i {
    font-size: 14px;
}

/* Buttons */
.gh-btn {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    background: #fff;
    color: #111827;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    line-height: 1;
    cursor: pointer;
    transition: all 0.2s ease;
    white-space: nowrap;
}

.gh-btn:hover {
    background: #f9fafb;
}

.gh-btn-primary {
    background: #111827;
    color: #fff;
    border-color: #111827;
}

.gh-btn-primary:hover {
    background: #1f2937;
    border-color: #1f2937;
}

.gh-btn i {
    font-size: 16px;
}

.gh-btn-green {
    background: #10b981;
    color: #fff;
    border-color: #10b981;
}

.gh-btn-green:hover {
    background: #059669;
    border-color: #059669;
}

.gh-btn-link {
    padding: 0;
    background: none;
    border: none;
    color: #10b981;
}

.gh-btn-link:hover {
    background: none;
    color: #059669;
}

/* Save button */
.gh-fixed-save-button {
    position: fixed;
    bottom: 32px;
    right: 32px;
    z-index: 1000;
}

/* Icon sizes */
.ti {
    font-size: 16px;
    line-height: 1;
}

/* Typography Settings */
.gh-typography-settings {
    margin-top: 16px;
}

.gh-typography-option-group {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-bottom: 20px;
}

.gh-typography-option {
    position: relative;
}

.gh-typography-option input[type="radio"] {
    position: absolute;
    opacity: 0;
}

.gh-typography-label {
    display: block;
    padding: 20px;
    background: #fff;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: center;
}

.gh-typography-option input[type="radio"]:checked + .gh-typography-label {
    border-color: #111827;
    background: #f9fafb;
}

.gh-typography-option:hover .gh-typography-label {
    border-color: #9ca3af;
}

.gh-typography-preview {
    display: flex;
    align-items: baseline;
    justify-content: center;
    gap: 8px;
    margin-bottom: 12px;
    height: 40px;
}

.gh-typography-heading {
    font-size: 28px;
    font-weight: 700;
    line-height: 1;
    color: #111827;
}

.gh-typography-body {
    font-size: 16px;
    line-height: 1;
    color: #6b7280;
}

.gh-typography-name {
    font-size: 13px;
    font-weight: 500;
    color: #111827;
}

/* Expandable Block */
.gh-expandable-block {
    margin-top: 12px;
}

.gh-expandable-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 0;
    cursor: pointer;
    font-size: 13px;
    font-weight: 500;
    color: #111827;
    list-style: none;
}

.gh-expandable-header::-webkit-details-marker {
    display: none;
}

.gh-expandable-header i {
    transition: transform 0.2s ease;
    font-size: 14px;
    color: #6b7280;
}

details[open] .gh-expandable-header i {
    transform: rotate(90deg);
}

.gh-expandable-content {
    padding-top: 16px;
    padding-bottom: 8px;
    border-top: 1px solid #e5e7eb;
    margin-top: 12px;
}

/* Upload zone */
.gh-upload-zone {
    background: #f9fafb;
    border: 2px dashed #e5e7eb;
    border-radius: 8px;
    padding: 48px 24px;
    text-align: center;
    margin: 28px;
    transition: all 0.3s ease;
}

.gh-upload-zone.dragover {
    border-color: #111827;
    background: #f3f4f6;
}

.gh-upload-zone-icon {
    width: 48px;
    height: 48px;
    margin: 0 auto 16px;
    opacity: 0.5;
}

.gh-upload-zone-title {
    font-size: 16px;
    font-weight: 600;
    color: #111827;
    margin-bottom: 8px;
}

.gh-upload-zone-description {
    font-size: 14px;
    color: #6b7280;
    margin-bottom: 24px;
}

/* Responsive */
@media (max-width: 768px) {
    .gh-design-modal {
        flex-direction: column;
    }
    
    .gh-design-sidebar {
        width: 100%;
        border-right: none;
        border-bottom: 1px solid #e5e7eb;
    }
    
    .gh-design-preview {
        display: none;
    }
}
</style>

<main class="main-content">
    <div class="container-fluid">
        <!-- Page Header -->
        <div class="gh-page-header">
            <h2 class="gh-page-title">Design</h2>
            <button class="gh-btn gh-btn-primary" id="saveButton" onclick="saveSettings()">
                <i class="ti ti-check"></i>
                <span>Save</span>
            </button>
        </div>

        <div class="gh-design-modal">
            <!-- Sidebar -->
            <div class="gh-design-sidebar">
                <div class="gh-tabs-sticky">
                    <div class="gh-tabs">
                        <div class="gh-tab active" data-tab="brand">Brand</div>
                        <div class="gh-tab" data-tab="theme">Themes</div>
                    </div>
                </div>
                
                <div class="gh-design-sidebar-content">
                    <!-- Brand Tab Content -->
                    <div class="gh-tab-content active" id="brand-tab">
                        <div class="gh-form-section">
                            <h3 class="gh-form-section-title">Site Identity</h3>
                            
                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Accent color</label>
                                <p class="gh-setting-desc">Primary color used in your theme</p>
                                <div class="gh-color-picker-wrapper">
                                    <input type="color" 
                                           id="accent_color" 
                                           name="accent_color" 
                                           class="gh-input gh-color-input" 
                                           value="<cfoutput>#htmlEditFormat(designSettings.accent_color ?: '##15171A')#</cfoutput>">
                                    <input type="text" 
                                           id="accent_color_text" 
                                           name="accent_color_text" 
                                           class="gh-input gh-color-text" 
                                           value="<cfoutput>#htmlEditFormat(designSettings.accent_color ?: '##15171A')#</cfoutput>">
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Publication icon</label>
                                <p class="gh-setting-desc">A square image used as a favicon and app icon</p>
                                <div class="gh-image-uploader">
                                    <cfif len(designSettings.icon ?: '')>
                                        <cfset iconUrl = replaceGhostUrl(designSettings.icon)>
                                        <div class="gh-image-preview" id="icon-preview">
                                            <img src="<cfoutput>#htmlEditFormat(iconUrl)#</cfoutput>" alt="Icon">
                                            <button type="button" class="gh-image-delete" onclick="removeImage('icon')" aria-label="Remove icon"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                        </div>
                                    <cfelse>
                                        <div class="gh-image-preview" id="icon-preview" style="display:none;">
                                            <img src="" alt="Icon">
                                            <button type="button" class="gh-image-delete" onclick="removeImage('icon')" aria-label="Remove icon"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                        </div>
                                    </cfif>
                                    <input type="hidden" id="icon" name="icon" value="<cfoutput>#htmlEditFormat(designSettings.icon ?: '')#</cfoutput>">
                                    <button type="button" class="gh-upload-button" onclick="document.getElementById('icon-upload').click()">
                                        <i class="ti ti-upload"></i>
                                        <span>Upload icon</span>
                                    </button>
                                    <input type="file" id="icon-upload" accept="image/*" style="display:none;" onchange="uploadImage('icon', this)">
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Publication logo</label>
                                <p class="gh-setting-desc">The primary logo for your brand</p>
                                <div class="gh-image-uploader">
                                    <cfif len(designSettings.logo ?: '')>
                                        <cfset logoUrl = replaceGhostUrl(designSettings.logo)>
                                        <div class="gh-image-preview" id="logo-preview">
                                            <img src="<cfoutput>#htmlEditFormat(logoUrl)#</cfoutput>" alt="Logo">
                                            <button type="button" class="gh-image-delete" onclick="removeImage('logo')" aria-label="Remove logo"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                        </div>
                                    <cfelse>
                                        <div class="gh-image-preview" id="logo-preview" style="display:none;">
                                            <img src="" alt="Logo">
                                            <button type="button" class="gh-image-delete" onclick="removeImage('logo')" aria-label="Remove logo"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                        </div>
                                    </cfif>
                                    <input type="hidden" id="logo" name="logo" value="<cfoutput>#htmlEditFormat(designSettings.logo ?: '')#</cfoutput>">
                                    <button type="button" class="gh-upload-button" onclick="document.getElementById('logo-upload').click()">
                                        <i class="ti ti-upload"></i>
                                        <span>Upload logo</span>
                                    </button>
                                    <input type="file" id="logo-upload" accept="image/*" style="display:none;" onchange="uploadImage('logo', this)">
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Publication cover</label>
                                <p class="gh-setting-desc">An optional large background image for your site</p>
                                <div class="gh-image-uploader">
                                    <cfif len(designSettings.cover_image ?: '')>
                                        <cfset coverUrl = replaceGhostUrl(designSettings.cover_image)>
                                        <div class="gh-image-preview" id="cover_image-preview">
                                            <img src="<cfoutput>#htmlEditFormat(coverUrl)#</cfoutput>" alt="Cover">
                                            <button type="button" class="gh-image-delete" onclick="removeImage('cover_image')" aria-label="Remove cover"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                        </div>
                                    <cfelse>
                                        <div class="gh-image-preview" id="cover_image-preview" style="display:none;">
                                            <img src="" alt="Cover">
                                            <button type="button" class="gh-image-delete" onclick="removeImage('cover_image')" aria-label="Remove cover"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                        </div>
                                    </cfif>
                                    <input type="hidden" id="cover_image" name="cover_image" value="<cfoutput>#htmlEditFormat(designSettings.cover_image ?: '')#</cfoutput>">
                                    <button type="button" class="gh-upload-button" onclick="document.getElementById('cover_image-upload').click()">
                                        <i class="ti ti-upload"></i>
                                        <span>Upload cover</span>
                                    </button>
                                    <input type="file" id="cover_image-upload" accept="image/*" style="display:none;" onchange="uploadImage('cover_image', this)">
                                </div>
                            </div>
                        </div>

                        <div class="gh-form-section">
                            <h3 class="gh-form-section-title">Site Design</h3>
                            
                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Typography</label>
                                <p class="gh-setting-desc">Customize the fonts used on your site</p>
                                
                                <div class="gh-typography-settings">
                                    <div class="gh-typography-option-group">
                                        <div class="gh-typography-option">
                                            <input type="radio" id="font-sans" name="typography_preset" value="sans" 
                                                   <cfif (designSettings.heading_font ?: 'sans-serif') EQ 'sans-serif' AND (designSettings.body_font ?: 'sans-serif') EQ 'sans-serif'>checked</cfif>>
                                            <label for="font-sans" class="gh-typography-label">
                                                <div class="gh-typography-preview">
                                                    <span class="gh-typography-heading" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">Aa</span>
                                                    <span class="gh-typography-body" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">Abc</span>
                                                </div>
                                                <div class="gh-typography-name">Modern sans-serif</div>
                                            </label>
                                        </div>
                                        
                                        <div class="gh-typography-option">
                                            <input type="radio" id="font-serif" name="typography_preset" value="serif" 
                                                   <cfif (designSettings.heading_font ?: '') EQ 'serif' AND (designSettings.body_font ?: '') EQ 'serif'>checked</cfif>>
                                            <label for="font-serif" class="gh-typography-label">
                                                <div class="gh-typography-preview">
                                                    <span class="gh-typography-heading" style="font-family: Georgia, 'Times New Roman', serif;">Aa</span>
                                                    <span class="gh-typography-body" style="font-family: Georgia, 'Times New Roman', serif;">Abc</span>
                                                </div>
                                                <div class="gh-typography-name">Elegant serif</div>
                                            </label>
                                        </div>
                                    </div>
                                    
                                    <details class="gh-expandable-block">
                                        <summary class="gh-expandable-header">
                                            <span>Advanced options</span>
                                            <i class="ti ti-chevron-right"></i>
                                        </summary>
                                        <div class="gh-expandable-content">
                                            <div style="margin-bottom: 16px;">
                                                <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Heading font</label>
                                                <select id="heading_font" name="heading_font" class="gh-select">
                                                    <option value="sans-serif" <cfif (designSettings.heading_font ?: 'sans-serif') EQ 'sans-serif'>selected</cfif>>Sans-serif</option>
                                                    <option value="serif" <cfif (designSettings.heading_font ?: '') EQ 'serif'>selected</cfif>>Serif</option>
                                                    <option value="slab" <cfif (designSettings.heading_font ?: '') EQ 'slab'>selected</cfif>>Slab</option>
                                                </select>
                                            </div>
                                            
                                            <div>
                                                <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Body font</label>
                                                <select id="body_font" name="body_font" class="gh-select">
                                                    <option value="sans-serif" <cfif (designSettings.body_font ?: 'sans-serif') EQ 'sans-serif'>selected</cfif>>Sans-serif</option>
                                                    <option value="serif" <cfif (designSettings.body_font ?: '') EQ 'serif'>selected</cfif>>Serif</option>
                                                </select>
                                            </div>
                                        </div>
                                    </details>
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Site-wide</label>
                                <p class="gh-setting-desc">Site-wide design settings</p>
                                
                                <div style="margin-bottom: 16px;">
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Color scheme</label>
                                    <select id="color_scheme" name="color_scheme" class="gh-select">
                                        <option value="auto" <cfif (designSettings.color_scheme ?: 'auto') EQ 'auto'>selected</cfif>>Auto</option>
                                        <option value="light" <cfif (designSettings.color_scheme ?: '') EQ 'light'>selected</cfif>>Light</option>
                                        <option value="dark" <cfif (designSettings.color_scheme ?: '') EQ 'dark'>selected</cfif>>Dark</option>
                                    </select>
                                </div>
                                
                                <div>
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Logo for dark mode</label>
                                    <div class="gh-image-uploader">
                                        <cfif len(designSettings.logo_dark ?: '')>
                                            <cfset logoDarkUrl = replaceGhostUrl(designSettings.logo_dark)>
                                            <div class="gh-image-preview" id="logo_dark-preview">
                                                <img src="<cfoutput>#htmlEditFormat(logoDarkUrl)#</cfoutput>" alt="Dark Logo">
                                                <button type="button" class="gh-image-delete" onclick="removeImage('logo_dark')" aria-label="Remove dark logo"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                            </div>
                                        <cfelse>
                                            <div class="gh-image-preview" id="logo_dark-preview" style="display:none;">
                                                <img src="" alt="Dark Logo">
                                                <button type="button" class="gh-image-delete" onclick="removeImage('logo_dark')" aria-label="Remove dark logo"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L13 13M13 1L1 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg></button>
                                            </div>
                                        </cfif>
                                        <input type="hidden" id="logo_dark" name="logo_dark" value="<cfoutput>#htmlEditFormat(designSettings.logo_dark ?: '')#</cfoutput>">
                                        <button type="button" class="gh-upload-button" onclick="document.getElementById('logo_dark-upload').click()">
                                            <i class="ti ti-upload"></i>
                                            <span>Upload dark logo</span>
                                        </button>
                                        <input type="file" id="logo_dark-upload" accept="image/*" style="display:none;" onchange="uploadImage('logo_dark', this)">
                                    </div>
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Navigation</label>
                                <p class="gh-setting-desc">Links in your site navigation</p>
                                
                                <div style="margin-bottom: 16px;">
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Primary navigation</label>
                                    <div class="gh-navigation-list" id="primary-navigation">
                                        <!--- Navigation items will be loaded here --->
                                    </div>
                                    <button type="button" class="gh-btn gh-add-navigation" onclick="addNavigationItem('primary')">
                                        <i class="ti ti-plus"></i>
                                        <span>Add item</span>
                                    </button>
                                </div>
                                
                                <div>
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Secondary navigation</label>
                                    <div class="gh-navigation-list" id="secondary-navigation">
                                        <!--- Navigation items will be loaded here --->
                                    </div>
                                    <button type="button" class="gh-btn gh-add-navigation" onclick="addNavigationItem('secondary')">
                                        <i class="ti ti-plus"></i>
                                        <span>Add item</span>
                                    </button>
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Site Features</label>
                                <p class="gh-setting-desc">Additional features and settings for your publication</p>
                                
                                <div class="gh-toggle-group" style="margin-bottom: 16px;">
                                    <label class="gh-toggle-switch">
                                        <input type="checkbox" id="show_author" name="show_author"
                                               <cfif (designSettings.show_author ?: 'true') EQ 'true'>checked</cfif>>
                                        <span class="gh-toggle-slider"></span>
                                    </label>
                                    <label for="show_author" class="gh-toggle-label">Show author</label>
                                </div>
                                <p class="gh-setting-desc" style="margin-left: 56px; margin-top: -8px; margin-bottom: 16px;">Display author information on posts</p>
                                
                                <div class="gh-toggle-group" style="margin-bottom: 16px;">
                                    <label class="gh-toggle-switch">
                                        <input type="checkbox" id="standard_load_more" name="standard_load_more"
                                               <cfif (designSettings.standard_load_more ?: 'false') EQ 'true'>checked</cfif>>
                                        <span class="gh-toggle-slider"></span>
                                    </label>
                                    <label for="standard_load_more" class="gh-toggle-label">Standard load more button</label>
                                </div>
                                <p class="gh-setting-desc" style="margin-left: 56px; margin-top: -8px; margin-bottom: 16px;">Show a load more button instead of infinite scroll</p>
                                
                                <div class="gh-toggle-group" style="margin-bottom: 16px;">
                                    <label class="gh-toggle-switch">
                                        <input type="checkbox" id="navigation_right" name="navigation_right"
                                               <cfif (designSettings.navigation_right ?: 'false') EQ 'true'>checked</cfif>>
                                        <span class="gh-toggle-slider"></span>
                                    </label>
                                    <label for="navigation_right" class="gh-toggle-label">Navigation on the right side</label>
                                </div>
                                <p class="gh-setting-desc" style="margin-left: 56px; margin-top: -8px; margin-bottom: 16px;">Move navigation to the right side of the header</p>
                                
                                <div class="gh-toggle-group" style="margin-bottom: 16px;">
                                    <label class="gh-toggle-switch">
                                        <input type="checkbox" id="show_authors_widget" name="show_authors_widget"
                                               <cfif (designSettings.show_authors_widget ?: 'false') EQ 'true'>checked</cfif>>
                                        <span class="gh-toggle-slider"></span>
                                    </label>
                                    <label for="show_authors_widget" class="gh-toggle-label">Show authors widget</label>
                                </div>
                                <p class="gh-setting-desc" style="margin-left: 56px; margin-top: -8px; margin-bottom: 16px;">Display an authors widget in the sidebar</p>
                                
                                <div class="gh-toggle-group" style="margin-bottom: 16px;">
                                    <label class="gh-toggle-switch">
                                        <input type="checkbox" id="show_tags_widget" name="show_tags_widget"
                                               <cfif (designSettings.show_tags_widget ?: 'false') EQ 'true'>checked</cfif>>
                                        <span class="gh-toggle-slider"></span>
                                    </label>
                                    <label for="show_tags_widget" class="gh-toggle-label">Show tags widget</label>
                                </div>
                                <p class="gh-setting-desc" style="margin-left: 56px; margin-top: -8px; margin-bottom: 16px;">Display a tags widget in the sidebar</p>
                                
                                <div style="margin-bottom: 16px;">
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Tags widget URL slug</label>
                                    <input type="text" id="tags_widget_slug" name="tags_widget_slug" 
                                           class="gh-input" 
                                           value="<cfoutput>#htmlEditFormat(designSettings.tags_widget_slug ?: '')#</cfoutput>"
                                           placeholder="/tag/">
                                </div>
                                
                                <div style="margin-bottom: 16px;">
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Special section tag</label>
                                    <input type="text" id="special_section_tag" name="special_section_tag" 
                                           class="gh-input" 
                                           value="<cfoutput>#htmlEditFormat(designSettings.special_section_tag ?: '')#</cfoutput>"
                                           placeholder="featured">
                                    <p class="gh-setting-desc" style="margin-top: 4px;">Posts with this tag will appear in a special section</p>
                                </div>
                                
                                <div style="margin-bottom: 16px;">
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Footer copyright</label>
                                    <input type="text" id="footer_copyright" name="footer_copyright" 
                                           class="gh-input" 
                                           value="<cfoutput>#htmlEditFormat(designSettings.footer_copyright ?: '')#</cfoutput>"
                                           placeholder="© 2024 Your Site">
                                </div>
                            </div>

                            <div class="gh-setting-group">
                                <label class="gh-setting-label">Code injection</label>
                                <p class="gh-setting-desc">Add custom code to your publication</p>
                                
                                <div style="margin-bottom: 16px;">
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Site header</label>
                                    <textarea id="codeinjection_head" 
                                              name="codeinjection_head" 
                                              class="gh-textarea" 
                                              rows="4"
                                              placeholder="<!-- Code injected into <head> -->"><cfoutput>#htmlEditFormat(designSettings.codeinjection_head ?: '')#</cfoutput></textarea>
                                </div>
                                
                                <div>
                                    <label class="gh-setting-label" style="font-size: 13px; margin-bottom: 6px;">Site footer</label>
                                    <textarea id="codeinjection_foot" 
                                              name="codeinjection_foot" 
                                              class="gh-textarea" 
                                              rows="4"
                                              placeholder="<!-- Code injected before </body> -->"><cfoutput>#htmlEditFormat(designSettings.codeinjection_foot ?: '')#</cfoutput></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Theme Tab Content -->
                    <div class="gh-tab-content" id="theme-tab">
                        <div class="gh-tabs-sticky">
                            <div class="gh-tabs" style="margin-top: -24px; padding-top: 24px;">
                                <div class="gh-tab active" data-tab="official">Official themes</div>
                                <div class="gh-tab" data-tab="installed">Installed</div>
                            </div>
                        </div>

                        <!-- Official Themes -->
                        <div class="gh-tab-content active" id="official-tab">
                            <div class="gh-themes-grid">
                                <!--- Default Theme Card --->
                                <div class="gh-theme-card" onclick="previewTheme('default')">
                                    <div class="gh-theme-preview">
                                        <cfif activeTheme EQ 'default'>
                                            <div class="gh-theme-active">Active</div>
                                        </cfif>
                                        <i class="ti ti-brush gh-theme-icon"></i>
                                    </div>
                                    <div class="gh-theme-info">
                                        <h4 class="gh-theme-name">Default</h4>
                                        <p class="gh-theme-category">Clean & minimal</p>
                                    </div>
                                </div>

                                <!--- Available themes from Ghost marketplace --->
                                <div class="gh-theme-card" onclick="window.open('https://ghost.org/themes/', '_blank')">
                                    <div class="gh-theme-preview" style="background: #15171a;">
                                        <i class="ti ti-external-link gh-theme-icon" style="color: #fff;"></i>
                                    </div>
                                    <div class="gh-theme-info">
                                        <h4 class="gh-theme-name">Browse marketplace</h4>
                                        <p class="gh-theme-category">Find more themes</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Installed Themes -->
                        <div class="gh-tab-content" id="installed-tab">
                            <!-- Upload Zone -->
                            <div class="gh-upload-zone" id="themeUploadZone">
                                <svg class="gh-upload-zone-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                                </svg>
                                <h3 class="gh-upload-zone-title">Upload a theme</h3>
                                <p class="gh-upload-zone-description">
                                    Drag & drop a Ghost theme zip file or click to browse
                                </p>
                                <form id="themeUploadForm" action="/ghost/admin/ajax/upload-theme.cfm" method="post" enctype="multipart/form-data">
                                    <input type="file" name="themeFile" id="themeFile" accept=".zip" style="display: none;">
                                    <button type="button" class="gh-btn gh-btn-primary" onclick="document.getElementById('themeFile').click()">
                                        <i class="ti ti-upload"></i>
                                        <span>Upload theme</span>
                                    </button>
                                </form>
                            </div>

                            <div class="gh-themes-list">
                                <!--- Default Theme --->
                                <div class="gh-theme-list-item">
                                    <div class="gh-theme-list-info">
                                        <div class="gh-theme-list-name">
                                            Default
                                            <cfif activeTheme EQ 'default'>
                                                <span class="active"> — Active</span>
                                            </cfif>
                                        </div>
                                        <div class="gh-theme-list-version">1.0.0</div>
                                    </div>
                                    <div class="gh-theme-list-actions">
                                        <cfif activeTheme NEQ 'default'>
                                            <button type="button" class="gh-btn-link" onclick="activateTheme('default')">
                                                Activate
                                            </button>
                                        </cfif>
                                    </div>
                                </div>

                                <!--- Installed Themes --->
                                <cfoutput query="qThemes">
                                    <cfif name NEQ "." AND name NEQ ".." AND name NEQ "default">
                                        <div class="gh-theme-list-item">
                                            <div class="gh-theme-list-info">
                                                <div class="gh-theme-list-name">
                                                    #name#
                                                    <cfif activeTheme EQ name>
                                                        <span class="active"> — Active</span>
                                                    </cfif>
                                                </div>
                                                <div class="gh-theme-list-version">1.0.0</div>
                                            </div>
                                            <div class="gh-theme-list-actions">
                                                <cfif activeTheme NEQ name>
                                                    <button type="button" class="gh-btn-link" onclick="activateTheme('#name#')">
                                                        Activate
                                                    </button>
                                                </cfif>
                                                <button type="button" class="gh-btn" onclick="if(confirm('Delete this theme?')) deleteTheme('#name#')">
                                                    <i class="ti ti-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </cfif>
                                </cfoutput>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

            <!-- Preview -->
            <div class="gh-design-preview">
                <div class="gh-preview-container">
                    <div class="gh-preview-browser">
                        <div class="gh-preview-browser-header">
                            <div class="gh-preview-browser-dot"></div>
                            <div class="gh-preview-browser-dot"></div>
                            <div class="gh-preview-browser-dot"></div>
                        </div>
                        <div class="gh-preview-browser-content">
                            <iframe id="preview-iframe" class="gh-preview-iframe" src="/ghost/blog/"></iframe>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
// Toast notification function
function showMessage(message, type) {
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
    
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.style.cssText = 'position: fixed; bottom: 1rem; right: 1rem; z-index: 9999; display: flex; flex-direction: column-reverse; gap: 0.5rem;';
        document.body.appendChild(container);
    }
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.remove('translate-x-full');
    }, 100);
    
    setTimeout(() => {
        toast.classList.add('translate-x-full');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 3000);
}

// Tab switching
document.querySelectorAll('.gh-tab').forEach(tab => {
    tab.addEventListener('click', function() {
        const parent = this.parentElement;
        const allTabs = parent.querySelectorAll('.gh-tab');
        const tabId = this.getAttribute('data-tab');
        
        // Remove active from all tabs in this group
        allTabs.forEach(t => t.classList.remove('active'));
        this.classList.add('active');
        
        // Handle main tabs (brand/theme)
        if (tabId === 'brand' || tabId === 'theme') {
            document.querySelectorAll('#brand-tab, #theme-tab').forEach(content => {
                content.classList.remove('active');
            });
            document.getElementById(tabId + '-tab').classList.add('active');
        }
        
        // Handle sub tabs (official/installed)
        if (tabId === 'official' || tabId === 'installed') {
            document.querySelectorAll('#official-tab, #installed-tab').forEach(content => {
                content.classList.remove('active');
            });
            document.getElementById(tabId + '-tab').classList.add('active');
        }
    });
});

// Color picker synchronization
document.getElementById('accent_color').addEventListener('input', function() {
    document.getElementById('accent_color_text').value = this.value;
    updatePreview();
});

document.getElementById('accent_color_text').addEventListener('input', function() {
    document.getElementById('accent_color').value = this.value;
    updatePreview();
});

// Update preview
function updatePreview() {
    const iframe = document.getElementById('preview-iframe');
    if (iframe && iframe.contentWindow) {
        iframe.contentWindow.location.reload();
    }
}

// Image upload
function uploadImage(type, input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        const formData = new FormData();
        formData.append('image', file);
        
        showMessage('Uploading ' + type + '...', 'info');
        
        fetch('/ghost/admin/ajax/upload-image.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById(type).value = data.url;
                const preview = document.getElementById(type + '-preview');
                const img = preview.querySelector('img');
                img.src = data.url;
                preview.style.display = 'block';
                showMessage(type.charAt(0).toUpperCase() + type.slice(1) + ' uploaded successfully', 'success');
                updatePreview();
            } else {
                showMessage(data.message || 'Failed to upload ' + type, 'error');
            }
        })
        .catch(error => {
            showMessage('Error uploading ' + type, 'error');
            console.error('Error:', error);
        });
    }
}

// Remove image
function removeImage(type) {
    if (confirm('Remove this ' + type + '?')) {
        document.getElementById(type).value = '';
        document.getElementById(type + '-preview').style.display = 'none';
        updatePreview();
    }
}

// Navigation management
let navigation = <cfoutput>#serializeJSON(deserializeJSON(designSettings.navigation ?: '[]'))#</cfoutput>;
let secondaryNavigation = <cfoutput>#serializeJSON(deserializeJSON(designSettings.secondary_navigation ?: '[]'))#</cfoutput>;

function renderNavigation(type) {
    const container = document.getElementById(type + '-navigation');
    const items = type === 'primary' ? navigation : secondaryNavigation;
    
    container.innerHTML = '';
    items.forEach((item, index) => {
        const div = document.createElement('div');
        div.className = 'gh-navigation-item';
        div.innerHTML = `
            <input type="text" class="gh-input" value="${item.label}" placeholder="Label" onchange="updateNavigationItem('${type}', ${index}, 'label', this.value)">
            <input type="text" class="gh-input" value="${item.url}" placeholder="URL" onchange="updateNavigationItem('${type}', ${index}, 'url', this.value)">
            <button type="button" onclick="removeNavigationItem('${type}', ${index})">
                <i class="ti ti-x"></i>
            </button>
        `;
        container.appendChild(div);
    });
}

function addNavigationItem(type) {
    const items = type === 'primary' ? navigation : secondaryNavigation;
    items.push({ label: '', url: '' });
    renderNavigation(type);
}

function updateNavigationItem(type, index, field, value) {
    const items = type === 'primary' ? navigation : secondaryNavigation;
    items[index][field] = value;
}

function removeNavigationItem(type, index) {
    const items = type === 'primary' ? navigation : secondaryNavigation;
    items.splice(index, 1);
    renderNavigation(type);
}

// Initial render
renderNavigation('primary');
renderNavigation('secondary');

// Typography preset handling
document.querySelectorAll('input[name="typography_preset"]').forEach(radio => {
    radio.addEventListener('change', function() {
        if (this.checked) {
            if (this.value === 'sans') {
                document.getElementById('heading_font').value = 'sans-serif';
                document.getElementById('body_font').value = 'sans-serif';
            } else if (this.value === 'serif') {
                document.getElementById('heading_font').value = 'serif';
                document.getElementById('body_font').value = 'serif';
            }
            updatePreview();
        }
    });
});

// Update radio buttons when dropdowns change
function updateTypographyPreset() {
    const headingFont = document.getElementById('heading_font').value;
    const bodyFont = document.getElementById('body_font').value;
    
    if (headingFont === 'sans-serif' && bodyFont === 'sans-serif') {
        document.getElementById('font-sans').checked = true;
    } else if (headingFont === 'serif' && bodyFont === 'serif') {
        document.getElementById('font-serif').checked = true;
    } else {
        // Uncheck all if custom combination
        document.querySelectorAll('input[name="typography_preset"]').forEach(radio => {
            radio.checked = false;
        });
    }
}

document.getElementById('heading_font').addEventListener('change', updateTypographyPreset);
document.getElementById('body_font').addEventListener('change', updateTypographyPreset);

// Theme functions
function activateTheme(themeName) {
    showMessage('Activating theme...', 'info');
    
    fetch('/ghost/admin/ajax/activate-theme.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            themeName: themeName
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Theme activated successfully!', 'success');
            setTimeout(() => {
                location.reload();
            }, 1500);
        } else {
            showMessage(data.message || 'Failed to activate theme', 'error');
        }
    })
    .catch(error => {
        showMessage('An error occurred while activating the theme', 'error');
        console.error('Activation error:', error);
    });
}

function deleteTheme(themeName) {
    fetch('/ghost/admin/ajax/delete-theme.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            themeName: themeName
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Theme deleted successfully!', 'success');
            setTimeout(() => {
                location.reload();
            }, 1500);
        } else {
            showMessage(data.message || 'Failed to delete theme', 'error');
        }
    })
    .catch(error => {
        showMessage('An error occurred while deleting the theme', 'error');
        console.error('Delete error:', error);
    });
}

function previewTheme(themeName) {
    // In a real implementation, this would change the preview
    showMessage('Theme preview: ' + themeName, 'info');
}

// Theme upload
document.addEventListener('DOMContentLoaded', function() {
    const uploadZone = document.getElementById('themeUploadZone');
    const fileInput = document.getElementById('themeFile');
    const uploadForm = document.getElementById('themeUploadForm');

    // Drag and drop
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        uploadZone.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        uploadZone.addEventListener(eventName, () => {
            uploadZone.classList.add('dragover');
        }, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        uploadZone.addEventListener(eventName, () => {
            uploadZone.classList.remove('dragover');
        }, false);
    });

    uploadZone.addEventListener('drop', handleDrop, false);

    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        
        if (files.length > 0 && files[0].name.endsWith('.zip')) {
            fileInput.files = files;
            uploadTheme();
        } else {
            showMessage('Please upload a valid theme zip file', 'error');
        }
    }

    fileInput.addEventListener('change', function() {
        if (this.files.length > 0) {
            uploadTheme();
        }
    });

    function uploadTheme() {
        const formData = new FormData(uploadForm);
        
        showMessage('Uploading theme...', 'info');
        
        fetch(uploadForm.action, {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showMessage('Theme uploaded successfully!', 'success');
                setTimeout(() => {
                    location.reload();
                }, 1500);
            } else {
                showMessage(data.message || 'Failed to upload theme', 'error');
            }
        })
        .catch(error => {
            showMessage('An error occurred while uploading the theme', 'error');
            console.error('Upload error:', error);
        });
    }
});

// Save settings
function saveSettings() {
    const button = document.getElementById('saveButton');
    const buttonText = button.querySelector('span');
    button.disabled = true;
    buttonText.textContent = 'Saving...';
    
    const settings = {
        // Branding
        accent_color: document.getElementById('accent_color').value,
        icon: document.getElementById('icon').value,
        logo: document.getElementById('logo').value,
        cover_image: document.getElementById('cover_image').value,
        logo_dark: document.getElementById('logo_dark').value,
        
        // Typography
        heading_font: document.getElementById('heading_font').value,
        body_font: document.getElementById('body_font').value,
        
        // Site Wide
        color_scheme: document.getElementById('color_scheme').value,
        
        // Navigation
        navigation: JSON.stringify(navigation),
        secondary_navigation: JSON.stringify(secondaryNavigation),
        
        // Site Features
        show_author: document.getElementById('show_author').checked ? 'true' : 'false',
        standard_load_more: document.getElementById('standard_load_more').checked ? 'true' : 'false',
        navigation_right: document.getElementById('navigation_right').checked ? 'true' : 'false',
        show_authors_widget: document.getElementById('show_authors_widget').checked ? 'true' : 'false',
        show_tags_widget: document.getElementById('show_tags_widget').checked ? 'true' : 'false',
        tags_widget_slug: document.getElementById('tags_widget_slug').value,
        special_section_tag: document.getElementById('special_section_tag').value,
        footer_copyright: document.getElementById('footer_copyright').value,
        
        // Code injection
        codeinjection_head: document.getElementById('codeinjection_head').value,
        codeinjection_foot: document.getElementById('codeinjection_foot').value
    };
    
    fetch('/ghost/admin/ajax/save-settings.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(settings)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Settings saved successfully', 'success');
            updatePreview();
        } else {
            showMessage(data.message || 'Failed to save settings', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('An error occurred while saving settings', 'error');
    })
    .finally(() => {
        button.disabled = false;
        buttonText.textContent = 'Save';
    });
}
</script>

<cfinclude template="includes/footer.cfm">