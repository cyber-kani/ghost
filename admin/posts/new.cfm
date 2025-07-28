<!--- Ghost-style New Post/Page Editor for CFGHOST CMS --->
<!--- This creates new posts/pages using the modern Ghost editor with card-based content blocks --->

<cfparam name="url.type" default="post">
<cfset pageTitle = url.type eq "page" ? "New Page" : "New Post">

<!--- Check login status --->
<cfif not structKeyExists(session, "ISLOGGEDIN") or not session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login" addtoken="false">
</cfif>

<!--- Include the posts functions --->
<cfinclude template="../includes/posts-functions.cfm">

<!--- Initialize new post data --->
<cfscript>
// Create new post with Ghost-style ID (24 character hex string)
postData = {
    id: lcase(left(replace(createUUID(), "-", "", "all"), 24)),
    title: "",
    html: "",
    plaintext: "",
    feature_image: "",
    featured: false,
    status: "draft",
    visibility: "public",
    slug: "",
    custom_excerpt: "",
    meta_title: "",
    meta_description: "",
    canonical_url: "",
    custom_template: "",
    codeinjection_head: "",
    codeinjection_foot: "",
    show_title_and_feature_image: true,
    og_title: "",
    og_description: "",
    og_image: "",
    twitter_title: "",
    twitter_description: "",
    twitter_image: "",
    type: url.type,
    published_at: "",
    created_at: now(),
    updated_at: now(),
    created_by: session.USERID ?: "1",
    updated_by: session.USERID ?: "1",
    tags: [],
    authors: [{
        id: session.USERID ?: "1",
        name: session.USERNAME ?: "Admin User",
        email: session.USEREMAIL ?: "admin@example.com",
        avatar: "",
        slug: ""
    }]
};

// Set postId for consistency with edit page
postId = postData.id;

// Get all tags for the tags selector
tagsResult = getTags(1, 100);
allTags = tagsResult.success ? tagsResult.data : [];

// Empty values for new post
firstParagraphText = "";
errorMessage = "";
</cfscript>

<!DOCTYPE html>
<html lang="en" dir="ltr" data-color-theme="Blue_Theme" class="light">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#pageTitle# - CFGHOST</cfoutput></title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="/favicon.ico?v=ghost" type="image/x-icon">
    <link rel="icon" href="/favicon.ico?v=ghost" type="image/x-icon">
    <link rel="icon" type="image/svg+xml" href="/ghost/favicon.svg?v=ghost">
    
    <!-- Core CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css">
    
    <!-- Tabler Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    
    <!-- Include shared editor styles -->
    <cfinclude template="../includes/editor/editor-styles.cfm">
</head>

<body class="DEFAULT_THEME">
    <main>
        <div class="ghost-editor">
            <!-- Include the shared editor template -->
            <cfinclude template="../includes/editor/editor-template.cfm">
        </div>
    </main>
    
    <!-- Core JS -->
    <script src="/ghost/admin/assets/js/vendor.min.js"></script>
    <script src="/ghost/admin/assets/js/app.init.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/preline@2.0.2/dist/preline.js"></script>
    
    <!-- Include shared editor scripts -->
    <cfinclude template="../includes/editor/editor-scripts.cfm">
    
    <!-- Include preview component -->
    <cfinclude template="../includes/editor/preview-component.cfm">
    
    <!-- Initialize editor for new post -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize preview component with post ID
            GhostPreview.init('<cfoutput>#postId#</cfoutput>');
            
            // Set page title
            if (document.querySelector('.editor-title')) {
                document.querySelector('.editor-title').textContent = 'New Post';
            }
            
            // Focus on title input
            const titleInput = document.getElementById('postTitle');
            if (titleInput) {
                setTimeout(() => {
                    titleInput.focus();
                }, 100);
            }
        });
    </script>
</body>
</html>