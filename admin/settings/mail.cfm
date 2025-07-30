<cfparam name="request.dsn" default="blog">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Get current mail settings --->
<cfquery name="getSettings" datasource="#request.dsn#">
    SELECT `key` as settingKey, `value` as settingValue, type 
    FROM settings
    WHERE `key` IN (
        'mail_transport', 'mail_host', 'mail_port', 'mail_username', 
        'mail_password', 'mail_secure', 'mail_from_address', 'mail_from_name',
        'mail_reply_to', 'mail_service', 'mail_auth_type', 'mail_region',
        'mailjetApiKey', 'mailjetSecret'
    )
</cfquery>

<!--- Convert query to structure for easier access --->
<cfset settings = {}>
<cfloop query="getSettings">
    <cfset settings[settingKey] = settingValue>
</cfloop>

<!--- Set defaults for missing settings --->
<cfparam name="settings.mail_transport" default="SMTP">
<cfparam name="settings.mail_host" default="">
<cfparam name="settings.mail_port" default="587">
<cfparam name="settings.mail_username" default="">
<cfparam name="settings.mail_password" default="">
<cfparam name="settings.mail_secure" default="STARTTLS">
<cfparam name="settings.mail_from_address" default="">
<cfparam name="settings.mail_from_name" default="">
<cfparam name="settings.mail_reply_to" default="">
<cfparam name="settings.mail_service" default="Custom">
<cfparam name="settings.mail_auth_type" default="login">
<cfparam name="settings.mail_region" default="us-east-1">
<cfparam name="settings.mailjetApiKey" default="">
<cfparam name="settings.mailjetSecret" default="">

<cfset pageTitle = "Mail Settings">
<cfinclude template="../includes/header.cfm">

<style>
/* Mail settings styles */
.mail-header {
    margin-bottom: 2rem;
}

.mail-title {
    font-size: 2rem;
    font-weight: 700;
    color: #15171a;
    margin: 0 0 0.5rem 0;
}

.mail-description {
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

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.form-row.single {
    grid-template-columns: 1fr;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-group:last-child {
    margin-bottom: 0;
}

.form-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    margin-bottom: 0.5rem;
}

.form-input,
.form-select {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    transition: all 0.2s ease;
}

.form-input:focus,
.form-select:focus {
    outline: none;
    border-color: #14b8a6;
    box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.1);
}

.form-hint {
    font-size: 0.75rem;
    color: #6b7280;
    margin-top: 0.25rem;
}

/* Service presets */
.service-presets {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
}

.service-preset {
    padding: 1rem;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: center;
}

.service-preset:hover {
    border-color: #14b8a6;
}

.service-preset.active {
    border-color: #14b8a6;
    background: #f0fdfa;
}

.service-preset-name {
    font-weight: 600;
    color: #15171a;
    margin-bottom: 0.25rem;
}

.service-preset-desc {
    font-size: 0.75rem;
    color: #738a94;
}

/* Test mail section */
.test-mail-section {
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: 8px;
    padding: 1.5rem;
    margin-top: 2rem;
}

.test-mail-title {
    font-size: 1rem;
    font-weight: 600;
    color: #15171a;
    margin: 0 0 1rem 0;
}

.test-mail-form {
    display: flex;
    gap: 1rem;
    align-items: end;
}

.test-mail-input {
    flex: 1;
}

/* Settings footer */
.settings-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 2rem;
    border-top: 1px solid #e5e7eb;
}

.btn-test {
    background: #6b7280;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-test:hover {
    background: #4b5563;
}

/* Show/hide password */
.password-field {
    position: relative;
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

.password-toggle:hover {
    color: #374151;
}
</style>

<div class="container-fluid">
    <div class="settings-container">
        <div class="mail-header">
            <h1 class="mail-title">Mail</h1>
            <p class="mail-description">Configure email delivery for your publication</p>
        </div>

        <!-- Settings Navigation -->
        <div class="settings-navigation mb-6">
            <nav class="flex space-x-8 border-b border-gray-200">
                <a href="/ghost/admin/settings/general" class="pb-3 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                    General
                </a>
                <a href="/ghost/admin/settings/security" class="pb-3 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                    Security
                </a>
                <a href="/ghost/admin/settings/mail" class="pb-3 px-1 border-b-2 border-primary font-medium text-sm text-primary">
                    Mail
                </a>
            </nav>
        </div>

        <!--- Mail Service Provider Section --->
        <div class="settings-section">
            <div class="section-header">
                <h2 class="section-title">Mail Service</h2>
                <p class="section-description">Choose your email delivery service</p>
            </div>

            <div class="service-presets">
                <div class="service-preset <cfif settings.mail_service EQ 'Custom'>active</cfif>" onclick="selectService('Custom')">
                    <div class="service-preset-name">Custom SMTP</div>
                    <div class="service-preset-desc">Configure your own SMTP server</div>
                </div>
                <div class="service-preset <cfif settings.mail_service EQ 'Gmail'>active</cfif>" onclick="selectService('Gmail')">
                    <div class="service-preset-name">Gmail</div>
                    <div class="service-preset-desc">Use Gmail SMTP</div>
                </div>
                <div class="service-preset <cfif settings.mail_service EQ 'SendGrid'>active</cfif>" onclick="selectService('SendGrid')">
                    <div class="service-preset-name">SendGrid</div>
                    <div class="service-preset-desc">Transactional email service</div>
                </div>
                <div class="service-preset <cfif settings.mail_service EQ 'Mailgun'>active</cfif>" onclick="selectService('Mailgun')">
                    <div class="service-preset-name">Mailgun</div>
                    <div class="service-preset-desc">Email API service</div>
                </div>
                <div class="service-preset <cfif settings.mail_service EQ 'AWS SES'>active</cfif>" onclick="selectService('AWS SES')">
                    <div class="service-preset-name">AWS SES</div>
                    <div class="service-preset-desc">Amazon Simple Email Service</div>
                </div>
                <div class="service-preset <cfif settings.mail_service EQ 'Mailjet'>active</cfif>" onclick="selectService('Mailjet')">
                    <div class="service-preset-name">Mailjet</div>
                    <div class="service-preset-desc">Email delivery service</div>
                </div>
            </div>
        </div>

        <!--- SMTP Configuration Section --->
        <div class="settings-section" id="smtp-config">
            <div class="section-header">
                <h2 class="section-title">SMTP Configuration</h2>
                <p class="section-description">Configure your SMTP server settings</p>
            </div>

            <div class="settings-group">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="mail_host">SMTP Host</label>
                        <input type="text" id="mail_host" name="mail_host" class="form-input" value="<cfoutput>#settings.mail_host#</cfoutput>" placeholder="smtp.example.com">
                        <div class="form-hint">Your SMTP server hostname</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="mail_port">Port</label>
                        <input type="number" id="mail_port" name="mail_port" class="form-input" value="<cfoutput>#settings.mail_port#</cfoutput>" placeholder="587">
                        <div class="form-hint">Usually 587 (STARTTLS) or 465 (SSL)</div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="mail_username">Username</label>
                        <input type="text" id="mail_username" name="mail_username" class="form-input" value="<cfoutput>#settings.mail_username#</cfoutput>" placeholder="your-email@example.com">
                        <div class="form-hint">SMTP authentication username</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="mail_password">Password</label>
                        <div class="password-field">
                            <input type="password" id="mail_password" name="mail_password" class="form-input" value="<cfoutput>#settings.mail_password#</cfoutput>" placeholder="Enter your password">
                            <button type="button" class="password-toggle" onclick="togglePassword('mail_password')">
                                <i class="ti ti-eye" id="mail_password_icon"></i>
                            </button>
                        </div>
                        <div class="form-hint">SMTP authentication password</div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="mail_secure">Security</label>
                        <select id="mail_secure" name="mail_secure" class="form-select">
                            <option value="STARTTLS" <cfif settings.mail_secure EQ "STARTTLS">selected</cfif>>STARTTLS (recommended)</option>
                            <option value="SSL" <cfif settings.mail_secure EQ "SSL">selected</cfif>>SSL/TLS</option>
                            <option value="NONE" <cfif settings.mail_secure EQ "NONE">selected</cfif>>None (not recommended)</option>
                        </select>
                        <div class="form-hint">Email encryption method</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="mail_auth_type">Authentication</label>
                        <select id="mail_auth_type" name="mail_auth_type" class="form-select">
                            <option value="login" <cfif settings.mail_auth_type EQ "login">selected</cfif>>LOGIN</option>
                            <option value="plain" <cfif settings.mail_auth_type EQ "plain">selected</cfif>>PLAIN</option>
                            <option value="cram-md5" <cfif settings.mail_auth_type EQ "cram-md5">selected</cfif>>CRAM-MD5</option>
                        </select>
                        <div class="form-hint">SMTP authentication method</div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Mailjet API Configuration Section --->
        <div class="settings-section" id="mailjet-config" style="display: none;">
            <div class="section-header">
                <h2 class="section-title">Mailjet API Configuration</h2>
                <p class="section-description">Configure your Mailjet API credentials (alternative to SMTP)</p>
            </div>

            <div class="settings-group">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="mailjetApiKey">API Key</label>
                        <input type="text" id="mailjetApiKey" name="mailjetApiKey" class="form-input" value="<cfoutput>#settings.mailjetApiKey#</cfoutput>" placeholder="Your Mailjet API Key">
                        <div class="form-hint">Find this in your Mailjet account settings</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="mailjetSecret">Secret Key</label>
                        <div class="password-field">
                            <input type="password" id="mailjetSecret" name="mailjetSecret" class="form-input" value="<cfoutput>#settings.mailjetSecret#</cfoutput>" placeholder="Your Mailjet Secret Key">
                            <button type="button" class="password-toggle" onclick="togglePassword('mailjetSecret')">
                                <i class="ti ti-eye" id="mailjetSecret_icon"></i>
                            </button>
                        </div>
                        <div class="form-hint">Your Mailjet secret key</div>
                    </div>
                </div>
                
                <div class="form-row single">
                    <div class="form-group">
                        <div style="background: #f0f9ff; border: 1px solid #bae6fd; border-radius: 6px; padding: 1rem;">
                            <p style="margin: 0; font-size: 0.875rem; color: #0369a1;">
                                <i class="ti ti-info-circle mr-1"></i>
                                <strong>Mailjet API:</strong> Mailjet uses API-based email delivery for better delivery rates and detailed analytics.
                                Get your API credentials from your Mailjet account dashboard.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!--- From Address Section --->
        <div class="settings-section">
            <div class="section-header">
                <h2 class="section-title">From Address</h2>
                <p class="section-description">Set the sender information for outgoing emails</p>
            </div>

            <div class="settings-group">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="mail_from_address">From Email</label>
                        <input type="email" id="mail_from_address" name="mail_from_address" class="form-input" value="<cfoutput>#settings.mail_from_address#</cfoutput>" placeholder="noreply@yourdomain.com">
                        <div class="form-hint">Email address that emails are sent from</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="mail_from_name">From Name</label>
                        <input type="text" id="mail_from_name" name="mail_from_name" class="form-input" value="<cfoutput>#settings.mail_from_name#</cfoutput>" placeholder="Your Publication Name">
                        <div class="form-hint">Name that appears as the sender</div>
                    </div>
                </div>

                <div class="form-row single">
                    <div class="form-group">
                        <label class="form-label" for="mail_reply_to">Reply-To Address (optional)</label>
                        <input type="email" id="mail_reply_to" name="mail_reply_to" class="form-input" value="<cfoutput>#settings.mail_reply_to#</cfoutput>" placeholder="contact@yourdomain.com">
                        <div class="form-hint">Where replies should be sent (if different from From Email)</div>
                    </div>
                </div>
            </div>
        </div>

        <!--- Test Mail Section --->
        <div class="settings-section">
            <div class="test-mail-section">
                <h3 class="test-mail-title">Send Test Email</h3>
                <p class="form-hint mb-3">Send a test email to verify your configuration</p>
                <div class="test-mail-form">
                    <div class="test-mail-input">
                        <input type="email" id="test_email" class="form-input" placeholder="Enter email address to test">
                    </div>
                    <button type="button" class="btn-test" onclick="sendTestEmail()">
                        <i class="ti ti-send mr-2"></i>Send Test
                    </button>
                </div>
            </div>
        </div>

        <div class="settings-footer">
            <div class="form-hint">
                <i class="ti ti-info-circle mr-1"></i>
                Changes will take effect immediately after saving
            </div>
            <button type="button" class="btn btn-primary" onclick="saveMailSettings()">
                <i class="ti ti-device-floppy mr-2"></i>Save settings
            </button>
        </div>
    </div>
</div>

<script>
// Service presets configuration
const servicePresets = {
    'Gmail': {
        host: 'smtp.gmail.com',
        port: 587,
        secure: 'STARTTLS',
        auth_type: 'login'
    },
    'SendGrid': {
        host: 'smtp.sendgrid.net',
        port: 587,
        secure: 'STARTTLS',
        auth_type: 'login'
    },
    'Mailgun': {
        host: 'smtp.mailgun.org',
        port: 587,
        secure: 'STARTTLS',
        auth_type: 'login'
    },
    'AWS SES': {
        host: 'email-smtp.us-east-1.amazonaws.com',
        port: 587,
        secure: 'STARTTLS',
        auth_type: 'login'
    },
    'Mailjet': {
        host: 'in-v3.mailjet.com',
        port: 587,
        secure: 'STARTTLS',
        auth_type: 'login'
    },
    'Custom': {
        host: '',
        port: 587,
        secure: 'STARTTLS',
        auth_type: 'login'
    }
};

// Select service preset
function selectService(service) {
    // Update active state
    document.querySelectorAll('.service-preset').forEach(preset => {
        preset.classList.remove('active');
    });
    event.target.closest('.service-preset').classList.add('active');
    
    // Show/hide sections based on service
    const smtpConfig = document.getElementById('smtp-config');
    const mailjetConfig = document.getElementById('mailjet-config');
    
    if (service === 'Mailjet') {
        // Hide SMTP section and show Mailjet API section for Mailjet
        smtpConfig.style.display = 'none';
        mailjetConfig.style.display = 'block';
    } else {
        // Show SMTP section and hide Mailjet API section for other services
        smtpConfig.style.display = 'block';
        mailjetConfig.style.display = 'none';
        
        // Apply preset configuration for SMTP services
        const config = servicePresets[service];
        if (config) {
            document.getElementById('mail_host').value = config.host;
            document.getElementById('mail_port').value = config.port;
            document.getElementById('mail_secure').value = config.secure;
            document.getElementById('mail_auth_type').value = config.auth_type;
        }
    }
}

// Toggle password visibility
function togglePassword(fieldId) {
    const passwordInput = document.getElementById(fieldId);
    const passwordIcon = document.getElementById(fieldId + '_icon');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        passwordIcon.className = 'ti ti-eye-off';
    } else {
        passwordInput.type = 'password';
        passwordIcon.className = 'ti ti-eye';
    }
}

// Send test email
function sendTestEmail() {
    const testEmail = document.getElementById('test_email').value;
    const settings = getMailSettings();
    
    if (!testEmail) {
        showMessage('Please enter an email address', 'error');
        return;
    }
    
    if (!isValidEmail(testEmail)) {
        showMessage('Please enter a valid email address', 'error');
        return;
    }
    
    // Validate configuration before sending test
    if (settings.mail_service === 'Mailjet') {
        if (!settings.mailjetApiKey || !settings.mailjetSecret) {
            showMessage('Please configure Mailjet API credentials first', 'error');
            return;
        }
    } else {
        if (!settings.mail_host) {
            showMessage('Please configure SMTP settings first', 'error');
            return;
        }
    }
    
    if (!settings.mail_from_address) {
        showMessage('Please configure from email address first', 'error');
        return;
    }
    
    showMessage('Sending test email...', 'info');
    
    fetch('/ghost/admin/ajax/send-test-email.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            email: testEmail,
            settings: getMailSettings()
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Test email sent successfully', 'success');
        } else {
            showMessage(data.message || 'Failed to send test email', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('An error occurred while sending test email', 'error');
    });
}

// Get current mail settings
function getMailSettings() {
    return {
        mail_service: document.querySelector('.service-preset.active .service-preset-name').textContent.trim(),
        mail_host: document.getElementById('mail_host').value,
        mail_port: document.getElementById('mail_port').value,
        mail_username: document.getElementById('mail_username').value,
        mail_password: document.getElementById('mail_password').value,
        mail_secure: document.getElementById('mail_secure').value,
        mail_auth_type: document.getElementById('mail_auth_type').value,
        mail_from_address: document.getElementById('mail_from_address').value,
        mail_from_name: document.getElementById('mail_from_name').value,
        mail_reply_to: document.getElementById('mail_reply_to').value,
        mailjetApiKey: document.getElementById('mailjetApiKey').value,
        mailjetSecret: document.getElementById('mailjetSecret').value
    };
}

// Save mail settings
function saveMailSettings() {
    const settings = getMailSettings();
    
    // Validate required fields based on service type
    if (settings.mail_service === 'Mailjet') {
        // Validate Mailjet API credentials
        if (!settings.mailjetApiKey) {
            showMessage('Mailjet API Key is required', 'error');
            return;
        }
        if (!settings.mailjetSecret) {
            showMessage('Mailjet Secret Key is required', 'error');
            return;
        }
    } else {
        // Validate SMTP settings for other services
        if (!settings.mail_host && settings.mail_service !== 'Custom') {
            showMessage('SMTP host is required', 'error');
            return;
        }
    }
    
    // From email is always required regardless of service
    if (!settings.mail_from_address) {
        showMessage('From email address is required', 'error');
        return;
    }
    
    showMessage('Saving mail settings...', 'info');
    
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
            showMessage('Mail settings saved successfully', 'success');
        } else {
            showMessage(data.message || 'Failed to save settings', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('An error occurred while saving', 'error');
    });
}

// Email validation
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Message display function
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

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    // Show/hide appropriate sections based on selected service
    const activeService = document.querySelector('.service-preset.active .service-preset-name');
    const smtpConfig = document.getElementById('smtp-config');
    const mailjetConfig = document.getElementById('mailjet-config');
    
    if (activeService && activeService.textContent === 'Mailjet') {
        // Hide SMTP, show Mailjet API
        smtpConfig.style.display = 'none';
        mailjetConfig.style.display = 'block';
    } else {
        // Show SMTP, hide Mailjet API (default)
        smtpConfig.style.display = 'block';
        mailjetConfig.style.display = 'none';
    }
});
</script>

<cfinclude template="../includes/footer.cfm">