/**
 * Simple PostService.cfc - Standalone version for testing
 */
component displayname="PostServiceSimple" hint="Simple PostService without BaseService dependency" {

    /**
     * Constructor
     */
    public PostServiceSimple function init() {
        variables.datasource = "blog";
        variables.tableName = "posts";
        return this;
    }
    
    /**
     * Get sample posts data
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
        var result = {
            success: true,
            message: "Sample data loaded",
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
                    type: "post",
                    visibility: "public"
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
                    type: "post",
                    visibility: "public"
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
                    type: "post",
                    visibility: "public"
                }
            ],
            totalRecords: 3,
            currentPage: arguments.page,
            totalPages: 1,
            startRecord: 1,
            endRecord: 3
        };
        
        return result;
    }
    
    /**
     * Get post statistics
     */
    public struct function getPostStats() {
        return {
            success: true,
            message: "Sample stats loaded",
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
}