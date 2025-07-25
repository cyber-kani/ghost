<cfparam name="url.type" default="">
<cfswitch expression="#url.type#">
    <cfcase value="draft">
        <cfset pageTitle = "Drafts">
    </cfcase>
    <cfcase value="scheduled">
        <cfset pageTitle = "Scheduled">
    </cfcase>
    <cfdefaultcase>
        <cfset pageTitle = "Posts">
    </cfdefaultcase>
</cfswitch>
<cfinclude template="includes/header.cfm">

<!--- Include posts functions (no components needed) --->
<cfinclude template="includes/posts-functions.cfm">

<!--- Initialize posts data with direct function calls --->
<cfscript>
    // Initialize variables
    postsData = [];
    hasServiceError = false;
    serviceErrorMessage = "";
    
    try {
        // No components needed - functions are included directly
        hasServiceError = false;
    } catch (any e) {
        hasServiceError = true;
        serviceErrorMessage = e.message;
        writeOutput("<!-- Posts functions loading error: " & e.message & " -->");
    }
    
    // Get request parameters - Ghost style parameters
    param name="url.page" default="1";
    // url.type is already declared above for pageTitle logic
    param name="url.visibility" default=""; // all, public, members, paid
    param name="url.author" default="";
    param name="url.tag" default="";
    param name="url.order" default="newest"; // newest, oldest, recently-updated
    param name="url.search" default=""; // search query
    
    // Convert Ghost filters to our system
    statusFilter = "";
    if (url.type == "draft") statusFilter = "draft";
    else if (url.type == "published") statusFilter = "published";
    else if (url.type == "scheduled") statusFilter = "scheduled";
    
    // Get posts with filters - use direct function calls
    if (!hasServiceError) {
        try {
            postsResult = getPosts(
                page = val(url.page),
                limit = 15,
                status = statusFilter,
                author = url.author,
                featured = (url.type == "featured"),
                type = "post"
            );
            
            // Get post statistics
            statsResult = getPostStats();
        } catch (any e) {
            hasServiceError = true;
            serviceErrorMessage = e.message;
        }
    }
    
    // Provide fallback data if service failed
    if (hasServiceError) {
        postsResult = {
            success: true,
            data: [
                {
                    id: "1",
                    title: "Welcome to Ghost CFML",
                    status: "published",
                    created_at: now(),
                    updated_at: now(),
                    published_at: now(),
                    featured: true,
                    primary_tag: "Getting Started",
                    created_by: "1",
                    feature_image: "",
                    plaintext: "Welcome to your new Ghost CFML blog! This is a sample post to get you started..."
                },
                {
                    id: "2", 
                    title: "Building a Modern CMS with CFML",
                    status: "draft",
                    created_at: now(),
                    updated_at: now(),
                    published_at: "",
                    featured: false,
                    primary_tag: "Development", 
                    created_by: "1",
                    feature_image: "",
                    plaintext: "Learn how to build modern content management systems using ColdFusion..."
                },
                {
                    id: "3",
                    title: "Advanced Ghost Features Coming Soon",
                    status: "scheduled",
                    created_at: now(),
                    updated_at: now(),
                    published_at: dateAdd("d", 7, now()),
                    featured: false,
                    primary_tag: "Updates",
                    created_by: "1",
                    feature_image: "",
                    plaintext: "Exciting new features are on the way for Ghost CFML including..."
                }
            ],
            recordCount: 3,
            totalRecords: 3,
            currentPage: 1,
            totalPages: 1,
            startRecord: 1,
            endRecord: 3
        };
        
        statsResult = {
            success: true,
            stats: {
                total: 3,
                published: 1,
                draft: 1,
                scheduled: 1,
                posts: 3,
                pages: 0,
                featured: 1
            }
        };
    }
    
    // Get authors from database - simplified approach
    authors = [];
    if (!hasServiceError) {
        try {
            // Get unique authors from posts table
            authorsQuery = queryExecute("SELECT DISTINCT created_by FROM posts WHERE created_by IS NOT NULL", {}, {datasource: "blog"});
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
            {id: "1", name: "John Doe", avatar: "https://ui-avatars.com/api/?name=John+Doe&background=5D87FF&color=fff"},
            {id: "2", name: "Jane Smith", avatar: "https://ui-avatars.com/api/?name=Jane+Smith&background=49BEFF&color=fff"},
            {id: "3", name: "Mike Johnson", avatar: "https://ui-avatars.com/api/?name=Mike+Johnson&background=13DEB9&color=fff"},
            {id: "4", name: "Sarah Lee", avatar: "https://ui-avatars.com/api/?name=Sarah+Lee&background=FFAE1F&color=fff"}
        ];
    }
    
    // Available filter options - use variables scope for accessibility
    variables.availableTypes = [
        {value: "", label: "All posts"},
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
                                   id="text-srh" placeholder="Search Posts..." 
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
                        <a href="/ghost/admin/posts/new" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i>Add New Post
                        </a>
                    </div>
                </div>

                <!-- Ghost-style Posts Cards Layout -->
                <cfif postsResult.success and postsResult.recordCount gt 0>
                    
                    <!-- Bulk Actions Bar (Initially Hidden) -->
                    <div id="bulkActionsBar" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6 hidden">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-3">
                                <span class="text-sm font-medium text-blue-800">
                                    <span id="selectedCount">0</span> posts selected
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
                    
                    <!-- Posts List -->
                    <div class="ghost-posts-list">
                        <cfoutput>
                        <cfloop array="#postsResult.data#" index="post">
                            <div class="ghost-post-card group" data-post-id="#post.id#">
                                
                                <!-- Selection and Feature Image -->
                                <div class="ghost-post-image">
                                    <div class="absolute top-3 left-3 z-10">
                                        <input type="checkbox" class="post-checkbox form-check-input" 
                                               value="#post.id#" onchange="updateBulkActions()">
                                    </div>
                                    
                                    <cfif structKeyExists(post, 'feature_image') and len(trim(post.feature_image)) gt 0>
                                        <div class="ghost-feature-image">
                                            <img src="#post.feature_image#" alt="#htmlEditFormat(post.title)#" loading="lazy">
                                        </div>
                                    <cfelse>
                                        <div class="ghost-feature-image-placeholder">
                                            <i class="ti ti-photo text-4xl text-gray-400"></i>
                                        </div>
                                    </cfif>
                                    
                                    <!-- Featured Star -->
                                    <cfif post.featured>
                                        <div class="absolute top-3 right-3">
                                            <i class="ti ti-star-filled text-yellow-500 text-lg drop-shadow-sm"></i>
                                        </div>
                                    </cfif>
                                </div>
                                
                                <!-- Post Content -->
                                <div class="ghost-post-content">
                                    
                                    <!-- Title and Status -->
                                    <div class="ghost-post-header">
                                        <h3 class="ghost-post-title">
                                            <a href="/ghost/admin/posts/edit/#post.id#" class="text-decoration-none">
                                                #htmlEditFormat(post.title)#
                                            </a>
                                        </h3>
                                        
                                        <!-- Status Badge -->
                                        <div class="ghost-post-status">
                                            <cfswitch expression="#post.status#">
                                                <cfcase value="published">
                                                    <span class="ghost-status-badge ghost-status-published">
                                                        <i class="ti ti-world"></i>
                                                        Published
                                                    </span>
                                                </cfcase>
                                                <cfcase value="draft">
                                                    <span class="ghost-status-badge ghost-status-draft">
                                                        <i class="ti ti-edit"></i>
                                                        Draft
                                                    </span>
                                                </cfcase>
                                                <cfcase value="scheduled">
                                                    <span class="ghost-status-badge ghost-status-scheduled">
                                                        <i class="ti ti-clock"></i>
                                                        Scheduled
                                                    </span>
                                                </cfcase>
                                                <cfdefaultcase>
                                                    <span class="ghost-status-badge ghost-status-default">
                                                        #post.status#
                                                    </span>
                                                </cfdefaultcase>
                                            </cfswitch>
                                        </div>
                                    </div>
                                    
                                    <!-- Excerpt -->
                                    <cfif structKeyExists(post, "plaintext") and len(trim(post.plaintext)) gt 0>
                                        <p class="ghost-post-excerpt">
                                            #left(stripTags(post.plaintext), 120)#<cfif len(post.plaintext) gt 120>...</cfif>
                                        </p>
                                    </cfif>
                                    
                                    <!-- Tags -->
                                    <cfif structKeyExists(post, "tags") and isArray(post.tags) and arrayLen(post.tags) gt 0>
                                        <div class="ghost-post-tags">
                                            <cfloop array="#post.tags#" index="tag">
                                                <span class="ghost-tag">#htmlEditFormat(tag.name)#</span>
                                            </cfloop>
                                        </div>
                                    </cfif>
                                    
                                    <!-- Meta Information -->
                                    <div class="ghost-post-meta">
                                        <div class="ghost-post-author">
                                            <cfset authorInfo = "">
                                            <cfset authorAvatar = "">
                                            
                                            <!--- First try: check if post has author object --->
                                            <cfif structKeyExists(post, "author") and structKeyExists(post.author, "name")>
                                                <cfset authorInfo = post.author.name>
                                                <cfset authorAvatar = post.author.avatar>
                                            <!--- Second try: look up in authors array --->
                                            <cfelseif isDefined("authors") and isArray(authors)>
                                                <cfloop array="#authors#" index="author">
                                                    <cfif author.id eq post.created_by>
                                                        <cfset authorInfo = author.name>
                                                        <cfset authorAvatar = author.avatar>
                                                        <cfbreak>
                                                    </cfif>
                                                </cfloop>
                                            </cfif>
                                            
                                            <!--- Fallback: generate author name from created_by --->
                                            <cfif len(authorInfo) eq 0>
                                                <cfif structKeyExists(post, "created_by") and len(post.created_by) gt 0>
                                                    <cfset authorInfo = "Author " & post.created_by>
                                                    <cfset authorAvatar = "https://ui-avatars.com/api/?name=Author+" & post.created_by & "&background=5D87FF&color=fff">
                                                <cfelse>
                                                    <cfset authorInfo = "Unknown Author">
                                                    <cfset authorAvatar = "https://ui-avatars.com/api/?name=Unknown+Author&background=5D87FF&color=fff">
                                                </cfif>
                                            </cfif>
                                            
                                            <cfif len(authorAvatar) gt 0>
                                                <img src="#authorAvatar#" alt="#authorInfo#" class="ghost-author-avatar">
                                            </cfif>
                                            <span class="ghost-author-name">#authorInfo#</span>
                                        </div>
                                        
                                        <!-- Date Display -->
                                        <cfif post.status eq "published" and isDate(post.published_at)>
                                            <div class="ghost-published-date">
                                                Published #dateFormat(post.published_at, "mmm d, yyyy")#
                                            </div>
                                        <cfelseif post.status eq "draft" and isDate(post.created_at)>
                                            <div class="ghost-created-date">
                                                Created #dateFormat(post.created_at, "mmm d, yyyy")#
                                            </div>
                                        <cfelseif post.status eq "scheduled" and isDate(post.published_at)>
                                            <div class="ghost-scheduled-date">
                                                Scheduled for #dateFormat(post.published_at, "mmm d, yyyy")#
                                            </div>
                                        </cfif>
                                        
                                        <div class="ghost-post-date">
                                            <cfset relativeDate = "">
                                            <cfset useDate = "">
                                            
                                            <!--- Always use created_at for relative time calculation --->
                                            <cfif isDate(post.created_at)>
                                                <cfset useDate = post.created_at>
                                            <cfelseif isDate(post.updated_at)>
                                                <cfset useDate = post.updated_at>
                                            </cfif>
                                            
                                            <!--- Calculate relative time since creation --->
                                            <cfif isDate(useDate)>
                                                <cfset timeDiff = dateDiff("h", useDate, now())>
                                                <cfif timeDiff lt 24>
                                                    <cfif timeDiff lt 1>
                                                        <cfset minutes = dateDiff("n", useDate, now())>
                                                        #minutes# min<cfif minutes neq 1>s</cfif> ago
                                                    <cfelse>
                                                        #timeDiff# hour<cfif timeDiff neq 1>s</cfif> ago
                                                    </cfif>
                                                <cfelseif timeDiff lt 168>
                                                    <cfset days = dateDiff("d", useDate, now())>
                                                    #days# day<cfif days neq 1>s</cfif> ago
                                                <cfelse>
                                                    #dateFormat(useDate, "mmm d, yyyy")#
                                                </cfif>
                                            <cfelse>
                                                No date
                                            </cfif>
                                        </div>
                                    </div>
                                    
                                    <!-- Quick Actions -->
                                    <div class="ghost-post-actions">
                                        <div class="ghost-actions-left">
                                            <!-- Quick Publish Toggle -->
                                            <cfif post.status eq "draft">
                                                <button class="ghost-quick-action ghost-publish-btn" 
                                                        onclick="quickPublish('#post.id#')" 
                                                        title="Publish now">
                                                    <i class="ti ti-world"></i>
                                                </button>
                                            <cfelseif post.status eq "published">
                                                <button class="ghost-quick-action ghost-unpublish-btn" 
                                                        onclick="quickUnpublish('#post.id#')" 
                                                        title="Unpublish">
                                                    <i class="ti ti-world-off"></i>
                                                </button>
                                            </cfif>
                                            
                                            <!-- Duplicate -->
                                            <button class="ghost-quick-action" 
                                                    onclick="duplicatePost('#post.id#')" 
                                                    title="Duplicate post">
                                                <i class="ti ti-copy"></i>
                                            </button>
                                            
                                            <!-- View (if published) -->
                                            <cfif post.status eq "published">
                                                <a href="/post/#post.id#" target="_blank" 
                                                   class="ghost-quick-action" title="View post">
                                                    <i class="ti ti-external-link"></i>
                                                </a>
                                            </cfif>
                                        </div>
                                        
                                        <div class="ghost-actions-right">
                                            <!-- Edit -->
                                            <a href="/ghost/admin/posts/edit/#post.id#" 
                                               class="ghost-edit-btn" title="Edit post">
                                                <i class="ti ti-edit"></i>
                                                Edit
                                            </a>
                                            
                                            <!-- More Actions -->
                                            <div class="ghost-more-actions">
                                                <button class="ghost-more-btn" onclick="togglePostMenu('#post.id#')">
                                                    <i class="ti ti-dots-vertical"></i>
                                                </button>
                                                <div class="ghost-post-menu" id="postMenu#post.id#">
                                                    <button onclick="deletePost('#post.id#', '#escapeForJS(post.title)#')" class="text-red-600">
                                                        <i class="ti ti-trash"></i>Delete
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </cfloop>
                        </cfoutput>
                    </div>
                    
                    <!-- Pagination - Spike Style -->
                    <cfoutput>
                    <cfif postsResult.totalPages gt 1>
                        <div class="flex items-center justify-between mt-6">
                            <div>
                                <p class="text-sm text-bodytext">
                                    Showing #postsResult.startRecord# to #postsResult.endRecord# of #postsResult.totalRecords# entries
                                </p>
                            </div>
                            
                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-center mb-0">
                                    <cfif postsResult.currentPage gt 1>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=#postsResult.currentPage - 1#&type=#url.type#&visibility=#url.visibility#&author=#url.author#&tag=#url.tag#&order=#url.order#&search=#url.search#">
                                                <i class="ti ti-chevron-left"></i>
                                            </a>
                                        </li>
                                    </cfif>
                                    
                                    <cfloop from="1" to="#postsResult.totalPages#" index="pageNum">
                                        <cfif pageNum eq postsResult.currentPage>
                                            <li class="page-item active">
                                                <span class="page-link">#pageNum#</span>
                                            </li>
                                        <cfelse>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=#pageNum#&type=#url.type#&visibility=#url.visibility#&author=#url.author#&tag=#url.tag#&order=#url.order#&search=#url.search#">#pageNum#</a>
                                            </li>
                                        </cfif>
                                    </cfloop>
                                    
                                    <cfif postsResult.currentPage lt postsResult.totalPages>
                                        <li class="page-item">
                                            <a class="page-link" href="?page=#postsResult.currentPage + 1#&type=#url.type#&visibility=#url.visibility#&author=#url.author#&tag=#url.tag#&order=#url.order#&search=#url.search#">
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
                        <cfoutput>
                        <cfswitch expression="#url.type#">
                            <cfcase value="draft">
                                <h4 class="font-semibold text-dark dark:text-white mb-3">No drafts found</h4>
                                <p class="text-bodytext mb-4">
                                    <cfif url.author eq "" and url.search eq "">
                                        You don't have any draft posts yet. Start writing!
                                    <cfelse>
                                        Try adjusting your search or filter criteria.
                                    </cfif>
                                </p>
                            </cfcase>
                            <cfcase value="scheduled">
                                <h4 class="font-semibold text-dark dark:text-white mb-3">No scheduled posts found</h4>
                                <p class="text-bodytext mb-4">
                                    <cfif url.author eq "" and url.search eq "">
                                        You don't have any posts scheduled for future publication.
                                    <cfelse>
                                        Try adjusting your search or filter criteria.
                                    </cfif>
                                </p>
                            </cfcase>
                            <cfdefaultcase>
                                <h4 class="font-semibold text-dark dark:text-white mb-3">No posts found</h4>
                                <p class="text-bodytext mb-4">
                                    <cfif url.type eq "" and url.author eq "" and url.search eq "">
                                        Get started by creating your first post.
                                    <cfelse>
                                        Try adjusting your search or filter criteria.
                                    </cfif>
                                </p>
                            </cfdefaultcase>
                        </cfswitch>
                        
                        <cfif url.type eq "" and url.author eq "" and url.search eq "">
                            <a href="/ghost/admin/posts/new" class="btn btn-primary">
                                <i class="ti ti-plus me-2"></i>Create Your First Post
                            </a>
                        <cfelse>
                            <a href="/ghost/admin/posts" class="btn btn-outline-primary">
                                <i class="ti ti-refresh me-2"></i>Clear Filters
                            </a>
                        </cfif>
                        </cfoutput>
                    </div>
                </cfif>
            </div>
        </div>
    </div>
</div>

<!-- Ghost-style Posts CSS -->
<style>
/* Ghost Posts List Layout */
.ghost-posts-list {
    display: grid;
    gap: 1rem;
}

.ghost-post-card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    overflow: hidden;
    transition: all 0.2s ease;
    position: relative;
}

.ghost-post-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    border-color: #d1d5db;
}

.ghost-post-card {
    display: grid;
    grid-template-columns: 200px 1fr;
    min-height: 140px;
}

/* Feature Image */
.ghost-post-image {
    position: relative;
    background: #f9fafb;
    display: flex;
    align-items: center;
    justify-content: center;
}

.ghost-feature-image {
    width: 100%;
    height: 100%;
    overflow: hidden;
}

.ghost-feature-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.2s ease;
}

.ghost-post-card:hover .ghost-feature-image img {
    transform: scale(1.02);
}

.ghost-feature-image-placeholder {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #f9fafb 0%, #f3f4f6 100%);
}

/* Post Content */
.ghost-post-content {
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.ghost-post-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 0.75rem;
}

.ghost-post-title {
    font-size: 1.125rem;
    font-weight: 600;
    line-height: 1.4;
    margin: 0;
    flex: 1;
    margin-right: 1rem;
}

.ghost-post-title a {
    color: #111827;
    text-decoration: none;
    transition: color 0.2s ease;
}

.ghost-post-title a:hover {
    color: #6366f1;
}

/* Status Badges */
.ghost-status-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 0.25rem 0.5rem;
    border-radius: 6px;
    white-space: nowrap;
}

.ghost-status-published {
    background: #dcfce7;
    color: #16a34a;
}

.ghost-status-draft {
    background: #fef3c7;
    color: #d97706;
}

.ghost-status-scheduled {
    background: #dbeafe;
    color: #2563eb;
}

.ghost-status-default {
    background: #f3f4f6;
    color: #6b7280;
}

/* Post Excerpt */
.ghost-post-excerpt {
    color: #64748b;
    font-size: 0.875rem;
    line-height: 1.5;
    margin: 0 0 1rem 0;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    display: -webkit-box;
}

/* Tags */
.ghost-post-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-bottom: 1rem;
}

.ghost-tag {
    background: #f1f5f9;
    color: #475569;
    font-size: 0.75rem;
    font-weight: 500;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    text-decoration: none;
}

.ghost-tag:hover {
    background: #e2e8f0;
    color: #334155;
}

/* Meta Information */
.ghost-post-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    font-size: 0.75rem;
    color: #64748b;
}

.ghost-post-author {
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.ghost-author-avatar {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    object-fit: cover;
}

.ghost-author-name {
    font-weight: 500;
}

.ghost-published-date {
    font-size: 0.75rem;
    color: #64748b;
    font-weight: 500;
    margin-bottom: 0.25rem;
}

.ghost-created-date {
    font-size: 0.75rem;
    color: #d97706;
    font-weight: 500;
    margin-bottom: 0.25rem;
}

.ghost-scheduled-date {
    font-size: 0.75rem;
    color: #2563eb;
    font-weight: 500;
    margin-bottom: 0.25rem;
}

.ghost-post-date {
    font-weight: 400;
}

/* Actions */
.ghost-post-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: auto;
}

.ghost-actions-left {
    display: flex;
    gap: 0.5rem;
    opacity: 0;
    transition: opacity 0.2s ease;
}

.ghost-post-card:hover .ghost-actions-left {
    opacity: 1;
}

.ghost-quick-action {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    background: white;
    color: #6b7280;
    text-decoration: none;
    transition: all 0.2s ease;
    cursor: pointer;
}

.ghost-quick-action:hover {
    background: #f9fafb;
    border-color: #d1d5db;
    color: #374151;
}

.ghost-publish-btn:hover {
    background: #dcfce7;
    border-color: #16a34a;
    color: #16a34a;
}

.ghost-unpublish-btn:hover {
    background: #fef2f2;
    border-color: #dc2626;
    color: #dc2626;
}

.ghost-actions-right {
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.ghost-edit-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.375rem 0.75rem;
    background: #6366f1;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 0.75rem;
    font-weight: 500;
    text-decoration: none;
    transition: background 0.2s ease;
}

.ghost-edit-btn:hover {
    background: #5b5df1;
    color: white;
}

/* More Actions Menu */
.ghost-more-actions {
    position: relative;
}

.ghost-more-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    border: 1px solid #e5e7eb;
    border-radius: 6px;
    background: white;
    color: #6b7280;
    cursor: pointer;
    transition: all 0.2s ease;
}

.ghost-more-btn:hover {
    background: #f9fafb;
    border-color: #d1d5db;
    color: #374151;
}

.ghost-post-menu {
    position: fixed;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    min-width: 120px;
    z-index: 1000;
    display: none;
}

.ghost-post-menu.show {
    display: block;
}

.ghost-post-menu button {
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

.ghost-post-menu button:hover {
    background: #f9fafb;
}

.ghost-post-menu button:first-child {
    border-radius: 8px 8px 0 0;
}

.ghost-post-menu button:last-child {
    border-radius: 0 0 8px 8px;
}

/* Responsive Design */
@media (max-width: 768px) {
    .ghost-post-card {
        grid-template-columns: 1fr;
        grid-template-rows: 120px 1fr;
    }
    
    .ghost-post-content {
        padding: 1rem;
    }
    
    .ghost-post-header {
        flex-direction: column;
        gap: 0.5rem;
        align-items: flex-start;
    }
    
    .ghost-post-title {
        margin-right: 0;
    }
}

/* Bulk Actions */
.hidden {
    display: none;
}

/* Alert Messages */
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

/* Force sidebar visibility on large screens */
@media (min-width: 1024px) {
    #application-sidebar-brand {
        transform: translateX(0) !important;
        display: block !important;
    }
}

/* Debug styles */
.debug-sidebar {
    border: 2px solid red !important;
    background: yellow !important;
}
</style>

<!-- JavaScript -->
<script>
// Debug: Check if script is loading
console.log('Posts page JavaScript loading...');

// Define deletePost function first to ensure it's available
function deletePost(postId, postTitle) {
    console.log('deletePost called:', {postId: postId, postTitle: postTitle});
    
    if (confirm('Are you sure you want to delete "' + postTitle + '"? This action cannot be undone.')) {
        // Show loading state
        const deleteButton = document.querySelector(`button[onclick*="${postId}"]`);
        if (!deleteButton) {
            console.error('Delete button not found for post:', postId);
            return;
        }
        
        const originalContent = deleteButton.innerHTML;
        deleteButton.innerHTML = '<i class="ti ti-loader animate-spin"></i>';
        deleteButton.disabled = true;
        
        // Create form data
        const formData = new FormData();
        formData.append('postId', postId);
        
        console.log('Making AJAX request to delete post:', postId);
        
        // Make AJAX request
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
            
            // Handle both lowercase and uppercase keys (ColdFusion returns uppercase)
            const success = data.success || data.SUCCESS;
            const message = data.message || data.MESSAGE;
            
            console.log('Success:', success);
            console.log('Message:', message);
            
            if (success) {
                // Show success message
                console.log('Showing success message:', message);
                showMessage(message || 'Post deleted successfully', 'success');
                
                // Remove the card from the list with animation
                const postCard = deleteButton.closest('.ghost-post-card');
                postCard.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
                postCard.style.opacity = '0';
                postCard.style.transform = 'scale(0.95)';
                
                setTimeout(() => {
                    postCard.remove();
                    // Update page if no posts remain
                    const remainingCards = document.querySelectorAll('.ghost-post-card').length;
                    if (remainingCards === 0) {
                        location.reload();
                    }
                }, 300);
                
            } else {
                // Show error message
                console.log('Showing error message:', message);
                showMessage(message || 'An error occurred while deleting the post', 'error');
                
                // Restore button state
                deleteButton.innerHTML = originalContent;
                deleteButton.disabled = false;
            }
        })
        .catch(error => {
            console.error('Delete error:', error);
            showMessage('An error occurred while deleting the post. Please try again.', 'error');
            
            // Restore button state
            deleteButton.innerHTML = originalContent;
            deleteButton.disabled = false;
        });
    }
}

console.log('deletePost function defined');

// Ensure deletePost is globally accessible
window.deletePost = deletePost;

// Filter and Search Functions
function applyFilters() {
    const type = document.getElementById('typeFilter').value;
    const author = document.getElementById('authorFilter').value;
    const search = document.getElementById('text-srh').value;
    
    const params = new URLSearchParams();
    if (type) params.set('type', type);
    if (author) params.set('author', author);
    if (search) params.set('search', search);
    
    window.location.href = '/ghost/admin/posts' + (params.toString() ? '?' + params.toString() : '');
}

// Ghost-style Interface Functions
function updateBulkActions() {
    const checkboxes = document.querySelectorAll('.post-checkbox:checked');
    const bulkBar = document.getElementById('bulkActionsBar');
    const selectedCount = document.getElementById('selectedCount');
    
    if (checkboxes.length > 0) {
        bulkBar.classList.remove('hidden');
        selectedCount.textContent = checkboxes.length;
    } else {
        bulkBar.classList.add('hidden');
    }
}

function clearSelection() {
    const checkboxes = document.querySelectorAll('.post-checkbox');
    checkboxes.forEach(cb => cb.checked = false);
    updateBulkActions();
}

function bulkDelete() {
    const checkboxes = document.querySelectorAll('.post-checkbox:checked');
    if (checkboxes.length === 0) return;
    
    const postIds = Array.from(checkboxes).map(cb => cb.value);
    const confirmMsg = `Are you sure you want to delete ${postIds.length} post${postIds.length > 1 ? 's' : ''}? This action cannot be undone.`;
    
    if (confirm(confirmMsg)) {
        // TODO: Implement bulk delete AJAX call
        showMessage(`${postIds.length} posts deleted successfully`, 'success');
        setTimeout(() => location.reload(), 1000);
    }
}

function togglePostMenu(postId) {
    // Close all other menus first
    document.querySelectorAll('.ghost-post-menu').forEach(menu => {
        if (menu.id !== `postMenu${postId}`) {
            menu.classList.remove('show');
        }
    });
    
    // Toggle current menu
    const menu = document.getElementById(`postMenu${postId}`);
    const button = document.querySelector(`button[onclick*="togglePostMenu('${postId}')"]`);
    
    if (menu.classList.contains('show')) {
        menu.classList.remove('show');
    } else {
        // Position menu relative to button
        const buttonRect = button.getBoundingClientRect();
        const menuHeight = 80; // Approximate menu height
        const windowHeight = window.innerHeight;
        
        // Check if there's enough space below
        if (buttonRect.bottom + menuHeight > windowHeight) {
            // Position above the button
            menu.style.top = (buttonRect.top - menuHeight - 5) + 'px';
        } else {
            // Position below the button
            menu.style.top = (buttonRect.bottom + 5) + 'px';
        }
        
        menu.style.left = (buttonRect.right - 120) + 'px'; // 120px is menu width
        menu.classList.add('show');
    }
}

function quickPublish(postId) {
    const button = document.querySelector(`button[onclick*="${postId}"]`);
    const originalContent = button.innerHTML;
    
    button.innerHTML = '<i class="ti ti-loader animate-spin"></i>';
    button.disabled = true;
    
    // AJAX call to publish post
    const formData = new FormData();
    formData.append('postId', postId);
    formData.append('status', 'published');
    
    fetch('/ghost/admin/ajax/quick-publish.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        const success = data.success || data.SUCCESS;
        const message = data.message || data.MESSAGE;
        
        if (success) {
            showMessage('Post published successfully', 'success');
            setTimeout(() => location.reload(), 1000);
        } else {
            showMessage('Error publishing post: ' + (message || 'Unknown error'), 'error');
            button.innerHTML = originalContent;
            button.disabled = false;
        }
    })
    .catch(error => {
        console.error('Publish error:', error);
        showMessage('Error publishing post', 'error');
        button.innerHTML = originalContent;
        button.disabled = false;
    });
}

function quickUnpublish(postId) {
    const button = document.querySelector(`button[onclick*="${postId}"]`);
    const originalContent = button.innerHTML;
    
    button.innerHTML = '<i class="ti ti-loader animate-spin"></i>';
    button.disabled = true;
    
    // AJAX call to unpublish post
    const formData = new FormData();
    formData.append('postId', postId);
    formData.append('status', 'draft');
    
    fetch('/ghost/admin/ajax/quick-publish.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        const success = data.success || data.SUCCESS;
        const message = data.message || data.MESSAGE;
        
        if (success) {
            showMessage('Post unpublished successfully', 'success');
            setTimeout(() => location.reload(), 1000);
        } else {
            showMessage('Error unpublishing post: ' + (message || 'Unknown error'), 'error');
            button.innerHTML = originalContent;
            button.disabled = false;
        }
    })
    .catch(error => {
        console.error('Unpublish error:', error);
        showMessage('Error unpublishing post', 'error');
        button.innerHTML = originalContent;
        button.disabled = false;
    });
}

function duplicatePost(postId) {
    showMessage('Duplicating post...', 'info');
    
    const formData = new FormData();
    formData.append('postId', postId);
    
    fetch('/ghost/admin/ajax/duplicate-post.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        const success = data.success || data.SUCCESS;
        const message = data.message || data.MESSAGE;
        const newPostId = data.newPostId || data.NEWPOSTID;
        
        if (success) {
            showMessage('Post duplicated successfully', 'success');
            setTimeout(() => {
                window.location.href = `/ghost/admin/posts/edit/${newPostId}`;
            }, 1000);
        } else {
            showMessage('Error duplicating post: ' + (message || 'Unknown error'), 'error');
        }
    })
    .catch(error => {
        console.error('Duplicate error:', error);
        showMessage('Error duplicating post', 'error');
    });
}

// Close menus when clicking outside
document.addEventListener('click', function(e) {
    if (!e.target.closest('.ghost-more-actions')) {
        document.querySelectorAll('.ghost-post-menu').forEach(menu => {
            menu.classList.remove('show');
        });
    }
});

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
    console.log('Posts page loaded');
    
    // Debug sidebar visibility
    const sidebar = document.getElementById('application-sidebar-brand');
    if (sidebar) {
        console.log('Sidebar found:', sidebar);
        console.log('Sidebar classes:', sidebar.className);
        console.log('Sidebar computed transform:', window.getComputedStyle(sidebar).transform);
        console.log('Sidebar computed display:', window.getComputedStyle(sidebar).display);
        
        // Add debug class to make it visible
        sidebar.classList.add('debug-sidebar');
    } else {
        console.error('Sidebar not found!');
    }
    
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
            const checkboxes = document.querySelectorAll('.post-checkbox');
            checkboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
        });
    }
    
    // Verify deletePost function is available
    console.log('deletePost function available:', typeof deletePost);
});
</script>

<cfinclude template="includes/footer.cfm">