<!--- Theme Management Page --->
<cfparam name="request.dsn" default="blog">

<!--- Get current theme setting --->
<cfquery name="qCurrentTheme" datasource="#request.dsn#">
    SELECT value FROM settings WHERE `key` = 'active_theme'
</cfquery>

<cfset currentTheme = qCurrentTheme.recordCount ? qCurrentTheme.value : "default">

<!--- Get available themes --->
<cfset themesPath = expandPath("/ghost/themes/")>
<cfdirectory action="list" directory="#themesPath#" name="qThemes" type="dir">

<!--- Filter out system directories --->
<cfset themes = []>
<cfloop query="qThemes">
    <cfif qThemes.name NEQ "." AND qThemes.name NEQ "..">
        <!--- Check if theme has required files --->
        <cfif fileExists("#themesPath##qThemes.name#/theme.json") AND fileExists("#themesPath##qThemes.name#/index.cfm")>
            <!--- Read theme info --->
            <cfset themeJson = fileRead("#themesPath##qThemes.name#/theme.json")>
            <cfset themeInfo = deserializeJSON(themeJson)>
            <cfset themeInfo.id = qThemes.name>
            <cfset themeInfo.active = (currentTheme EQ qThemes.name)>
            <cfset arrayAppend(themes, themeInfo)>
        </cfif>
    </cfif>
</cfloop>

<cfset pageTitle = "Themes">
<cfinclude template="../includes/header.cfm">

<div class="gh-canvas">
    <header class="gh-canvas-header">
        <h2 class="gh-canvas-title">Themes</h2>
        <section class="view-actions">
            <button class="gh-btn gh-btn-primary" onclick="window.location.href='upload.cfm'">
                <span>Upload theme</span>
            </button>
        </section>
    </header>

    <div class="gh-contentfilter">
        <ul class="gh-contentfilter-menu">
            <li class="gh-contentfilter-menu-item">
                <a href="javascript:void(0)" class="gh-contentfilter-menu-link active" data-tab="installed">
                    Installed
                </a>
            </li>
            <li class="gh-contentfilter-menu-item">
                <a href="javascript:void(0)" class="gh-contentfilter-menu-link" data-tab="marketplace">
                    Marketplace
                </a>
            </li>
        </ul>
    </div>

    <section class="view-container">
        <!--- Installed Themes Tab Content --->
        <div id="installed-tab" class="tab-content">
            <div class="gh-list">
                <cfloop array="#themes#" index="theme">
                <div class="gh-list-item theme-item <cfif theme.active>active</cfif>">
                    <div class="gh-list-data">
                        <h3 class="gh-list-item-title">
                            <cfoutput>#theme.name#</cfoutput>
                        </h3>
                        <p class="gh-list-item-meta">
                            <cfoutput>
                                Version #theme.version# &bull; By #theme.author#<br>
                                #theme.description#
                            </cfoutput>
                        </p>
                    </div>
                    <div class="gh-list-item-actions">
                        <cfif theme.active>
                            <div class="active-status">
                                <span>Active</span>
                            </div>
                        <cfelse>
                            <button class="gh-btn gh-btn-primary" onclick="activateTheme('<cfoutput>#theme.id#</cfoutput>')">
                                <span>Activate</span>
                            </button>
                        </cfif>
                    </div>
                </div>
                </cfloop>
            </div>

            <cfif arrayLen(themes) EQ 0>
                <div class="no-posts-box">
                    <div class="no-posts">
                        <h3>No themes found</h3>
                        <p>Upload a new theme to get started.</p>
                    </div>
                </div>
            </cfif>
        </div>
        
        <!--- Marketplace Tab Content --->
        <div id="marketplace-tab" class="tab-content" style="display: none;">
            <div class="marketplace-placeholder">
                <h3>Theme Marketplace</h3>
                <p>Browse and install themes from the Ghost marketplace.</p>
                <p class="coming-soon">Coming soon...</p>
            </div>
        </div>
    </section>
</div>

<style>
/* Content Filter Tabs */
.gh-contentfilter {
    border-bottom: 1px solid var(--whitegrey);
    margin-bottom: 2rem;
}

.gh-contentfilter-menu {
    display: flex;
    margin: 0;
    padding: 0;
    list-style: none;
}

.gh-contentfilter-menu-item {
    margin-right: 2rem;
}

.gh-contentfilter-menu-link {
    display: block;
    padding: 1rem 0;
    color: var(--midgrey);
    text-decoration: none;
    font-weight: 500;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.2px;
    position: relative;
    transition: color 0.2s ease;
}

.gh-contentfilter-menu-link:hover {
    color: var(--darkgrey);
}

.gh-contentfilter-menu-link.active {
    color: var(--darkgrey);
}

.gh-contentfilter-menu-link.active::after {
    content: '';
    position: absolute;
    bottom: -1px;
    left: 0;
    right: 0;
    height: 3px;
    background: var(--blue);
}

.gh-list-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.gh-list-data {
    flex: 1;
}

.gh-list-item-title {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0 0 0.5rem 0;
    color: var(--darkgrey);
}

.gh-list-item-meta {
    font-size: 0.875rem;
    color: var(--midgrey);
    margin: 0;
}

.theme-item {
    padding: 2rem;
    border: 1px solid var(--whitegrey);
    border-radius: 8px;
    margin-bottom: 1rem;
    transition: all 0.3s ease;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.theme-item:hover {
    border-color: var(--lightgrey);
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.theme-item.active {
    border-color: #3b82f6;
    background: rgba(59, 130, 246, 0.05);
}

.gh-list-item-actions {
    display: flex;
    gap: 1rem;
    align-items: center;
    flex-shrink: 0;
}

/* Ensure consistent button sizing */
.gh-btn {
    min-width: 90px;
}


.active-status {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 90px;
    height: 38px;
    padding: 0 20px;
    color: #3b82f6;
    font-size: 14px;
    font-weight: 600;
    letter-spacing: 0.2px;
}

.active-status span {
    color: #3b82f6;
}

.marketplace-placeholder {
    text-align: center;
    padding: 4rem 2rem;
    color: var(--midgrey);
}

.marketplace-placeholder h3 {
    font-size: 1.8rem;
    margin-bottom: 1rem;
    color: var(--darkgrey);
}

.marketplace-placeholder p {
    font-size: 1.2rem;
    margin-bottom: 0.5rem;
}

.marketplace-placeholder .coming-soon {
    font-style: italic;
    color: var(--lightgrey);
    margin-top: 2rem;
}
</style>

<script>
function activateTheme(themeId) {
    if (confirm('Are you sure you want to activate this theme?')) {
        fetch('ajax/activate-theme.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ theme: themeId })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showMessage('Theme activated successfully', 'success');
                setTimeout(() => location.reload(), 1000);
            } else {
                showMessage(data.message || 'Failed to activate theme', 'error');
            }
        })
        .catch(error => {
            showMessage('An error occurred', 'error');
        });
    }
}

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

// Tab switching functionality
document.addEventListener('DOMContentLoaded', function() {
    const tabLinks = document.querySelectorAll('.gh-contentfilter-menu-link');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Remove active class from all links
            tabLinks.forEach(l => l.classList.remove('active'));
            
            // Add active class to clicked link
            this.classList.add('active');
            
            // Hide all tab contents
            tabContents.forEach(content => content.style.display = 'none');
            
            // Show corresponding tab content
            const tabName = this.getAttribute('data-tab');
            const tabContent = document.getElementById(tabName + '-tab');
            if (tabContent) {
                tabContent.style.display = 'block';
            }
        });
    });
});
</script>

<cfinclude template="../includes/footer.cfm">