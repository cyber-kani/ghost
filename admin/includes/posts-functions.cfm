<!--- 
Posts Functions - Direct implementation without components
This file contains all post-related functions as regular CFML functions
--->

<cfscript>
/**
 * Get paginated posts from database
 */
function getPosts(
    numeric page = 1,
    numeric limit = 15,
    string status = "",
    string author = "",
    boolean featured = false,
    string type = "post"
) {
    try {
        var offset = (arguments.page - 1) * arguments.limit;
        
        // Build WHERE clause
        var whereClause = "1=1";
        var queryParams = {};
        
        // Filter by type (post vs page)
        if (len(arguments.type)) {
            whereClause &= " AND p.type = :type";
            queryParams.type = {value: arguments.type, cfsqltype: "cf_sql_varchar"};
        }
        
        if (len(arguments.status)) {
            whereClause &= " AND p.status = :status";
            queryParams.status = {value: arguments.status, cfsqltype: "cf_sql_varchar"};
        }
        
        if (len(arguments.author)) {
            whereClause &= " AND p.created_by = :author";
            queryParams.author = {value: arguments.author, cfsqltype: "cf_sql_varchar"};
        }
        
        if (arguments.featured) {
            whereClause &= " AND p.featured = 1";
        }
        
        // Get posts with author information
        var sql = "
            SELECT p.id, p.title, p.status, p.created_at, p.updated_at, p.published_at, 
                   p.featured, p.created_by, p.plaintext, p.html, p.slug, p.type, p.visibility,
                   p.feature_image, p.custom_excerpt,
                   u.name as author_name, u.slug as author_slug, u.profile_image as author_avatar
            FROM posts p
            LEFT JOIN posts_authors pa ON p.id = pa.post_id AND pa.sort_order = 0
            LEFT JOIN users u ON pa.author_id = u.id
            WHERE " & whereClause & "
            ORDER BY p.updated_at DESC 
            LIMIT " & arguments.limit & " OFFSET " & offset;
        
        // Debug output (comment out for production)    
        // writeOutput("<!-- DEBUG getPosts: status='" & arguments.status & "', whereClause='" & whereClause & "' -->");
            
        var result = queryExecute(sql, queryParams, {datasource: request.dsn});
        
        // Get total count
        var countSql = "SELECT COUNT(DISTINCT p.id) as total FROM posts p LEFT JOIN posts_authors pa ON p.id = pa.post_id WHERE " & whereClause;
        var countResult = queryExecute(countSql, queryParams, {datasource: request.dsn});
        var totalRecords = countResult.total;
        
        // Convert query to array of structs
        var posts = [];
        for (var i = 1; i <= result.recordCount; i++) {
            var post = {
                id: result.id[i],
                title: result.title[i],
                status: result.status[i],
                created_at: result.created_at[i],
                updated_at: result.updated_at[i],
                published_at: result.published_at[i],
                featured: result.featured[i] ? true : false,
                created_by: result.created_by[i],
                plaintext: result.plaintext[i] ?: "",
                html: result.html[i] ?: "",
                slug: result.slug[i] ?: "",
                type: result.type[i] ?: "post",
                visibility: result.visibility[i] ?: "public",
                feature_image: result.feature_image[i] ?: "",
                custom_excerpt: result.custom_excerpt[i] ?: ""
            };
            
            // Add author info from database
            var authorName = "";
            var authorAvatar = "";
            
            if (len(result.author_name[i] ?: "")) {
                authorName = result.author_name[i];
                authorAvatar = len(result.author_avatar[i] ?: "") ? result.author_avatar[i] : "https://ui-avatars.com/api/?name=" & URLEncodedFormat(authorName) & "&background=5D87FF&color=fff";
            } else {
                authorName = "Author " & post.created_by;
                authorAvatar = "https://ui-avatars.com/api/?name=Author+" & post.created_by & "&background=5D87FF&color=fff";
            }
            
            post.author = {
                id: post.created_by,
                name: authorName,
                avatar: authorAvatar,
                slug: result.author_slug[i] ?: ""
            };
            
            // Also add author_name at top level for compatibility
            post.author_name = authorName;
            
            arrayAppend(posts, post);
        }
        
        return {
            success: true,
            data: posts,
            recordCount: result.recordCount,
            totalRecords: totalRecords,
            currentPage: arguments.page,
            totalPages: ceiling(totalRecords / arguments.limit),
            startRecord: ((arguments.page - 1) * arguments.limit) + 1,
            endRecord: min(((arguments.page - 1) * arguments.limit) + result.recordCount, totalRecords)
        };
        
    } catch (any e) {
        // Debug error output (comment out for production)
        // writeOutput("<!-- ERROR in getPosts: " & e.message & " -->");
        return {
            success: false,
            message: "Error retrieving posts: " & e.message,
            data: [],
            recordCount: 0,
            totalRecords: 0,
            currentPage: 1,
            totalPages: 0,
            startRecord: 0,
            endRecord: 0
        };
    }
}

/**
 * Delete a post by ID with cascade deletion of related records
 */
function deletePost(required string id) {
    try {
        // Check if post exists
        var checkResult = queryExecute("SELECT title FROM posts WHERE id = :id", {
            id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
        }, {datasource: request.dsn});
        
        if (checkResult.recordCount == 0) {
            return {
                success: false,
                message: "Post not found",
                data: {}
            };
        }
        
        var postTitle = checkResult.title;
        
        // Begin transaction for safe deletion
        var transaction = queryExecute("START TRANSACTION", {}, {datasource: request.dsn});
        
        try {
            // Delete related records first (cascade deletion)
            // This list covers common Ghost CMS related tables
            var relatedTables = [
                {table: "posts_tags", column: "post_id"},
                {table: "posts_authors", column: "post_id"},
                {table: "posts_meta", column: "post_id"},
                {table: "email_recipients", column: "post_id"},
                {table: "comments", column: "post_id"},
                {table: "clicks", column: "post_id"},
                {table: "email_batches", column: "post_id"}
            ];
            
            var deletedRelated = [];
            
            for (var rel in relatedTables) {
                try {
                    // Check if table exists and has records
                    var countResult = queryExecute("SELECT COUNT(*) as count FROM " & rel.table & " WHERE " & rel.column & " = :id", {
                        id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
                    }, {datasource: request.dsn});
                    
                    if (countResult.count > 0) {
                        // Delete related records
                        queryExecute("DELETE FROM " & rel.table & " WHERE " & rel.column & " = :id", {
                            id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
                        }, {datasource: request.dsn});
                        
                        arrayAppend(deletedRelated, rel.table & " (" & countResult.count & " records)");
                    }
                } catch (any tableError) {
                    // Table might not exist - continue with next table
                    // This is normal for partial Ghost implementations
                }
            }
            
            // Now delete the main post
            queryExecute("DELETE FROM posts WHERE id = :id", {
                id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
            }, {datasource: request.dsn});
            
            // Commit transaction
            queryExecute("COMMIT", {}, {datasource: request.dsn});
            
            var message = "Post deleted successfully";
            if (arrayLen(deletedRelated) > 0) {
                message = "Post and " & arrayLen(deletedRelated) & " related records deleted";
            }
            
            return {
                success: true,
                message: message,
                data: {
                    deletedId: arguments.id,
                    deletedTitle: postTitle,
                    relatedDeleted: deletedRelated
                }
            };
            
        } catch (any deleteError) {
            // Rollback transaction on error
            queryExecute("ROLLBACK", {}, {datasource: request.dsn});
            throw deleteError;
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
 * Get post statistics
 */
function getPostStats() {
    try {
        var result = queryExecute("
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) as published,
                SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft,
                SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) as scheduled,
                SUM(CASE WHEN featured = 1 THEN 1 ELSE 0 END) as featured,
                COUNT(*) as posts,
                0 as pages
            FROM posts
            WHERE type = 'post'
        ", {}, {datasource: request.dsn});
        
        var stats = {
            total: result.total,
            published: result.published,
            draft: result.draft,
            scheduled: result.scheduled,
            featured: result.featured,
            posts: result.posts,
            pages: result.pages
        };
        
        return {
            success: true,
            stats: stats
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error retrieving stats: " & e.message,
            stats: {
                total: 0,
                published: 0,
                draft: 0,
                scheduled: 0,
                featured: 0,
                posts: 0,
                pages: 0
            }
        };
    }
}

/**
 * Get paginated pages from database (type = 'page')
 */
function getPages(
    numeric page = 1,
    numeric limit = 15,
    string status = "",
    string author = ""
) {
    return getPosts(
        page = arguments.page,
        limit = arguments.limit,
        status = arguments.status,
        author = arguments.author,
        featured = false,
        type = "page"
    );
}

/**
 * Get page statistics
 */
function getPageStats() {
    try {
        var result = queryExecute("
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) as published,
                SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft,
                SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) as scheduled,
                0 as featured,
                COUNT(*) as pages,
                0 as posts
            FROM posts
            WHERE type = 'page'
        ", {}, {datasource: request.dsn});
        
        var stats = {
            total: result.total,
            published: result.published,
            draft: result.draft,
            scheduled: result.scheduled,
            featured: result.featured,
            posts: result.posts,
            pages: result.pages
        };
        
        return {
            success: true,
            stats: stats
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error retrieving stats: " & e.message,
            stats: {
                total: 0,
                published: 0,
                draft: 0,
                scheduled: 0,
                featured: 0,
                posts: 0,
                pages: 0
            }
        };
    }
}

/**
 * Get all tags from database
 */
function getTags(
    numeric page = 1,
    numeric limit = 15
) {
    try {
        var offset = (arguments.page - 1) * arguments.limit;
        
        // Get tags with post counts
        var sql = "
            SELECT t.id, t.name, t.slug, t.description, t.created_at, t.updated_at,
                   COUNT(pt.post_id) as post_count
            FROM tags t 
            LEFT JOIN posts_tags pt ON t.id = pt.tag_id
            LEFT JOIN posts p ON pt.post_id = p.id AND p.type = 'post'
            GROUP BY t.id, t.name, t.slug, t.description, t.created_at, t.updated_at
            ORDER BY t.name ASC
            LIMIT " & arguments.limit & " OFFSET " & offset;
            
        var result = queryExecute(sql, {}, {datasource: request.dsn});
        
        // Get total count
        var countSql = "SELECT COUNT(*) as total FROM tags";
        var countResult = queryExecute(countSql, {}, {datasource: request.dsn});
        var totalRecords = countResult.total;
        
        // Convert query to array of structs
        var tags = [];
        for (var i = 1; i <= result.recordCount; i++) {
            var tag = {
                id: result.id[i],
                name: result.name[i],
                slug: result.slug[i] ?: "",
                description: result.description[i] ?: "",
                created_at: result.created_at[i],
                updated_at: result.updated_at[i],
                post_count: result.post_count[i]
            };
            
            arrayAppend(tags, tag);
        }
        
        return {
            success: true,
            data: tags,
            recordCount: result.recordCount,
            totalRecords: totalRecords,
            currentPage: arguments.page,
            totalPages: ceiling(totalRecords / arguments.limit),
            startRecord: ((arguments.page - 1) * arguments.limit) + 1,
            endRecord: min(((arguments.page - 1) * arguments.limit) + result.recordCount, totalRecords)
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error retrieving tags: " & e.message,
            data: [],
            recordCount: 0,
            totalRecords: 0,
            currentPage: 1,
            totalPages: 0,
            startRecord: 0,
            endRecord: 0
        };
    }
}

/**
 * Delete a tag by ID
 */
function deleteTag(required string id) {
    try {
        // Check if tag exists
        var checkResult = queryExecute("SELECT name FROM tags WHERE id = :id", {
            id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
        }, {datasource: request.dsn});
        
        if (checkResult.recordCount == 0) {
            return {
                success: false,
                message: "Tag not found",
                data: {}
            };
        }
        
        var tagName = checkResult.name;
        
        // Begin transaction for safe deletion
        var transaction = queryExecute("START TRANSACTION", {}, {datasource: request.dsn});
        
        try {
            // Delete related records first (posts_tags)
            var postsTagsCount = queryExecute("SELECT COUNT(*) as count FROM posts_tags WHERE tag_id = :id", {
                id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
            }, {datasource: request.dsn});
            
            if (postsTagsCount.count > 0) {
                queryExecute("DELETE FROM posts_tags WHERE tag_id = :id", {
                    id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
                }, {datasource: request.dsn});
            }
            
            // Now delete the tag
            queryExecute("DELETE FROM tags WHERE id = :id", {
                id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
            }, {datasource: request.dsn});
            
            // Commit transaction
            queryExecute("COMMIT", {}, {datasource: request.dsn});
            
            var message = "Tag deleted successfully";
            if (postsTagsCount.count > 0) {
                message = "Tag and " & postsTagsCount.count & " post associations deleted";
            }
            
            return {
                success: true,
                message: message,
                data: {
                    deletedId: arguments.id,
                    deletedName: tagName
                }
            };
            
        } catch (any deleteError) {
            // Rollback transaction on error
            queryExecute("ROLLBACK", {}, {datasource: request.dsn});
            throw deleteError;
        }
        
    } catch (any e) {
        return {
            success: false,
            message: "Error deleting tag: " & e.message,
            data: {}
        };
    }
}

/**
 * Get a single post by ID with full details including tags
 */
function getPostById(required string id) {
    try {
        // Get the post with all fields including code injection and templates
        var postQuery = queryExecute("
            SELECT p.id, p.title, p.html, p.plaintext, p.feature_image, p.featured, p.status, 
                   p.visibility, p.slug, p.custom_excerpt, p.canonical_url, p.type, p.published_at, 
                   p.created_at, p.updated_at, p.created_by, p.updated_by,
                   p.codeinjection_head, p.codeinjection_foot, p.custom_template,
                   p.show_title_and_feature_image,
                   pm.meta_title, pm.meta_description,
                   pm.og_title, pm.og_description, pm.og_image,
                   pm.twitter_title, pm.twitter_description, pm.twitter_image
            FROM posts p
            LEFT JOIN posts_meta pm ON p.id = pm.post_id
            WHERE p.id = :id
        ", {
            id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
        }, {datasource: request.dsn});
        
        if (postQuery.recordCount == 0) {
            return {
                success: false,
                message: "Post not found",
                data: []
            };
        }
        
        // Convert to struct
        var post = {
            id: postQuery.id[1],
            title: postQuery.title[1] ?: "",
            html: postQuery.html[1] ?: "",
            plaintext: postQuery.plaintext[1] ?: "",
            feature_image: postQuery.feature_image[1] ?: "",
            featured: postQuery.featured[1] ?: false,
            status: postQuery.status[1] ?: "draft",
            visibility: postQuery.visibility[1] ?: "public",
            slug: postQuery.slug[1] ?: "",
            custom_excerpt: postQuery.custom_excerpt[1] ?: "",
            canonical_url: postQuery.canonical_url[1] ?: "",
            type: postQuery.type[1] ?: "post",
            published_at: postQuery.published_at[1],
            created_at: postQuery.created_at[1],
            updated_at: postQuery.updated_at[1],
            created_by: postQuery.created_by[1] ?: "",
            updated_by: postQuery.updated_by[1] ?: "",
            // Additional fields from posts table
            codeinjection_head: postQuery.codeinjection_head[1] ?: "",
            codeinjection_foot: postQuery.codeinjection_foot[1] ?: "",
            custom_template: postQuery.custom_template[1] ?: "",
            show_title_and_feature_image: postQuery.show_title_and_feature_image[1] ?: true,
            // Fields from posts_meta table
            meta_title: postQuery.meta_title[1] ?: "",
            meta_description: postQuery.meta_description[1] ?: "",
            og_title: postQuery.og_title[1] ?: "",
            og_description: postQuery.og_description[1] ?: "",
            og_image: postQuery.og_image[1] ?: "",
            twitter_title: postQuery.twitter_title[1] ?: "",
            twitter_description: postQuery.twitter_description[1] ?: "",
            twitter_image: postQuery.twitter_image[1] ?: ""
        };
        
        // Get all authors for this post
        var authorsQuery = queryExecute("
            SELECT u.id, u.name, u.slug, u.profile_image
            FROM posts_authors pa
            INNER JOIN users u ON pa.author_id = u.id
            WHERE pa.post_id = :postId
            ORDER BY pa.sort_order
        ", {
            postId: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
        }, {datasource: request.dsn});
        
        // Build authors array
        var authors = [];
        for (var i = 1; i <= authorsQuery.recordCount; i++) {
            arrayAppend(authors, {
                id: authorsQuery.id[i],
                name: authorsQuery.name[i],
                slug: authorsQuery.slug[i] ?: "",
                avatar: authorsQuery.profile_image[i] ?: "https://ui-avatars.com/api/?name=" & URLEncodedFormat(authorsQuery.name[i]) & "&background=5D87FF&color=fff"
            });
        }
        
        // Set primary author (for backward compatibility)
        var authorName = "";
        var authorAvatar = "";
        
        if (len(postQuery.author_name[1] ?: "")) {
            authorName = postQuery.author_name[1];
            authorAvatar = len(postQuery.author_avatar[1] ?: "") ? postQuery.author_avatar[1] : "https://ui-avatars.com/api/?name=" & URLEncodedFormat(authorName) & "&background=5D87FF&color=fff";
        } else {
            authorName = "Author " & post.created_by;
            authorAvatar = "https://ui-avatars.com/api/?name=Author+" & post.created_by & "&background=5D87FF&color=fff";
        }
        
        post.author = {
            id: post.created_by,
            name: authorName,
            avatar: authorAvatar,
            slug: postQuery.author_slug[1] ?: ""
        };
        
        // Get tags for this post
        var tagsQuery = queryExecute("
            SELECT t.id, t.name, t.slug 
            FROM tags t
            INNER JOIN posts_tags pt ON t.id = pt.tag_id
            WHERE pt.post_id = :postId
            ORDER BY t.name
        ", {
            postId: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
        }, {datasource: request.dsn});
        
        var tags = [];
        for (var i = 1; i <= tagsQuery.recordCount; i++) {
            arrayAppend(tags, {
                id: tagsQuery.id[i],
                name: tagsQuery.name[i],
                slug: tagsQuery.slug[i] ?: ""
            });
        }
        
        post.tags = tags;
        
        return {
            success: true,
            data: [post]
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error retrieving post: " & e.message & " - SQL Error: " & (e.sql ?: "No SQL") & " - Detail: " & (e.detail ?: "No detail"),
            data: []
        };
    }
}

/**
 * Create a new post
 */
function createPost(required struct postData) {
    try {
        var sql = "
            INSERT INTO posts (
                id, uuid, title, html, plaintext, featured, status, 
                visibility, slug, type, published_at, created_by, 
                created_at, updated_at, email_recipient_filter
            ) VALUES (
                :id, :uuid, :title, :html, :plaintext, :featured, :status,
                :visibility, :slug, :type, :published_at, :created_by,
                :created_at, :updated_at, :email_recipient_filter
            )
        ";
        
        var params = {
            id: {value: arguments.postData.id, cfsqltype: "cf_sql_varchar"},
            uuid: {value: arguments.postData.uuid ?: createUUID(), cfsqltype: "cf_sql_varchar"},
            title: {value: arguments.postData.title ?: "", cfsqltype: "cf_sql_varchar"},
            html: {value: arguments.postData.html ?: "", cfsqltype: "cf_sql_longvarchar"},
            plaintext: {value: arguments.postData.plaintext ?: "", cfsqltype: "cf_sql_longvarchar"},
            featured: {value: arguments.postData.featured ?: false, cfsqltype: "cf_sql_bit"},
            status: {value: arguments.postData.status ?: "draft", cfsqltype: "cf_sql_varchar"},
            visibility: {value: arguments.postData.visibility ?: "public", cfsqltype: "cf_sql_varchar"},
            slug: {value: arguments.postData.slug ?: "", cfsqltype: "cf_sql_varchar"},
            type: {value: arguments.postData.type ?: "post", cfsqltype: "cf_sql_varchar"},
            created_by: {value: arguments.postData.created_by ?: "1", cfsqltype: "cf_sql_varchar"},
            created_at: {value: arguments.postData.created_at ?: now(), cfsqltype: "cf_sql_timestamp"},
            updated_at: {value: arguments.postData.updated_at ?: now(), cfsqltype: "cf_sql_timestamp"},
            email_recipient_filter: {value: arguments.postData.email_recipient_filter ?: "all", cfsqltype: "cf_sql_varchar"}
        };
        
        // Handle published_at which can be null
        if (structKeyExists(arguments.postData, "published_at") and len(arguments.postData.published_at)) {
            params.published_at = {value: arguments.postData.published_at, cfsqltype: "cf_sql_timestamp"};
        } else {
            params.published_at = {value: "", cfsqltype: "cf_sql_timestamp", null: true};
        }
        
        queryExecute(sql, params, {datasource: request.dsn});
        
        return {
            success: true,
            message: "Post created successfully"
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error creating post: " & e.message
        };
    }
}

/**
 * Update an existing post
 */
function updatePost(required struct postData) {
    try {
        var sql = "
            UPDATE posts SET
                title = :title,
                html = :html,
                plaintext = :plaintext,
                featured = :featured,
                status = :status,
                visibility = :visibility,
                slug = :slug,
                type = :type,
                updated_at = :updated_at
        ";
        
        var params = {
            title: {value: arguments.postData.title ?: "", cfsqltype: "cf_sql_varchar"},
            html: {value: arguments.postData.html ?: "", cfsqltype: "cf_sql_longvarchar"},
            plaintext: {value: arguments.postData.plaintext ?: "", cfsqltype: "cf_sql_longvarchar"},
            featured: {value: arguments.postData.featured ?: false, cfsqltype: "cf_sql_bit"},
            status: {value: arguments.postData.status ?: "draft", cfsqltype: "cf_sql_varchar"},
            visibility: {value: arguments.postData.visibility ?: "public", cfsqltype: "cf_sql_varchar"},
            slug: {value: arguments.postData.slug ?: "", cfsqltype: "cf_sql_varchar"},
            type: {value: arguments.postData.type ?: "post", cfsqltype: "cf_sql_varchar"},
            updated_at: {value: arguments.postData.updated_at ?: now(), cfsqltype: "cf_sql_timestamp"},
            id: {value: arguments.postData.id, cfsqltype: "cf_sql_varchar"}
        };
        
        // Handle published_at which can be null
        if (structKeyExists(arguments.postData, "published_at") and len(arguments.postData.published_at)) {
            sql &= ", published_at = :published_at";
            params.published_at = {value: arguments.postData.published_at, cfsqltype: "cf_sql_timestamp"};
        }
        
        sql &= " WHERE id = :id";
        
        queryExecute(sql, params, {datasource: request.dsn});
        
        return {
            success: true,
            message: "Post updated successfully"
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error updating post: " & e.message
        };
    }
}

/**
 * Strip HTML tags from text
 */
function stripTags(required string str) {
    var result = arguments.str;
    result = reReplace(result, "<[^>]*>", "", "all");
    result = replace(result, "&nbsp;", " ", "all");
    result = replace(result, "&amp;", "&", "all");
    result = replace(result, "&lt;", "<", "all");
    result = replace(result, "&gt;", ">", "all");
    result = replace(result, "&quot;", '"', "all");
    return trim(result);
}

/**
 * Get tags for a specific post
 */
function getPostTags(required string postId) {
    try {
        var tagsQuery = queryExecute("
            SELECT t.id, t.name, t.slug 
            FROM tags t
            INNER JOIN posts_tags pt ON t.id = pt.tag_id
            WHERE pt.post_id = :postId
            ORDER BY t.name
        ", {
            postId: {value: arguments.postId, cfsqltype: "cf_sql_varchar"}
        }, {datasource: request.dsn});
        
        var tags = [];
        for (var i = 1; i <= tagsQuery.recordCount; i++) {
            arrayAppend(tags, {
                id: tagsQuery.id[i],
                name: tagsQuery.name[i],
                slug: tagsQuery.slug[i] ?: ""
            });
        }
        
        return {
            success: true,
            data: tags
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error retrieving post tags: " & e.message,
            data: []
        };
    }
}

/**
 * Escape string for JavaScript (replacement for javaScriptStringFormat)
 */
function escapeForJS(required string str) {
    var result = arguments.str;
    result = replace(result, "\", "\\", "all");  // Escape backslashes first
    result = replace(result, "'", "\'", "all");   // Escape single quotes
    result = replace(result, '"', '\"', "all");   // Escape double quotes
    result = replace(result, chr(13), "\r", "all"); // Escape carriage returns
    result = replace(result, chr(10), "\n", "all"); // Escape line feeds
    return result;
}
</cfscript>