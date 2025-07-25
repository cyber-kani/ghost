<!--- Dynamic page title and post loading --->
<cfscript>
    // Extract ID from URL path: /ghost/admin/post/edit/[id]
    // Try multiple methods to get the post ID
    postId = "";
    
    // Method 1: PATH_INFO
    if (structKeyExists(cgi, "path_info") && len(trim(cgi.path_info))) {
        pathInfo = cgi.path_info;
        urlParts = listToArray(pathInfo, "/");
        
        // Find the ID after 'edit' in the URL path
        for (i = 1; i <= arrayLen(urlParts); i++) {
            if (urlParts[i] == "edit" && i < arrayLen(urlParts)) {
                postId = urlParts[i + 1];
                break;
            }
        }
    }
    
    // Method 2: Parse from SCRIPT_NAME and REQUEST_URI
    if (len(trim(postId)) == 0 && structKeyExists(cgi, "request_uri")) {
        requestUri = cgi.request_uri;
        // Extract everything after /post/edit/
        if (find("/post/edit/", requestUri)) {
            startPos = find("/post/edit/", requestUri) + len("/post/edit/");
            remainder = mid(requestUri, startPos, len(requestUri));
            // Get first part before any query string or additional path
            if (find("?", remainder)) {
                postId = left(remainder, find("?", remainder) - 1);
            } else if (find("/", remainder)) {
                postId = left(remainder, find("/", remainder) - 1);
            } else {
                postId = remainder;
            }
        }
    }
    
    // Method 3: Fallback to URL parameter
    if (len(trim(postId)) == 0) {
        param name="url.id" default="";
        postId = url.id;
    }
    
    // Clean the post ID (remove any trailing slashes or parameters)
    postId = trim(postId);
    if (right(postId, 1) == "/") {
        postId = left(postId, len(postId) - 1);
    }
    
    // Debug output (remove in production)
    writeOutput("<!-- DEBUG: ");
    writeOutput("REQUEST_URI: " & (structKeyExists(cgi, "request_uri") ? cgi.request_uri : "not found"));
    writeOutput(", PATH_INFO: " & (structKeyExists(cgi, "path_info") ? cgi.path_info : "not found"));
    writeOutput(", SCRIPT_NAME: " & (structKeyExists(cgi, "script_name") ? cgi.script_name : "not found"));
    writeOutput(", Extracted postId: '" & postId & "'");
    writeOutput(" -->");
</cfscript>

<cfparam name="url.type" default="post"> <!--- post or page --->

<cfset pageTitle = (url.type == "page") ? "Edit Page" : "Edit Post">

<!--- Load post data if editing existing post --->
<cfscript>
    // Initialize variables
    post = {};
    isNewPost = (len(trim(postId)) == 0);
    hasError = false;
    errorMessage = "";
    
    if (!isNewPost) {
        try {
            // In a real implementation, you'd load the post from database
            // For now, we'll simulate loading a post
            post = {
                id: postId,
                title: "Sample Post Title",
                slug: "sample-post-title",
                html: "<p>This is the content of the post with <strong>formatting</strong> and <a href='#'>links</a>.</p><h2>Subheading</h2><p>More content here...</p>",
                plaintext: "This is the content of the post with formatting and links. Subheading More content here...",
                feature_image: "",
                excerpt: "A brief excerpt of the post content...",
                status: "draft",
                visibility: "public",
                published_at: "",
                created_at: now(),
                updated_at: now(),
                featured: false,
                tags: ["Sample Tag", "Another Tag"],
                meta_title: "",
                meta_description: "",
                og_image: "",
                og_title: "",
                og_description: "",
                twitter_image: "",
                twitter_title: "",
                twitter_description: "",
                canonical_url: "",
                custom_excerpt: "",
                codeinjection_head: "",
                codeinjection_foot: "",
                created_by: "1",
                type: url.type
            };
            pageTitle = (url.type == "page") ? "Edit Page: " & post.title : "Edit Post: " & post.title;
        } catch (any e) {
            hasError = true;
            errorMessage = "Error loading post: " & e.message;
        }
    } else {
        // New post defaults
        post = {
            id: "",
            title: "",
            slug: "",
            html: "",
            plaintext: "",
            feature_image: "",
            excerpt: "",
            status: "draft",
            visibility: "public",
            published_at: "",
            created_at: now(),
            updated_at: now(),
            featured: false,
            tags: [],
            meta_title: "",
            meta_description: "",
            og_image: "",
            og_title: "",
            og_description: "",
            twitter_image: "",
            twitter_title: "",
            twitter_description: "",
            canonical_url: "",
            custom_excerpt: "",
            codeinjection_head: "",
            codeinjection_foot: "",
            created_by: "1",
            type: url.type
        };
        pageTitle = (url.type == "page") ? "New Page" : "New Post";
    }
    
    // Available tags for selection (would come from database)
    availableTags = [
        {id: "1", name: "Technology", slug: "technology"},
        {id: "2", name: "Travel", slug: "travel"},
        {id: "3", name: "Food", slug: "food"},
        {id: "4", name: "Lifestyle", slug: "lifestyle"},
        {id: "5", name: "Business", slug: "business"}
    ];
</cfscript>

<cfinclude template="../includes/header.cfm">

<!-- Custom Editor Styles -->
<style>
.editor-container {
    min-height: 500px;
}

.editor-toolbar {
    border-bottom: 1px solid #e5e7eb;
    padding: 12px 16px;
    background: #f9fafb;
    border-radius: 8px 8px 0 0;
}

.editor-content {
    padding: 20px;
    min-height: 400px;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    font-size: 16px;
}

.editor-content:focus {
    outline: none;
}

.card-menu {
    border: 2px dashed #d1d5db;
    border-radius: 8px;
    padding: 20px;
    text-align: center;
    margin: 20px 0;
    transition: all 0.2s;
}

.card-menu:hover {
    border-color: #6366f1;
    background-color: #f8fafc;
}

.tag-input {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    min-height: 42px;
    padding: 8px 12px;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    background: white;
}

.tag-item {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    background: #3b82f6;
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 14px;
}

.tag-remove {
    cursor: pointer;
    background: rgba(255,255,255,0.3);
    border-radius: 50%;
    width: 16px;
    height: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
}

.settings-panel {
    max-height: 600px;
    overflow-y: auto;
}

.floating-toolbar {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: white;
    border-radius: 12px;
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    padding: 12px 20px;
    display: flex;
    gap: 12px;
    align-items: center;
    z-index: 1000;
}

.word-count {
    font-size: 14px;
    color: #6b7280;
}

@media (max-width: 768px) {
    .floating-toolbar {
        position: relative;
        bottom: auto;
        right: auto;
        margin-top: 20px;
        justify-content: center;
    }
}
</style>

<!-- Main Editor Layout -->
<div class="body-wrapper">
    <div class="container-fluid">
        
        <!-- Error Display -->
        <cfif hasError>
            <div class="alert alert-danger mb-6">
                <div class="d-flex align-items-center">
                    <i class="ti ti-alert-circle me-2"></i>
                    <cfoutput>#errorMessage#</cfoutput>
                </div>
            </div>
        </cfif>

        <!-- Editor Header -->
        <div class="card mb-6 shadow-none">
            <div class="card-body p-6">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <a href="javascript:history.back()" class="btn btn-light-secondary btn-sm">
                            <i class="ti ti-arrow-left me-2"></i>Back
                        </a>
                        <div>
                            <h4 class="font-semibold text-xl text-dark dark:text-white mb-1">
                                <cfoutput>#pageTitle#</cfoutput>
                            </h4>
                            <div class="flex items-center gap-4 text-sm text-bodytext">
                                <span class="flex items-center gap-1">
                                    <i class="ti ti-clock text-sm"></i>
                                    <cfoutput>
                                        <cfif isNewPost>
                                            Creating new #lcase(url.type)#
                                        <cfelse>
                                            Last updated #dateFormat(post.updated_at, "mmm d, yyyy")# at #timeFormat(post.updated_at, "h:mm tt")#
                                        </cfif>
                                    </cfoutput>
                                </span>
                                <span class="word-count">0 words</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="flex gap-2">
                        <button type="button" class="btn btn-outline-secondary" id="previewBtn">
                            <i class="ti ti-eye me-2"></i>Preview
                        </button>
                        <button type="button" class="btn btn-outline-primary" id="settingsBtn" data-bs-toggle="modal" data-bs-target="#settingsModal">
                            <i class="ti ti-settings me-2"></i>Settings
                        </button>
                        <div class="dropdown">
                            <button class="btn btn-primary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                <i class="ti ti-device-floppy me-2"></i>Save
                            </button>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="#" onclick="savePost('draft')">Save as Draft</a></li>
                                <li><a class="dropdown-item" href="#" onclick="savePost('published')">Publish Now</a></li>
                                <li><a class="dropdown-item" href="#" onclick="savePost('scheduled')">Schedule</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            
            <!-- Main Editor Column -->
            <div class="col-xl-8 col-lg-7">
                
                <!-- Title Input -->
                <div class="card mb-4">
                    <div class="card-body p-0">
                        <input type="text" 
                               class="form-control border-0 fs-4 fw-bold" 
                               id="postTitle"
                               placeholder="Post title"
                               value="<cfoutput>#post.title#</cfoutput>"
                               style="font-size: 28px; padding: 24px;">
                    </div>
                </div>

                <!-- Feature Image -->
                <div class="card mb-4" id="featureImageCard">
                    <div class="card-body">
                        <div class="feature-image-container">
                            <cfif len(trim(post.feature_image)) gt 0>
                                <div class="position-relative">
                                    <img src="<cfoutput>#post.feature_image#</cfoutput>" class="img-fluid rounded" id="featureImagePreview">
                                    <div class="position-absolute top-0 end-0 p-2">
                                        <button class="btn btn-sm btn-light-error" onclick="removeFeatureImage()">
                                            <i class="ti ti-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            <cfelse>
                                <div class="text-center py-5 border-2 border-dashed rounded" id="featureImagePlaceholder">
                                    <i class="ti ti-photo display-6 text-bodytext mb-3"></i>
                                    <h5 class="text-dark dark:text-white mb-2">Add a feature image</h5>
                                    <p class="text-bodytext mb-3">Upload an image to make your post stand out</p>
                                    <button class="btn btn-primary" onclick="uploadFeatureImage()">
                                        <i class="ti ti-upload me-2"></i>Upload Image
                                    </button>
                                </div>
                            </cfif>
                        </div>
                    </div>
                </div>

                <!-- Main Editor -->
                <div class="card editor-container">
                    <!-- Editor Toolbar -->
                    <div class="editor-toolbar">
                        <div class="flex items-center gap-2">
                            <button class="btn btn-sm btn-light-secondary" onclick="formatText('bold')" title="Bold (Cmd+B)">
                                <i class="ti ti-bold"></i>
                            </button>
                            <button class="btn btn-sm btn-light-secondary" onclick="formatText('italic')" title="Italic (Cmd+I)">
                                <i class="ti ti-italic"></i>
                            </button>
                            <button class="btn btn-sm btn-light-secondary" onclick="formatText('underline')" title="Underline">
                                <i class="ti ti-underline"></i>
                            </button>
                            
                            <div class="vr mx-2"></div>
                            
                            <div class="dropdown">
                                <button class="btn btn-sm btn-light-secondary dropdown-toggle" data-bs-toggle="dropdown">
                                    <i class="ti ti-heading me-1"></i>Heading
                                </button>
                                <ul class="dropdown-menu">
                                    <li><a class="dropdown-item" href="#" onclick="formatText('h1')">Heading 1</a></li>
                                    <li><a class="dropdown-item" href="#" onclick="formatText('h2')">Heading 2</a></li>
                                    <li><a class="dropdown-item" href="#" onclick="formatText('h3')">Heading 3</a></li>
                                    <li><a class="dropdown-item" href="#" onclick="formatText('p')">Paragraph</a></li>
                                </ul>
                            </div>
                            
                            <button class="btn btn-sm btn-light-secondary" onclick="formatText('quote')" title="Quote">
                                <i class="ti ti-quote"></i>
                            </button>
                            
                            <div class="vr mx-2"></div>
                            
                            <button class="btn btn-sm btn-light-secondary" onclick="formatText('ul')" title="Bullet List">
                                <i class="ti ti-list"></i>
                            </button>
                            <button class="btn btn-sm btn-light-secondary" onclick="formatText('ol')" title="Numbered List">
                                <i class="ti ti-list-numbers"></i>
                            </button>
                            
                            <div class="vr mx-2"></div>
                            
                            <button class="btn btn-sm btn-light-secondary" onclick="insertLink()" title="Link (Cmd+K)">
                                <i class="ti ti-link"></i>
                            </button>
                            <button class="btn btn-sm btn-light-secondary" onclick="insertImage()" title="Image">
                                <i class="ti ti-photo"></i>
                            </button>
                            
                            <div class="vr mx-2"></div>
                            
                            <button class="btn btn-sm btn-light-secondary" onclick="insertCard()" title="Insert Card (+)">
                                <i class="ti ti-plus"></i>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Editor Content Area -->
                    <div class="editor-content" 
                         contenteditable="true" 
                         id="editorContent"
                         data-placeholder="Start writing your story...">
                        <cfoutput>#post.html#</cfoutput>
                    </div>
                    
                    <!-- Card Insert Menu (Hidden by default) -->
                    <div class="card-menu d-none" id="cardMenu">
                        <h6 class="mb-3">Insert Content</h6>
                        <div class="row g-3">
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertImageCard()">
                                    <i class="ti ti-photo d-block mb-2 fs-4"></i>
                                    <small>Image</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertVideoCard()">
                                    <i class="ti ti-video d-block mb-2 fs-4"></i>
                                    <small>Video</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertEmbedCard()">
                                    <i class="ti ti-code d-block mb-2 fs-4"></i>
                                    <small>Embed</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertBookmarkCard()">
                                    <i class="ti ti-bookmark d-block mb-2 fs-4"></i>
                                    <small>Bookmark</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertGalleryCard()">
                                    <i class="ti ti-layout-grid d-block mb-2 fs-4"></i>
                                    <small>Gallery</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertDividerCard()">
                                    <i class="ti ti-minus d-block mb-2 fs-4"></i>
                                    <small>Divider</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertHTMLCard()">
                                    <i class="ti ti-code d-block mb-2 fs-4"></i>
                                    <small>HTML</small>
                                </button>
                            </div>
                            <div class="col-md-3 col-6">
                                <button class="btn btn-outline-primary w-100 h-100" onclick="insertProductCard()">
                                    <i class="ti ti-shopping-cart d-block mb-2 fs-4"></i>
                                    <small>Product</small>
                                </button>
                            </div>
                        </div>
                        <button class="btn btn-sm btn-outline-secondary mt-3" onclick="hideCardMenu()">Cancel</button>
                    </div>
                </div>
            </div>

            <!-- Sidebar -->
            <div class="col-xl-4 col-lg-5">
                
                <!-- Quick Actions -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Publish</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Status</label>
                            <select class="form-select" id="postStatus">
                                <option value="draft" <cfif post.status eq "draft">selected</cfif>>Draft</option>
                                <option value="published" <cfif post.status eq "published">selected</cfif>>Published</option>
                                <option value="scheduled" <cfif post.status eq "scheduled">selected</cfif>>Scheduled</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Visibility</label>
                            <select class="form-select" id="postVisibility">
                                <option value="public" <cfif post.visibility eq "public">selected</cfif>>Public</option>
                                <option value="members" <cfif post.visibility eq "members">selected</cfif>>Members only</option>
                                <option value="paid" <cfif post.visibility eq "paid">selected</cfif>>Paid members only</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">Publish Date</label>
                            <input type="datetime-local" class="form-control" id="publishDate" value="<cfoutput>#dateFormat(post.published_at, 'yyyy-mm-dd')#T#timeFormat(post.published_at, 'HH:mm')#</cfoutput>">
                        </div>
                        
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="featuredPost" <cfif post.featured>checked</cfif>>
                            <label class="form-check-label" for="featuredPost">
                                Featured post
                            </label>
                        </div>
                        
                        <div class="d-grid gap-2">
                            <button class="btn btn-primary" onclick="savePost()">
                                <i class="ti ti-device-floppy me-2"></i>Save
                            </button>
                            <button class="btn btn-outline-primary" onclick="previewPost()">
                                <i class="ti ti-eye me-2"></i>Preview
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Tags -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Tags</h5>
                    </div>
                    <div class="card-body">
                        <div class="tag-input" id="tagInput">
                            <cfoutput>
                            <cfloop array="#post.tags#" index="tag">
                                <span class="tag-item">
                                    #tag#
                                    <span class="tag-remove" onclick="removeTag(this)">×</span>
                                </span>
                            </cfloop>
                            </cfoutput>
                            <input type="text" placeholder="Add tags..." class="border-0 outline-0 flex-1" id="tagInputField">
                        </div>
                        <div class="mt-2">
                            <small class="text-bodytext">Popular tags:</small>
                            <div class="mt-1">
                                <cfoutput>
                                <cfloop array="#availableTags#" index="tag">
                                    <button class="btn btn-sm btn-outline-secondary me-1 mb-1" onclick="addTag('#tag.name#')">
                                        #tag.name#
                                    </button>
                                </cfloop>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Excerpt -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">Excerpt</h5>
                    </div>
                    <div class="card-body">
                        <textarea class="form-control" rows="3" placeholder="Write a short excerpt..." id="postExcerpt"><cfoutput>#post.excerpt#</cfoutput></textarea>
                        <div class="form-text">Optional excerpt that appears in previews</div>
                    </div>
                </div>

                <!-- URL Slug -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="card-title mb-0">URL</h5>
                    </div>
                    <div class="card-body">
                        <div class="input-group">
                            <span class="input-group-text">your-site.com/</span>
                            <input type="text" class="form-control" id="postSlug" value="<cfoutput>#post.slug#</cfoutput>">
                        </div>
                        <div class="form-text">The URL slug for this post</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Floating Toolbar -->
<div class="floating-toolbar">
    <span class="word-count">0 words</span>
    <div class="vr"></div>
    <button class="btn btn-sm btn-light-secondary" onclick="savePost('draft')" title="Save Draft">
        <i class="ti ti-device-floppy"></i>
    </button>
    <button class="btn btn-sm btn-light-success" onclick="previewPost()" title="Preview">
        <i class="ti ti-eye"></i>
    </button>
</div>

<!-- Settings Modal -->
<div class="modal fade" id="settingsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Post Settings</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body settings-panel">
                
                <!-- SEO Settings -->
                <div class="mb-4">
                    <h6 class="fw-bold mb-3">SEO & Social</h6>
                    
                    <div class="mb-3">
                        <label class="form-label">Meta Title</label>
                        <input type="text" class="form-control" id="metaTitle" value="<cfoutput>#post.meta_title#</cfoutput>">
                        <div class="form-text">Recommended: 70 characters</div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Meta Description</label>
                        <textarea class="form-control" rows="3" id="metaDescription"><cfoutput>#post.meta_description#</cfoutput></textarea>
                        <div class="form-text">Recommended: 156 characters</div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Canonical URL</label>
                        <input type="url" class="form-control" id="canonicalUrl" value="<cfoutput>#post.canonical_url#</cfoutput>">
                    </div>
                </div>

                <!-- Social Media -->
                <div class="mb-4">
                    <h6 class="fw-bold mb-3">Social Media</h6>
                    
                    <!-- Facebook -->
                    <div class="mb-3">
                        <label class="form-label">Facebook Title</label>
                        <input type="text" class="form-control" id="ogTitle" value="<cfoutput>#post.og_title#</cfoutput>">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Facebook Description</label>
                        <textarea class="form-control" rows="2" id="ogDescription"><cfoutput>#post.og_description#</cfoutput></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Facebook Image</label>
                        <input type="url" class="form-control" id="ogImage" value="<cfoutput>#post.og_image#</cfoutput>">
                    </div>
                    
                    <!-- Twitter -->
                    <div class="mb-3">
                        <label class="form-label">Twitter Title</label>
                        <input type="text" class="form-control" id="twitterTitle" value="<cfoutput>#post.twitter_title#</cfoutput>">
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Twitter Description</label>
                        <textarea class="form-control" rows="2" id="twitterDescription"><cfoutput>#post.twitter_description#</cfoutput></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Twitter Image</label>
                        <input type="url" class="form-control" id="twitterImage" value="<cfoutput>#post.twitter_image#</cfoutput>">
                    </div>
                </div>

                <!-- Code Injection -->
                <div class="mb-4">
                    <h6 class="fw-bold mb-3">Code Injection</h6>
                    
                    <div class="mb-3">
                        <label class="form-label">Header Code</label>
                        <textarea class="form-control font-monospace" rows="4" id="headerCode" placeholder="<!-- Custom head code --><script></script>"><cfoutput>#post.codeinjection_head#</cfoutput></textarea>
                        <div class="form-text">Code injected into the post &lt;head&gt;</div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Footer Code</label>
                        <textarea class="form-control font-monospace" rows="4" id="footerCode" placeholder="<!-- Custom footer code --><script></script>"><cfoutput>#post.codeinjection_foot#</cfoutput></textarea>
                        <div class="form-text">Code injected into the post footer</div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="saveSettings()">Save Settings</button>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript -->
<script>
console.log('Ghost Editor JavaScript loading...');

// Editor functionality
let editorContent = document.getElementById('editorContent');
let wordCountElements = document.querySelectorAll('.word-count');

// Word count functionality
function updateWordCount() {
    const text = editorContent.innerText || editorContent.textContent || '';
    const wordCount = text.trim() ? text.trim().split(/\s+/).length : 0;
    wordCountElements.forEach(el => {
        el.textContent = wordCount + ' words';
    });
}

// Initialize word count
updateWordCount();

// Update word count on content change
editorContent.addEventListener('input', updateWordCount);

// Auto-save functionality
let autoSaveTimer;
function triggerAutoSave() {
    clearTimeout(autoSaveTimer);
    autoSaveTimer = setTimeout(() => {
        console.log('Auto-saving...');
        // Auto-save implementation
    }, 2000);
}

editorContent.addEventListener('input', triggerAutoSave);

// Formatting functions
function formatText(command) {
    document.execCommand(command, false, null);
    editorContent.focus();
}

// Insert link
function insertLink() {
    const url = prompt('Enter URL:');
    if (url) {
        document.execCommand('createLink', false, url);
    }
    editorContent.focus();
}

// Insert image
function insertImage() {
    const url = prompt('Enter image URL:');
    if (url) {
        document.execCommand('insertImage', false, url);
    }
    editorContent.focus();
}

// Card insertion
function insertCard() {
    const cardMenu = document.getElementById('cardMenu');
    cardMenu.classList.toggle('d-none');
}

function hideCardMenu() {
    document.getElementById('cardMenu').classList.add('d-none');
}

// Card type functions
function insertImageCard() {
    const imageHtml = '<div class="image-card my-4"><p>📸 Image Card - Click to upload image</p></div>';
    document.execCommand('insertHTML', false, imageHtml);
    hideCardMenu();
}

function insertVideoCard() {
    const videoHtml = '<div class="video-card my-4"><p>🎥 Video Card - Click to add video</p></div>';
    document.execCommand('insertHTML', false, videoHtml);
    hideCardMenu();
}

function insertEmbedCard() {
    const embedHtml = '<div class="embed-card my-4"><p>🔗 Embed Card - Click to add embed code</p></div>';
    document.execCommand('insertHTML', false, embedHtml);
    hideCardMenu();
}

function insertBookmarkCard() {
    const bookmarkHtml = '<div class="bookmark-card my-4"><p>🔖 Bookmark Card - Click to add bookmark</p></div>';
    document.execCommand('insertHTML', false, bookmarkHtml);
    hideCardMenu();
}

function insertGalleryCard() {
    const galleryHtml = '<div class="gallery-card my-4"><p>🖼️ Gallery Card - Click to add images</p></div>';
    document.execCommand('insertHTML', false, galleryHtml);
    hideCardMenu();
}

function insertDividerCard() {
    const dividerHtml = '<hr class="my-4">';
    document.execCommand('insertHTML', false, dividerHtml);
    hideCardMenu();
}

function insertHTMLCard() {
    const htmlCode = prompt('Enter HTML code:');
    if (htmlCode) {
        document.execCommand('insertHTML', false, htmlCode);
    }
    hideCardMenu();
}

function insertProductCard() {
    const productHtml = '<div class="product-card my-4 p-3 border rounded"><p>🛒 Product Card - Click to configure product</p></div>';
    document.execCommand('insertHTML', false, productHtml);
    hideCardMenu();
}

// Tag management
function addTag(tagName) {
    const tagInput = document.getElementById('tagInput');
    const tagItem = document.createElement('span');
    tagItem.className = 'tag-item';
    tagItem.innerHTML = `${tagName} <span class="tag-remove" onclick="removeTag(this)">×</span>`;
    
    // Insert before the input field
    const inputField = document.getElementById('tagInputField');
    tagInput.insertBefore(tagItem, inputField);
}

function removeTag(element) {
    element.parentNode.remove();
}

// Tag input functionality
document.getElementById('tagInputField').addEventListener('keypress', function(e) {
    if (e.key === 'Enter' || e.key === ',') {
        e.preventDefault();
        const tagName = this.value.trim();
        if (tagName) {
            addTag(tagName);
            this.value = '';
        }
    }
});

// Feature image functions
function uploadFeatureImage() {
    // Simulate file upload
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const placeholder = document.getElementById('featureImagePlaceholder');
                placeholder.innerHTML = `
                    <div class="position-relative">
                        <img src="${e.target.result}" class="img-fluid rounded" id="featureImagePreview">
                        <div class="position-absolute top-0 end-0 p-2">
                            <button class="btn btn-sm btn-light-error" onclick="removeFeatureImage()">
                                <i class="ti ti-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
            };
            reader.readAsDataURL(file);
        }
    };
    input.click();
}

function removeFeatureImage() {
    document.getElementById('featureImagePlaceholder').innerHTML = `
        <div class="text-center py-5 border-2 border-dashed rounded">
            <i class="ti ti-photo display-6 text-bodytext mb-3"></i>
            <h5 class="text-dark dark:text-white mb-2">Add a feature image</h5>
            <p class="text-bodytext mb-3">Upload an image to make your post stand out</p>
            <button class="btn btn-primary" onclick="uploadFeatureImage()">
                <i class="ti ti-upload me-2"></i>Upload Image
            </button>
        </div>
    `;
}

// Save functions
function savePost(status = null) {
    const postData = {
        title: document.getElementById('postTitle').value,
        content: editorContent.innerHTML,
        slug: document.getElementById('postSlug').value,
        excerpt: document.getElementById('postExcerpt').value,
        status: status || document.getElementById('postStatus').value,
        visibility: document.getElementById('postVisibility').value,
        featured: document.getElementById('featuredPost').checked,
        publishDate: document.getElementById('publishDate').value
    };
    
    console.log('Saving post:', postData);
    
    // Show success message
    showMessage('Post saved successfully!', 'success');
}

function saveSettings() {
    const settingsData = {
        metaTitle: document.getElementById('metaTitle').value,
        metaDescription: document.getElementById('metaDescription').value,
        canonicalUrl: document.getElementById('canonicalUrl').value,
        ogTitle: document.getElementById('ogTitle').value,
        ogDescription: document.getElementById('ogDescription').value,
        ogImage: document.getElementById('ogImage').value,
        twitterTitle: document.getElementById('twitterTitle').value,
        twitterDescription: document.getElementById('twitterDescription').value,
        twitterImage: document.getElementById('twitterImage').value,
        headerCode: document.getElementById('headerCode').value,
        footerCode: document.getElementById('footerCode').value
    };
    
    console.log('Saving settings:', settingsData);
    
    // Close modal
    const modal = bootstrap.Modal.getInstance(document.getElementById('settingsModal'));
    modal.hide();
    
    showMessage('Settings saved successfully!', 'success');
}

// Preview function
function previewPost() {
    console.log('Opening preview...');
    showMessage('Preview feature coming soon!', 'info');
}

// Auto-generate slug from title
document.getElementById('postTitle').addEventListener('input', function() {
    const title = this.value;
    const slug = title.toLowerCase()
        .replace(/[^\w\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .trim('-');
    document.getElementById('postSlug').value = slug;
});

// Message function (reuse from other pages)
function showMessage(message, type) {
    const existingMessage = document.querySelector('.alert-message');
    if (existingMessage) {
        existingMessage.remove();
    }
    
    const messageEl = document.createElement('div');
    messageEl.className = `alert-message fixed top-4 right-4 px-4 py-3 rounded-md shadow-lg z-50 max-w-md`;
    
    if (type === 'success') {
        messageEl.className += ' bg-success text-white';
        messageEl.innerHTML = `<i class="ti ti-check-circle me-2"></i>${message}`;
    } else if (type === 'error') {
        messageEl.className += ' bg-error text-white';
        messageEl.innerHTML = `<i class="ti ti-alert-circle me-2"></i>${message}`;
    } else if (type === 'info') {
        messageEl.className += ' bg-info text-white';
        messageEl.innerHTML = `<i class="ti ti-info-circle me-2"></i>${message}`;
    }
    
    messageEl.innerHTML += `<button onclick="this.parentElement.remove()" class="ml-3 text-white hover:text-gray-200"><i class="ti ti-x"></i></button>`;
    
    document.body.appendChild(messageEl);
    
    setTimeout(() => {
        if (messageEl.parentElement) {
            messageEl.style.transition = 'opacity 0.3s ease';
            messageEl.style.opacity = '0';
            setTimeout(() => messageEl.remove(), 300);
        }
    }, 5000);
}

// Keyboard shortcuts
document.addEventListener('keydown', function(e) {
    if (e.metaKey || e.ctrlKey) {
        switch(e.key) {
            case 'b':
                e.preventDefault();
                formatText('bold');
                break;
            case 'i':
                e.preventDefault();
                formatText('italic');
                break;
            case 'k':
                e.preventDefault();
                insertLink();
                break;
            case 's':
                e.preventDefault();
                savePost();
                break;
        }
    }
    
    // Slash command for cards
    if (e.key === '/' && editorContent.contains(document.activeElement)) {
        setTimeout(() => {
            const selection = window.getSelection();
            if (selection.toString() === '/') {
                insertCard();
            }
        }, 100);
    }
});

console.log('Ghost Editor JavaScript loaded successfully');
</script>

<cfinclude template="../includes/footer.cfm">