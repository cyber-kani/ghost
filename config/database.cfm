<!---
    Database Configuration Helper
    This file contains database configuration constants and helper functions
--->

<cfscript>
    // Database Configuration Constants
    application.database = {
        datasource: "blog",
        name: "cc_prod",
        type: "MySQL",
        timeout: 30,
        maxConnections: 50
    };

    // Ghost Core Tables - Essential for blog functionality
    application.database.coreTables = [
        "posts",           // Blog posts and pages
        "users",           // Staff/admin users
        "tags",            // Content tags
        "posts_tags",      // Post-tag relationships
        "roles",           // User roles (admin, editor, etc.)
        "roles_users",     // User-role assignments
        "permissions",     // Permission definitions
        "permissions_roles", // Role permissions
        "permissions_users", // Direct user permissions
        "settings"         // Site configuration
    ];

    // Ghost Extended Tables - For advanced features
    application.database.extendedTables = [
        "sessions",                    // User sessions
        "members",                     // Public members/subscribers
        "members_stripe_customers",    // Stripe integration
        "stripe_products",             // Stripe products
        "stripe_prices",               // Stripe pricing
        "benefits",                    // Membership benefits
        "members_products",            // Member subscriptions
        "newsletters",                 // Newsletter management
        "posts_authors",               // Multi-author support
        "invites",                     // User invitations
        "brute",                       // Brute force protection
        "webhooks",                    // Webhook management
        "integrations",                // Third-party integrations
        "api_keys",                    // API key management
        "actions",                     // Activity logging
        "emails",                      // Email tracking
        "email_batches",               // Email batch processing
        "email_recipients",            // Email recipient tracking
        "mobiledoc_revisions",         // Content revisions
        "posts_meta",                  // Post metadata
        "users_meta",                  // User metadata
        "tags_meta"                    // Tag metadata
    ];

    // Required columns for core tables
    application.database.requiredColumns = {
        posts: ["id", "uuid", "title", "slug", "mobiledoc", "html", "comment_id", "plaintext", "feature_image", "featured", "type", "status", "locale", "visibility", "email_recipient_filter", "created_at", "created_by", "updated_at", "updated_by", "published_at", "published_by", "custom_excerpt", "codeinjection_head", "codeinjection_foot", "custom_template", "canonical_url"],
        users: ["id", "name", "slug", "password", "email", "profile_image", "cover_image", "bio", "website", "location", "facebook", "twitter", "accessibility", "status", "locale", "visibility", "meta_title", "meta_description", "tour", "last_seen", "created_at", "created_by", "updated_at", "updated_by"],
        tags: ["id", "name", "slug", "description", "feature_image", "parent_id", "visibility", "og_image", "og_title", "og_description", "twitter_image", "twitter_title", "twitter_description", "meta_title", "meta_description", "codeinjection_head", "codeinjection_foot", "canonical_url", "accent_color", "created_at", "created_by", "updated_at", "updated_by"],
        settings: ["id", "key", "value", "type", "flags", "created_at", "created_by", "updated_at", "updated_by"]
    };

    /**
     * Test database connectivity
     * @return struct with connection status and details
     */
    function testDatabaseConnection() {
        local.result = {
            connected: false,
            message: "",
            details: {},
            timestamp: now()
        };
        
        try {
            // Test basic connection
            local.testQuery = queryExecute(
                "SELECT 1 as test_value, NOW() as server_time",
                {},
                {datasource: application.database.datasource, timeout: 10}
            );
            
            if (local.testQuery.recordCount == 1) {
                local.result.connected = true;
                local.result.message = "Database connection successful";
                local.result.details.serverTime = local.testQuery.server_time;
                local.result.details.testValue = local.testQuery.test_value;
            } else {
                local.result.message = "Connection established but test query failed";
            }
            
        } catch (any e) {
            local.result.message = "Database connection failed: " & e.message;
            local.result.details.error = e;
        }
        
        return local.result;
    }

    /**
     * Check if all required tables exist
     * @return struct with table existence status
     */
    function checkTableExistence() {
        local.result = {
            allTablesExist: false,
            existingTables: [],
            missingTables: [],
            totalChecked: 0
        };
        
        local.allTables = [];
        arrayAppend(local.allTables, application.database.coreTables, true);
        arrayAppend(local.allTables, application.database.extendedTables, true);
        
        local.result.totalChecked = arrayLen(local.allTables);
        
        for (local.tableName in local.allTables) {
            try {
                local.testQuery = queryExecute(
                    "SELECT COUNT(*) as row_count FROM #local.tableName#",
                    {},
                    {datasource: application.database.datasource, timeout: 5}
                );
                
                arrayAppend(local.result.existingTables, {
                    name: local.tableName,
                    rowCount: local.testQuery.row_count
                });
                
            } catch (any e) {
                arrayAppend(local.result.missingTables, local.tableName);
            }
        }
        
        local.result.allTablesExist = (arrayLen(local.result.missingTables) == 0);
        
        return local.result;
    }

    /**
     * Validate table structure for a specific table
     * @param tableName The table to validate
     * @return struct with validation results
     */
    function validateTableStructure(required string tableName) {
        local.result = {
            valid: false,
            columns: [],
            missingColumns: [],
            message: ""
        };
        
        if (!structKeyExists(application.database.requiredColumns, arguments.tableName)) {
            local.result.message = "No validation rules defined for table: " & arguments.tableName;
            return local.result;
        }
        
        try {
            local.describeQuery = queryExecute(
                "DESCRIBE #arguments.tableName#",
                {},
                {datasource: application.database.datasource}
            );
            
            // Get actual columns
            for (local.i = 1; local.i <= local.describeQuery.recordCount; local.i++) {
                arrayAppend(local.result.columns, local.describeQuery.Field[local.i]);
            }
            
            // Check for missing required columns
            local.requiredColumns = application.database.requiredColumns[arguments.tableName];
            for (local.reqColumn in local.requiredColumns) {
                if (!arrayFind(local.result.columns, local.reqColumn)) {
                    arrayAppend(local.result.missingColumns, local.reqColumn);
                }
            }
            
            local.result.valid = (arrayLen(local.result.missingColumns) == 0);
            local.result.message = local.result.valid ? 
                "Table structure is valid" : 
                "Missing required columns: " & arrayToList(local.result.missingColumns);
            
        } catch (any e) {
            local.result.message = "Error validating table structure: " & e.message;
        }
        
        return local.result;
    }

    /**
     * Get database statistics
     * @return struct with database statistics
     */
    function getDatabaseStats() {
        local.result = {
            tables: {},
            totalRecords: 0,
            errors: []
        };
        
        local.tablesToCheck = ["posts", "users", "tags", "members", "settings"];
        
        for (local.tableName in local.tablesToCheck) {
            try {
                local.countQuery = queryExecute(
                    "SELECT COUNT(*) as record_count FROM #local.tableName#",
                    {},
                    {datasource: application.database.datasource}
                );
                
                local.result.tables[local.tableName] = local.countQuery.record_count;
                local.result.totalRecords += local.countQuery.record_count;
                
            } catch (any e) {
                arrayAppend(local.result.errors, "Error counting #local.tableName#: " & e.message);
            }
        }
        
        return local.result;
    }
</cfscript>

<!--- Initialize database configuration on first load --->
<cfif NOT structKeyExists(application, "databaseConfigured")>
    <cfset application.databaseConfigured = true>
    <cfset application.databaseInitTime = now()>
    
    <!--- Log database configuration --->
    <cflog file="database" text="Database configuration initialized for datasource: #application.database.datasource#" type="information">
</cfif>