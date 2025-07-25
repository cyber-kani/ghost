<cfset pageTitle = "Pages">
<cfinclude template="includes/header.cfm">

<!--- Include posts functions (no components needed) --->
<cfinclude template="includes/posts-functions.cfm">

<!--- Initialize pages data with direct function calls --->
<cfscript>
    // Initialize variables
    pagesData = [];
    hasServiceError = false;
    serviceErrorMessage = "";
    
    try {
        // No components needed - functions are included directly
        hasServiceError = false;
    } catch (any e) {
        hasServiceError = true;
        serviceErrorMessage = e.message;
        writeOutput("<!-- Pages functions loading error: " & e.message & " -->");
    }
    
    // Get request parameters
    param name="url.page" default="1";
    param name="url.type" default=""; // all, draft, published, scheduled
    param name="url.author" default="";
    param name="url.search" default=""; // search query
    
    // Convert filters to our system
    statusFilter = "";
    if (url.type == "draft") statusFilter = "draft";
    else if (url.type == "published") statusFilter = "published";
    else if (url.type == "scheduled") statusFilter = "scheduled";
    
    // Get pages with filters - use direct function calls
    if (!hasServiceError) {
        try {
            pagesResult = getPages(
                page = val(url.page),
                limit = 15,
                status = statusFilter,
                author = url.author
            );
            
            // Get page statistics
            statsResult = getPageStats();
        } catch (any e) {
            hasServiceError = true;
            serviceErrorMessage = e.message;
        }
    }
    
    // Provide fallback data if service failed
    if (hasServiceError) {
        pagesResult = {
            success: true,
            data: [
                {
                    id: "1",
                    title: "About",
                    status: "published",
                    created_at: now(),
                    updated_at: now(),
                    published_at: now(),
                    featured: false,
                    created_by: "1",
                    feature_image: "",
                    plaintext: "Learn more about our website and mission..."
                }
            ],
            recordCount: 1,
            totalRecords: 1,
            currentPage: 1,
            totalPages: 1,
            startRecord: 1,
            endRecord: 1
        };
        
        statsResult = {
            success: true,
            stats: {
                total: 1,
                published: 1,
                draft: 0,
                scheduled: 0,
                posts: 0,
                pages: 1,
                featured: 0
            }
        };
    }
    
    // Get authors from database - simplified approach
    authors = [];
    if (!hasServiceError) {
        try {
            // Get unique authors from posts table where type = 'page'
            authorsQuery = queryExecute("SELECT DISTINCT created_by FROM posts WHERE created_by IS NOT NULL AND type = 'page'", {}, {datasource: "blog"});
            for (row = 1; row <= authorsQuery.recordCount; row++) {
                authorStruct = {
                    id: authorsQuery.created_by[row],
                    name: "Author " & authorsQuery.created_by[row],
                    avatar: "https://ui-avatars.com/api/?name=Author+" & authorsQuery.created_by[row] & "&background=5D87FF&color=fff"
                };
                arrayAppend(authors, authorStruct);
            }
        } catch (any e) {
            // If author fetch fails, continue with empty array
        }
    }
    
    // Fallback authors if database fetch fails
    if (arrayLen(authors) == 0) {
        authors = [
            {id: "1", name: "John Doe", avatar: "https://ui-avatars.com/api/?name=John+Doe&background=5D87FF&color=fff"}
        ];
    }
    
    // Available filter options
    variables.availableTypes = [
        {value: "", label: "All pages"},
        {value: "draft", label: "Draft"},
        {value: "published", label: "Published"},
        {value: "scheduled", label: "Scheduled"}
    ];
</cfscript>

<!-- Spike Tailwind Pro Main Content -->
<div class="body-wrapper">
    <div class="container-fluid">
        
        <!-- Breadcrumb Card - Spike Style -->
        <div class="card mb-6 shadow-none">
            <div class="card-body p-6">
                <div class="sm:flex items-center justify-between">
                    <div>
                        <h4 class="font-semibold text-xl text-dark dark:text-white">Pages</h4>
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
                        <li class="flex items-center text-sm font-medium" aria-current="page">Pages</li>
                    </ol>
                </div>
            </div>
        </div>

        <!-- Main Content Card -->
        <div class="card">
            <div class="card-body">
                
                <!-- Header with Search and Actions - Spike Style -->
                <div class="flex items-center justify-between mb-6">
                    
                    <!-- Left Side - Search and Filters -->
                    <div class="flex items-center gap-5">
                        
                        <!-- Search Form - Exact Spike Pattern -->
                        <form class="relative">
                            <input type="text" class="form-control search-chat py-2 ps-10" 
                                   id="text-srh" placeholder="Search Pages..." 
                                   value="<cfoutput>#url.search#</cfoutput>">
                            <i class="ti ti-search absolute top-1.5 start-0 translate-middle-y text-lg text-dark dark:text-darklink ms-3"></i>
                        </form>
                        
                        <!-- Filter Dropdowns -->
                        <div class="flex gap-3">
                            <select class="form-select" id="typeFilter" onchange="applyFilters()">
                                <cfoutput>
                                <cfloop array="#variables.availableTypes#" index="type">
                                    <option value="#type.value#" <cfif url.type eq type.value>selected</cfif>>#type.label#</option>
                                </cfloop>
                                </cfoutput>
                            </select>
                            
                            <select class="form-select" id="authorFilter" onchange="applyFilters()">
                                <option value="">All authors</option>
                                <cfoutput>
                                <cfloop array="#authors#" index="author">
                                    <option value="#author.id#" <cfif url.author eq author.id>selected</cfif>>#author.name#</option>
                                </cfloop>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Right Side - Action Buttons -->
                    <div class="flex gap-2">
                        <button class="btn btn-outline-secondary">
                            <i class="ti ti-file-export me-2"></i>Export
                        </button>
                        <a href="/ghost/admin/pages/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>Add New Page
                        </a>
                    </div>
                </div>

                <!-- Pages Table - Exact Spike Datatable -->
                <cfif pagesResult.success and pagesResult.recordCount gt 0>
                    <div class="datatable border border-light-dark overflow-hidden rounded-md">
                        <table class="w-full" id="example">
                            <thead class="border border-b-0 border-t border-light-dark">
                                <tr>
                                    <th class="py-4 px-6 text-start">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" id="selectAll">
                                        </div>
                                    </th>
                                    <th class="py-4 px-6 text-start font-semibold">Title</th>
                                    <th class="py-4 px-6 text-start font-semibold">Status</th>
                                    <th class="py-4 px-6 text-start font-semibold">Actions</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-border dark:divide-darkborder">
                                <cfoutput>
                                <cfloop array="#pagesResult.data#" index="page">
                                    <tr class="hover:bg-lightgray dark:hover:bg-darkgray transition-colors">
                                        <!-- Checkbox -->
                                        <td class="py-4 px-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" value="#page.id#">
                                            </div>
                                        </td>
                                        
                                        <!-- Title -->
                                        <td class="py-4 px-6">
                                            <div class="flex items-start">
                                                <div class="flex-1">
                                                    <h6 class="font-semibold text-dark dark:text-white mb-1 hover:text-primary transition-colors">
                                                        <a href="/ghost/admin/pages/edit/#page.id#">#page.title#</a>
                                                    </h6>
                                                    <cfif structKeyExists(page, "plaintext") and len(trim(page.plaintext)) gt 0>
                                                        <p class="text-bodytext text-sm mb-2">
                                                            #left(page.plaintext, 80)#<cfif len(page.plaintext) gt 80>...</cfif>
                                                        </p>
                                                    </cfif>
                                                    
                                                    <!-- Author and Updated Info -->
                                                    <div class="flex items-center gap-4 text-xs text-bodytext">
                                                        <!-- Author Info -->
                                                        <div class="flex items-center gap-2">
                                                            <cfif structKeyExists(page, "author")>
                                                                <cfif len(trim(page.author.avatar)) gt 0>
                                                                    <img src="#page.author.avatar#" class="rounded-full" width="20" height="20" alt="Author">
                                                                </cfif>
                                                                <span>By #page.author.name#</span>
                                                            <cfelse>
                                                                <!-- Fallback for pages without enhanced author data -->
                                                                <cfset authorInfo = "">
                                                                <cfset authorAvatar = "">
                                                                <cfloop array="#authors#" index="author">
                                                                    <cfif author.id eq page.created_by>
                                                                        <cfset authorInfo = author.name>
                                                                        <cfset authorAvatar = author.avatar>
                                                                        <cfbreak>
                                                                    </cfif>
                                                                </cfloop>
                                                                <cfif len(authorAvatar) gt 0>
                                                                    <img src="#authorAvatar#" class="rounded-full" width="20" height="20" alt="Author">
                                                                </cfif>
                                                                <span>By 
                                                                    <cfif len(authorInfo) gt 0>
                                                                        #authorInfo#
                                                                    <cfelse>
                                                                        Unknown Author
                                                                    </cfif>
                                                                </span>
                                                            </cfif>
                                                        </div>
                                                        
                                                        <!-- Separator -->
                                                        <span>•</span>
                                                        
                                                        <!-- Updated Date -->
                                                        <div class="flex items-center gap-1">
                                                            <i class="ti ti-clock text-xs"></i>
                                                            <span>
                                                                <cfif isDate(page.updated_at)>
                                                                    Updated #dateFormat(page.updated_at, "mmm d, yyyy")# at #timeFormat(page.updated_at, "h:mm tt")#
                                                                <cfelse>
                                                                    No update date
                                                                </cfif>
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        
                                        <!-- Status -->
                                        <td class="py-4 px-6">
                                            <cfswitch expression="#page.status#">
                                                <cfcase value="published">
                                                    <span class="badge text-bg-success">
                                                        <i class="ti ti-check me-1"></i>Published
                                                    </span>
                                                </cfcase>
                                                <cfcase value="draft">
                                                    <span class="badge text-bg-warning">
                                                        <i class="ti ti-edit me-1"></i>Draft
                                                    </span>
                                                </cfcase>
                                                <cfcase value="scheduled">
                                                    <span class="badge text-bg-info">
                                                        <i class="ti ti-clock me-1"></i>Scheduled
                                                    </span>
                                                </cfcase>
                                                <cfdefaultcase>
                                                    <span class="badge text-bg-secondary">#page.status#</span>
                                                </cfdefaultcase>
                                            </cfswitch>
                                        </td>
                                        
                                        <!-- Actions -->
                                        <td class="py-4 px-6">
                                            <div class="action-btn flex gap-2">
                                                <a href="/ghost/admin/pages/edit/#page.id#" class="btn btn-light-primary btn-sm" title="Edit">
                                                    <i class="ti ti-edit"></i>
                                                </a>
                                                <cfif page.status eq "published">
                                                    <a href="/page/#page.id#" target="_blank" class="btn btn-light-success btn-sm" title="View">
                                                        <i class="ti ti-eye"></i>
                                                    </a>
                                                </cfif>
                                                <button onclick="deletePage('#page.id#', '#escapeForJS(page.title)#')" class="btn btn-light-error btn-sm" title="Delete">
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
                    <cfif pagesResult.totalPages gt 1>
                        <div class="flex items-center justify-between mt-6">
                            <div>
                                <p class="text-sm text-bodytext">
                                    Showing #pagesResult.startRecord# to #pagesResult.endRecord# of #pagesResult.totalRecords# entries
                                </p>
                            </div>
                            
                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-center mb-0">
                                    <cfif pagesResult.currentPage gt 1>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=#pagesResult.currentPage - 1#&type=#url.type#&author=#url.author#&search=#url.search#">
                                                <i class="ti ti-chevron-left"></i>
                                            </a>
                                        </li>
                                    </cfif>
                                    
                                    <cfloop from="1" to="#pagesResult.totalPages#" index="pageNum">
                                        <cfif pageNum eq pagesResult.currentPage>
                                            <li class="page-item active">
                                                <span class="page-link">#pageNum#</span>
                                            </li>
                                        <cfelse>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=#pageNum#&type=#url.type#&author=#url.author#&search=#url.search#">#pageNum#</a>
                                            </li>
                                        </cfif>
                                    </cfloop>
                                    
                                    <cfif pagesResult.currentPage lt pagesResult.totalPages>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=#pagesResult.currentPage + 1#&type=#url.type#&author=#url.author#&search=#url.search#">
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
                            <i class="ti ti-file-text display-6 text-bodytext"></i>
                        </div>
                        <h4 class="font-semibold text-dark dark:text-white mb-3">No pages found</h4>
                        <p class="text-bodytext mb-4">
                            <cfif url.type eq "" and url.author eq "" and url.search eq "">
                                Get started by creating your first page.
                            <cfelse>
                                Try adjusting your search or filter criteria.
                            </cfif>
                        </p>
                        <cfif url.type eq "" and url.author eq "" and url.search eq "">
                            <a href="/ghost/admin/pages/new" class="btn btn-primary">
                                <i class="ti ti-plus me-2"></i>Create Your First Page
                            </a>
                        <cfelse>
                            <a href="/ghost/admin/pages" class="btn btn-outline-primary">
                                <i class="ti ti-refresh me-2"></i>Clear Filters
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
console.log('Pages page JavaScript loading...');

// Define deletePage function first to ensure it's available
function deletePage(pageId, pageTitle) {
    console.log('deletePage called:', {pageId: pageId, pageTitle: pageTitle});
    
    if (confirm('Are you sure you want to delete "' + pageTitle + '"? This action cannot be undone.')) {
        // Show loading state
        const deleteButton = document.querySelector(`button[onclick*="${pageId}"]`);
        if (!deleteButton) {
            console.error('Delete button not found for page:', pageId);
            return;
        }
        
        const originalContent = deleteButton.innerHTML;
        deleteButton.innerHTML = '<i class="ti ti-loader animate-spin"></i>';
        deleteButton.disabled = true;
        
        // Create form data
        const formData = new FormData();
        formData.append('postId', pageId); // Using 'postId' since pages are stored in posts table
        
        console.log('Making AJAX request to delete page:', pageId);
        
        // Make AJAX request (using same endpoint as posts since pages are in posts table)
        fetch('/ghost/admin/ajax/delete-post.cfm', {
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
                const message = data.message || data.MESSAGE || 'Page deleted successfully';
                showMessage(message, 'success');
                
                // Remove the row from the table with animation
                const row = deleteButton.closest('tr');
                row.style.transition = 'opacity 0.3s ease';
                row.style.opacity = '0';
                
                setTimeout(() => {
                    row.remove();
                    // Update page if no pages remain
                    const remainingRows = document.querySelectorAll('tbody tr').length;
                    if (remainingRows === 0) {
                        location.reload();
                    }
                }, 300);
                
            } else {
                // Show error message
                const errorMessage = data.message || data.MESSAGE || 'An error occurred while deleting the page';
                showMessage(errorMessage, 'error');
                
                // Restore button state
                deleteButton.innerHTML = originalContent;
                deleteButton.disabled = false;
            }
        })
        .catch(error => {
            console.error('Delete error:', error);
            showMessage('An error occurred while deleting the page. Please try again.', 'error');
            
            // Restore button state
            deleteButton.innerHTML = originalContent;
            deleteButton.disabled = false;
        });
    }
}

console.log('deletePage function defined');

// Ensure deletePage is globally accessible
window.deletePage = deletePage;

// Filter and Search Functions
function applyFilters() {
    const type = document.getElementById('typeFilter').value;
    const author = document.getElementById('authorFilter').value;
    const search = document.getElementById('text-srh').value;
    
    const params = new URLSearchParams();
    if (type) params.set('type', type);
    if (author) params.set('author', author);
    if (search) params.set('search', search);
    
    window.location.href = '/ghost/admin/pages' + (params.toString() ? '?' + params.toString() : '');
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
    console.log('Pages page loaded');
    
    // Search input with debounce
    let searchTimeout;
    const searchInput = document.getElementById('text-srh');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(applyFilters, 500);
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
    
    // Verify deletePage function is available
    console.log('deletePage function available:', typeof deletePage);
});
</script>

<cfinclude template="includes/footer.cfm">