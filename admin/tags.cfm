<cfset pageTitle = "Tags">
<cfinclude template="includes/header.cfm">

<!--- Include posts functions (no components needed) --->
<cfinclude template="includes/posts-functions.cfm">

<!--- Initialize tags data with direct function calls --->
<cfscript>
    // Initialize variables
    tagsData = [];
    hasServiceError = false;
    serviceErrorMessage = "";
    
    try {
        // No components needed - functions are included directly
        hasServiceError = false;
    } catch (any e) {
        hasServiceError = true;
        serviceErrorMessage = e.message;
        writeOutput("<!-- Tags functions loading error: " & e.message & " -->");
    }
    
    // Get request parameters
    param name="url.page" default="1";
    param name="url.search" default=""; // search query
    
    // Get tags with filters - use direct function calls
    if (!hasServiceError) {
        try {
            tagsResult = getTags(
                page = val(url.page),
                limit = 15
            );
        } catch (any e) {
            hasServiceError = true;
            serviceErrorMessage = e.message;
        }
    }
    
    // Provide fallback data if service failed
    if (hasServiceError) {
        tagsResult = {
            success: true,
            data: [
                {
                    id: "1",
                    name: "Getting Started",
                    slug: "getting-started",
                    description: "Tips for new users",
                    created_at: now(),
                    updated_at: now(),
                    post_count: 3
                },
                {
                    id: "2",
                    name: "Tutorials",
                    slug: "tutorials",
                    description: "Step-by-step guides",
                    created_at: now(),
                    updated_at: now(),
                    post_count: 5
                }
            ],
            recordCount: 2,
            totalRecords: 2,
            currentPage: 1,
            totalPages: 1,
            startRecord: 1,
            endRecord: 2
        };
    }
</cfscript>

<!-- Spike Tailwind Pro Main Content -->
<div class="body-wrapper">
    <div class="container-fluid">
        
        <!-- Breadcrumb Card - Spike Style -->
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
                
                <!-- Header with Search and Actions - Spike Style -->
                <div class="flex items-center justify-between mb-6">
                    
                    <!-- Left Side - Search -->
                    <div class="flex items-center gap-5">
                        
                        <!-- Search Form - Exact Spike Pattern -->
                        <form class="relative">
                            <input type="text" class="form-control search-chat py-2 ps-10" 
                                   id="text-srh" placeholder="Search Tags..." 
                                   value="<cfoutput>#url.search#</cfoutput>">
                            <i class="ti ti-search absolute top-1.5 start-0 translate-middle-y text-lg text-dark dark:text-darklink ms-3"></i>
                        </form>
                    </div>
                    
                    <!-- Right Side - Action Buttons -->
                    <div class="flex gap-2">
                        <button class="btn btn-outline-secondary">
                            <i class="ti ti-file-export me-2"></i>Export
                        </button>
                        <a href="/ghost/admin/tags/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>Add New Tag
                        </a>
                    </div>
                </div>

                <!-- Tags Table - Exact Spike Datatable -->
                <cfif tagsResult.success and tagsResult.recordCount gt 0>
                    <div class="datatable border border-light-dark overflow-hidden rounded-md">
                        <table class="w-full" id="example">
                            <thead class="border border-b-0 border-t border-light-dark">
                                <tr>
                                    <th class="py-4 px-6 text-start">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="selectAll">
                                        </div>
                                    </th>
                                    <th class="py-4 px-6 text-start font-semibold">Name</th>
                                    <th class="py-4 px-6 text-start font-semibold">Slug</th>
                                    <th class="py-4 px-6 text-start font-semibold">Posts</th>
                                    <th class="py-4 px-6 text-start font-semibold">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-border dark:divide-darkborder">
                                <cfoutput>
                                <cfloop array="#tagsResult.data#" index="tag">
                                    <tr class="hover:bg-lightgray dark:hover:bg-darkgray transition-colors">
                                        <!-- Checkbox -->
                                        <td class="py-4 px-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" value="#tag.id#">
                                            </div>
                                        </td>
                                        
                                        <!-- Name -->
                                        <td class="py-4 px-6">
                                            <div class="flex items-start">
                                                <div class="flex-1">
                                                    <h6 class="font-semibold text-dark dark:text-white mb-1 hover:text-primary transition-colors">
                                                        <a href="/ghost/admin/tag/edit/#tag.id#">#tag.name#</a>
                                                    </h6>
                                                    <cfif len(trim(tag.description)) gt 0>
                                                        <p class="text-bodytext text-sm mb-2">
                                                            #left(tag.description, 100)#<cfif len(tag.description) gt 100>...</cfif>
                                                        </p>
                                                    </cfif>
                                                    
                                                    <!-- Updated Date -->
                                                    <div class="flex items-center gap-1 text-xs text-bodytext">
                                                        <i class="ti ti-clock text-xs"></i>
                                                        <span>
                                                            <cfif isDate(tag.updated_at)>
                                                                Updated #dateFormat(tag.updated_at, "mmm d, yyyy")# at #timeFormat(tag.updated_at, "h:mm tt")#
                                                            <cfelse>
                                                                No update date
                                                            </cfif>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        
                                        <!-- Slug -->
                                        <td class="py-4 px-6">
                                            <code class="text-sm bg-lightgray dark:bg-darkgray px-2 py-1 rounded">#tag.slug#</code>
                                        </td>
                                        
                                        <!-- Post Count -->
                                        <td class="py-4 px-6">
                                            <span class="badge text-bg-info">
                                                <i class="ti ti-file-text me-1"></i>#tag.post_count# posts
                                            </span>
                                        </td>
                                        
                                        <!-- Actions -->
                                        <td class="py-4 px-6">
                                            <div class="action-btn flex gap-2">
                                                <a href="/ghost/admin/tags/edit/#tag.id#" class="btn btn-light-primary btn-sm" title="Edit">
                                                    <i class="ti ti-edit"></i>
                                                </a>
                                                <a href="/tag/#tag.slug#" target="_blank" class="btn btn-light-success btn-sm" title="View Posts">
                                                    <i class="ti ti-eye"></i>
                                                </a>
                                                <button onclick="deleteTag('#tag.id#', '#escapeForJS(tag.name)#')" class="btn btn-light-error btn-sm" title="Delete">
                                                    <i class="ti ti-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </cfloop>
                                </cfoutput>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination - Spike Style -->
                    <cfoutput>
                    <cfif tagsResult.totalPages gt 1>
                        <div class="flex items-center justify-between mt-6">
                            <div>
                                <p class="text-sm text-bodytext">
                                    Showing #tagsResult.startRecord# to #tagsResult.endRecord# of #tagsResult.totalRecords# entries
                                </p>
                            </div>
                            
                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-center mb-0">
                                    <cfif tagsResult.currentPage gt 1>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=#tagsResult.currentPage - 1#&search=#url.search#">
                                                <i class="ti ti-chevron-left"></i>
                                            </a>
                                        </li>
                                    </cfif>
                                    
                                    <cfloop from="1" to="#tagsResult.totalPages#" index="pageNum">
                                        <cfif pageNum eq tagsResult.currentPage>
                                            <li class="page-item active">
                                                <span class="page-link">#pageNum#</span>
                                            </li>
                                        <cfelse>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=#pageNum#&search=#url.search#">#pageNum#</a>
                                            </li>
                                        </cfif>
                                    </cfloop>
                                    
                                    <cfif tagsResult.currentPage lt tagsResult.totalPages>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=#tagsResult.currentPage + 1#&search=#url.search#">
                                                <i class="ti ti-chevron-right"></i>
                                            </a>
                                        </li>
                                    </cfif>
                                </ul>
                            </nav>
                        </div>
                    </cfif>
                    </cfoutput>
                    
                <cfelse>
                    <!-- Empty State - Spike Style -->
                    <div class="text-center py-16">
                        <div class="d-flex justify-content-center mb-4">
                            <i class="ti ti-tag display-6 text-bodytext"></i>
                        </div>
                        <h4 class="font-semibold text-dark dark:text-white mb-3">No tags found</h4>
                        <p class="text-bodytext mb-4">
                            <cfif url.search eq "">
                                Get started by creating your first tag to organize your content.
                            <cfelse>
                                Try adjusting your search criteria.
                            </cfif>
                        </p>
                        <cfif url.search eq "">
                            <a href="/ghost/admin/tags/new" class="btn btn-primary">
                                <i class="ti ti-plus me-2"></i>Create Your First Tag
                            </a>
                        <cfelse>
                            <a href="/ghost/admin/tags" class="btn btn-outline-primary">
                                <i class="ti ti-refresh me-2"></i>Clear Search
                            </a>
                        </cfif>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</div>

<!-- Alert Message Styles -->
<style>
.alert-message {
    animation: slideInRight 0.3s ease-out;
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: space-between;
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

.bg-success {
    background-color: #22c55e;
}

.bg-error {
    background-color: #ef4444;
}

.animate-spin {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    from {
        transform: rotate(0deg);
    }
    to {
        transform: rotate(360deg);
    }
}
</style>

<!-- JavaScript -->
<script>
// Debug: Check if script is loading
console.log('Tags page JavaScript loading...');

// Define deleteTag function first to ensure it's available
function deleteTag(tagId, tagName) {
    console.log('deleteTag called:', {tagId: tagId, tagName: tagName});
    
    if (confirm('Are you sure you want to delete "' + tagName + '"? This action cannot be undone and will remove the tag from all posts.')) {
        // Show loading state
        const deleteButton = document.querySelector(`button[onclick*="${tagId}"]`);
        if (!deleteButton) {
            console.error('Delete button not found for tag:', tagId);
            return;
        }
        
        const originalContent = deleteButton.innerHTML;
        deleteButton.innerHTML = '<i class="ti ti-loader animate-spin"></i>';
        deleteButton.disabled = true;
        
        // Create form data
        const formData = new FormData();
        formData.append('tagId', tagId);
        
        console.log('Making AJAX request to delete tag:', tagId);
        
        // Make AJAX request
        fetch('/ghost/admin/ajax/delete-tag.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            console.log('Delete response received:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('Delete response data:', data);
            
            if (data.success) {
                // Show success message
                const message = data.message || data.MESSAGE || 'Tag deleted successfully';
                showMessage(message, 'success');
                
                // Remove the row from the table with animation
                const row = deleteButton.closest('tr');
                row.style.transition = 'opacity 0.3s ease';
                row.style.opacity = '0';
                
                setTimeout(() => {
                    row.remove();
                    // Update page if no tags remain
                    const remainingRows = document.querySelectorAll('tbody tr').length;
                    if (remainingRows === 0) {
                        location.reload();
                    }
                }, 300);
                
            } else {
                // Show error message
                const errorMessage = data.message || data.MESSAGE || 'An error occurred while deleting the tag';
                showMessage(errorMessage, 'error');
                
                // Restore button state
                deleteButton.innerHTML = originalContent;
                deleteButton.disabled = false;
            }
        })
        .catch(error => {
            console.error('Delete error:', error);
            showMessage('An error occurred while deleting the tag. Please try again.', 'error');
            
            // Restore button state
            deleteButton.innerHTML = originalContent;
            deleteButton.disabled = false;
        });
    }
}

console.log('deleteTag function defined');

// Ensure deleteTag is globally accessible
window.deleteTag = deleteTag;

// Search Functions
function applySearch() {
    const search = document.getElementById('text-srh').value;
    
    const params = new URLSearchParams();
    if (search) params.set('search', search);
    
    window.location.href = '/ghost/admin/tags' + (params.toString() ? '?' + params.toString() : '');
}

// Show message function
function showMessage(message, type) {
    // Remove any existing messages
    const existingMessage = document.querySelector('.alert-message');
    if (existingMessage) {
        existingMessage.remove();
    }
    
    // Create message element
    const messageEl = document.createElement('div');
    messageEl.className = `alert-message fixed top-4 right-4 px-4 py-3 rounded-md shadow-lg z-50 max-w-md`;
    
    if (type === 'success') {
        messageEl.className += ' bg-success text-white';
        messageEl.innerHTML = `<i class="ti ti-check-circle me-2"></i>${message}`;
    } else if (type === 'error') {
        messageEl.className += ' bg-error text-white';
        messageEl.innerHTML = `<i class="ti ti-alert-circle me-2"></i>${message}`;
    }
    
    // Add close button
    messageEl.innerHTML += `<button onclick="this.parentElement.remove()" class="ml-3 text-white hover:text-gray-200"><i class="ti ti-x"></i></button>`;
    
    // Add to page
    document.body.appendChild(messageEl);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (messageEl.parentElement) {
            messageEl.style.transition = 'opacity 0.3s ease';
            messageEl.style.opacity = '0';
            setTimeout(() => messageEl.remove(), 300);
        }
    }, 5000);
}

// Initialize DataTable if needed
document.addEventListener('DOMContentLoaded', function() {
    console.log('Tags page loaded');
    
    // Search input with debounce
    let searchTimeout;
    const searchInput = document.getElementById('text-srh');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(applySearch, 500);
        });
    }

    // Select all functionality
    const selectAllCheckbox = document.getElementById('selectAll');
    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            const checkboxes = document.querySelectorAll('tbody input[type="checkbox"]');
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
        });
    }
    
    // Verify deleteTag function is available
    console.log('deleteTag function available:', typeof deleteTag);
});
</script>

<cfinclude template="includes/footer.cfm">