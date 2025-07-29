<!--- Ghost Theme Management Page --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.action" default="">
<cfparam name="form.themeName" default="">

<cfset pageTitle = "Themes">

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


<!--- Get available themes --->
<cfdirectory action="list" directory="#expandPath('/ghost/themes/')#" name="qThemes" type="dir">

<!--- Include header --->
<cfinclude template="includes/header.cfm">

<style>
/* Ghost-style theme cards */
.gh-themes-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
    padding: 32px 0;
}

.gh-theme-card {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    overflow: hidden;
    transition: all 0.3s ease;
    position: relative;
}

.gh-theme-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    transform: translateY(-2px);
}

.gh-theme-card.active {
    border-color: #30cf43;
    box-shadow: 0 0 0 1px #30cf43;
}

.gh-theme-screenshot {
    width: 100%;
    height: 200px;
    background: #f3f4f6;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #9ca3af;
    font-size: 48px;
    position: relative;
    overflow: hidden;
}

.gh-theme-screenshot img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.gh-theme-content {
    padding: 20px;
}

.gh-theme-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
}

.gh-theme-name {
    font-size: 18px;
    font-weight: 600;
    color: #15171a;
    margin: 0;
}

.gh-theme-version {
    font-size: 12px;
    color: #738a94;
    background: #f3f4f6;
    padding: 2px 8px;
    border-radius: 3px;
}

.gh-theme-description {
    font-size: 14px;
    color: #626d79;
    line-height: 1.5;
    margin-bottom: 16px;
}

.gh-theme-actions {
    display: flex;
    gap: 12px;
}

.gh-theme-button {
    flex: 1;
    padding: 8px 16px;
    border: 1px solid #e5e7eb;
    background: #fff;
    color: #15171a;
    font-size: 14px;
    font-weight: 500;
    border-radius: 4px;
    cursor: pointer;
    text-align: center;
    transition: all 0.2s ease;
}

.gh-theme-button:hover {
    background: #f3f4f6;
}

.gh-theme-button.primary {
    background: #15171a;
    color: #fff;
    border-color: #15171a;
}

.gh-theme-button.primary:hover {
    background: #394047;
}

.gh-theme-button.success {
    background: #30cf43;
    color: #fff;
    border-color: #30cf43;
}

.gh-theme-active-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    background: #30cf43;
    color: #fff;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
}

.gh-theme-upload {
    background: #f8f9fa;
    border: 2px dashed #e5e7eb;
    border-radius: 8px;
    padding: 48px 24px;
    text-align: center;
    margin-bottom: 32px;
    transition: all 0.3s ease;
}

.gh-theme-upload.dragover {
    border-color: #15171a;
    background: #f3f4f6;
}

.gh-theme-upload-icon {
    width: 48px;
    height: 48px;
    margin: 0 auto 16px;
    opacity: 0.5;
}

.gh-theme-upload-title {
    font-size: 16px;
    font-weight: 600;
    color: #15171a;
    margin-bottom: 8px;
}

.gh-theme-upload-description {
    font-size: 14px;
    color: #738a94;
    margin-bottom: 24px;
}

.gh-upload-button {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    background: #15171a;
    color: #fff;
    border: none;
    border-radius: 4px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.gh-upload-button:hover {
    background: #394047;
}

.gh-upload-button svg {
    width: 16px;
    height: 16px;
}

/* Toast styles */
.translate-x-full {
    transform: translateX(100%);
}

#toastContainer > div {
    transition: all 0.3s ease-in-out;
}
</style>

<main class="main-content">
    <div class="container-fluid">
        <!-- Page Header -->
        <div class="gh-canvas-header">
            <div class="gh-canvas-header-content">
                <h2 class="gh-canvas-title">Themes</h2>
                <section class="view-actions">
                    <span class="dropdown">
                        <button class="gh-btn gh-btn-icon icon-only gh-btn-action-icon" aria-label="Settings">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
                                <path fill="currentColor" d="M12 8.5a3.5 3.5 0 1 0 0 7 3.5 3.5 0 0 0 0-7zM12 14a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/>
                                <path fill="currentColor" d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm0 18a8 8 0 1 1 0-16 8 8 0 0 1 0 16z"/>
                            </svg>
                        </button>
                    </span>
                </section>
            </div>
        </div>

        <div class="gh-content">
            <!--- Display messages --->
            <cfif structKeyExists(variables, "successMessage")>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <cfoutput>#successMessage#</cfoutput>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </cfif>
            
            <cfif structKeyExists(variables, "errorMessage")>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <cfoutput>#errorMessage#</cfoutput>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </cfif>

            <!-- Theme Upload Section -->
            <div class="gh-theme-upload" id="themeUploadZone">
                <svg class="gh-theme-upload-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                </svg>
                <h3 class="gh-theme-upload-title">Upload a theme</h3>
                <p class="gh-theme-upload-description">
                    Drag & drop a Ghost theme zip file or click to browse
                </p>
                <form id="themeUploadForm" action="ajax/upload-theme.cfm" method="post" enctype="multipart/form-data">
                    <input type="file" name="themeFile" id="themeFile" accept=".zip" style="display: none;">
                    <button type="button" class="gh-upload-button" onclick="document.getElementById('themeFile').click()">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                        </svg>
                        Upload theme
                    </button>
                </form>
            </div>

            <!-- Available Themes -->
            <h3 style="margin-bottom: 24px; font-size: 16px; font-weight: 600;">Installed themes</h3>
            
            <div class="gh-themes-container">
                <!--- Default Theme Card --->
                <div class="gh-theme-card<cfif activeTheme EQ 'default'> active</cfif>">
                    <cfif activeTheme EQ 'default'>
                        <div class="gh-theme-active-badge">Active</div>
                    </cfif>
                    <div class="gh-theme-screenshot">
                        <i class="ti ti-brush"></i>
                    </div>
                    <div class="gh-theme-content">
                        <div class="gh-theme-header">
                            <h4 class="gh-theme-name">Default</h4>
                            <span class="gh-theme-version">1.0.0</span>
                        </div>
                        <p class="gh-theme-description">
                            The default Ghost theme. Clean, minimal and responsive.
                        </p>
                        <div class="gh-theme-actions">
                            <cfif activeTheme NEQ 'default'>
                                <button type="button" class="gh-theme-button primary" style="width: 100%;" onclick="activateTheme('default')">
                                    Activate
                                </button>
                            <cfelse>
                                <button class="gh-theme-button success" disabled style="cursor: default;">
                                    Active Theme
                                </button>
                            </cfif>
                        </div>
                    </div>
                </div>

                <!--- Loop through uploaded themes --->
                <cfoutput query="qThemes">
                    <cfif name NEQ "." AND name NEQ ".." AND name NEQ "default">
                        <!--- Try to read theme package.json --->
                        <cfset themePath = expandPath('/ghost/themes/#name#/package.json')>
                        <cfset themeInfo = {
                            name: name,
                            description: "Custom theme",
                            version: "1.0.0"
                        }>
                        
                        <cfif fileExists(themePath)>
                            <cftry>
                                <cffile action="read" file="#themePath#" variable="themeJson">
                                <cfset themeData = deserializeJSON(themeJson)>
                                <cfif structKeyExists(themeData, "description")>
                                    <cfset themeInfo.description = themeData.description>
                                </cfif>
                                <cfif structKeyExists(themeData, "version")>
                                    <cfset themeInfo.version = themeData.version>
                                </cfif>
                                <cfcatch>
                                    <!--- Use defaults if JSON parsing fails --->
                                </cfcatch>
                            </cftry>
                        </cfif>

                        <div class="gh-theme-card<cfif activeTheme EQ name> active</cfif>">
                            <cfif activeTheme EQ name>
                                <div class="gh-theme-active-badge">Active</div>
                            </cfif>
                            <div class="gh-theme-screenshot">
                                <cfset screenshotPath = "/ghost/themes/#name#/assets/screenshot.jpg">
                                <cfif fileExists(expandPath(screenshotPath))>
                                    <img src="#screenshotPath#" alt="#themeInfo.name# screenshot">
                                <cfelse>
                                    <i class="ti ti-brush"></i>
                                </cfif>
                            </div>
                            <div class="gh-theme-content">
                                <div class="gh-theme-header">
                                    <h4 class="gh-theme-name">#themeInfo.name#</h4>
                                    <span class="gh-theme-version">#themeInfo.version#</span>
                                </div>
                                <p class="gh-theme-description">
                                    #themeInfo.description#
                                </p>
                                <div class="gh-theme-actions">
                                    <cfif activeTheme NEQ name>
                                        <button type="button" class="gh-theme-button primary" style="width: 100%;" onclick="activateTheme('#name#')">
                                            Activate
                                        </button>
                                    <cfelse>
                                        <button class="gh-theme-button success" disabled style="cursor: default;">
                                            Active Theme
                                        </button>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                    </cfif>
                </cfoutput>
            </div>
        </div>
    </div>
</main>

<script>
// Toast message function
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

// Theme upload functionality
document.addEventListener('DOMContentLoaded', function() {
    const uploadZone = document.getElementById('themeUploadZone');
    const fileInput = document.getElementById('themeFile');
    const uploadForm = document.getElementById('themeUploadForm');

    // Drag and drop functionality
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

    // File input change
    fileInput.addEventListener('change', function() {
        if (this.files.length > 0) {
            uploadTheme();
        }
    });

    function uploadTheme() {
        const formData = new FormData(uploadForm);
        
        // Show loading state
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

// Theme activation function
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
</script>

<cfinclude template="includes/footer.cfm">