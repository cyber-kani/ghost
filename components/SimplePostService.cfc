component {
    
    public SimplePostService function init() {
        return this;
    }
    
    public struct function getPosts(
        numeric page = 1,
        numeric limit = 15,
        string status = "",
        string author = "",
        boolean featured = false
    ) {
        try {
            // Direct database query to get posts
            var result = queryExecute("
                SELECT id, title, status, created_at, updated_at, published_at, 
                       featured, created_by, plaintext, html, slug
                FROM posts 
                ORDER BY updated_at DESC 
                LIMIT :limit OFFSET :offset
            ", {
                limit: {value: arguments.limit, cfsqltype: "cf_sql_integer"},
                offset: {value: (arguments.page - 1) * arguments.limit, cfsqltype: "cf_sql_integer"}
            }, {
                datasource: "blog"
            });
            
            // Get total count
            var countResult = queryExecute("SELECT COUNT(*) as total FROM posts", {}, {datasource: "blog"});
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
                    featured: result.featured[i],
                    created_by: result.created_by[i],
                    plaintext: result.plaintext[i],
                    html: result.html[i],
                    slug: result.slug[i]
                };
                
                // Add basic author info
                post.author = {
                    id: post.created_by,
                    name: "Sample Author",
                    avatar: "https://ui-avatars.com/api/?name=Sample+Author&background=5D87FF&color=fff"
                };
                
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
            return {
                success: false,
                message: "Error retrieving posts: " & e.message,
                data: [],
                recordCount: 0,
                totalRecords: 0
            };
        }
    }
    
    public struct function deletePost(required string id) {
        try {
            // Check if post exists
            var checkResult = queryExecute("SELECT title FROM posts WHERE id = :id", {
                id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
            }, {datasource: "blog"});
            
            if (checkResult.recordCount == 0) {
                return {
                    success: false,
                    message: "Post not found",
                    data: {}
                };
            }
            
            var postTitle = checkResult.title;
            
            // Delete the post
            queryExecute("DELETE FROM posts WHERE id = :id", {
                id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}
            }, {datasource: "blog"});
            
            return {
                success: true,
                message: "Post '" & postTitle & "' has been deleted successfully",
                data: {
                    deletedId: arguments.id,
                    deletedTitle: postTitle
                }
            };
            
        } catch (any e) {
            return {
                success: false,
                message: "Error deleting post: " & e.message,
                data: {}
            };
        }
    }
    
    public struct function getPostStats() {
        try {
            var stats = {
                total: 0,
                published: 0,
                draft: 0,
                scheduled: 0,
                featured: 0
            };
            
            var result = queryExecute("
                SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) as published,
                    SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft,
                    SUM(CASE WHEN status = 'scheduled' THEN 1 ELSE 0 END) as scheduled,
                    SUM(CASE WHEN featured = 1 THEN 1 ELSE 0 END) as featured
                FROM posts
            ", {}, {datasource: "blog"});
            
            if (result.recordCount > 0) {
                stats.total = result.total;
                stats.published = result.published;
                stats.draft = result.draft;
                stats.scheduled = result.scheduled;
                stats.featured = result.featured;
            }
            
            return {
                success: true,
                stats: stats
            };
            
        } catch (any e) {
            return {
                success: false,
                message: "Error retrieving stats: " & e.message,
                stats: {}
            };
        }
    }
}