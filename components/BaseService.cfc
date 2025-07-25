/**
 * BaseService.cfc
 * Foundation service class for all Ghost CFML database operations
 * Provides common CRUD operations and utilities following OOP principles
 * 
 * Material3 + Apple HIG + Ghost CMS Implementation
 * Version: 1.0.0
 */
component displayname="BaseService" hint="Base service class providing common database operations" {

    // Properties
    property name="datasource" type="string" getter="true" setter="false";
    property name="tableName" type="string" getter="true" setter="false";
    property name="primaryKey" type="string" getter="true" setter="false";
    property name="requiredFields" type="array" getter="true" setter="false";
    
    /**
     * Constructor
     * @param datasource The datasource name to use
     * @param tableName The primary table this service manages
     * @param primaryKey The primary key field name (default: "id")
     * @param requiredFields Array of required field names for validation
     */
    public BaseService function init(
        required string datasource = "blog",
        string tableName = "",
        string primaryKey = "id",
        array requiredFields = []
    ) {
        variables.datasource = arguments.datasource;
        variables.tableName = arguments.tableName;
        variables.primaryKey = arguments.primaryKey;
        variables.requiredFields = arguments.requiredFields;
        
        // Validate constructor parameters
        if (len(variables.tableName) == 0) {
            throw(type="InvalidArgumentException", message="tableName is required for BaseService initialization");
        }
        
        return this;
    }
    
    /**
     * Create a new record
     * @param data Struct containing the data to insert
     * @return struct with success status and inserted record ID
     */
    public struct function create(required struct data) {
        var result = {
            success: false,
            message: "",
            id: "",
            data: {}
        };
        
        // Validate required fields
        var validation = validateRequiredFields(arguments.data);
        if (!validation.valid) {
            result.message = validation.message;
            return result;
        }
        
        // Add timestamps if not provided
        if (!structKeyExists(arguments.data, "created_at")) {
            arguments.data.created_at = now();
        }
        if (!structKeyExists(arguments.data, "updated_at")) {
            arguments.data.updated_at = now();
        }
        
        // Generate UUID for primary key if not provided
        if (!structKeyExists(arguments.data, variables.primaryKey)) {
            arguments.data[variables.primaryKey] = createGhostId();
        }
        
        try {
            // Build INSERT query dynamically
            var columns = structKeyList(arguments.data);
            var placeholders = "";
            var params = {};
            
            for (var column in structKeyArray(arguments.data)) {
                placeholders = listAppend(placeholders, ":" & column);
                params[column] = {value: arguments.data[column], cfsqltype: getSQLType(arguments.data[column])};
            }
            
            var sql = "INSERT INTO #variables.tableName# (#columns#) VALUES (#placeholders#)";
            
            queryExecute(sql, params, {datasource: variables.datasource});
            
            result.success = true;
            result.message = "Record created successfully";
            result.id = arguments.data[variables.primaryKey];
            result.data = arguments.data;
            
        } catch (any e) {
            result.message = "Database error during create: " & e.message;
            logError("BaseService.create", e, arguments.data);
        }
        
        return result;
    }
    
    /**
     * Read a record by primary key
     * @param id The primary key value
     * @return struct with success status and record data
     */
    public struct function read(required string id) {
        var result = {
            success: false,
            message: "",
            data: {}
        };
        
        try {
            var sql = "SELECT * FROM #variables.tableName# WHERE #variables.primaryKey# = :id";
            var query = queryExecute(sql, {id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}}, {datasource: variables.datasource});
            
            if (query.recordCount > 0) {
                result.success = true;
                result.message = "Record found";
                result.data = queryRowToStruct(query, 1);
            } else {
                result.message = "Record not found";
            }
            
        } catch (any e) {
            result.message = "Database error during read: " & e.message;
            logError("BaseService.read", e, {id: arguments.id});
        }
        
        return result;
    }
    
    /**
     * Update a record by primary key
     * @param id The primary key value
     * @param data Struct containing the data to update
     * @return struct with success status and updated record data
     */
    public struct function update(required string id, required struct data) {
        var result = {
            success: false,
            message: "",
            data: {}
        };
        
        // Check if record exists
        var existingRecord = read(arguments.id);
        if (!existingRecord.success) {
            result.message = "Cannot update: " & existingRecord.message;
            return result;
        }
        
        // Add updated timestamp
        arguments.data.updated_at = now();
        
        try {
            // Build UPDATE query dynamically
            var setClause = "";
            var params = {id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}};
            
            for (var column in structKeyArray(arguments.data)) {
                if (column != variables.primaryKey) { // Don't update primary key
                    setClause = listAppend(setClause, "#column# = :#column#");
                    params[column] = {value: arguments.data[column], cfsqltype: getSQLType(arguments.data[column])};
                }
            }
            
            var sql = "UPDATE #variables.tableName# SET #setClause# WHERE #variables.primaryKey# = :id";
            
            queryExecute(sql, params, {datasource: variables.datasource});
            
            // Get updated record
            var updatedRecord = read(arguments.id);
            
            result.success = true;
            result.message = "Record updated successfully";
            result.data = updatedRecord.success ? updatedRecord.data : {};
            
        } catch (any e) {
            result.message = "Database error during update: " & e.message;
            logError("BaseService.update", e, {id: arguments.id, data: arguments.data});
        }
        
        return result;
    }
    
    /**
     * Delete a record by primary key
     * @param id The primary key value
     * @return struct with success status
     */
    public struct function delete(required string id) {
        var result = {
            success: false,
            message: ""
        };
        
        // Check if record exists
        var existingRecord = read(arguments.id);
        if (!existingRecord.success) {
            result.message = "Cannot delete: " & existingRecord.message;
            return result;
        }
        
        try {
            var sql = "DELETE FROM #variables.tableName# WHERE #variables.primaryKey# = :id";
            queryExecute(sql, {id: {value: arguments.id, cfsqltype: "cf_sql_varchar"}}, {datasource: variables.datasource});
            
            result.success = true;
            result.message = "Record deleted successfully";
            
        } catch (any e) {
            result.message = "Database error during delete: " & e.message;
            logError("BaseService.delete", e, {id: arguments.id});
        }
        
        return result;
    }
    
    /**
     * List records with pagination and filtering
     * @param page Page number (default: 1)
     * @param limit Records per page (default: 20)
     * @param orderBy Column to order by (default: primary key)
     * @param orderDirection Sort direction (default: "DESC")
     * @param filters Struct of column filters
     * @return struct with success status, records array, and pagination info
     */
    public struct function list(
        numeric page = 1,
        numeric limit = 20,
        string orderBy = "",
        string orderDirection = "DESC",
        struct filters = {}
    ) {
        var result = {
            success: false,
            message: "",
            data: [],
            pagination: {
                page: arguments.page,
                limit: arguments.limit,
                total: 0,
                totalPages: 0,
                hasNext: false,
                hasPrev: false
            }
        };
        
        // Set default orderBy to primary key if not specified
        if (len(arguments.orderBy) == 0) {
            arguments.orderBy = variables.primaryKey;
        }
        
        // Validate orderDirection
        if (!listFindNoCase("ASC,DESC", arguments.orderDirection)) {
            arguments.orderDirection = "DESC";
        }
        
        try {
            // Build WHERE clause from filters
            var whereClause = "";
            var params = {};
            
            if (!structIsEmpty(arguments.filters)) {
                var conditions = [];
                for (var column in structKeyArray(arguments.filters)) {
                    arrayAppend(conditions, "#column# = :#column#");
                    params[column] = {value: arguments.filters[column], cfsqltype: getSQLType(arguments.filters[column])};
                }
                whereClause = "WHERE " & arrayToList(conditions, " AND ");
            }
            
            // Get total count for pagination
            var countSql = "SELECT COUNT(*) as total FROM #variables.tableName# #whereClause#";
            var countQuery = queryExecute(countSql, params, {datasource: variables.datasource});
            var totalRecords = countQuery.total;
            
            // Calculate pagination
            result.pagination.total = totalRecords;
            result.pagination.totalPages = ceiling(totalRecords / arguments.limit);
            result.pagination.hasNext = (arguments.page < result.pagination.totalPages);
            result.pagination.hasPrev = (arguments.page > 1);
            
            // Get records with pagination
            var offset = (arguments.page - 1) * arguments.limit;
            var sql = "SELECT * FROM #variables.tableName# #whereClause# ORDER BY #arguments.orderBy# #arguments.orderDirection# LIMIT #arguments.limit# OFFSET #offset#";
            
            var query = queryExecute(sql, params, {datasource: variables.datasource});
            
            // Convert query to array of structs
            var records = [];
            for (var i = 1; i <= query.recordCount; i++) {
                arrayAppend(records, queryRowToStruct(query, i));
            }
            
            result.success = true;
            result.message = "Records retrieved successfully";
            result.data = records;
            
        } catch (any e) {
            result.message = "Database error during list: " & e.message;
            logError("BaseService.list", e, arguments);
        }
        
        return result;
    }
    
    /**
     * Count records with optional filtering
     * @param filters Struct of column filters
     * @return numeric count of records
     */
    public numeric function count(struct filters = {}) {
        try {
            var whereClause = "";
            var params = {};
            
            if (!structIsEmpty(arguments.filters)) {
                var conditions = [];
                for (var column in structKeyArray(arguments.filters)) {
                    arrayAppend(conditions, "#column# = :#column#");
                    params[column] = {value: arguments.filters[column], cfsqltype: getSQLType(arguments.filters[column])};
                }
                whereClause = "WHERE " & arrayToList(conditions, " AND ");
            }
            
            var sql = "SELECT COUNT(*) as total FROM #variables.tableName# #whereClause#";
            var query = queryExecute(sql, params, {datasource: variables.datasource});
            
            return query.total;
            
        } catch (any e) {
            logError("BaseService.count", e, arguments);
            return 0;
        }
    }
    
    /**
     * Check if a record exists
     * @param id The primary key value
     * @return boolean true if record exists
     */
    public boolean function exists(required string id) {
        var readResult = read(arguments.id);
        return readResult.success;
    }
    
    // PRIVATE HELPER METHODS
    
    /**
     * Validate required fields in data struct
     * @param data The data struct to validate
     * @return struct with validation result
     */
    private struct function validateRequiredFields(required struct data) {
        var result = {
            valid: true,
            message: "",
            missingFields: []
        };
        
        for (var field in variables.requiredFields) {
            if (!structKeyExists(arguments.data, field) || len(arguments.data[field]) == 0) {
                arrayAppend(result.missingFields, field);
                result.valid = false;
            }
        }
        
        if (!result.valid) {
            result.message = "Missing required fields: " & arrayToList(result.missingFields);
        }
        
        return result;
    }
    
    /**
     * Convert a query row to a struct
     * @param query The query object
     * @param row The row number to convert
     * @return struct representation of the row
     */
    private struct function queryRowToStruct(required query query, required numeric row) {
        var result = {};
        var columns = listToArray(arguments.query.columnList);
        
        for (var column in columns) {
            result[column] = arguments.query[column][arguments.row];
        }
        
        return result;
    }
    
    /**
     * Get appropriate SQL type for a value
     * @param value The value to get SQL type for
     * @return string SQL type constant
     */
    private string function getSQLType(required any value) {
        if (isNumeric(arguments.value)) {
            return "cf_sql_numeric";
        } else if (isDate(arguments.value)) {
            return "cf_sql_timestamp";
        } else if (isBoolean(arguments.value)) {
            return "cf_sql_bit";
        } else {
            return "cf_sql_varchar";
        }
    }
    
    /**
     * Generate a Ghost-compatible ID (24-character hex string)
     * @return string Ghost-style ID
     */
    private string function createGhostId() {
        return lCase(replace(createUUID(), "-", "", "all")).left(24);
    }
    
    /**
     * Log errors for debugging and monitoring
     * @param method The method where error occurred
     * @param error The error object
     * @param context Additional context data
     */
    private void function logError(required string method, required any error, struct context = {}) {
        var logMessage = "BaseService.#arguments.method# - #arguments.error.message#";
        
        if (!structIsEmpty(arguments.context)) {
            logMessage &= " | Context: " & serializeJSON(arguments.context);
        }
        
        writeLog(file="ghost-errors", text=logMessage, type="error");
    }
    
    /**
     * Get table metadata for introspection
     * @return struct with table information
     */
    public struct function getTableInfo() {
        return {
            tableName: variables.tableName,
            primaryKey: variables.primaryKey,
            datasource: variables.datasource,
            requiredFields: variables.requiredFields
        };
    }
    
    /**
     * Execute a custom query with error handling
     * @param sql The SQL query to execute
     * @param params Parameters for the query
     * @param options Query execution options
     * @return struct with query result and metadata
     */
    public struct function executeQuery(
        required string sql,
        struct params = {},
        struct options = {}
    ) {
        var result = {
            success: false,
            message: "",
            query: "",
            recordCount: 0
        };
        
        // Set default datasource
        if (!structKeyExists(arguments.options, "datasource")) {
            arguments.options.datasource = variables.datasource;
        }
        
        try {
            var query = queryExecute(arguments.sql, arguments.params, arguments.options);
            
            result.success = true;
            result.message = "Query executed successfully";
            result.query = query;
            result.recordCount = query.recordCount;
            
        } catch (any e) {
            result.message = "Query execution error: " & e.message;
            logError("BaseService.executeQuery", e, {sql: arguments.sql, params: arguments.params});
        }
        
        return result;
    }
}