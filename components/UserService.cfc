/**
 * UserService.cfc
 * User management service for Ghost CFML implementation
 * Extends BaseService to provide user-specific functionality
 * 
 * Material3 + Apple HIG + Ghost CMS Implementation
 * Version: 1.0.0
 */
component displayname="UserService" extends="BaseService" hint="Service class for managing Ghost users/authors" {

    /**
     * Constructor
     * Initializes UserService with users table configuration
     */
    public UserService function init() {
        // Initialize base service with users table configuration
        super.init(
            datasource = "blog",
            tableName = "users",
            primaryKey = "id",
            requiredFields = ["name", "email", "slug", "status"]
        );
        
        // User-specific configuration
        variables.validStatuses = ["active", "inactive", "invited"];
        variables.validRoles = ["admin", "editor", "author", "contributor"];
        
        return this;
    }
    
    /**
     * Get all users for author dropdown/filtering
     * @param active Include only active users
     * @return struct with users array
     */
    public struct function getUsers(boolean active = true) {
        var filters = {};
        
        if (arguments.active) {
            filters.status = "active";
        }
        
        var result = super.list(
            page = 1,
            limit = 100, // Get all users for dropdown
            orderBy = "name",
            orderDirection = "ASC",
            filters = filters
        );
        
        return result;
    }
    
    /**
     * Get user by ID with avatar generation
     * @param id User ID
     * @return struct with user data including generated avatar
     */
    public struct function getUserById(required string id) {
        var result = super.read(arguments.id);
        
        if (result.success && structKeyExists(result, "data")) {
            // Add generated avatar if not present
            if (!structKeyExists(result.data, "profile_image") || len(trim(result.data.profile_image)) == 0) {
                result.data.avatar = generateAvatar(result.data.name, result.data.id);
            } else {
                result.data.avatar = result.data.profile_image;
            }
        }
        
        return result;
    }
    
    /**
     * Get multiple users by IDs with avatar generation
     * @param ids Array of user IDs
     * @return struct with users data
     */
    public struct function getUsersByIds(required array ids) {
        if (arrayLen(arguments.ids) == 0) {
            return {
                success: true,
                data: [],
                message: "No user IDs provided"
            };
        }
        
        try {
            var inClause = "'" & arrayToList(arguments.ids, "','") & "'";
            var sql = "SELECT * FROM users WHERE id IN (#inClause#) ORDER BY name ASC";
            
            var queryResult = super.executeQuery(sql, {});
            
            if (queryResult.success) {
                var users = [];
                
                for (var i = 1; i <= queryResult.recordCount; i++) {
                    var user = queryRowToStruct(queryResult.query, i);
                    
                    // Add generated avatar if not present
                    if (!structKeyExists(user, "profile_image") || len(trim(user.profile_image)) == 0) {
                        user.avatar = generateAvatar(user.name, user.id);
                    } else {
                        user.avatar = user.profile_image;
                    }
                    
                    arrayAppend(users, user);
                }
                
                return {
                    success: true,
                    data: users,
                    message: "Users retrieved successfully"
                };
            } else {
                return queryResult;
            }
            
        } catch (any e) {
            return {
                success: false,
                message: "Error retrieving users: " & e.message,
                data: []
            };
        }
    }
    
    /**
     * Create a new user with Ghost-specific validation and defaults
     * @param data Struct containing user data
     * @return struct with creation result
     */
    public struct function createUser(required struct data) {
        // Set Ghost-specific defaults
        arguments.data = setUserDefaults(arguments.data);
        
        // Validate user-specific fields
        var validation = validateUserData(arguments.data);
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
            arguments.data.slug = generateSlug(arguments.data.name);
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
     * Get user statistics
     * @return struct with user counts by status and role
     */
    public struct function getUserStats() {
        var result = {
            success: false,
            message: "",
            stats: {
                total: 0,
                active: 0,
                inactive: 0,
                invited: 0,
                admins: 0,
                editors: 0,
                authors: 0,
                contributors: 0
            }
        };
        
        try {
            // Get basic counts
            result.stats.total = super.count();
            result.stats.active = super.count({status: "active"});
            result.stats.inactive = super.count({status: "inactive"});
            result.stats.invited = super.count({status: "invited"});
            
            // Role counts would require roles_users table join
            // For now, set default values
            result.stats.admins = 1;
            result.stats.editors = 0;
            result.stats.authors = result.stats.active - 1;
            result.stats.contributors = 0;
            
            result.success = true;
            result.message = "User statistics retrieved successfully";
            
        } catch (any e) {
            result.message = "Error retrieving user statistics: " & e.message;
        }
        
        return result;
    }
    
    // PRIVATE HELPER METHODS
    
    /**
     * Set default values for new users
     * @param data User data struct
     * @return struct with defaults applied
     */
    private struct function setUserDefaults(required struct data) {
        // Set default status
        if (!structKeyExists(arguments.data, "status")) {
            arguments.data.status = "active";
        }
        
        // Set default locale
        if (!structKeyExists(arguments.data, "locale")) {
            arguments.data.locale = "en";
        }
        
        // Set default timezone
        if (!structKeyExists(arguments.data, "timezone")) {
            arguments.data.timezone = "UTC";
        }
        
        // Set default visibility
        if (!structKeyExists(arguments.data, "visibility")) {
            arguments.data.visibility = "public";
        }
        
        return arguments.data;
    }
    
    /**
     * Validate user-specific data
     * @param data User data to validate
     * @param requireAll Whether all required fields must be present
     * @return struct with validation result
     */
    private struct function validateUserData(required struct data, boolean requireAll = true) {
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
        
        // Validate email format
        if (structKeyExists(arguments.data, "email") && len(arguments.data.email) > 0) {
            if (!isValid("email", arguments.data.email)) {
                arrayAppend(result.errors, "Invalid email format");
                result.valid = false;
            }
        }
        
        // Validate name length
        if (structKeyExists(arguments.data, "name") && len(arguments.data.name) > 191) {
            arrayAppend(result.errors, "Name cannot exceed 191 characters");
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
     * Generate a URL-friendly slug from name
     * @param name User name
     * @return string URL-friendly slug
     */
    private string function generateSlug(required string name) {
        var slug = lCase(trim(arguments.name));
        
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
            var sql = "SELECT COUNT(*) as count FROM users WHERE slug = :slug";
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
     * Generate avatar URL using UI Avatars service
     * @param name User name
     * @param id User ID for consistent color
     * @return string Avatar URL
     */
    private string function generateAvatar(required string name, required string id) {
        var colors = ["5D87FF", "49BEFF", "13DEB9", "FFAE1F", "FA896B", "539BFF"];
        var colorIndex = (len(arguments.id) mod arrayLen(colors)) + 1;
        var backgroundColor = colors[colorIndex];
        
        var cleanName = encodeForURL(arguments.name);
        
        return "https://ui-avatars.com/api/?name=" & cleanName & "&background=" & backgroundColor & "&color=fff&size=64";
    }
    
    /**
     * Convert query row to struct
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