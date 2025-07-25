/**
 * PostService.cfc
 * Post management service for Ghost CFML implementation
 * Extends BaseService to provide post-specific functionality
 * 
 * Material3 + Apple HIG + Ghost CMS Implementation
 * Version: 1.0.0
 */
component displayname="PostService" extends="BaseService" hint="Service class for managing Ghost posts and pages" {

    /**
     * Constructor
     * Initializes PostService with posts table configuration
     */
    public PostService function init() {
        // Initialize base service with posts table configuration
        super.init(
            datasource = "blog",
            tableName = "posts",
            primaryKey = "id",
            requiredFields = ["title", "slug", "type", "status"]
        );
        
        // Post-specific configuration
        variables.validStatuses = ["draft", "published", "scheduled"];
        variables.validTypes = ["post", "page"];
        variables.validVisibility = ["public", "members", "paid"];
        
        return this;
    }
    
    /**
     * Create a new post with Ghost-specific validation and defaults
     * @param data Struct containing post data
     * @return struct with creation result
     */
    public struct function createPost(required struct data) {
        // Set Ghost-specific defaults
        arguments.data = setPostDefaults(arguments.data);
        
        // Validate post-specific fields
        var validation = validatePostData(arguments.data);
        if (!validation.valid) {
            return {
                success: false,
                message: validation.message,
                id: "",
                data: {}
            };
        }
        
        // Generate slug if not provided
        if (!structKeyExists(arguments.data, "slug") || len(arguments.data.slug) == 0) {
            arguments.data.slug = generateSlug(arguments.data.title);
        }
        
        // Ensure slug is unique
        arguments.data.slug = ensureUniqueSlug(arguments.data.slug);
        
        // Generate UUID if not provided
        if (!structKeyExists(arguments.data, "uuid")) {
            arguments.data.uuid = createUUID();
        }
        
        // Call parent create method
        return super.create(arguments.data);
    }
    
    /**
     * Update an existing post
     * @param id Post ID
     * @param data Updated post data
     * @return struct with update result
     */
    public struct function updatePost(required string id, required struct data) {
        // Validate post-specific fields if provided
        var validation = validatePostData(arguments.data, false);
        if (!validation.valid) {
            return {
                success: false,
                message: validation.message,
                data: {}
            };
        }
        
        // Handle slug updates
        if (structKeyExists(arguments.data, "slug") && len(arguments.data.slug) > 0) {
            arguments.data.slug = ensureUniqueSlug(arguments.data.slug, arguments.id);
        }
        
        // Handle status changes
        if (structKeyExists(arguments.data, "status")) {
            arguments.data = handleStatusChange(arguments.id, arguments.data);
        }
        
        return super.update(arguments.id, arguments.data);
    }
    
    /**
     * Get posts with enhanced filtering for Ghost features
     * @param page Page number
     * @param limit Posts per page
     * @param status Filter by status (draft, published, scheduled)
     * @param type Filter by type (post, page)
     * @param author Filter by author ID
     * @param tag Filter by tag slug
     * @param featured Filter featured posts only
     * @return struct with posts and pagination
     */
    public struct function getPosts(
        numeric page = 1,
        numeric limit = 20,
        string status = "",
        string type = "post",
        string author = "",
        string tag = "",
        boolean featured = false
    ) {
        var filters = {};
        
        // Apply type filter (default to posts, not pages)
        if (len(arguments.type) > 0) {
            filters.type = arguments.type;
        }
        
        // Apply status filter
        if (len(arguments.status) > 0 && arrayFind(variables.validStatuses, arguments.status)) {
            filters.status = arguments.status;
        }
        
        // Apply author filter
        if (len(arguments.author) > 0) {
            filters.created_by = arguments.author;
        }
        
        // Apply featured filter
        if (arguments.featured) {
            filters.featured = 1;
        }
        
        var result = super.list(
            page = arguments.page,
            limit = arguments.limit,
            orderBy = "updated_at",
            orderDirection = "DESC",
            filters = filters
        );
        
        // Add tag filtering if specified (requires JOIN)
        if (len(arguments.tag) > 0 && result.success) {
            result = filterPostsByTag(result, arguments.tag);
        }
        
        // Enhance posts with author information
        if (result.success && arrayLen(result.data) > 0) {
            result.data = enhancePostsWithAuthors(result.data);
        }
        
        // Transform BaseService result to expected posts.cfm format
        if (result.success) {
            result.recordCount = arrayLen(result.data);
            result.totalRecords = result.pagination.total;
            result.currentPage = result.pagination.page;
            result.totalPages = result.pagination.totalPages;
            result.startRecord = ((result.currentPage - 1) * arguments.limit) + 1;
            result.endRecord = min(result.startRecord + arrayLen(result.data) - 1, result.totalRecords);
        }
        
        return result;
    }
    
    /**
     * Get a single post by slug (for frontend display)
     * @param slug Post slug
     * @param status Optional status filter (default: published)
     * @return struct with post data
     */
    public struct function getPostBySlug(required string slug, string status = "published") {
        try {
            var sql = "SELECT * FROM posts WHERE slug = :slug";
            var params = {slug: {value: arguments.slug, cfsqltype: "cf_sql_varchar"}};
            
            if (len(arguments.status) > 0) {
                sql &= " AND status = :status";
                params.status = {value: arguments.status, cfsqltype: "cf_sql_varchar"};
            }
            
            var queryResult = super.executeQuery(sql, params);
            
            if (queryResult.success && queryResult.recordCount > 0) {
                return {
                    success: true,
                    message: "Post found",
                    data: queryRowToStruct(queryResult.query, 1)
                };
            } else {
                return {
                    success: false,
                    message: "Post not found",
                    data: {}
                };
            }
            
        } catch (any e) {
            return {
                success: false,
                message: "Error retrieving post: " & e.message,
                data: {}
            };
        }
    }
    
    /**
     * Publish a draft post
     * @param id Post ID
     * @return struct with operation result
     */
    public struct function publishPost(required string id) {
        var updateData = {
            status: "published",
            published_at: now(),
            published_by: getCurrentUserId()
        };
        
        return updatePost(arguments.id, updateData);
    }
    
    /**
     * Unpublish a post (set to draft)
     * @param id Post ID
     * @return struct with operation result
     */
    public struct function unpublishPost(required string id) {
        var updateData = {
            status: "draft",
            published_at: "",
            published_by: ""
        };
        
        return updatePost(arguments.id, updateData);
    }
    
    /**
     * Schedule a post for future publication
     * @param id Post ID
     * @param publishDate When to publish the post
     * @return struct with operation result
     */
    public struct function schedulePost(required string id, required date publishDate) {
        var updateData = {
            status: "scheduled",
            published_at: arguments.publishDate,
            published_by: getCurrentUserId()
        };
        
        return updatePost(arguments.id, updateData);
    }
    
    /**
     * Toggle featured status of a post
     * @param id Post ID
     * @return struct with operation result
     */
    public struct function toggleFeatured(required string id) {
        var currentPost = read(arguments.id);
        if (!currentPost.success) {
            return currentPost;
        }
        
        var newFeaturedStatus = currentPost.data.featured ? false : true;
        return updatePost(arguments.id, {featured: newFeaturedStatus});
    }
    
    /**
     * Delete a post permanently
     * @param id Post ID
     * @return struct with operation result
     */
    public struct function deletePost(required string id) {
        try {
            // First check if post exists
            var postCheck = read(arguments.id);
            if (!postCheck.success) {
                return {
                    success: false,
                    message: "Post not found",
                    data: {}
                };
            }
            
            // Store post title for success message
            var postTitle = postCheck.data.title;
            
            // Delete the post using BaseService delete method
            var deleteResult = super.delete(arguments.id);
            
            if (deleteResult.success) {
                return {
                    success: true,
                    message: "Post '" & postTitle & "' has been deleted successfully",
                    data: {
                        deletedId: arguments.id,
                        deletedTitle: postTitle
                    }
                };
            } else {
                return {
                    success: false,
                    message: "Failed to delete post: " & deleteResult.message,
                    data: {}
                };
            }
            
        } catch (any e) {
            return {
                success: false,
                message: "Error deleting post: " & e.message,
                data: {}
            };
        }
    }
    
    /**
     * Get all authors for filter dropdown
     * @return struct with authors array
     */
    public struct function getAuthors() {
        try {
            var userService = createObject("component", "components.UserService").init();
            var result = userService.getUsers(active = true);
            
            if (result.success) {
                return {
                    success: true,
                    message: "Authors retrieved successfully",
                    data: result.data
                };
            } else {
                return result;
            }
            
        } catch (any e) {
            return {
                success: false,
                message: "Error retrieving authors: " & e.message,
                data: []
            };
        }
    }
    
    /**
     * Get post statistics
     * @return struct with post counts by status and type
     */
    public struct function getPostStats() {
        var result = {
            success: false,
            message: "",
            stats: {
                total: 0,
                published: 0,
                draft: 0,
                scheduled: 0,
                posts: 0,
                pages: 0,
                featured: 0
            }
        };
        
        try {
            // Get total counts
            result.stats.total = super.count();
            result.stats.published = super.count({status: "published"});
            result.stats.draft = super.count({status: "draft"});
            result.stats.scheduled = super.count({status: "scheduled"});
            result.stats.posts = super.count({type: "post"});
            result.stats.pages = super.count({type: "page"});
            result.stats.featured = super.count({featured: 1});
            
            result.success = true;
            result.message = "Statistics retrieved successfully";
            
        } catch (any e) {
            result.message = "Error retrieving post statistics: " & e.message;
        }
        
        return result;
    }
    
    // PRIVATE HELPER METHODS
    
    /**
     * Set default values for new posts
     * @param data Post data struct
     * @return struct with defaults applied
     */
    private struct function setPostDefaults(required struct data) {
        // Set default type
        if (!structKeyExists(arguments.data, "type")) {
            arguments.data.type = "post";
        }
        
        // Set default status
        if (!structKeyExists(arguments.data, "status")) {
            arguments.data.status = "draft";
        }
        
        // Set default visibility
        if (!structKeyExists(arguments.data, "visibility")) {
            arguments.data.visibility = "public";
        }
        
        // Set default featured status
        if (!structKeyExists(arguments.data, "featured")) {
            arguments.data.featured = false;
        }
        
        // Set default comment_id (required by Ghost schema)
        if (!structKeyExists(arguments.data, "comment_id")) {
            arguments.data.comment_id = createGhostUUID();
        }
        
        // Set default locale
        if (!structKeyExists(arguments.data, "locale")) {
            arguments.data.locale = "en";
        }
        
        // Set author information
        if (!structKeyExists(arguments.data, "created_by")) {
            arguments.data.created_by = getCurrentUserId();
        }
        if (!structKeyExists(arguments.data, "updated_by")) {
            arguments.data.updated_by = getCurrentUserId();
        }
        
        // Generate plaintext from HTML if provided
        if (structKeyExists(arguments.data, "html") && !structKeyExists(arguments.data, "plaintext")) {
            arguments.data.plaintext = generatePlaintext(arguments.data.html);
        }
        
        // Default mobiledoc if not provided (Ghost's editor format)
        if (!structKeyExists(arguments.data, "mobiledoc")) {
            arguments.data.mobiledoc = '{"version":"0.3.1","atoms":[],"cards":[],"markups":[],"sections":[[1,"p",[[0,[],0,""]]]]}';
        }
        
        return arguments.data;
    }
    
    /**
     * Validate post-specific data
     * @param data Post data to validate
     * @param requireAll Whether all required fields must be present
     * @return struct with validation result
     */
    private struct function validatePostData(required struct data, boolean requireAll = true) {
        var result = {
            valid: true,
            message: "",
            errors: []
        };
        
        // Validate status
        if (structKeyExists(arguments.data, "status") && !arrayFind(variables.validStatuses, arguments.data.status)) {
            arrayAppend(result.errors, "Invalid status. Must be one of: " & arrayToList(variables.validStatuses));
            result.valid = false;
        }
        
        // Validate type
        if (structKeyExists(arguments.data, "type") && !arrayFind(variables.validTypes, arguments.data.type)) {
            arrayAppend(result.errors, "Invalid type. Must be one of: " & arrayToList(variables.validTypes));
            result.valid = false;
        }
        
        // Validate visibility
        if (structKeyExists(arguments.data, "visibility") && !arrayFind(variables.validVisibility, arguments.data.visibility)) {
            arrayAppend(result.errors, "Invalid visibility. Must be one of: " & arrayToList(variables.validVisibility));
            result.valid = false;
        }
        
        // Validate title length
        if (structKeyExists(arguments.data, "title") && len(arguments.data.title) > 255) {
            arrayAppend(result.errors, "Title cannot exceed 255 characters");
            result.valid = false;
        }
        
        // Validate slug format
        if (structKeyExists(arguments.data, "slug") && len(arguments.data.slug) > 0) {
            if (!isValidSlug(arguments.data.slug)) {
                arrayAppend(result.errors, "Slug contains invalid characters. Use only letters, numbers, and hyphens");
                result.valid = false;
            }
        }
        
        if (!result.valid) {
            result.message = arrayToList(result.errors, "; ");
        }
        
        return result;
    }
    
    /**
     * Generate a URL-friendly slug from title
     * @param title Post title
     * @return string URL-friendly slug
     */
    private string function generateSlug(required string title) {
        var slug = lCase(trim(arguments.title));
        
        // Replace special characters and spaces with hyphens
        slug = reReplace(slug, "[^a-z0-9\s-]", "", "all");
        slug = reReplace(slug, "\s+", "-", "all");
        slug = reReplace(slug, "-+", "-", "all");
        slug = reReplace(slug, "^-+|-+$", "", "all");
        
        // Limit length
        if (len(slug) > 100) {
            slug = left(slug, 100);
            slug = reReplace(slug, "^-+|-+$", "", "all");
        }
        
        return slug;
    }
    
    /**
     * Ensure slug is unique by appending number if needed
     * @param slug Proposed slug
     * @param excludeId ID to exclude from uniqueness check
     * @return string unique slug
     */
    private string function ensureUniqueSlug(required string slug, string excludeId = "") {
        var baseSlug = arguments.slug;
        var counter = 1;
        var finalSlug = baseSlug;
        
        while (slugExists(finalSlug, arguments.excludeId)) {
            finalSlug = baseSlug & "-" & counter;
            counter++;
        }
        
        return finalSlug;
    }
    
    /**
     * Check if a slug already exists
     * @param slug Slug to check
     * @param excludeId ID to exclude from check
     * @return boolean true if slug exists
     */
    private boolean function slugExists(required string slug, string excludeId = "") {
        try {
            var sql = "SELECT COUNT(*) as count FROM posts WHERE slug = :slug";
            var params = {slug: {value: arguments.slug, cfsqltype: "cf_sql_varchar"}};
            
            if (len(arguments.excludeId) > 0) {
                sql &= " AND id != :excludeId";
                params.excludeId = {value: arguments.excludeId, cfsqltype: "cf_sql_varchar"};
            }
            
            var queryResult = super.executeQuery(sql, params);
            return queryResult.success && queryResult.query.count > 0;
            
        } catch (any e) {
            return false;
        }
    }
    
    /**
     * Validate slug format
     * @param slug Slug to validate
     * @return boolean true if valid
     */
    private boolean function isValidSlug(required string slug) {
        // Check if slug contains only valid characters
        return reFind("^[a-z0-9-]+$", arguments.slug) > 0;
    }
    
    /**
     * Handle status change logic (publishing dates, etc.)
     * @param id Post ID
     * @param data Update data
     * @return struct updated data with status change handling
     */
    private struct function handleStatusChange(required string id, required struct data) {
        var currentPost = read(arguments.id);
        if (!currentPost.success) {
            return arguments.data;
        }
        
        var oldStatus = currentPost.data.status;
        var newStatus = arguments.data.status;
        
        // Handle publishing
        if (oldStatus != "published" && newStatus == "published") {
            if (!structKeyExists(arguments.data, "published_at") || len(arguments.data.published_at) == 0) {
                arguments.data.published_at = now();
            }
            if (!structKeyExists(arguments.data, "published_by")) {
                arguments.data.published_by = getCurrentUserId();
            }
        }
        
        // Handle unpublishing
        if (oldStatus == "published" && newStatus != "published") {
            // Keep published_at and published_by for history
            // No changes needed
        }
        
        return arguments.data;
    }
    
    /**
     * Filter posts by tag (requires JOIN with posts_tags table)
     * @param result Current list result
     * @param tagSlug Tag slug to filter by
     * @return struct filtered result
     */
    private struct function filterPostsByTag(required struct result, required string tagSlug) {
        // This would require implementing tag relationships
        // For now, return the original result
        // TODO: Implement tag filtering with JOIN when TagService is created
        return arguments.result;
    }
    
    /**
     * Generate plaintext from HTML content
     * @param html HTML content
     * @return string plain text version
     */
    private string function generatePlaintext(required string html) {
        // Remove HTML tags and entities
        var plaintext = reReplace(arguments.html, "<[^>]*>", "", "all");
        plaintext = reReplace(plaintext, "&[a-z]+;", " ", "all");
        plaintext = reReplace(plaintext, "\s+", " ", "all");
        plaintext = trim(plaintext);
        
        // Limit length for database storage
        if (len(plaintext) > 2000) {
            plaintext = left(plaintext, 2000) & "...";
        }
        
        return plaintext;
    }
    
    /**
     * Create Ghost-compatible UUID
     * @return string Ghost UUID format
     */
    private string function createGhostUUID() {
        return createUUID();
    }
    
    /**
     * Get current user ID (placeholder for authentication system)
     * @return string current user ID
     */
    private string function getCurrentUserId() {
        // TODO: Implement proper user authentication
        // For now, return a default user ID
        if (structKeyExists(session, "userId")) {
            return session.userId;
        } else {
            return "default-user-id";
        }
    }
    
    /**
     * Enhance posts array with author information
     * @param posts Array of post structs
     * @return array Enhanced posts with author data
     */
    private array function enhancePostsWithAuthors(required array posts) {
        try {
            // Get unique author IDs from posts
            var authorIds = [];
            for (var post in arguments.posts) {
                if (structKeyExists(post, "created_by") && len(post.created_by) > 0) {
                    if (!arrayFind(authorIds, post.created_by)) {
                        arrayAppend(authorIds, post.created_by);
                    }
                }
            }
            
            if (arrayLen(authorIds) == 0) {
                return arguments.posts; // No authors to enhance
            }
            
            // Get author data
            var userService = createObject("component", "components.UserService").init();
            var authorsResult = userService.getUsersByIds(authorIds);
            
            if (!authorsResult.success) {
                return arguments.posts; // Return original posts if author fetch fails
            }
            
            // Create author lookup map for performance
            var authorMap = {};
            for (var author in authorsResult.data) {
                authorMap[author.id] = author;
            }
            
            // Enhance posts with author information
            for (var i = 1; i <= arrayLen(arguments.posts); i++) {
                var post = arguments.posts[i];
                if (structKeyExists(post, "created_by") && structKeyExists(authorMap, post.created_by)) {
                    var author = authorMap[post.created_by];
                    post.author = {
                        id: author.id,
                        name: author.name,
                        slug: structKeyExists(author, "slug") ? author.slug : "",
                        avatar: author.avatar
                    };
                } else {
                    // Default author for posts without valid author
                    post.author = {
                        id: "",
                        name: "Unknown Author",
                        slug: "",
                        avatar: "https://ui-avatars.com/api/?name=Unknown+Author&background=CCCCCC&color=fff&size=64"
                    };
                }
            }
            
            return arguments.posts;
            
        } catch (any e) {
            // On error, return original posts
            return arguments.posts;
        }
    }
    
    /**
     * Convert query row to struct (inherit from BaseService)
     * @param query Query object
     * @param row Row number
     * @return struct Row data
     */
    private struct function queryRowToStruct(required query query, required numeric row) {
        var result = {};
        var columns = listToArray(arguments.query.columnList);
        
        for (var column in columns) {
            result[column] = arguments.query[column][arguments.row];
        }
        
        return result;
    }
}