<cfparam name="url.type" default="">
<cfparam name="request.dsn" default="blog">
<cfparam name="url.visibility" default="">
<cfparam name="url.author" default="">
<cfparam name="url.tag" default="">
<cfparam name="url.order" default="newest">
<cfparam name="url.search" default="">

<cfswitch expression="#url.type#">
    <cfcase value="draft">
        <cfset pageTitle = "Draft Pages">
    </cfcase>
    <cfcase value="published">
        <cfset pageTitle = "Published Pages">
    </cfcase>
    <cfcase value="scheduled">
        <cfset pageTitle = "Scheduled Pages">
    </cfcase>
    <cfdefaultcase>
        <cfset pageTitle = "Pages">
    </cfdefaultcase>
</cfswitch>
<cfinclude template="includes/header.cfm">

<!--- Ensure userRole is available --->
<cfif NOT structKeyExists(session, "userRole")>
    <cfset session.userRole = "Author">
</cfif>

<!--- Include posts functions (no components needed) --->
<cfinclude template="includes/posts-functions.cfm">

<!--- Initialize pages data with direct function calls --->
<cfscript>
    // Initialize variables
    pagesData = [];
    hasServiceError = false;
    serviceErrorMessage = "";
    
    try {
        // Test database connection and function availability
        testQuery = queryExecute("SELECT 1 as test", {}, {datasource: request.dsn});
        hasServiceError = false;
    } catch (any e) {
        hasServiceError = true;
        serviceErrorMessage = e.message;
        writeOutput("<!-- Pages functions loading error: " & e.message & " -->");
    }
    
    // Get request parameters
    param name="url.page" default="1";
    
    // Convert filters to our system
    statusFilter = "";
    if (url.type == "draft") statusFilter = "draft";
    else if (url.type == "published") statusFilter = "published";
    else if (url.type == "scheduled") statusFilter = "scheduled";
    else if (url.type == "featured") statusFilter = "featured";
    
    // Get pages with filters - use direct function calls
    if (!hasServiceError) {
        try {
            pagesResult = getPages(
                page = val(url.page),
                limit = 15,
                status = statusFilter,
                author = url.author,
                tag = url.tag,
                visibility = url.visibility,
                order = url.order,
                search = url.search
            );
            
            // Get page statistics
            statsResult = getPageStats();
        } catch (any e) {
            hasServiceError = true;
            serviceErrorMessage = e.message;
            writeOutput("<!-- Pages query error: " & e.message & " -->");
            
            // Create empty result structure
            pagesResult = {
                success: false,
                data: [],
                recordCount: 0,
                totalPages: 0,
                currentPage: 1
            };
            
            statsResult = {
                total: 0,
                published: 0,
                draft: 0,
                scheduled: 0
            };
        }
    } else {
        // Create empty result structure
        pagesResult = {
            success: false,
            data: [],
            recordCount: 0,
            totalPages: 0,
            currentPage: 1
        };
        
        statsResult = {
            total: 0,
            published: 0,
            draft: 0,
            scheduled: 0
        };
    }
    
    // Get authors from database
    authors = [];
    if (!hasServiceError) {
        try {
            // Get all users who have created pages
            authorsQuery = queryExecute("
                SELECT DISTINCT u.id, u.name, u.email, u.profile_image
                FROM users u
                INNER JOIN posts p ON u.id = p.created_by
                WHERE u.status = 'active'
                AND p.type = 'page'
                ORDER BY u.name ASC
            ", {}, {datasource: request.dsn});
            
            for (row = 1; row <= authorsQuery.recordCount; row++) {
                authorStruct = {
                    id: authorsQuery.id[row],
                    name: authorsQuery.name[row],
                    email: authorsQuery.email[row],
                    profile_image: authorsQuery.profile_image[row]
                };
                arrayAppend(authors, authorStruct);
            }
        } catch (any e) {
            // If authors fetch fails, continue with empty array
        }
    }
    
    // Add sample authors if none found
    if (arrayLen(authors) == 0) {
        authors = [
            {id: "1", name: "Admin User", email: "admin@example.com", profile_image: ""},
            {id: "2", name: "Jane Doe", email: "jane@example.com", profile_image: ""},
            {id: "3", name: "John Smith", email: "john@example.com", profile_image: ""}
        ];
    }
    
    // Get tags from database
    tags = [];
    if (!hasServiceError) {
        try {
            // Get all active tags used in pages
            tagsQuery = queryExecute("
                SELECT DISTINCT t.id, t.name, t.slug
                FROM tags t
                INNER JOIN posts_tags pt ON t.id = pt.tag_id
                INNER JOIN posts p ON pt.post_id = p.id
                WHERE p.type = 'page'
                ORDER BY t.name ASC
            ", {}, {datasource: request.dsn});
            
            for (row = 1; row <= tagsQuery.recordCount; row++) {
                tagStruct = {
                    id: tagsQuery.id[row],
                    name: tagsQuery.name[row],
                    slug: tagsQuery.slug[row]
                };
                arrayAppend(tags, tagStruct);
            }
        } catch (any e) {
            // If tags fetch fails, continue with empty array
        }
    }
    
    // Available filter options - use variables scope for accessibility
    variables.availableTypes = [
        {value: "", label: "All pages"},
        {value: "draft", label: "Draft"},
        {value: "published", label: "Published"},
        {value: "scheduled", label: "Scheduled"},
        {value: "featured", label: "Featured"}
    ];
    
    variables.availableVisibilities = [
        {value: "", label: "All access"},
        {value: "public", label: "Public"},
        {value: "members", label: "Members only"},
        {value: "paid", label: "Paid members only"}
    ];
    
    variables.availableOrders = [
        {value: "newest", label: "Newest first"},
        {value: "oldest", label: "Oldest first"},
        {value: "recently-updated", label: "Recently updated"}
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
                        <h4 class="font-semibold text-xl text-dark dark:text-white"><cfoutput>#pageTitle#</cfoutput></h4>
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
                        <li class="flex items-center text-sm font-medium" aria-current="page"><cfoutput>#pageTitle#</cfoutput></li>
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
                                   value="<cfoutput>#url.search#</cfoutput>"
                                   autocomplete="off">
                            <i class="ti ti-search absolute top-1.5 start-0 translate-middle-y text-lg text-dark dark:text-darklink ms-3"></i>
                            <!-- Search Results Dropdown -->
                            <div id="searchDropdown" class="absolute top-full left-0 bg-white border border-gray-200 rounded-lg shadow-lg mt-1 max-h-96 overflow-y-auto" style="display: none; z-index: 1000; width: 600px; max-width: 90vw;">
                                <div id="searchResults"></div>
                            </div>
                        </form>
                        
                        <!-- Filter Dropdowns -->
                        <div class="flex gap-3">
                            <!-- Type Filter -->
                            <select class="form-select" id="typeFilter" onchange="applyFilters()">
                                <cfoutput>
                                <cfloop array="#variables.availableTypes#" index="type">
                                    <option value="#type.value#" <cfif url.type eq type.value>selected</cfif>>#type.label#</option>
                                </cfloop>
                                </cfoutput>
                            </select>
                            
                            <!-- Visibility Filter -->
                            <cfif NOT (structKeyExists(session, "userRole") AND session.userRole EQ "Contributor")>
                                <select class="form-select" id="visibilityFilter" onchange="applyFilters()">
                                    <cfoutput>
                                    <cfloop array="#variables.availableVisibilities#" index="visibility">
                                        <option value="#visibility.value#" <cfif url.visibility eq visibility.value>selected</cfif>>#visibility.label#</option>
                                    </cfloop>
                                    </cfoutput>
                                </select>
                            </cfif>
                            
                            <!-- Author Filter -->
                            <cfif NOT (structKeyExists(session, "userRole") AND (session.userRole EQ "Author" OR session.userRole EQ "Contributor"))>
                                <select class="form-select" id="authorFilter" onchange="applyFilters()">
                                    <option value="">All authors</option>
                                    <cfoutput>
                                    <cfloop array="#authors#" index="author">
                                        <option value="#author.id#" <cfif url.author eq author.id>selected</cfif>>#author.name#</option>
                                    </cfloop>
                                    </cfoutput>
                                </select>
                            </cfif>
                            
                            <!-- Tag Filter -->
                            <cfif NOT (structKeyExists(session, "userRole") AND session.userRole EQ "Contributor")>
                                <select class="form-select" id="tagFilter" onchange="applyFilters()">
                                    <option value="">All tags</option>
                                    <cfoutput>
                                    <cfloop array="#tags#" index="tag">
                                        <option value="#tag.id#" <cfif url.tag eq tag.id>selected</cfif>>#tag.name#</option>
                                    </cfloop>
                                    </cfoutput>
                                </select>
                            </cfif>
                            
                            <!-- Sort Order -->
                            <select class="form-select" id="orderFilter" onchange="applyFilters()">
                                <cfoutput>
                                <cfloop array="#variables.availableOrders#" index="order">
                                    <option value="#order.value#" <cfif url.order eq order.value>selected</cfif>>#order.label#</option>
                                </cfloop>
                                </cfoutput>
                            </select>
                        </div>
                    </div>
                    
                    <!-- Right Side - Action Buttons -->
                    <div class="flex gap-2">
                        <a href="/ghost/admin/pages/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>Add New Page
                        </a>
                    </div>
                </div>

                <!-- Ghost-style Pages Cards Layout -->
                <cfif pagesResult.success and pagesResult.recordCount gt 0>
                    
                    <!-- Bulk Actions Bar (Initially Hidden) -->
                    <div id="bulkActionsBar" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6 hidden">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-3">
                                <span class="text-sm font-medium text-blue-800">
                                    <span id="selectedCount">0</span> pages selected
                                </span>
                                <button class="text-blue-600 hover:text-blue-800 text-sm underline" onclick="clearSelection()">
                                    Clear selection
                                </button>
                            </div>
                            <div class="flex gap-2">
                                <button class="btn btn-sm btn-outline-primary">
                                    <i class="ti ti-edit me-1"></i>Bulk Edit
                                </button>
                                <button class="btn btn-sm btn-outline-danger" onclick="bulkDelete()">
                                    <i class="ti ti-trash me-1"></i>Delete Selected
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Pages List -->
                    <div class="ghost-posts-list">
                        <cfoutput>
                        <cfloop array="#pagesResult.data#" index="page">
                            <div class="ghost-post-card" data-post-id="#page.id#">
                                <div class="ghost-post-card-content">
                                    <!-- Checkbox for bulk selection -->
                                    <div class="ghost-post-checkbox">
                                        <input type="checkbox" 
                                               id="post-#page.id#" 
                                               value="#page.id#"
                                               onchange="updateBulkSelection()"
                                               class="form-check-input">
                                    </div>
                                    
                                    <!-- Post Metadata -->
                                    <div class="ghost-post-meta">
                                        <!-- Title and Feature Image -->
                                        <div class="flex items-start gap-4">
                                            <cfif len(page.feature_image)>
                                                <div class="ghost-post-image">
                                                    <img src="#page.feature_image#" alt="#page.title#" class="rounded">
                                                </div>
                                            </cfif>
                                            
                                            <div class="flex-1">
                                                <h3 class="ghost-post-title">
                                                    <a href="/ghost/admin/pages/edit/#page.id#">#page.title#</a>
                                                    <cfif page.featured>
                                                        <i class="ti ti-star-filled text-amber-500 ms-1" title="Featured"></i>
                                                    </cfif>
                                                </h3>
                                                
                                                <cfif len(page.custom_excerpt)>
                                                    <p class="ghost-post-excerpt">#page.custom_excerpt#</p>
                                                </cfif>
                                                
                                                <div class="ghost-post-details">
                                                    <span class="ghost-post-author">
                                                        <i class="ti ti-user text-sm me-1"></i>
                                                        #page.author_name#
                                                    </span>
                                                    
                                                    <cfif page.status eq "published">
                                                        <span class="ghost-post-date">
                                                            <i class="ti ti-calendar text-sm me-1"></i>
                                                            Published #dateFormat(page.published_at, "dd mmm yyyy")#
                                                        </span>
                                                    <cfelseif page.status eq "scheduled">
                                                        <span class="ghost-post-date text-blue-600">
                                                            <i class="ti ti-clock text-sm me-1"></i>
                                                            Scheduled for #dateFormat(page.published_at, "dd mmm yyyy")# at #timeFormat(page.published_at, "HH:mm")#
                                                        </span>
                                                    <cfelse>
                                                        <span class="ghost-post-date text-gray-500">
                                                            <i class="ti ti-edit text-sm me-1"></i>
                                                            Draft - Updated #dateFormat(page.updated_at, "dd mmm yyyy")#
                                                        </span>
                                                    </cfif>
                                                    
                                                    <cfif page.visibility neq "public">
                                                        <span class="ghost-post-visibility">
                                                            <cfswitch expression="#page.visibility#">
                                                                <cfcase value="members">
                                                                    <i class="ti ti-users text-sm me-1"></i>Members only
                                                                </cfcase>
                                                                <cfcase value="paid">
                                                                    <i class="ti ti-currency-dollar text-sm me-1"></i>Paid members only
                                                                </cfcase>
                                                                <cfdefaultcase>
                                                                    <i class="ti ti-lock text-sm me-1"></i>#page.visibility#
                                                                </cfdefaultcase>
                                                            </cfswitch>
                                                        </span>
                                                    </cfif>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Action Buttons -->
                                    <div class="ghost-post-actions">
                                        <a href="/ghost/admin/pages/edit/#page.id#" class="ghost-post-action-link" title="Edit">
                                            <i class="ti ti-pencil"></i>
                                        </a>
                                        <cfif page.status eq "published">
                                            <a href="/#page.slug#" target="_blank" class="ghost-post-action-link" title="View">
                                                <i class="ti ti-external-link"></i>
                                            </a>
                                        </cfif>
                                        <button type="button" 
                                                class="ghost-post-action-link text-danger" 
                                                onclick="deletePost('#page.id#', 'page')"
                                                title="Delete">
                                            <i class="ti ti-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </cfloop>
                        </cfoutput>
                    </div>
                    
                    <!-- Pagination -->
                    <cfif pagesResult.totalPages gt 1>
                        <div class="flex justify-center mt-8">
                            <nav aria-label="Page navigation">
                                <ul class="pagination">
                                    <cfoutput>
                                    <!-- Previous Button -->
                                    <li class="page-item <cfif url.page eq 1>disabled</cfif>">
                                        <a class="page-link" href="?page=#max(1, url.page - 1)#&type=#url.type#&author=#url.author#&search=#url.search#&visibility=#url.visibility#&tag=#url.tag#&order=#url.order#" aria-label="Previous">
                                            <span aria-hidden="true">&laquo;</span>
                                        </a>
                                    </li>
                                    
                                    <!-- Page Numbers -->
                                    <cfloop from="1" to="#pagesResult.totalPages#" index="pageNum">
                                        <li class="page-item <cfif url.page eq pageNum>active</cfif>">
                                            <a class="page-link" href="?page=#pageNum#&type=#url.type#&author=#url.author#&search=#url.search#&visibility=#url.visibility#&tag=#url.tag#&order=#url.order#">#pageNum#</a>
                                        </li>
                                    </cfloop>
                                    
                                    <!-- Next Button -->
                                    <li class="page-item <cfif url.page eq pagesResult.totalPages>disabled</cfif>">
                                        <a class="page-link" href="?page=#min(pagesResult.totalPages, url.page + 1)#&type=#url.type#&author=#url.author#&search=#url.search#&visibility=#url.visibility#&tag=#url.tag#&order=#url.order#" aria-label="Next">
                                            <span aria-hidden="true">&raquo;</span>
                                        </a>
                                    </li>
                                    </cfoutput>
                                </ul>
                            </nav>
                        </div>
                    </cfif>
                    
                <cfelse>
                    <!-- Empty State -->
                    <div class="text-center py-12">
                        <div class="mb-6">
                            <i class="ti ti-file-text text-6xl text-gray-300"></i>
                        </div>
                        <h3 class="text-xl font-semibold mb-2">No pages found</h3>
                        <p class="text-gray-600 mb-6">
                            <cfif len(url.type) or len(url.author) or len(url.search) or len(url.visibility) or len(url.tag)>
                                Try adjusting your filters or search query
                            <cfelse>
                                Get started by creating your first page
                            </cfif>
                        </p>
                        <a href="/ghost/admin/pages/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>Create New Page
                        </a>
                    </div>
                </cfif>
                
            </div>
        </div>
        
    </div>
</div>

<style>
/* Ghost-style post card styling */
.ghost-posts-list {
    display: flex;
    flex-direction: column;
    gap: 1px;
    background: #e5e7eb;
    border: 1px solid #e5e7eb;
    border-radius: 0.5rem;
    overflow: hidden;
}

.ghost-post-card {
    background: white;
    transition: all 0.2s ease;
}

.ghost-post-card:hover {
    background: #f9fafb;
}

.ghost-post-card-content {
    display: flex;
    align-items: center;
    padding: 1.25rem;
    gap: 1rem;
}

.ghost-post-checkbox {
    flex-shrink: 0;
}

.ghost-post-meta {
    flex: 1;
    min-width: 0;
}

.ghost-post-image {
    width: 60px;
    height: 45px;
    flex-shrink: 0;
}

.ghost-post-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.ghost-post-title {
    font-size: 1rem;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 0.25rem;
    display: flex;
    align-items: center;
}

.ghost-post-title a {
    color: inherit;
    text-decoration: none;
}

.ghost-post-title a:hover {
    color: #14b8ff;
}

.ghost-post-excerpt {
    font-size: 0.875rem;
    color: #6b7280;
    margin-bottom: 0.5rem;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.ghost-post-details {
    display: flex;
    align-items: center;
    gap: 1rem;
    font-size: 0.75rem;
    color: #9ca3af;
    flex-wrap: wrap;
}

.ghost-post-details span {
    display: flex;
    align-items: center;
}

.ghost-post-actions {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex-shrink: 0;
}

.ghost-post-action-link {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    border-radius: 0.25rem;
    color: #6b7280;
    transition: all 0.2s ease;
}

.ghost-post-action-link:hover {
    background: #f3f4f6;
    color: #1f2937;
}

.ghost-post-action-link.text-danger:hover {
    background: #fee2e2;
    color: #dc2626;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .ghost-post-card-content {
        flex-wrap: wrap;
    }
    
    .ghost-post-actions {
        width: 100%;
        justify-content: flex-end;
        margin-top: 0.5rem;
    }
}
</style>

<script>
// Selected items tracking
let selectedItems = new Set();

// Update bulk selection
function updateBulkSelection() {
    const checkboxes = document.querySelectorAll('.ghost-posts-list input[type="checkbox"]');
    selectedItems.clear();
    
    checkboxes.forEach(checkbox => {
        if (checkbox.checked) {
            selectedItems.add(checkbox.value);
        }
    });
    
    // Update UI
    document.getElementById('selectedCount').textContent = selectedItems.size;
    document.getElementById('bulkActionsBar').classList.toggle('hidden', selectedItems.size === 0);
}

// Clear selection
function clearSelection() {
    document.querySelectorAll('.ghost-posts-list input[type="checkbox"]').forEach(checkbox => {
        checkbox.checked = false;
    });
    updateBulkSelection();
}

// Delete post function
function deletePost(pageId, type = 'page') {
    if (confirm('Are you sure you want to delete this ' + type + '?')) {
        // Show loading state
        const card = document.querySelector(`[data-post-id="${pageId}"]`);
        if (card) {
            card.style.opacity = '0.5';
        }
        
        // Make delete request
        fetch('/ghost/admin/ajax/delete-post.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `id=${pageId}`
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Remove the card with animation
                if (card) {
                    card.style.transition = 'all 0.3s ease';
                    card.style.transform = 'translateX(-100%)';
                    card.style.opacity = '0';
                    setTimeout(() => {
                        card.remove();
                        // Check if list is empty
                        if (document.querySelectorAll('.ghost-post-card').length === 0) {
                            location.reload();
                        }
                    }, 300);
                }
            } else {
                alert('Error deleting ' + type + ': ' + (data.message || 'Unknown error'));
                if (card) {
                    card.style.opacity = '1';
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting ' + type);
            if (card) {
                card.style.opacity = '1';
            }
        });
    }
}

// Bulk delete function
function bulkDelete() {
    if (selectedItems.size === 0) return;
    
    if (confirm(`Are you sure you want to delete ${selectedItems.size} pages?`)) {
        // Implementation for bulk delete
        console.log('Bulk delete:', Array.from(selectedItems));
    }
}

// Apply filters function
function applyFilters() {
    const type = document.getElementById('typeFilter').value;
    const visibility = document.getElementById('visibilityFilter')?.value || '';
    const author = document.getElementById('authorFilter')?.value || '';
    const tag = document.getElementById('tagFilter')?.value || '';
    const order = document.getElementById('orderFilter').value;
    const search = document.getElementById('text-srh').value;
    
    // Build URL with filters
    const params = new URLSearchParams();
    if (type) params.append('type', type);
    if (visibility) params.append('visibility', visibility);
    if (author) params.append('author', author);
    if (tag) params.append('tag', tag);
    if (order) params.append('order', order);
    if (search) params.append('search', search);
    
    // Navigate to filtered URL
    window.location.href = '/ghost/admin/pages' + (params.toString() ? '?' + params.toString() : '');
}

// Search functionality
window.searchPages = function(query) {
    console.log('Searching for:', query);
    
    if (!query || query.trim().length < 2) {
        document.getElementById('searchDropdown').style.display = 'none';
        return;
    }
    
    // Show loading state
    document.getElementById('searchResults').innerHTML = '<div class="p-4 text-center"><i class="ti ti-loader-2 animate-spin"></i> Searching...</div>';
    document.getElementById('searchDropdown').style.display = 'block';
    
    // Fetch search results
    fetch(`/ghost/admin/ajax/search-posts.cfm?q=${encodeURIComponent(query)}&type=page`)
        .then(response => response.json())
        .then(data => {
            const success = data.success || data.SUCCESS;
            const pages = data.posts || data.POSTS || [];
            
            if (success && pages.length > 0) {
                showSearchResults(pages);
            } else {
                document.getElementById('searchResults').innerHTML = '<div class="p-4 text-center text-gray-500">No pages found</div>';
            }
        })
        .catch(error => {
            console.error('Search error:', error);
            document.getElementById('searchResults').innerHTML = '<div class="p-4 text-center text-red-500">Search error</div>';
        });
}

function showSearchResults(pages) {
    let html = '<div class="search-results-list">';
    
    pages.forEach(page => {
        const pageData = {
            id: page.id || page.ID,
            title: page.title || page.TITLE,
            status: page.status || page.STATUS,
            author_name: page.author_name || page.AUTHOR_NAME,
            published_at: page.published_at || page.PUBLISHED_AT,
            created_at: page.created_at || page.CREATED_AT
        };
        
        const date = pageData.status === 'published' ? pageData.published_at : pageData.created_at;
        const statusBadge = pageData.status === 'published' ? 
            '<span class="badge bg-success">Published</span>' : 
            '<span class="badge bg-secondary">Draft</span>';
        
        html += `
            <a href="/ghost/admin/pages/edit/${pageData.id}" class="search-result-item">
                <div>
                    <div class="font-medium">${pageData.title}</div>
                    <div class="text-sm text-gray-600">
                        ${statusBadge}
                        <span class="ms-2">by ${pageData.author_name}</span>
                        <span class="ms-2">${new Date(date).toLocaleDateString()}</span>
                    </div>
                </div>
            </a>
        `;
    });
    
    html += '</div>';
    document.getElementById('searchResults').innerHTML = html;
}

// Initialize search with debouncing
let searchTimeout;
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('text-srh');
    
    if (searchInput) {
        searchInput.addEventListener('input', function(e) {
            clearTimeout(searchTimeout);
            const query = e.target.value.trim();
            
            if (query.length >= 2) {
                searchTimeout = setTimeout(() => {
                    window.searchPages(query);
                }, 300);
            } else {
                document.getElementById('searchDropdown').style.display = 'none';
            }
        });
        
        // Hide dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.relative')) {
                document.getElementById('searchDropdown').style.display = 'none';
            }
        });
        
        // Handle enter key to submit search
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                applyFilters();
            }
        });
    }
});
</script>

<style>
/* Search dropdown styles */
.search-results-list {
    max-height: 400px;
    overflow-y: auto;
}

.search-result-item {
    display: block;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #e5e7eb;
    text-decoration: none;
    color: inherit;
    transition: background-color 0.2s;
}

.search-result-item:hover {
    background-color: #f3f4f6;
}

.search-result-item:last-child {
    border-bottom: none;
}

.badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
    font-weight: 500;
    line-height: 1;
    border-radius: 0.25rem;
}

.bg-success {
    background-color: #10b981;
    color: white;
}

.bg-secondary {
    background-color: #6b7280;
    color: white;
}
</style>

<cfinclude template="includes/footer.cfm">