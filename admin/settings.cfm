<!--- Ghost General Settings Page --->
<cfparam name="request.dsn" default="blog">
<cfset pageTitle = "General Settings">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login" addtoken="false">
</cfif>

<!--- Get all settings --->
<cfquery name="qSettings" datasource="#request.dsn#">
    SELECT * FROM settings
</cfquery>

<!--- Convert to struct for easy access --->
<cfset settings = {}>
<cfloop query="qSettings">
    <cfset settings[qSettings.key] = qSettings.value>
</cfloop>

<!--- Include header --->
<cfinclude template="includes/header.cfm">

<style>
/* Ghost-style settings */
.gh-main-section {
    margin: 0 auto;
    max-width: 1200px;
}

.gh-main-section-block {
    margin-bottom: 5vmin;
}

.gh-main-section-content {
    margin-top: 1.6rem;
}

.gh-setting-group {
    display: flex;
    align-items: flex-start;
    margin-bottom: 3.2rem;
    padding-bottom: 3.2rem;
    border-bottom: 1px solid #e5e7eb;
}

.gh-setting-group:last-child {
    margin-bottom: 0;
    padding-bottom: 0;
    border-bottom: none;
}

.gh-setting-first {
    flex: 0 0 30%;
    margin-right: 5%;
}

.gh-setting-header h4 {
    margin: 0 0 0.4rem;
    font-size: 1.5rem;
    font-weight: 600;
    line-height: 1.4;
}

.gh-setting-desc {
    margin: 0;
    color: #738a94;
    font-size: 1.4rem;
    line-height: 1.5;
}

.gh-setting-last {
    flex: 1;
}

.gh-setting-content {
    display: flex;
    flex-direction: column;
    gap: 1.6rem;
}

.form-group {
    margin-bottom: 0;
}

.form-group label {
    display: block;
    margin-bottom: 0.6rem;
    color: #15171a;
    font-size: 1.3rem;
    font-weight: 600;
    letter-spacing: 0.02rem;
}

.form-group input[type="text"],
.form-group input[type="url"],
.form-group textarea,
.form-group select {
    width: 100%;
    padding: 0.8rem 1.2rem;
    border: 1px solid #e5e7eb;
    border-radius: 3px;
    font-size: 1.4rem;
    line-height: 1.5;
    transition: border-color 0.15s linear;
}

.form-group input[type="text"]:focus,
.form-group input[type="url"]:focus,
.form-group textarea:focus,
.form-group select:focus {
    outline: 0;
    border-color: #15171a;
}

.form-group textarea {
    min-height: 80px;
    resize: vertical;
}

.form-group .form-text {
    margin-top: 0.4rem;
    color: #738a94;
    font-size: 1.3rem;
}

.gh-expandable-block {
    margin-top: 2.4rem;
}

.gh-expandable-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 1.6rem 2.4rem;
    background: #f9f9fa;
    border: 1px solid #e5e7eb;
    border-radius: 3px;
    cursor: pointer;
    transition: all 0.1s ease;
}

.gh-expandable-header:hover {
    background: #f4f5f6;
}

.gh-expandable-title {
    display: flex;
    align-items: center;
    gap: 1.2rem;
}

.gh-expandable-title h4 {
    margin: 0;
    font-size: 1.5rem;
    font-weight: 600;
}

.gh-expandable-indicator svg {
    width: 1.6rem;
    height: 1.6rem;
    transition: transform 0.2s ease;
}

.gh-expandable-block.expanded .gh-expandable-indicator svg {
    transform: rotate(180deg);
}

.gh-expandable-content {
    display: none;
    padding: 2.4rem;
    border: 1px solid #e5e7eb;
    border-top: none;
    border-radius: 0 0 3px 3px;
}

.gh-expandable-block.expanded .gh-expandable-content {
    display: block;
}

.settings-save-button {
    position: fixed;
    bottom: 3.2rem;
    right: 3.2rem;
    z-index: 1000;
}

.gh-btn-primary {
    padding: 0.8rem 1.6rem;
    background: #15171a;
    color: #fff;
    border: 1px solid #15171a;
    border-radius: 3px;
    font-size: 1.4rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.gh-btn-primary:hover {
    background: #394047;
    border-color: #394047;
}

.gh-btn-primary:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

/* Toggle switch */
.toggle-group {
    display: flex;
    align-items: center;
    gap: 1.2rem;
}

.toggle-switch {
    position: relative;
    width: 50px;
    height: 28px;
}

.toggle-switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

.toggle-slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #e5e7eb;
    transition: 0.4s;
    border-radius: 28px;
}

.toggle-slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 4px;
    bottom: 4px;
    background-color: white;
    transition: 0.4s;
    border-radius: 50%;
}

input:checked + .toggle-slider {
    background-color: #30cf43;
}

input:checked + .toggle-slider:before {
    transform: translateX(22px);
}

.toggle-label {
    color: #15171a;
    font-size: 1.4rem;
    font-weight: 500;
}

/* Timezone select */
select.timezone-select {
    max-width: 100%;
}

/* Color picker */
.color-picker-wrapper {
    display: flex;
    align-items: center;
    gap: 1.2rem;
}

.color-picker-input {
    width: 120px !important;
}

.color-preview {
    width: 40px;
    height: 40px;
    border-radius: 3px;
    border: 1px solid #e5e7eb;
}
</style>

<main class="main-content">
    <div class="container-fluid">
        <!-- Page Header -->
        <div class="gh-canvas-header">
            <div class="gh-canvas-header-content">
                <h2 class="gh-canvas-title">General settings</h2>
                <section class="view-actions">
                    <button class="gh-btn gh-btn-primary" id="saveSettings">
                        Save settings
                    </button>
                </section>
            </div>
        </div>

        <div class="gh-content">
            <div class="gh-main-section">
                <!-- Title & description -->
                <div class="gh-main-section-block">
                    <div class="gh-setting-group">
                        <div class="gh-setting-first">
                            <div class="gh-setting-header">
                                <h4>Title & description</h4>
                            </div>
                            <div class="gh-setting-desc">The details used to identify your publication around the web</div>
                        </div>
                        <div class="gh-setting-last">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="site_title">Site title</label>
                                    <input type="text" 
                                           id="site_title" 
                                           name="site_title" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.site_title ?: '')#</cfoutput>"
                                           placeholder="My Ghost Blog">
                                </div>
                                <div class="form-group">
                                    <label for="site_description">Site description</label>
                                    <textarea id="site_description" 
                                              name="site_description" 
                                              class="form-control" 
                                              rows="3"
                                              placeholder="A blog about interesting things"><cfoutput>#htmlEditFormat(settings.site_description ?: '')#</cfoutput></textarea>
                                    <small class="form-text">Used in your theme, meta data and search results</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Timezone -->
                    <div class="gh-setting-group">
                        <div class="gh-setting-first">
                            <div class="gh-setting-header">
                                <h4>Timezone</h4>
                            </div>
                            <div class="gh-setting-desc">Set the time and date of your publication, used for all published posts</div>
                        </div>
                        <div class="gh-setting-last">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="site_timezone">Site timezone</label>
                                    <select id="site_timezone" 
                                            name="site_timezone" 
                                            class="form-control timezone-select">
                                        <cfset timezones = [
                                            "Pacific/Tahiti", "Pacific/Honolulu", "America/Anchorage",
                                            "America/Los_Angeles", "America/Denver", "America/Chicago",
                                            "America/New_York", "America/Caracas", "America/Sao_Paulo",
                                            "UTC", "Europe/London", "Europe/Paris", "Europe/Berlin",
                                            "Africa/Cairo", "Asia/Jerusalem", "Asia/Dubai", "Asia/Karachi",
                                            "Asia/Kolkata", "Asia/Dhaka", "Asia/Bangkok", "Asia/Hong_Kong",
                                            "Asia/Tokyo", "Australia/Sydney", "Pacific/Auckland"
                                        ]>
                                        <cfloop array="#timezones#" index="tz">
                                            <option value="<cfoutput>#tz#</cfoutput>" 
                                                    <cfif settings.site_timezone EQ tz>selected</cfif>>
                                                <cfoutput>#tz#</cfoutput>
                                            </option>
                                        </cfloop>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Publication language -->
                    <div class="gh-setting-group">
                        <div class="gh-setting-first">
                            <div class="gh-setting-header">
                                <h4>Publication language</h4>
                            </div>
                            <div class="gh-setting-desc">Set the language/locale which is used on your site</div>
                        </div>
                        <div class="gh-setting-last">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="site_language">Site language</label>
                                    <input type="text" 
                                           id="site_language" 
                                           name="site_language" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.site_language ?: 'en')#</cfoutput>"
                                           placeholder="en">
                                    <small class="form-text">Default: en (English). Visit <a href="https://www.w3schools.com/tags/ref_language_codes.asp" target="_blank">this link</a> for a list of valid language codes</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Meta data -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header" onclick="toggleExpandable(this.parentElement)">
                            <div class="gh-expandable-title">
                                <h4>Meta data</h4>
                                <p class="gh-setting-desc">Extra content for search engines</p>
                            </div>
                            <div class="gh-expandable-indicator">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M7 10l5 5 5-5z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="gh-expandable-content">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="meta_title">Meta title</label>
                                    <input type="text" 
                                           id="meta_title" 
                                           name="meta_title" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.meta_title ?: '')#</cfoutput>"
                                           placeholder="My Ghost Blog">
                                    <small class="form-text">Recommended: 70 characters</small>
                                </div>
                                <div class="form-group">
                                    <label for="meta_description">Meta description</label>
                                    <textarea id="meta_description" 
                                              name="meta_description" 
                                              class="form-control" 
                                              rows="3"
                                              placeholder="A blog about interesting things"><cfoutput>#htmlEditFormat(settings.meta_description ?: '')#</cfoutput></textarea>
                                    <small class="form-text">Recommended: 156 characters</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Twitter card -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header" onclick="toggleExpandable(this.parentElement)">
                            <div class="gh-expandable-title">
                                <h4>Twitter card</h4>
                                <p class="gh-setting-desc">Customize structured data for Twitter</p>
                            </div>
                            <div class="gh-expandable-indicator">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M7 10l5 5 5-5z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="gh-expandable-content">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="twitter_title">Twitter title</label>
                                    <input type="text" 
                                           id="twitter_title" 
                                           name="twitter_title" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.twitter_title ?: '')#</cfoutput>">
                                </div>
                                <div class="form-group">
                                    <label for="twitter_description">Twitter description</label>
                                    <textarea id="twitter_description" 
                                              name="twitter_description" 
                                              class="form-control" 
                                              rows="3"><cfoutput>#htmlEditFormat(settings.twitter_description ?: '')#</cfoutput></textarea>
                                </div>
                                <div class="form-group">
                                    <label for="twitter_image">Twitter image</label>
                                    <input type="url" 
                                           id="twitter_image" 
                                           name="twitter_image" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.twitter_image ?: '')#</cfoutput>"
                                           placeholder="https://example.com/image.jpg">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Facebook card -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header" onclick="toggleExpandable(this.parentElement)">
                            <div class="gh-expandable-title">
                                <h4>Facebook card</h4>
                                <p class="gh-setting-desc">Customize Open Graph data</p>
                            </div>
                            <div class="gh-expandable-indicator">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M7 10l5 5 5-5z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="gh-expandable-content">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="og_title">Facebook title</label>
                                    <input type="text" 
                                           id="og_title" 
                                           name="og_title" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.og_title ?: '')#</cfoutput>">
                                </div>
                                <div class="form-group">
                                    <label for="og_description">Facebook description</label>
                                    <textarea id="og_description" 
                                              name="og_description" 
                                              class="form-control" 
                                              rows="3"><cfoutput>#htmlEditFormat(settings.og_description ?: '')#</cfoutput></textarea>
                                </div>
                                <div class="form-group">
                                    <label for="og_image">Facebook image</label>
                                    <input type="url" 
                                           id="og_image" 
                                           name="og_image" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.og_image ?: '')#</cfoutput>"
                                           placeholder="https://example.com/image.jpg">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Social accounts -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header" onclick="toggleExpandable(this.parentElement)">
                            <div class="gh-expandable-title">
                                <h4>Social accounts</h4>
                                <p class="gh-setting-desc">Link your social accounts</p>
                            </div>
                            <div class="gh-expandable-indicator">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M7 10l5 5 5-5z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="gh-expandable-content">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <label for="facebook">Facebook Page</label>
                                    <input type="url" 
                                           id="facebook" 
                                           name="facebook" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.facebook ?: '')#</cfoutput>"
                                           placeholder="https://www.facebook.com/ghost">
                                    <small class="form-text">URL of your publication's Facebook Page</small>
                                </div>
                                <div class="form-group">
                                    <label for="twitter">Twitter profile</label>
                                    <input type="url" 
                                           id="twitter" 
                                           name="twitter" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.twitter ?: '')#</cfoutput>"
                                           placeholder="https://twitter.com/ghost">
                                    <small class="form-text">URL of your publication's Twitter profile</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Make this site private -->
                    <div class="gh-expandable-block">
                        <div class="gh-expandable-header" onclick="toggleExpandable(this.parentElement)">
                            <div class="gh-expandable-title">
                                <h4>Make this site private</h4>
                                <p class="gh-setting-desc">Password protect your site</p>
                            </div>
                            <div class="gh-expandable-indicator">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                    <path d="M7 10l5 5 5-5z"/>
                                </svg>
                            </div>
                        </div>
                        <div class="gh-expandable-content">
                            <div class="gh-setting-content">
                                <div class="form-group">
                                    <div class="toggle-group">
                                        <label class="toggle-switch">
                                            <input type="checkbox" 
                                                   id="is_private" 
                                                   name="is_private"
                                                   <cfif settings.is_private EQ "true">checked</cfif>>
                                            <span class="toggle-slider"></span>
                                        </label>
                                        <label for="is_private" class="toggle-label">
                                            Password protect this site
                                        </label>
                                    </div>
                                    <small class="form-text">Only invited users will be able to access your site</small>
                                </div>
                                <div class="form-group" id="password-group" style="display: <cfif settings.is_private EQ "true">block<cfelse>none</cfif>;">
                                    <label for="password">Site password</label>
                                    <input type="text" 
                                           id="password" 
                                           name="password" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(settings.password ?: '')#</cfoutput>"
                                           placeholder="Enter password">
                                    <small class="form-text">Set the password for this site</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
// Toggle expandable sections
function toggleExpandable(element) {
    element.classList.toggle('expanded');
}

// Toggle password field visibility
document.getElementById('is_private').addEventListener('change', function() {
    const passwordGroup = document.getElementById('password-group');
    passwordGroup.style.display = this.checked ? 'block' : 'none';
});

// Save settings
document.getElementById('saveSettings').addEventListener('click', function() {
    const button = this;
    button.disabled = true;
    button.textContent = 'Saving...';
    
    // Collect all settings
    const settings = {
        site_title: document.getElementById('site_title').value,
        site_description: document.getElementById('site_description').value,
        site_timezone: document.getElementById('site_timezone').value,
        site_language: document.getElementById('site_language').value,
        meta_title: document.getElementById('meta_title').value,
        meta_description: document.getElementById('meta_description').value,
        twitter_title: document.getElementById('twitter_title').value,
        twitter_description: document.getElementById('twitter_description').value,
        twitter_image: document.getElementById('twitter_image').value,
        og_title: document.getElementById('og_title').value,
        og_description: document.getElementById('og_description').value,
        og_image: document.getElementById('og_image').value,
        facebook: document.getElementById('facebook').value,
        twitter: document.getElementById('twitter').value,
        is_private: document.getElementById('is_private').checked ? 'true' : 'false',
        password: document.getElementById('password').value
    };
    
    // Save settings via AJAX
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
        button.textContent = 'Save settings';
    });
});

// Auto-save on input change (debounced)
let saveTimeout;
const autoSaveInputs = document.querySelectorAll('input[type="text"], input[type="url"], textarea, select, input[type="checkbox"]');
autoSaveInputs.forEach(input => {
    input.addEventListener('change', function() {
        clearTimeout(saveTimeout);
        saveTimeout = setTimeout(() => {
            document.getElementById('saveSettings').click();
        }, 2000);
    });
});
</script>

<cfinclude template="includes/footer.cfm">