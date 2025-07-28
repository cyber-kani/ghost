<cfparam name="url.type" default="public">
<cfparam name="url.search" default="">
<cfparam name="request.dsn" default="blog">

<cfset pageTitle = "Tags">
<cfinclude template="includes/header.cfm">

<!--- Ensure userRole is available --->
<cfif NOT structKeyExists(session, "userRole")>
    <cfset session.userRole = "Author">
</cfif>

<!--- Include posts functions (no components needed) --->
<cfinclude template="includes/posts-functions.cfm">

<!--- Initialize tags data with direct function calls --->
<cfscript>
    // Initialize variables
    tagsData = [];
    hasServiceError = false;
    serviceErrorMessage = "";
    
    try {
        // Test database connection
        testQuery = queryExecute("SELECT 1 as test", {}, {datasource: request.dsn});
        hasServiceError = false;
    } catch (any e) {
        hasServiceError = true;
        serviceErrorMessage = e.message;
        writeOutput("<!-- Tags functions loading error: " & e.message & " -->");
    }
    
    // Get request parameters
    param name="url.page" default="1";
    
    // Get all tags
    if (!hasServiceError) {
        try {
            // Get tags based on type (public or internal)
            whereClause = "";
            if (url.type == "internal") {
                whereClause = "WHERE t.name LIKE '##%'";
            } else {
                whereClause = "WHERE t.name NOT LIKE '##%'";
            }
            
            // Get tags with post count
            tagsQuery = queryExecute("
                SELECT 
                    t.*,
                    COUNT(DISTINCT pt.post_id) as post_count
                FROM tags t
                LEFT JOIN posts_tags pt ON t.id = pt.tag_id
                #whereClause#
                GROUP BY t.id
                ORDER BY t.name ASC
            ", {}, {datasource: request.dsn});
            
            // Convert to array
            tags = [];
            for (row = 1; row <= tagsQuery.recordCount; row++) {
                tagStruct = {
                    id: tagsQuery.id[row],
                    name: tagsQuery.name[row],
                    slug: tagsQuery.slug[row],
                    description: tagsQuery.description[row] ?: "",
                    feature_image: tagsQuery.feature_image[row] ?: "",
                    visibility: tagsQuery.visibility[row] ?: "public",
                    meta_title: tagsQuery.meta_title[row] ?: "",
                    meta_description: tagsQuery.meta_description[row] ?: "",
                    accent_color: tagsQuery.accent_color[row] ?: "",
                    created_at: tagsQuery.created_at[row],
                    updated_at: tagsQuery.updated_at[row],
                    post_count: tagsQuery.post_count[row]
                };
                arrayAppend(tags, tagStruct);
            }
            
            // Filter by search if provided
            if (len(url.search)) {
                filteredTags = [];
                for (tag in tags) {
                    if (findNoCase(url.search, tag.name) || findNoCase(url.search, tag.slug)) {
                        arrayAppend(filteredTags, tag);
                    }
                }
                tags = filteredTags;
            }
            
        } catch (any e) {
            hasServiceError = true;
            serviceErrorMessage = e.message;
            writeOutput("<!-- Tags query error: " & e.message & " -->");
            tags = [];
        }
    } else {
        tags = [];
    }
</cfscript>

<!-- Modern UI Main Content -->
<div class="body-wrapper">
    <div class="container-fluid">
        
        <!-- Breadcrumb Card - Modern Style -->
        <div class="card mb-6 shadow-none">
            <div class="card-body p-6">
                <div class="sm:flex items-center justify-between">
                    <div>
                        <h4 class="font-semibold text-xl text-dark dark:text-white">Tags</h4>
                        <cfif hasServiceError>
                            <div class="mt-2 flex items-center">
                                <i class="ti ti-alert-circle text-error me-2"></i>
                                <span class="text-sm text-error">
                                    <cfoutput>Service Error: #serviceErrorMessage# (showing sample data)</cfoutput>
                                </span>
                            </div>
                        </cfif>
                    </div>
                    <ol class="flex items-center" aria-label="Breadcrumb">
                        <li class="flex items-center">
                            <a class="text-sm font-medium" href="/ghost/admin">Home</a>
                        </li>
                        <li>
                            <div class="h-1 w-1 rounded-full bg-bodytext mx-2.5 flex items-center mt-1"></div>
                        </li>
                        <li class="flex items-center text-sm font-medium" aria-current="page">Tags</li>
                    </ol>
                </div>
            </div>
        </div>

        <!-- Main Content Card -->
        <div class="card">
            <div class="card-body">
                
                <!-- Header with Search and Actions -->
                <div class="flex items-center justify-between mb-6">
                    
                    <!-- Left Side - Search and Filters -->
                    <div class="flex items-center gap-5">
                        
                        <!-- Search Form -->
                        <form class="relative" method="get">
                            <input type="hidden" name="type" value="<cfoutput>#url.type#</cfoutput>">
                            <input type="text" 
                                   class="form-control search-chat py-2 ps-10" 
                                   id="tag-search" 
                                   name="search"
                                   placeholder="Search Tags..." 
                                   value="<cfoutput>#url.search#</cfoutput>"
                                   autocomplete="off">
                            <i class="ti ti-search absolute top-1.5 start-0 translate-middle-y text-lg text-dark dark:text-darklink ms-3"></i>
                        </form>
                        
                        <!-- Type Filter Toggle -->
                        <div class="flex gap-2">
                            <a href="?type=public&search=<cfoutput>#url.search#</cfoutput>" 
                               class="px-4 py-2 rounded-md text-sm font-medium transition-all border <cfif url.type eq 'public'>bg-primary text-white border-primary<cfelse>bg-white text-gray-600 hover:text-gray-900 border-gray-300 hover:border-gray-400</cfif>">
                                Public tags
                            </a>
                            <a href="?type=internal&search=<cfoutput>#url.search#</cfoutput>" 
                               class="px-4 py-2 rounded-md text-sm font-medium transition-all border <cfif url.type eq 'internal'>bg-primary text-white border-primary<cfelse>bg-white text-gray-600 hover:text-gray-900 border-gray-300 hover:border-gray-400</cfif>">
                                Internal tags
                            </a>
                        </div>
                    </div>
                    
                    <!-- Right Side - Action Button -->
                    <div class="flex gap-2">
                        <a href="/ghost/admin/tags/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>New Tag
                        </a>
                    </div>
                </div>

                <!-- Tags List -->
                <cfif arrayLen(tags) gt 0>
                    <div class="tags-grid">
                        <cfoutput>
                        <cfloop array="#tags#" index="tag">
                            <div class="tag-card group" data-tag-id="#tag.id#">
                                <a href="/ghost/admin/tags/edit/#tag.id#" class="tag-card-link">
                                    <!-- Tag Header -->
                                    <div class="tag-card-header">
                                        <cfif len(tag.accent_color)>
                                            <div class="tag-color-indicator" style="background-color: ###tag.accent_color#"></div>
                                        <cfelse>
                                            <div class="tag-color-indicator" style="background-color: ##15171A"></div>
                                        </cfif>
                                        <h3 class="tag-name">
                                            #htmlEditFormat(tag.name)#
                                        </h3>
                                        <span class="tag-type-badge">
                                            <cfif left(tag.name, 1) eq "##">
                                                <i class="ti ti-lock text-xs"></i>
                                                Internal
                                            <cfelse>
                                                <i class="ti ti-world text-xs"></i>
                                                Public
                                            </cfif>
                                        </span>
                                    </div>
                                    
                                    <!-- Tag Description -->
                                    <cfif len(tag.description)>
                                        <p class="tag-description">
                                            #left(tag.description, 100)#<cfif len(tag.description) gt 100>...</cfif>
                                        </p>
                                    <cfelse>
                                        <p class="tag-description text-gray-400">
                                            No description
                                        </p>
                                    </cfif>
                                    
                                    <!-- Tag Meta -->
                                    <div class="tag-meta">
                                        <div class="tag-meta-item">
                                            <i class="ti ti-code text-sm"></i>
                                            <span class="font-mono text-xs">#tag.slug#</span>
                                        </div>
                                        <div class="tag-meta-item">
                                            <i class="ti ti-file-text text-sm"></i>
                                            <span>#tag.post_count# <cfif tag.post_count eq 1>post<cfelse>posts</cfif></span>
                                        </div>
                                    </div>
                                    
                                    <!-- Tag Actions -->
                                    <div class="tag-actions">
                                        <cfif tag.post_count gt 0>
                                            <a href="/ghost/admin/posts?tag=#tag.slug#" 
                                               class="tag-action-btn" 
                                               title="View posts"
                                               onclick="event.preventDefault(); event.stopPropagation(); window.location.href=this.href;">
                                                <i class="ti ti-eye"></i>
                                                View posts
                                            </a>
                                        </cfif>
                                        <button class="tag-action-btn tag-more-btn" 
                                                onclick="event.preventDefault(); event.stopPropagation(); toggleTagMenu('#tag.id#')">
                                            <i class="ti ti-dots-vertical"></i>
                                        </button>
                                    </div>
                                </a>
                                
                                <!-- Tag Menu -->
                                <div class="tag-menu" id="tagMenu#tag.id#">
                                    <button onclick="deleteTag('#tag.id#', '#escapeForJS(tag.name)#')" class="text-red-600">
                                        <i class="ti ti-trash"></i>Delete
                                    </button>
                                </div>
                            </div>
                        </cfloop>
                        </cfoutput>
                    </div>
                <cfelse>
                    <!-- Empty State -->
                    <div class="text-center py-16">
                        <div class="d-flex justify-content-center mb-4">
                            <i class="ti ti-tags display-6 text-bodytext"></i>
                        </div>
                        <h4 class="font-semibold text-dark dark:text-white mb-3">Start organizing your content</h4>
                        <p class="text-bodytext mb-4">
                            <cfif url.type eq "internal">
                                No internal tags found. Internal tags start with ## and are hidden from the public.
                            <cfelse>
                                Tags help organize your content and improve discoverability.
                            </cfif>
                        </p>
                        <a href="/ghost/admin/tags/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>Create your first tag
                        </a>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</div>

<style>
/* Modern Tags Grid Layout */
.tags-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.5rem;
}

/* Tag Card */
.tag-card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    overflow: hidden;
    transition: all 0.2s ease;
    position: relative;
}

.tag-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    border-color: #d1d5db;
    transform: translateY(-2px);
}

.tag-card-link {
    display: block;
    padding: 1.5rem;
    text-decoration: none;
    color: inherit;
}

/* Tag Header */
.tag-card-header {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 0.75rem;
}

.tag-color-indicator {
    width: 16px;
    height: 16px;
    border-radius: 50%;
    flex-shrink: 0;
}

.tag-name {
    font-size: 1.125rem;
    font-weight: 600;
    margin: 0;
    flex: 1;
    color: #111827;
}

.tag-type-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 0.25rem 0.5rem;
    border-radius: 6px;
    background: #f3f4f6;
    color: #6b7280;
}

/* Tag Description */
.tag-description {
    font-size: 0.875rem;
    line-height: 1.5;
    color: #64748b;
    margin: 0 0 1rem 0;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Tag Meta */
.tag-meta {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
    padding-top: 0.75rem;
    border-top: 1px solid #f3f4f6;
}

.tag-meta-item {
    display: flex;
    align-items: center;
    gap: 0.375rem;
    font-size: 0.75rem;
    color: #6b7280;
}

.tag-meta-item i {
    color: #9ca3af;
}

/* Tag Actions */
.tag-actions {
    display: flex;
    gap: 0.5rem;
    opacity: 0;
    transition: opacity 0.2s ease;
    align-items: center;
    justify-content: space-between;
}

.tag-card:hover .tag-actions {
    opacity: 1;
}

.tag-action-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.375rem 0.75rem;
    background: #f3f4f6;
    color: #4b5563;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    font-size: 0.75rem;
    font-weight: 500;
    text-decoration: none;
    transition: all 0.2s ease;
    cursor: pointer;
}

.tag-action-btn:hover {
    background: #6366f1;
    color: white;
    border-color: #6366f1;
}

.tag-more-btn {
    margin-left: auto;
    padding: 0.375rem;
    width: 28px;
    height: 28px;
    justify-content: center;
}

/* Tag Menu */
.tag-menu {
    position: absolute;
    top: 3.5rem;
    right: 1.5rem;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    min-width: 120px;
    z-index: 1000;
    display: none;
}

.tag-menu.show {
    display: block;
}

.tag-menu button {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: none;
    background: none;
    text-align: left;
    font-size: 0.75rem;
    cursor: pointer;
    transition: background 0.2s ease;
}

.tag-menu button:hover {
    background: #f9fafb;
}

/* Search Styles */
.search-chat {
    min-width: 300px;
}

/* Type Filter Toggle */
.bg-primary {
    background-color: #6366f1 !important;
}

.text-primary {
    color: #6366f1 !important;
}

.border-primary {
    border-color: #6366f1 !important;
}

/* Responsive Design */
@media (max-width: 768px) {
    .tags-grid {
        grid-template-columns: 1fr;
    }
    
    .flex.items-center.gap-5 {
        flex-direction: column;
        gap: 1rem;
        align-items: stretch;
    }
    
    .search-chat {
        min-width: 100%;
    }
}

/* Ghost Modal Styles */
.ghost-modal-backdrop {
    position: fixed;
    inset: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
}

.ghost-modal {
    background-color: white;
    border-radius: 0.5rem;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    max-width: 32rem;
    width: 100%;
    margin: 1rem;
    transform: scale(0.95);
    opacity: 0;
    transition: all 0.2s ease-out;
}

.ghost-modal-header {
    padding: 1.5rem;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}

.ghost-modal-header h3 {
    font-size: 1.125rem;
    font-weight: 600;
    color: #111827;
    margin: 0;
    padding-right: 1rem;
}

.ghost-modal-close {
    background: none;
    border: none;
    color: #6b7280;
    cursor: pointer;
    padding: 0.25rem;
    margin: -0.25rem -0.25rem -0.25rem 0;
    border-radius: 0.25rem;
    transition: color 0.15s ease-in-out;
}

.ghost-modal-close:hover {
    color: #111827;
}

.ghost-modal-body {
    padding: 1.5rem;
}

.ghost-modal-body p {
    margin: 0;
}

.ghost-modal-footer {
    padding: 1.5rem;
    border-top: 1px solid #e5e7eb;
    display: flex;
    gap: 0.75rem;
    justify-content: flex-end;
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
</style>

<script>
// Escape string for JavaScript
function escapeForJS(str) {
    return str.replace(/\\/g, '\\\\')
              .replace(/'/g, "\\'")
              .replace(/"/g, '\\"')
              .replace(/\n/g, '\\n')
              .replace(/\r/g, '\\r');
}

// Toggle tag menu
function toggleTagMenu(tagId) {
    // Close all other menus first
    document.querySelectorAll('.tag-menu').forEach(menu => {
        if (menu.id !== `tagMenu${tagId}`) {
            menu.classList.remove('show');
        }
    });
    
    // Toggle current menu
    const menu = document.getElementById(`tagMenu${tagId}`);
    menu.classList.toggle('show');
}

// Close menus when clicking outside
document.addEventListener('click', function(e) {
    if (!e.target.closest('.tag-more-btn') && !e.target.closest('.tag-menu')) {
        document.querySelectorAll('.tag-menu').forEach(menu => {
            menu.classList.remove('show');
        });
    }
});

// Delete tag function
function deleteTag(tagId, tagName) {
    // Show custom delete modal
    showDeleteModal(tagId, tagName);
}

// Show delete confirmation modal
function showDeleteModal(tagId, tagName) {
    // Create modal backdrop
    const backdrop = document.createElement('div');
    backdrop.className = 'ghost-modal-backdrop';
    backdrop.id = 'deleteModalBackdrop';
    
    // Create modal
    const modal = document.createElement('div');
    modal.className = 'ghost-modal';
    modal.innerHTML = `
        <div class="ghost-modal-header">
            <h3>Are you sure you want to delete this tag?</h3>
            <button type="button" class="ghost-modal-close" onclick="closeDeleteModal()">
                <i class="ti ti-x text-xl"></i>
            </button>
        </div>
        <div class="ghost-modal-body">
            <p class="text-gray-600 text-base mb-2">
                You're about to delete "<strong>${tagName}</strong>". 
                This will remove the tag from all posts. This action cannot be undone.
            </p>
        </div>
        <div class="ghost-modal-footer">
            <button type="button" class="ghost-btn ghost-btn-link" onclick="closeDeleteModal()">
                Cancel
            </button>
            <button type="button" class="ghost-btn ghost-btn-red" onclick="executeDeleteTag('${tagId}')">
                <span>Delete</span>
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

// Execute delete
function executeDeleteTag(tagId) {
    closeDeleteModal();
    
    // Show loading message
    showMessage('Deleting tag...', 'info');
    
    // Send delete request
    fetch('/ghost/admin/ajax/delete-tag.cfm', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ tagId: tagId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success || data.SUCCESS) {
            showMessage(data.message || 'Tag deleted successfully', 'success');
            // Remove tag card from DOM
            const tagCard = document.querySelector(`[data-tag-id="${tagId}"]`);
            if (tagCard) {
                tagCard.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                tagCard.style.opacity = '0';
                tagCard.style.transform = 'scale(0.95)';
                setTimeout(() => {
                    tagCard.remove();
                    // Check if no tags remain
                    if (document.querySelectorAll('.tag-card').length === 0) {
                        location.reload();
                    }
                }, 300);
            }
        } else {
            showMessage(data.message || 'Failed to delete tag', 'error');
        }
    })
    .catch(error => {
        console.error('Delete error:', error);
        showMessage('Failed to delete tag', 'error');
    });
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

// Keyboard shortcut for new tag
document.addEventListener('keydown', function(e) {
    // Press 'c' to create new tag (when not in input)
    if (e.key === 'c' && !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        window.location.href = '/ghost/admin/tags/new';
    }
});

// Auto-submit search on input
const searchInput = document.getElementById('tag-search');
if (searchInput) {
    let searchTimeout;
    searchInput.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            this.form.submit();
        }, 500);
    });
}
</script>

<cfinclude template="includes/footer.cfm">