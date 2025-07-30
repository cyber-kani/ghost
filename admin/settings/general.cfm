<cfparam name="request.dsn" default="blog">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Get current settings --->
<cfquery name="getSettings" datasource="#request.dsn#">
    SELECT `key` as settingKey, `value` as settingValue, type 
    FROM settings
    WHERE `key` IN (
        'title', 'description', 'timezone', 'locale',
        'facebook', 'twitter',
        'meta_title', 'meta_description', 'og_image', 'og_title', 
        'og_description', 'twitter_image', 'twitter_title', 'twitter_description',
        'posts_per_page', 'google_analytics', 'enable_comments', 'is_private', 'password',
        'staff_display_name', 'show_headline'
    )
</cfquery>

<!--- Convert to struct for easy access --->
<cfset settings = {}>
<cfloop query="getSettings">
    <cfset settings[getSettings.settingKey] = getSettings.settingValue>
</cfloop>

<!--- Set defaults if not exist --->
<cfparam name="settings.title" default="Ghost CMS">
<cfparam name="settings.description" default="Thoughts, stories and ideas">
<cfparam name="settings.timezone" default="UTC">
<cfparam name="settings.locale" default="en">
<cfparam name="settings.facebook" default="">
<cfparam name="settings.twitter" default="">
<cfparam name="settings.meta_title" default="">
<cfparam name="settings.meta_description" default="">
<cfparam name="settings.og_image" default="">
<cfparam name="settings.og_title" default="">
<cfparam name="settings.og_description" default="">
<cfparam name="settings.twitter_image" default="">
<cfparam name="settings.twitter_title" default="">
<cfparam name="settings.twitter_description" default="">
<cfparam name="settings.posts_per_page" default="10">
<cfparam name="settings.google_analytics" default="">
<cfparam name="settings.enable_comments" default="false">
<cfparam name="settings.is_private" default="false">
<cfparam name="settings.password" default="">
<cfparam name="settings.staff_display_name" default="true">
<cfparam name="settings.show_headline" default="true">

<cfset pageTitle = "General Settings">
<cfinclude template="../includes/header.cfm">

<style>
/* Ghost-style settings UI */
.settings-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

.settings-section {
    background: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    margin-bottom: 2rem;
    overflow: hidden;
    transition: all 0.3s ease;
}

.settings-section:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.12);
}

.settings-header {
    padding: 1.5rem 2rem;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
}

.settings-header h3 {
    margin: 0;
    font-size: 1.125rem;
    font-weight: 600;
    color: #15171a;
}

.settings-header p {
    margin: 0.25rem 0 0 0;
    font-size: 0.875rem;
    color: #6b7280;
}

.settings-content {
    padding: 2rem;
    display: none;
}

.settings-content.active {
    display: block;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
}

.form-group input[type="text"],
.form-group input[type="email"],
.form-group input[type="url"],
.form-group textarea,
.form-group select {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    transition: all 0.2s ease;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-group .hint {
    margin-top: 0.25rem;
    font-size: 0.75rem;
    color: #6b7280;
}

.form-group .char-count {
    text-align: right;
    font-size: 0.75rem;
    color: #9ca3af;
    margin-top: 0.25rem;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
}

.btn-save {
    background-color: #15171a;
    color: white;
    padding: 0.5rem 1rem;
    border: none;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-save:hover {
    background-color: #000;
    transform: translateY(-1px);
}

.btn-save:disabled {
    background-color: #9ca3af;
    cursor: not-allowed;
    transform: none;
}

.settings-actions {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.edit-toggle {
    background: none;
    border: none;
    color: #3b82f6;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: color 0.2s ease;
}

.edit-toggle:hover {
    color: #2563eb;
}

.color-input-wrapper {
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.color-input-wrapper input[type="color"] {
    width: 40px;
    height: 40px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    cursor: pointer;
}

.success-message {
    position: fixed;
    top: 2rem;
    right: 2rem;
    background-color: #10b981;
    color: white;
    padding: 1rem 1.5rem;
    border-radius: 6px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    z-index: 1000;
    animation: slideIn 0.3s ease-out;
}

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

@keyframes slideInRight {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes slideOutRight {
    from {
        transform: translateX(0);
        opacity: 1;
    }
    to {
        transform: translateX(100%);
        opacity: 0;
    }
}

.timezone-hint {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-top: 0.5rem;
    padding: 0.75rem;
    background-color: #f3f4f6;
    border-radius: 6px;
    font-size: 0.875rem;
    color: #4b5563;
}

.timezone-hint i {
    color: #3b82f6;
}

.upload-area {
    border: 2px dashed #d1d5db;
    border-radius: 8px;
    padding: 2rem;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s ease;
}

.upload-area:hover {
    border-color: #3b82f6;
    background-color: #f9fafb;
}

.upload-area.has-image {
    padding: 0;
    border: none;
}

.upload-area img {
    max-width: 200px;
    height: auto;
    border-radius: 8px;
}

.remove-image {
    margin-top: 0.5rem;
    color: #ef4444;
    font-size: 0.875rem;
    cursor: pointer;
}

.remove-image:hover {
    text-decoration: underline;
}

/* Toggle switch styles */
.toggle-label {
    display: flex;
    align-items: center;
    cursor: pointer;
    user-select: none;
}

.toggle-label input[type="checkbox"] {
    display: none;
}

.toggle-switch {
    position: relative;
    display: inline-block;
    width: 44px;
    height: 24px;
    background-color: #e5e7eb;
    border-radius: 12px;
    margin-right: 0.75rem;
    transition: background-color 0.2s ease;
}

.toggle-switch::after {
    content: '';
    position: absolute;
    top: 2px;
    left: 2px;
    width: 20px;
    height: 20px;
    background-color: white;
    border-radius: 50%;
    transition: transform 0.2s ease;
    box-shadow: 0 2px 4px rgba(0,0,0,0.15);
}

.toggle-label input[type="checkbox"]:checked + .toggle-switch {
    background-color: #10b981;
}

.toggle-label input[type="checkbox"]:checked + .toggle-switch::after {
    transform: translateX(20px);
}

.toggle-label input[type="checkbox"]:disabled + .toggle-switch {
    opacity: 0.6;
    cursor: not-allowed;
}

.toggle-label span:last-child {
    font-size: 0.875rem;
    color: #374151;
}

/* Preview Sections */
.preview-section {
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 1px solid #e5e7eb;
}

.preview-section h4 {
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
    margin-bottom: 0.75rem;
}

/* Search Engine Preview */
.search-preview {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 1rem;
    font-family: arial, sans-serif;
}

.preview-url {
    color: #202124;
    font-size: 14px;
    line-height: 1.3;
    margin-bottom: 3px;
}

.preview-title {
    color: #1a0dab;
    font-size: 20px;
    line-height: 1.3;
    margin-bottom: 3px;
    cursor: pointer;
    text-decoration: none;
}

.preview-title:hover {
    text-decoration: underline;
}

.preview-description {
    color: #545454;
    font-size: 14px;
    line-height: 1.58;
}

/* Social Media Previews */
.social-preview {
    background: #f0f2f5;
    border-radius: 8px;
    overflow: hidden;
    max-width: 500px;
}

.social-preview-image {
    width: 100%;
    height: 260px;
    background: #e5e7eb;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9ca3af;
    font-size: 14px;
}

.social-preview-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.social-preview-content {
    padding: 12px;
    background: white;
    border: 1px solid #dadde1;
    border-top: none;
}

.social-preview-domain {
    color: #65676b;
    font-size: 12px;
    text-transform: uppercase;
    margin-bottom: 2px;
}

.social-preview-title {
    color: #050505;
    font-size: 16px;
    font-weight: 600;
    line-height: 1.2;
    margin-bottom: 4px;
}

.social-preview-description {
    color: #65676b;
    font-size: 14px;
    line-height: 1.4;
}

/* X (Twitter) Preview */
.x-preview {
    background: white;
    border: 1px solid #cfd9de;
    border-radius: 16px;
    overflow: hidden;
    max-width: 500px;
}

.x-preview-image {
    width: 100%;
    height: 250px;
    background: #f7f9fa;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #536471;
    font-size: 14px;
}

.x-preview-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.x-preview-content {
    padding: 12px;
}

.x-preview-domain {
    color: #536471;
    font-size: 13px;
    margin-bottom: 2px;
}

.x-preview-title {
    color: #0f1419;
    font-size: 15px;
    font-weight: 700;
    line-height: 1.2;
    margin-bottom: 2px;
}

.x-preview-description {
    color: #536471;
    font-size: 15px;
    line-height: 1.3;
}
</style>

<div class="container-fluid">
    <div class="settings-container">
        <div class="mb-6">
            <h1 class="text-2xl font-bold text-gray-900">General Settings</h1>
            <p class="text-gray-600 mt-2">Basic settings for your publication</p>
        </div>

        <!-- Settings Navigation -->
        <div class="settings-navigation mb-6">
            <nav class="flex space-x-8 border-b border-gray-200">
                <a href="/ghost/admin/settings/general" class="pb-3 px-1 border-b-2 border-primary font-medium text-sm text-primary">
                    General
                </a>
                <a href="/ghost/admin/settings/security" class="pb-3 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                    Security
                </a>
                <a href="/ghost/admin/settings/mail" class="pb-3 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                    Mail
                </a>
            </nav>
        </div>

        <!-- Title & Description Section -->
        <div class="settings-section" id="title-section">
            <div class="settings-header" onclick="toggleSection('title')">
                <div>
                    <h3>Title & description</h3>
                    <p>The details used to identify your publication around the web</p>
                </div>
                <div class="settings-actions">
                    <button type="button" class="edit-toggle" onclick="toggleEdit(event, 'title')">
                        <i class="ti ti-edit mr-1"></i>Edit
                    </button>
                </div>
            </div>
            <div class="settings-content" id="title-content">
                <form id="title-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="site-title">Site title</label>
                            <input type="text" id="site-title" name="title" value="<cfoutput>#settings.title#</cfoutput>" maxlength="150" disabled>
                            <div class="hint">The name of your site</div>
                            <div class="char-count"><span id="title-count">0</span> / 150</div>
                        </div>
                        <div class="form-group">
                            <label for="site-description">Site description</label>
                            <input type="text" id="site-description" name="description" value="<cfoutput>#settings.description#</cfoutput>" maxlength="200" disabled>
                            <div class="hint">A short description, used in your theme, meta data and search results</div>
                            <div class="char-count"><span id="description-count">0</span> / 200</div>
                        </div>
                    </div>
                    <div class="mt-4" style="display: none;" id="title-actions">
                        <button type="button" class="btn-save" onclick="saveSettings('title')">Save</button>
                        <button type="button" class="edit-toggle ml-2" onclick="cancelEdit('title')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Site timezone Section -->
        <div class="settings-section" id="timezone-section">
            <div class="settings-header" onclick="toggleSection('timezone')">
                <div>
                    <h3>Site timezone</h3>
                    <p>Set the time and date of your publication, used for all published posts</p>
                </div>
            </div>
            <div class="settings-content" id="timezone-content">
                <form id="timezone-form">
                    <div class="form-group">
                        <label for="site-timezone">Site timezone</label>
                        <select id="site-timezone" name="timezone" class="form-control">
                            <cfinclude template="../includes/timezone-options.cfm">
                        </select>
                        <div class="timezone-hint">
                            <i class="ti ti-clock"></i>
                            <span>The local time here is currently <span id="local-time"></span></span>
                        </div>
                    </div>
                    <div class="mt-4">
                        <button type="button" class="btn-save" onclick="saveSettings('timezone')">Save</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Publication language Section -->
        <div class="settings-section" id="language-section">
            <div class="settings-header" onclick="toggleSection('language')">
                <div>
                    <h3>Publication language</h3>
                    <p>Set the language/locale which is used on your site</p>
                </div>
            </div>
            <div class="settings-content" id="language-content">
                <form id="language-form">
                    <div class="form-group">
                        <label for="site-locale">Site language</label>
                        <select id="site-locale" name="locale" class="form-control">
                            <option value="en" <cfif settings.locale EQ "en">selected</cfif>>English (en)</option>
                            <option value="es" <cfif settings.locale EQ "es">selected</cfif>>Spanish (es)</option>
                            <option value="fr" <cfif settings.locale EQ "fr">selected</cfif>>French (fr)</option>
                            <option value="de" <cfif settings.locale EQ "de">selected</cfif>>German (de)</option>
                            <option value="it" <cfif settings.locale EQ "it">selected</cfif>>Italian (it)</option>
                            <option value="pt" <cfif settings.locale EQ "pt">selected</cfif>>Portuguese (pt)</option>
                            <option value="nl" <cfif settings.locale EQ "nl">selected</cfif>>Dutch (nl)</option>
                            <option value="tr" <cfif settings.locale EQ "tr">selected</cfif>>Turkish (tr)</option>
                            <option value="ja" <cfif settings.locale EQ "ja">selected</cfif>>Japanese (ja)</option>
                            <option value="zh" <cfif settings.locale EQ "zh">selected</cfif>>Chinese (zh)</option>
                        </select>
                        <div class="hint">Default: English (en)</div>
                    </div>
                    <div class="mt-4">
                        <button type="button" class="btn-save" onclick="saveSettings('language')">Save</button>
                    </div>
                </form>
            </div>
        </div>


        <!-- Meta data Section -->
        <div class="settings-section" id="metadata-section">
            <div class="settings-header" onclick="toggleSection('metadata')">
                <div>
                    <h3>Meta data</h3>
                    <p>Extra content for search engines</p>
                </div>
                <div class="settings-actions">
                    <button type="button" class="edit-toggle" onclick="toggleEdit(event, 'metadata')">
                        <i class="ti ti-edit mr-1"></i>Edit
                    </button>
                </div>
            </div>
            <div class="settings-content" id="metadata-content">
                <form id="metadata-form">
                    <div class="form-group">
                        <label for="meta-title">Meta title</label>
                        <input type="text" id="meta-title" name="meta_title" value="<cfoutput>#settings.meta_title#</cfoutput>" maxlength="70" disabled>
                        <div class="hint">Recommended: 70 characters</div>
                        <div class="char-count"><span id="meta-title-count">0</span> / 70</div>
                    </div>
                    <div class="form-group">
                        <label for="meta-description">Meta description</label>
                        <textarea id="meta-description" name="meta_description" rows="3" maxlength="156" disabled><cfoutput>#settings.meta_description#</cfoutput></textarea>
                        <div class="hint">Recommended: 156 characters</div>
                        <div class="char-count"><span id="meta-description-count">0</span> / 156</div>
                    </div>
                    
                    <!-- Search Engine Preview -->
                    <div class="preview-section mt-6">
                        <h4 class="text-sm font-semibold text-gray-700 mb-3">Search engine preview</h4>
                        <div class="search-preview">
                            <div class="preview-url">
                                <cfoutput>#cgi.server_name#</cfoutput> › ghost
                            </div>
                            <div class="preview-title" id="search-preview-title">
                                <cfoutput>#len(settings.meta_title) ? settings.meta_title : settings.title#</cfoutput>
                            </div>
                            <div class="preview-description" id="search-preview-description">
                                <cfoutput>#len(settings.meta_description) ? settings.meta_description : settings.description#</cfoutput>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mt-4" style="display: none;" id="metadata-actions">
                        <button type="button" class="btn-save" onclick="saveSettings('metadata')">Save</button>
                        <button type="button" class="edit-toggle ml-2" onclick="cancelEdit('metadata')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Social accounts Section -->
        <div class="settings-section" id="social-section">
            <div class="settings-header" onclick="toggleSection('social')">
                <div>
                    <h3>Social accounts</h3>
                    <p>Link your social accounts for full structured data and rich card support</p>
                </div>
                <div class="settings-actions">
                    <button type="button" class="edit-toggle" onclick="toggleEdit(event, 'social')">
                        <i class="ti ti-edit mr-1"></i>Edit
                    </button>
                </div>
            </div>
            <div class="settings-content" id="social-content">
                <form id="social-form">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="facebook-page">Facebook Page</label>
                            <input type="url" id="facebook-page" name="facebook" placeholder="https://www.facebook.com/ghost" value="<cfoutput>#settings.facebook#</cfoutput>" disabled>
                            <div class="hint">URL of your publication's Facebook Page</div>
                        </div>
                        <div class="form-group">
                            <label for="twitter-profile">X (Twitter) profile</label>
                            <input type="text" id="twitter-profile" name="twitter" placeholder="@ghost" value="<cfoutput>#settings.twitter#</cfoutput>" disabled>
                            <div class="hint">URL of your publication's X (formerly Twitter) profile</div>
                        </div>
                    </div>
                    <div class="mt-4" style="display: none;" id="social-actions">
                        <button type="button" class="btn-save" onclick="saveSettings('social')">Save</button>
                        <button type="button" class="edit-toggle ml-2" onclick="cancelEdit('social')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- X card Section -->
        <div class="settings-section" id="twitter-card-section">
            <div class="settings-header" onclick="toggleSection('twitter-card')">
                <div>
                    <h3>X card</h3>
                    <p>Customize Open Graph data for X (formerly Twitter)</p>
                </div>
                <div class="settings-actions">
                    <button type="button" class="edit-toggle" onclick="toggleEdit(event, 'twitter-card')">
                        <i class="ti ti-edit mr-1"></i>Edit
                    </button>
                </div>
            </div>
            <div class="settings-content" id="twitter-card-content">
                <form id="twitter-card-form">
                    <div class="form-group">
                        <label for="twitter-title">X title</label>
                        <input type="text" id="twitter-title" name="twitter_title" value="<cfoutput>#settings.twitter_title#</cfoutput>" disabled>
                        <div class="hint">Title for X sharing</div>
                    </div>
                    <div class="form-group">
                        <label for="twitter-description">X description</label>
                        <textarea id="twitter-description" name="twitter_description" rows="3" disabled><cfoutput>#settings.twitter_description#</cfoutput></textarea>
                        <div class="hint">Description for X sharing</div>
                    </div>
                    <div class="form-group">
                        <label for="twitter-image">X image</label>
                        <input type="url" id="twitter-image" name="twitter_image" placeholder="https://example.com/image.jpg" value="<cfoutput>#settings.twitter_image#</cfoutput>" disabled>
                        <div class="hint">Image URL for X sharing</div>
                    </div>
                    
                    <!-- X Preview -->
                    <div class="preview-section">
                        <h4 class="text-sm font-semibold text-gray-700 mb-3">X (Twitter) preview</h4>
                        <div class="x-preview">
                            <div class="x-preview-image" id="x-preview-image">
                                <cfif len(settings.twitter_image)>
                                    <img src="<cfoutput>#settings.twitter_image#</cfoutput>" alt="X preview">
                                <cfelse>
                                    <span>No image set</span>
                                </cfif>
                            </div>
                            <div class="x-preview-content">
                                <div class="x-preview-domain"><cfoutput>#cgi.server_name#</cfoutput></div>
                                <div class="x-preview-title" id="x-preview-title">
                                    <cfoutput>#len(settings.twitter_title) ? settings.twitter_title : (len(settings.meta_title) ? settings.meta_title : settings.title)#</cfoutput>
                                </div>
                                <div class="x-preview-description" id="x-preview-description">
                                    <cfoutput>#len(settings.twitter_description) ? settings.twitter_description : (len(settings.meta_description) ? settings.meta_description : settings.description)#</cfoutput>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mt-4" style="display: none;" id="twitter-card-actions">
                        <button type="button" class="btn-save" onclick="saveSettings('twitter-card')">Save</button>
                        <button type="button" class="edit-toggle ml-2" onclick="cancelEdit('twitter-card')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Facebook card Section -->
        <div class="settings-section" id="facebook-card-section">
            <div class="settings-header" onclick="toggleSection('facebook-card')">
                <div>
                    <h3>Facebook card</h3>
                    <p>Customize Open Graph data for Facebook</p>
                </div>
                <div class="settings-actions">
                    <button type="button" class="edit-toggle" onclick="toggleEdit(event, 'facebook-card')">
                        <i class="ti ti-edit mr-1"></i>Edit
                    </button>
                </div>
            </div>
            <div class="settings-content" id="facebook-card-content">
                <form id="facebook-card-form">
                    <div class="form-group">
                        <label for="og-title">Facebook title</label>
                        <input type="text" id="og-title" name="og_title" value="<cfoutput>#settings.og_title#</cfoutput>" disabled>
                        <div class="hint">Title for Facebook sharing</div>
                    </div>
                    <div class="form-group">
                        <label for="og-description">Facebook description</label>
                        <textarea id="og-description" name="og_description" rows="3" disabled><cfoutput>#settings.og_description#</cfoutput></textarea>
                        <div class="hint">Description for Facebook sharing</div>
                    </div>
                    <div class="form-group">
                        <label for="og-image">Facebook image</label>
                        <input type="url" id="og-image" name="og_image" placeholder="https://example.com/image.jpg" value="<cfoutput>#settings.og_image#</cfoutput>" disabled>
                        <div class="hint">Image URL for Facebook sharing</div>
                    </div>
                    
                    <!-- Facebook Preview -->
                    <div class="preview-section">
                        <h4 class="text-sm font-semibold text-gray-700 mb-3">Facebook preview</h4>
                        <div class="social-preview">
                            <div class="social-preview-image" id="fb-preview-image">
                                <cfif len(settings.og_image)>
                                    <img src="<cfoutput>#settings.og_image#</cfoutput>" alt="Facebook preview">
                                <cfelse>
                                    <span>No image set</span>
                                </cfif>
                            </div>
                            <div class="social-preview-content">
                                <div class="social-preview-domain"><cfoutput>#cgi.server_name#</cfoutput></div>
                                <div class="social-preview-title" id="fb-preview-title">
                                    <cfoutput>#len(settings.og_title) ? settings.og_title : (len(settings.meta_title) ? settings.meta_title : settings.title)#</cfoutput>
                                </div>
                                <div class="social-preview-description" id="fb-preview-description">
                                    <cfoutput>#len(settings.og_description) ? settings.og_description : (len(settings.meta_description) ? settings.meta_description : settings.description)#</cfoutput>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mt-4" style="display: none;" id="facebook-card-actions">
                        <button type="button" class="btn-save" onclick="saveSettings('facebook-card')">Save</button>
                        <button type="button" class="edit-toggle ml-2" onclick="cancelEdit('facebook-card')">Cancel</button>
                    </div>
                </form>
            </div>
        </div>


    </div>
</div>

<script>
// Toggle section visibility
function toggleSection(section) {
    const content = document.getElementById(section + '-content');
    const isActive = content.classList.contains('active');
    
    // Close all sections
    document.querySelectorAll('.settings-content').forEach(el => {
        el.classList.remove('active');
    });
    
    // Open clicked section if it was closed
    if (!isActive) {
        content.classList.add('active');
    }
}

// Toggle edit mode
function toggleEdit(event, section) {
    event.stopPropagation();
    const form = document.getElementById(section + '-form');
    const inputs = form.querySelectorAll('input, textarea, select');
    const actions = document.getElementById(section + '-actions');
    
    inputs.forEach(input => {
        if (input.type !== 'hidden') {
            input.disabled = false;
        }
    });
    
    actions.style.display = 'block';
}

// Cancel edit mode
function cancelEdit(section) {
    const form = document.getElementById(section + '-form');
    const inputs = form.querySelectorAll('input, textarea, select');
    const actions = document.getElementById(section + '-actions');
    
    // Reset form
    form.reset();
    
    inputs.forEach(input => {
        if (input.type !== 'hidden') {
            input.disabled = true;
        }
    });
    
    actions.style.display = 'none';
}

// Character counter
document.addEventListener('DOMContentLoaded', function() {
    // Update character counts
    updateCharCount('site-title', 'title-count');
    updateCharCount('site-description', 'description-count');
    updateCharCount('meta-title', 'meta-title-count');
    updateCharCount('meta-description', 'meta-description-count');
    
    // Open the title section by default
    const titleSection = document.getElementById('title-content');
    if (titleSection) {
        titleSection.classList.add('active');
    }
    
    // Add input listeners
    ['site-title', 'site-description', 'meta-title', 'meta-description'].forEach(id => {
        const input = document.getElementById(id);
        if (input) {
            input.addEventListener('input', function() {
                updateCharCount(id, id.replace('site-', '').replace('-', '-') + '-count');
            });
        }
    });
    
    // Color picker sync (removed as branding is now in design section)
    
    // Live preview updates
    setupLivePreview();
    
    // Update timezone
    updateLocalTime();
    setInterval(updateLocalTime, 1000);
});

// Setup live preview updates
function setupLivePreview() {
    // Meta title updates
    const metaTitleInput = document.getElementById('meta-title');
    const titleInput = document.getElementById('site-title');
    
    if (metaTitleInput) {
        metaTitleInput.addEventListener('input', function() {
            updateSearchPreview();
            updateSocialPreviews();
        });
    }
    
    if (titleInput) {
        titleInput.addEventListener('input', function() {
            updateSearchPreview();
            updateSocialPreviews();
        });
    }
    
    // Meta description updates
    const metaDescInput = document.getElementById('meta-description');
    const descInput = document.getElementById('site-description');
    
    if (metaDescInput) {
        metaDescInput.addEventListener('input', function() {
            updateSearchPreview();
            updateSocialPreviews();
        });
    }
    
    if (descInput) {
        descInput.addEventListener('input', function() {
            updateSearchPreview();
            updateSocialPreviews();
        });
    }
    
    // X (Twitter) specific fields
    const twitterTitle = document.getElementById('twitter-title');
    const twitterDesc = document.getElementById('twitter-description');
    const twitterImage = document.getElementById('twitter-image');
    
    if (twitterTitle) {
        twitterTitle.addEventListener('input', updateXPreview);
    }
    if (twitterDesc) {
        twitterDesc.addEventListener('input', updateXPreview);
    }
    if (twitterImage) {
        twitterImage.addEventListener('input', updateXPreview);
    }
    
    // Facebook specific fields
    const fbTitle = document.getElementById('og-title');
    const fbDesc = document.getElementById('og-description');
    const fbImage = document.getElementById('og-image');
    
    if (fbTitle) {
        fbTitle.addEventListener('input', updateFacebookPreview);
    }
    if (fbDesc) {
        fbDesc.addEventListener('input', updateFacebookPreview);
    }
    if (fbImage) {
        fbImage.addEventListener('input', updateFacebookPreview);
    }
}

// Update search engine preview
function updateSearchPreview() {
    const titleEl = document.getElementById('search-preview-title');
    const descEl = document.getElementById('search-preview-description');
    
    if (titleEl) {
        const metaTitle = document.getElementById('meta-title')?.value || '';
        const siteTitle = document.getElementById('site-title')?.value || '';
        titleEl.textContent = metaTitle || siteTitle || 'Untitled';
    }
    
    if (descEl) {
        const metaDesc = document.getElementById('meta-description')?.value || '';
        const siteDesc = document.getElementById('site-description')?.value || '';
        descEl.textContent = metaDesc || siteDesc || 'No description';
    }
}

// Update X preview
function updateXPreview() {
    const titleEl = document.getElementById('x-preview-title');
    const descEl = document.getElementById('x-preview-description');
    const imageEl = document.getElementById('x-preview-image');
    
    if (titleEl) {
        const xTitle = document.getElementById('twitter-title')?.value || '';
        const metaTitle = document.getElementById('meta-title')?.value || '';
        const siteTitle = document.getElementById('site-title')?.value || '';
        titleEl.textContent = xTitle || metaTitle || siteTitle || 'Untitled';
    }
    
    if (descEl) {
        const xDesc = document.getElementById('twitter-description')?.value || '';
        const metaDesc = document.getElementById('meta-description')?.value || '';
        const siteDesc = document.getElementById('site-description')?.value || '';
        descEl.textContent = xDesc || metaDesc || siteDesc || 'No description';
    }
    
    if (imageEl) {
        const xImage = document.getElementById('twitter-image')?.value || '';
        if (xImage) {
            imageEl.innerHTML = `<img src="${xImage}" alt="X preview" onerror="this.parentElement.innerHTML='<span>Invalid image URL</span>'">`;
        } else {
            imageEl.innerHTML = '<span>No image set</span>';
        }
    }
}

// Update Facebook preview
function updateFacebookPreview() {
    const titleEl = document.getElementById('fb-preview-title');
    const descEl = document.getElementById('fb-preview-description');
    const imageEl = document.getElementById('fb-preview-image');
    
    if (titleEl) {
        const fbTitle = document.getElementById('og-title')?.value || '';
        const metaTitle = document.getElementById('meta-title')?.value || '';
        const siteTitle = document.getElementById('site-title')?.value || '';
        titleEl.textContent = fbTitle || metaTitle || siteTitle || 'Untitled';
    }
    
    if (descEl) {
        const fbDesc = document.getElementById('og-description')?.value || '';
        const metaDesc = document.getElementById('meta-description')?.value || '';
        const siteDesc = document.getElementById('site-description')?.value || '';
        descEl.textContent = fbDesc || metaDesc || siteDesc || 'No description';
    }
    
    if (imageEl) {
        const fbImage = document.getElementById('og-image')?.value || '';
        if (fbImage) {
            imageEl.innerHTML = `<img src="${fbImage}" alt="Facebook preview" onerror="this.parentElement.innerHTML='<span>Invalid image URL</span>'">`;
        } else {
            imageEl.innerHTML = '<span>No image set</span>';
        }
    }
}

// Update all social previews
function updateSocialPreviews() {
    updateXPreview();
    updateFacebookPreview();
}

function updateCharCount(inputId, countId) {
    const input = document.getElementById(inputId);
    const count = document.getElementById(countId);
    if (input && count) {
        count.textContent = input.value.length;
    }
}

function updateLocalTime() {
    const timezone = document.getElementById('site-timezone').value;
    const now = new Date();
    const options = {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: true
    };
    
    try {
        const localTime = now.toLocaleString('en-US', { ...options, timeZone: timezone });
        document.getElementById('local-time').textContent = localTime;
    } catch (e) {
        document.getElementById('local-time').textContent = now.toLocaleString('en-US', options);
    }
}

// Save settings via AJAX
function saveSettings(section) {
    const form = document.getElementById(section + '-form');
    const formData = new FormData(form);
    
    // Handle checkboxes that aren't checked (they don't get sent by default)
    form.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
        if (!checkbox.checked) {
            formData.append(checkbox.name, 'false');
        }
    });
    
    // Show loading state
    const btn = form.querySelector('.btn-save');
    const originalText = btn.textContent;
    btn.textContent = 'Saving...';
    btn.disabled = true;
    
    fetch('/ghost/admin/ajax/save-settings.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Settings saved successfully', 'success');
            
            // Disable inputs again
            form.querySelectorAll('input, textarea, select').forEach(input => {
                if (input.type !== 'hidden') {
                    input.disabled = true;
                }
            });
            
            // Hide actions
            document.getElementById(section + '-actions').style.display = 'none';
        } else {
            showMessage(data.message || 'Failed to save settings', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('Failed to save settings', 'error');
    })
    .finally(() => {
        btn.textContent = originalText;
        btn.disabled = false;
    });
}

// Image upload
function uploadImage(type) {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (file) {
            const formData = new FormData();
            formData.append('image', file);
            formData.append('type', type);
            
            fetch('/ghost/admin/ajax/upload-settings-image.cfm', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update UI
                    const uploadArea = document.getElementById(type + '-upload');
                    uploadArea.innerHTML = `
                        <div class="has-image">
                            <img src="${data.url}" alt="${type}">
                            <div class="remove-image" onclick="removeImage(event, '${type}')">Remove</div>
                        </div>
                    `;
                    
                    // Update hidden input
                    document.getElementById(type + '-input').value = data.url;
                    
                    showMessage('Image uploaded successfully', 'success');
                } else {
                    showMessage(data.message || 'Failed to upload image', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showMessage('Failed to upload image', 'error');
            });
        }
    };
    
    input.click();
}

// Remove image
function removeImage(event, type) {
    event.stopPropagation();
    
    const uploadArea = document.getElementById(type + '-upload');
    uploadArea.innerHTML = `
        <i class="ti ti-upload text-3xl text-gray-400"></i>
        <p class="mt-2 text-sm text-gray-600">Click to upload ${type.replace('_', ' ')}</p>
    `;
    
    document.getElementById(type + '-input').value = '';
}

// Show message function
function showMessage(message, type) {
    const existingMessage = document.querySelector('.alert-message');
    if (existingMessage) {
        existingMessage.remove();
    }
    
    const messageEl = document.createElement('div');
    messageEl.className = `alert-message fixed top-4 right-4 px-4 py-3 rounded-md shadow-lg z-50 max-w-md`;
    messageEl.style.animation = 'slideInRight 0.3s ease-out';
    
    if (type === 'success') {
        messageEl.className += ' bg-success text-white';
        messageEl.innerHTML = `<i class="ti ti-check-circle me-2"></i>${message}`;
    } else if (type === 'error') {
        messageEl.className += ' bg-error text-white';
        messageEl.innerHTML = `<i class="ti ti-alert-circle me-2"></i>${message}`;
    }
    
    document.body.appendChild(messageEl);
    
    setTimeout(() => {
        messageEl.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            messageEl.remove();
        }, 300);
    }, 5000);
}
</script>

<cfinclude template="../includes/footer.cfm">