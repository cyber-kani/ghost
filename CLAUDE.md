# CLAUDE.md - Coding Guidelines for Ghost CFML Application

## 🚨 CRITICAL: ColdFusion Syntax Rules

### **MANDATORY: Use CF Tags ONLY - NO CFSCRIPT**

This project uses **CF tags syntax exclusively**. Do not use cfscript blocks under any circumstances.

### ✅ ALWAYS Use CF Tags
```cfml
<!--- Variables --->
<cfset variableName = "value">
<cfset myArray = []>
<cfset myStruct = {}>

<!--- Conditions --->
<cfif condition>
    <!--- code --->
<cfelseif anotherCondition>
    <!--- code --->
<cfelse>
    <!--- code --->
</cfif>

<!--- Loops --->
<cfloop array="#arrayName#" index="item">
    <!--- code --->
</cfloop>

<cfloop query="queryName">
    <!--- code --->
</cfloop>

<cfloop from="1" to="10" index="i">
    <!--- code --->
</cfloop>

<!--- Queries --->
<cfquery name="queryName" datasource="#request.dsn#">
    SELECT * FROM table
    WHERE id = <cfqueryparam value="#id#" cfsqltype="cf_sql_varchar">
</cfquery>

<!--- Try/Catch --->
<cftry>
    <!--- code that might error --->
<cfcatch>
    <!--- error handling --->
</cfcatch>
</cftry>

<!--- Functions --->
<cffunction name="myFunction" returntype="string">
    <cfargument name="param1" type="string" required="true">
    <cfreturn arguments.param1>
</cffunction>
```

### ❌ NEVER Use CFScript
```cfml
<!--- DO NOT USE THIS SYNTAX --->
<cfscript>
    // No JavaScript-style syntax
    variableName = "value";
    if (condition) {
        // Not allowed
    }
    
    function myFunction() {
        // Not allowed
    }
</cfscript>
```

### Complex Logic in CF Tags
When you have complex logic, still use CF tags:

```cfml
<!--- Setting multiple variables --->
<cfset user = {}>
<cfset user.name = "John">
<cfset user.email = "john@example.com">
<cfset user.roles = ["admin", "editor"]>

<!--- Complex conditions --->
<cfif structKeyExists(user, "email") AND len(trim(user.email)) GT 0>
    <cfif findNoCase("@", user.email)>
        <cfset isValidEmail = true>
    <cfelse>
        <cfset isValidEmail = false>
    </cfif>
</cfif>

<!--- Working with arrays --->
<cfset myArray = []>
<cfset arrayAppend(myArray, "item1")>
<cfset arrayAppend(myArray, "item2")>

<!--- Working with structures --->
<cfset myStruct = {}>
<cfset structInsert(myStruct, "key1", "value1")>
<cfset myStruct["key2"] = "value2">
```

## Project Structure

The Ghost CFML application follows these conventions:

### Directory Structure
```
/ghost/
├── admin/              # Admin panel pages
│   ├── ajax/          # AJAX endpoints
│   ├── includes/      # Shared components (header, footer, functions)
│   ├── posts/         # Post management pages
│   ├── tags/          # Tag management pages
│   └── pages/         # Page management pages
├── api/               # API endpoints
├── blog/              # Public blog templates
└── router.cfm         # Main routing file
```

### Database Configuration
- Datasource: `request.dsn` (default: "blog")
- Always use cfqueryparam for security
- Use proper null handling with `null="#expression#"`

### UI/UX Conventions
- Follow Ghost CMS design patterns exactly
- Use Ghost-style CSS classes (gh-btn, gh-canvas, etc.)
- Implement expandable sections for metadata
- Include keyboard shortcuts where appropriate
- Show loading states and success/error messages

### User Notification Messages (Toast Style)

All user notifications should use the elegant toast style with white background and colored borders:

#### JavaScript Implementation
```javascript
function showMessage(message, type) {
    // Create toast notification
    const toast = document.createElement('div');
    toast.className = 'bg-white rounded-lg shadow-lg p-4 max-w-sm transform transition-all duration-300 translate-x-full border';
    
    if (type === 'success') {
        toast.className += ' border-green-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-check-circle text-green-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
                <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                    <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        `;
    } else if (type === 'error') {
        toast.className += ' border-red-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-alert-circle text-red-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
                <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                    <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        `;
    } else {
        toast.className += ' border-blue-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-info-circle text-blue-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
                <button class="ml-auto flex-shrink-0" onclick="this.parentElement.parentElement.remove()">
                    <i class="ti ti-x text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        `;
    }
    
    // Get or create toast container
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.style.cssText = 'position: fixed; bottom: 1rem; right: 1rem; z-index: 9999; display: flex; flex-direction: column-reverse; gap: 0.5rem;';
        document.body.appendChild(container);
    }
    container.appendChild(toast);
    
    // Animate in
    setTimeout(() => {
        toast.classList.remove('translate-x-full');
    }, 100);
    
    // Remove after 3 seconds
    setTimeout(() => {
        toast.classList.add('translate-x-full');
        setTimeout(() => {
            toast.remove();
        }, 300);
    }, 3000);
}
```

#### Usage Examples
```javascript
// Success message
showMessage('Post deleted successfully', 'success');
showMessage('Settings saved', 'success');
showMessage('Tag created successfully', 'success');

// Error message
showMessage('Failed to save changes', 'error');
showMessage('Please fill in all required fields', 'error');

// Info message
showMessage('Processing your request...', 'info');
showMessage('Saving...', 'info');
```

#### Toast Style Details
- **Background**: White with subtle colored borders
- **Success**: Green border (`border-green-200`) with green icon (`text-green-500`)
- **Error**: Red border (`border-red-200`) with red icon (`text-red-500`)
- **Info**: Blue border (`border-blue-200`) with blue icon (`text-blue-500`)
- **Text**: Gray (`text-gray-700`) for better readability
- **Close button**: Gray with hover effect

#### Features
- Fixed position at bottom-right corner (changed from top-right)
- Smooth slide-in animation from right
- Auto-dismiss after 3 seconds (shorter than before)
- Manual close button with hover effect
- Multiple toasts stack vertically from bottom up (using `flex-direction: column-reverse`)
- Elegant shadow and rounded corners
- Responsive width with max-width constraint

### Common CF Tags Patterns

#### AJAX Endpoints (CF Tags Only!)
```cfml
<!--- Set response headers --->
<cfcontent type="application/json">
<cfheader name="X-Content-Type-Options" value="nosniff">
<cfparam name="request.dsn" default="blog">

<cftry>
    <!--- Get JSON data from request body --->
    <cfset requestData = getHttpRequestData()>
    <cfset jsonData = deserializeJSON(toString(requestData.content))>
    
    <!--- Validate input using CF tags --->
    <cfif NOT structKeyExists(jsonData, "requiredField")>
        <cfthrow message="Missing required field">
    </cfif>
    
    <!--- Database operation --->
    <cfquery name="qResult" datasource="#request.dsn#">
        INSERT INTO table_name (field1, field2)
        VALUES (
            <cfqueryparam value="#jsonData.field1#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#jsonData.field2#" cfsqltype="cf_sql_varchar" null="#NOT structKeyExists(jsonData, 'field2')#">
        )
    </cfquery>
    
    <!--- Build response --->
    <cfset response = {}>
    <cfset response["success"] = true>
    <cfset response["message"] = "Operation successful">
    <cfset response["id"] = qResult.generatedKey>
    
    <cfoutput>#serializeJSON(response)#</cfoutput>
    
<cfcatch>
    <cfset errorResponse = {}>
    <cfset errorResponse["success"] = false>
    <cfset errorResponse["message"] = cfcatch.message>
    <cfoutput>#serializeJSON(errorResponse)#</cfoutput>
</cfcatch>
</cftry>
```

#### Form Pages with Data Processing
```cfml
<!--- Page parameters --->
<cfparam name="request.dsn" default="blog">
<cfparam name="url.id" default="">
<cfparam name="form.submitted" default="false">

<!--- Process form submission --->
<cfif form.submitted EQ "true">
    <cftry>
        <!--- Validate form data --->
        <cfif NOT len(trim(form.name))>
            <cfset errorMessage = "Name is required">
        <cfelse>
            <!--- Save data --->
            <cfquery datasource="#request.dsn#">
                UPDATE items
                SET name = <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">,
                    updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
                WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
            </cfquery>
            <cfset successMessage = "Item updated successfully">
        </cfif>
    <cfcatch>
        <cfset errorMessage = "An error occurred: #cfcatch.message#">
    </cfcatch>
</cfif>

<!--- Get existing data --->
<cfquery name="qItem" datasource="#request.dsn#">
    SELECT * FROM items
    WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset pageTitle = "Edit Item">
<cfinclude template="../includes/header.cfm">

<!--- Display messages --->
<cfif structKeyExists(variables, "errorMessage")>
    <div class="alert alert-error"><cfoutput>#errorMessage#</cfoutput></div>
</cfif>
<cfif structKeyExists(variables, "successMessage")>
    <div class="alert alert-success"><cfoutput>#successMessage#</cfoutput></div>
</cfif>

<!--- Form --->
<form method="post">
    <input type="hidden" name="submitted" value="true">
    <input type="text" name="name" value="<cfoutput>#qItem.name#</cfoutput>">
    <button type="submit">Save</button>
</form>

<cfinclude template="../includes/footer.cfm">
```

#### Working with Queries and Loops
```cfml
<!--- Get data --->
<cfquery name="qPosts" datasource="#request.dsn#">
    SELECT p.*, u.name as author_name
    FROM posts p
    INNER JOIN users u ON p.author_id = u.id
    WHERE p.status = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
    ORDER BY p.created_at DESC
</cfquery>

<!--- Loop through results --->
<cfoutput query="qPosts">
    <div class="post">
        <h2>#title#</h2>
        <p>By #author_name# on #dateFormat(created_at, "mmm dd, yyyy")#</p>
        <div>#excerpt#</div>
    </div>
</cfoutput>

<!--- Alternative: cfloop --->
<cfloop query="qPosts">
    <cfoutput>
        <div class="post">
            <h2>#qPosts.title#</h2>
            <p>By #qPosts.author_name#</p>
        </div>
    </cfoutput>
</cfloop>

<!--- Loop with index --->
<cfloop query="qPosts" startrow="1" endrow="10">
    <cfoutput>
        <div class="post">
            <span class="number">#qPosts.currentRow#.</span>
            <h2>#qPosts.title#</h2>
        </div>
    </cfoutput>
</cfloop>
```

### Testing Commands
- Run lint: `npm run lint` (if available)
- Run typecheck: `npm run typecheck` (if available)

### Git Commit Guidelines
- Use descriptive commit messages
- Include emoji footer: 🤖 Generated with [Claude Code](https://claude.ai/code)
- Co-author: Co-Authored-By: Claude <noreply@anthropic.com>

## Feature Implementation Status

### Completed Features
- [x] Tags Management
  - Tag list with public/internal filtering
  - Create new tag with full metadata
  - Edit existing tags
  - Delete tags functionality
- [x] Posts Management (existing)
- [x] Pages Management (existing)
- [x] Router with clean URLs

### Code Quality Standards
1. Always validate user input
2. Use proper error handling with cftry/cfcatch
3. Implement proper null checking
4. Follow Ghost's exact UI patterns
5. Maintain consistent naming conventions
6. Include helpful code comments where needed
7. Test all AJAX endpoints thoroughly

### Security Considerations
- Always use cfqueryparam in queries
- Validate JSON input in AJAX handlers
- Check user permissions where needed
- Sanitize HTML content appropriately
- Use proper CSRF protection

## Converting CFScript to CF Tags

If you encounter existing cfscript blocks, convert them to CF tags:

### Example Conversions

**CFScript Variable Assignment:**
```cfml
<!--- OLD (cfscript) --->
<cfscript>
    user = {};
    user.name = "John";
    user.roles = ["admin", "editor"];
    isActive = true;
</cfscript>

<!--- NEW (CF tags) --->
<cfset user = {}>
<cfset user.name = "John">
<cfset user.roles = ["admin", "editor"]>
<cfset isActive = true>
```

**CFScript Conditionals:**
```cfml
<!--- OLD (cfscript) --->
<cfscript>
    if (user.role == "admin") {
        canEdit = true;
    } else if (user.role == "editor") {
        canEdit = true;
        canDelete = false;
    } else {
        canEdit = false;
    }
</cfscript>

<!--- NEW (CF tags) --->
<cfif user.role EQ "admin">
    <cfset canEdit = true>
<cfelseif user.role EQ "editor">
    <cfset canEdit = true>
    <cfset canDelete = false>
<cfelse>
    <cfset canEdit = false>
</cfif>
```

**CFScript Try/Catch:**
```cfml
<!--- OLD (cfscript) --->
<cfscript>
    try {
        result = someFunction();
        writeOutput(serializeJSON(result));
    } catch (any e) {
        writeLog(text=e.message, file="errors");
        writeOutput('{"error": "' & e.message & '"}');
    }
</cfscript>

<!--- NEW (CF tags) --->
<cftry>
    <cfset result = someFunction()>
    <cfoutput>#serializeJSON(result)#</cfoutput>
<cfcatch>
    <cflog text="#cfcatch.message#" file="errors">
    <cfoutput>{"error": "#cfcatch.message#"}</cfoutput>
</cfcatch>
</cftry>
```

## Notes for Claude

When working on this codebase:
1. **MANDATORY: Use CF tags syntax ONLY** - Never write cfscript blocks
2. **Convert any existing cfscript to CF tags** when you encounter it
3. Maintain exact Ghost UI/UX compatibility
4. Test all features before marking tasks complete
5. Follow the established CF tags patterns in existing code
6. Create AJAX endpoints for all CRUD operations using CF tags
7. Update router.cfm when adding new routes
8. Use proper cfqueryparam in all queries for security
9. Always validate user input with CF tags conditionals
10. Handle errors with cftry/cfcatch blocks