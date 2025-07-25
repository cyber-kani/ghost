<!--- Post Editor with URL ID handling --->
<cfscript>
    // Get post ID from URL parameter (primary method)
    param name="url.id" default="";
    postId = url.id;
    
    // Clean the post ID
    postId = trim(postId);
    if (len(postId) > 0 && right(postId, 1) == "/") {
        postId = left(postId, len(postId) - 1);
    }
    
    // Debug output
    writeOutput("<!-- DEBUG INFO: ");
    writeOutput("URL.ID: '" & url.id & "'");
    writeOutput(", Extracted ID: '" & postId & "'");
    writeOutput(", REQUEST_URI: " & (structKeyExists(cgi, "request_uri") ? cgi.request_uri : "N/A"));
    writeOutput(" -->");
</cfscript>

<cfparam name="url.type" default="post">
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
                title: "Sample Post Title - ID: " & postId,
                slug: "sample-post-title",
                html: "<p>This is the content of the post with <strong>formatting</strong> and <a href='##'>links</a>.</p><h2>Subheading</h2><p>More content here...</p>",
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

<!-- Simple Test Display -->
<div class="body-wrapper">
    <div class="container-fluid">
        
        <!-- Test Information -->
        <div class="card mb-6">
            <div class="card-body">
                <h4 class="font-semibold text-xl text-dark dark:text-white mb-4">
                    <cfoutput>#pageTitle#</cfoutput>
                </h4>
                
                <div class="alert alert-info">
                    <h5>URL Routing Test</h5>
                    <cfoutput>
                        <p><strong>Post ID extracted:</strong> "#postId#"</p>
                        <p><strong>Is New Post:</strong> #isNewPost#</p>
                        <cfif !isNewPost>
                            <p><strong>Post Title:</strong> #post.title#</p>
                        </cfif>
                    </cfoutput>
                </div>
                
                <div class="mt-4">
                    <h6>Test URLs:</h6>
                    <ul>
                        <li><a href="/ghost/admin/post/edit.cfm/687de71ebc740c1b43f0a355">With .cfm extension</a></li>
                        <li><a href="/ghost/admin/post/edit.cfm?id=687de71ebc740c1b43f0a355">With URL parameter</a></li>
                        <li><a href="/ghost/admin/post/edit.cfm">New post (no ID)</a></li>
                    </ul>
                </div>
                
                <div class="mt-4">
                    <a href="javascript:history.back()" class="btn btn-secondary">
                        <i class="ti ti-arrow-left me-2"></i>Back
                    </a>
                    <a href="/ghost/admin/posts" class="btn btn-primary">
                        <i class="ti ti-list me-2"></i>All Posts
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<cfinclude template="../includes/footer.cfm">