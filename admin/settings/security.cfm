<cfparam name="request.dsn" default="blog">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Get current security settings --->
<cfquery name="getSettings" datasource="#request.dsn#">
    SELECT `key` as settingKey, `value` as settingValue, type 
    FROM settings
    WHERE `key` IN (
        'is_private', 'password', 'default_content_visibility',
        'members_signup_access', 'members_invite_only',
        'allow_external_signup', 'require_email_verification'
    )
</cfquery>

<!--- Convert query to structure for easier access --->
<cfset settings = {}>
<cfloop query="getSettings">
    <cfset settings[settingKey] = settingValue>
</cfloop>

<!--- Set defaults for missing settings --->
<cfparam name="settings.is_private" default="false">
<cfparam name="settings.password" default="">
<cfparam name="settings.default_content_visibility" default="public">
<cfparam name="settings.members_signup_access" default="all">
<cfparam name="settings.members_invite_only" default="false">
<cfparam name="settings.allow_external_signup" default="true">
<cfparam name="settings.require_email_verification" default="true">

<cfset pageTitle = "Security Settings">
<cfinclude template="../includes/header.cfm">

<style>
/* Security settings styles */
.security-header {
    margin-bottom: 2rem;
}

.security-title {
    font-size: 2rem;
    font-weight: 700;
    color: #15171a;
    margin: 0 0 0.5rem 0;
}

.security-description {
    font-size: 1rem;
    color: #738a94;
    margin: 0;
}

.settings-section {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 2rem;
    margin-bottom: 2rem;
}

.section-header {
    margin-bottom: 2rem;
    padding-bottom: 1.5rem;
    border-bottom: 1px solid #e5e7eb;
}

.section-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #15171a;
    margin: 0 0 0.5rem 0;
}

.section-description {
    font-size: 0.875rem;
    color: #738a94;
    margin: 0;
}

.settings-group {
    margin-bottom: 2rem;
}

.settings-group:last-child {
    margin-bottom: 0;
}

.setting-item {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 2rem;
    margin-bottom: 1.5rem;
}

.setting-item:last-child {
    margin-bottom: 0;
}

.setting-info {
    flex: 1;
}

.setting-label {
    font-size: 0.875rem;
    font-weight: 600;
    color: #15171a;
    margin: 0 0 0.25rem 0;
}

.setting-description {
    font-size: 0.875rem;
    color: #738a94;
    margin: 0;
}

.setting-control {
    flex-shrink: 0;
}

/* Toggle switch */
.toggle-switch {
    position: relative;
    display: inline-block;
    width: 44px;
    height: 24px;
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
    transition: .4s;
    border-radius: 24px;
}

.toggle-slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: .4s;
    border-radius: 50%;
}

input:checked + .toggle-slider {
    background-color: #14b8a6;
}

input:checked + .toggle-slider:before {
    transform: translateX(20px);
}

/* Password field */
.password-field {
    position: relative;
    margin-top: 1rem;
}

.password-input {
    width: 100%;
    padding: 0.5rem 2.5rem 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    transition: all 0.2s ease;
}

.password-input:focus {
    outline: none;
    border-color: #14b8a6;
    box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.1);
}

.password-toggle {
    position: absolute;
    right: 0.5rem;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    color: #738a94;
    cursor: pointer;
    padding: 0.25rem;
}

/* Select dropdown */
.setting-select {
    padding: 0.5rem 2rem 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    background: white;
    cursor: pointer;
    min-width: 180px;
}

/* Warning box */
.warning-box {
    background: #fef3c7;
    border: 1px solid #fde68a;
    border-radius: 6px;
    padding: 1rem;
    margin-top: 1rem;
    display: none;
}

.warning-box.show {
    display: block;
}

.warning-text {
    font-size: 0.875rem;
    color: #92400e;
    margin: 0;
}

/* Save button */
.settings-footer {
    display: flex;
    justify-content: flex-end;
    padding-top: 2rem;
}
</style>

<div class="container-fluid">
    <div class="settings-container">
        <div class="security-header">
            <h1 class="security-title">Security</h1>
            <p class="security-description">Configure security settings to control access to your site</p>
        </div>

        <!-- Settings Navigation -->
        <div class="settings-navigation mb-6">
            <nav class="flex space-x-8 border-b border-gray-200">
                <a href="/ghost/admin/settings/general" class="pb-3 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                    General
                </a>
                <a href="/ghost/admin/settings/security" class="pb-3 px-1 border-b-2 border-primary font-medium text-sm text-primary">
                    Security
                </a>
                <a href="/ghost/admin/settings/mail" class="pb-3 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                    Mail
                </a>
            </nav>
        </div>

    <!--- Site Access Section --->
    <div class="settings-section">
        <div class="section-header">
            <h2 class="section-title">Site Access</h2>
            <p class="section-description">Control who can access your site</p>
        </div>

        <div class="settings-group">
            <div class="setting-item">
                <div class="setting-info">
                    <h3 class="setting-label">Make site private</h3>
                    <p class="setting-description">Enable password protection for your entire site. Only people with the password can access your content.</p>
                </div>
                <div class="setting-control">
                    <label class="toggle-switch">
                        <input type="checkbox" id="is_private" <cfif settings.is_private EQ "true">checked</cfif>>
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>

            <div class="password-field" id="passwordField" <cfif settings.is_private NEQ "true">style="display: none;"</cfif>>
                <input type="password" id="site_password" class="password-input" value="<cfoutput>#settings.password#</cfoutput>" placeholder="Enter site password">
                <button type="button" class="password-toggle" onclick="togglePassword()">
                    <i class="ti ti-eye" id="passwordIcon"></i>
                </button>
            </div>

            <div class="warning-box <cfif settings.is_private EQ "true">show</cfif>" id="privateWarning">
                <p class="warning-text">
                    <i class="ti ti-alert-triangle mr-1"></i>
                    A private site is only accessible to visitors who enter the correct password
                </p>
            </div>
        </div>
    </div>

    <!--- Member Signup Section --->
    <div class="settings-section">
        <div class="section-header">
            <h2 class="section-title">Member Signup</h2>
            <p class="section-description">Configure how new members can join your site</p>
        </div>

        <div class="settings-group">
            <div class="setting-item">
                <div class="setting-info">
                    <h3 class="setting-label">Signup access level</h3>
                    <p class="setting-description">Control who can sign up for a member account on your site</p>
                </div>
                <div class="setting-control">
                    <select id="members_signup_access" class="setting-select">
                        <option value="all" <cfif settings.members_signup_access EQ "all">selected</cfif>>Anyone can sign up</option>
                        <option value="invite" <cfif settings.members_signup_access EQ "invite">selected</cfif>>Only invited people</option>
                        <option value="none" <cfif settings.members_signup_access EQ "none">selected</cfif>>Nobody</option>
                    </select>
                </div>
            </div>

            <div class="setting-item">
                <div class="setting-info">
                    <h3 class="setting-label">Require email verification</h3>
                    <p class="setting-description">New members must verify their email address before they can sign in</p>
                </div>
                <div class="setting-control">
                    <label class="toggle-switch">
                        <input type="checkbox" id="require_email_verification" <cfif settings.require_email_verification EQ "true">checked</cfif>>
                        <span class="toggle-slider"></span>
                    </label>
                </div>
            </div>
        </div>
    </div>

    <!--- Default Content Visibility Section --->
    <div class="settings-section">
        <div class="section-header">
            <h2 class="section-title">Default Content Visibility</h2>
            <p class="section-description">Set the default visibility for new posts</p>
        </div>

        <div class="settings-group">
            <div class="setting-item">
                <div class="setting-info">
                    <h3 class="setting-label">Default post access</h3>
                    <p class="setting-description">When you publish new posts, who should be able to see them by default?</p>
                </div>
                <div class="setting-control">
                    <select id="default_content_visibility" class="setting-select">
                        <option value="public" <cfif settings.default_content_visibility EQ "public">selected</cfif>>Public</option>
                        <option value="members" <cfif settings.default_content_visibility EQ "members">selected</cfif>>Members only</option>
                        <option value="paid" <cfif settings.default_content_visibility EQ "paid">selected</cfif>>Paid members only</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <div class="settings-footer">
        <button type="button" class="btn btn-primary" onclick="saveSecuritySettings()">
            <i class="ti ti-device-floppy mr-2"></i>Save settings
        </button>
    </div>
</div>

<script>
// Toggle password visibility
function togglePassword() {
    const passwordInput = document.getElementById('site_password');
    const passwordIcon = document.getElementById('passwordIcon');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        passwordIcon.className = 'ti ti-eye-off';
    } else {
        passwordInput.type = 'password';
        passwordIcon.className = 'ti ti-eye';
    }
}

// Handle private site toggle
document.getElementById('is_private').addEventListener('change', function() {
    const passwordField = document.getElementById('passwordField');
    const privateWarning = document.getElementById('privateWarning');
    
    if (this.checked) {
        passwordField.style.display = 'block';
        privateWarning.classList.add('show');
    } else {
        passwordField.style.display = 'none';
        privateWarning.classList.remove('show');
    }
});

// Save security settings
function saveSecuritySettings() {
    const settings = {
        is_private: document.getElementById('is_private').checked ? 'true' : 'false',
        password: document.getElementById('site_password').value,
        members_signup_access: document.getElementById('members_signup_access').value,
        require_email_verification: document.getElementById('require_email_verification').checked ? 'true' : 'false',
        default_content_visibility: document.getElementById('default_content_visibility').value
    };
    
    // Validate password if site is private
    if (settings.is_private === 'true' && !settings.password) {
        showMessage('Please enter a password for private site access', 'error');
        return;
    }
    
    // Show saving message
    showMessage('Saving security settings...', 'info');
    
    // Send to server
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
            showMessage('Security settings saved successfully', 'success');
        } else {
            showMessage(data.message || 'Failed to save settings', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('An error occurred while saving', 'error');
    });
}

// Message display function
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
    
    // Get or create toast container
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.style.cssText = 'position: fixed; bottom: 1rem; right: 1rem; z-index: 9999; display: flex; flex-direction: column-reverse; gap: 0.5rem;';
        document.body.appendChild(container);
    }
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
</script>

<cfinclude template="../includes/footer.cfm">