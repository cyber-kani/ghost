<!--- Setup Test User for Development --->
<cfparam name="url.email" default="">
<cfparam name="url.name" default="">
<cfparam name="url.role" default="Administrator">

<!DOCTYPE html>
<html>
<head>
    <title>Setup Test User - CFGhost</title>
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css">
</head>
<body class="bg-gray-100 p-8">
    <div class="max-w-2xl mx-auto bg-white rounded-lg shadow p-6">
        <h1 class="text-2xl font-bold mb-6">Setup Test User</h1>
        
        <cfif len(url.email) and len(url.name)>
            <cftry>
                <!--- Check if user already exists --->
                <cfquery name="checkUser" datasource="blog">
                    SELECT id FROM users 
                    WHERE email = <cfqueryparam value="#url.email#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <cfif checkUser.recordCount eq 0>
                    <!--- Create new user --->
                    <cfset userId = createUUID()>
                    <cfset userSlug = lcase(reReplace(url.name, "[^a-zA-Z0-9]", "-", "all"))>
                    
                    <!--- Ensure unique slug --->
                    <cfquery name="slugCheck" datasource="blog">
                        SELECT COUNT(*) as count FROM users WHERE slug = <cfqueryparam value="#userSlug#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <cfif slugCheck.count gt 0>
                        <cfset userSlug = userSlug & "-" & left(userId, 8)>
                    </cfif>
                    
                    <cfquery datasource="blog">
                        INSERT INTO users (
                            id, name, slug, password, email, 
                            status, visibility, created_at, created_by,
                            updated_at, updated_by
                        ) VALUES (
                            <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#url.name#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#userSlug#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#url.email#" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="active" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="public" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                            <cfqueryparam value="setup-script" cfsqltype="cf_sql_varchar">,
                            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                            <cfqueryparam value="setup-script" cfsqltype="cf_sql_varchar">
                        )
                    </cfquery>
                    
                    <!--- Get role ID --->
                    <cfquery name="getRole" datasource="blog">
                        SELECT id FROM roles WHERE name = <cfqueryparam value="#url.role#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <cfif getRole.recordCount gt 0>
                        <!--- Assign role --->
                        <cfquery datasource="blog">
                            INSERT INTO roles_users (id, role_id, user_id)
                            VALUES (
                                <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#getRole.id#" cfsqltype="cf_sql_varchar">,
                                <cfqueryparam value="#userId#" cfsqltype="cf_sql_varchar">
                            )
                        </cfquery>
                    </cfif>
                    
                    <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                        <h3 class="font-bold">User Created Successfully!</h3>
                        <p><strong>Email:</strong> <cfoutput>#url.email#</cfoutput></p>
                        <p><strong>Name:</strong> <cfoutput>#url.name#</cfoutput></p>
                        <p><strong>Role:</strong> <cfoutput>#url.role#</cfoutput></p>
                        <p><strong>Slug:</strong> <cfoutput>#userSlug#</cfoutput></p>
                    </div>
                <cfelse>
                    <div class="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded mb-4">
                        <p>User already exists with email: <cfoutput>#url.email#</cfoutput></p>
                    </div>
                </cfif>
                
                <cfcatch>
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                        <h3 class="font-bold">Error!</h3>
                        <p><cfoutput>#cfcatch.message#</cfoutput></p>
                        <cfif len(cfcatch.detail)>
                            <p><strong>Detail:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                        </cfif>
                    </div>
                </cfcatch>
            </cftry>
        </cfif>
        
        <form method="get" class="space-y-4">
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email Address</label>
                <input type="email" 
                       id="email" 
                       name="email" 
                       value="<cfoutput>#url.email#</cfoutput>"
                       required 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                       placeholder="admin@example.com">
            </div>
            
            <div>
                <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Full Name</label>
                <input type="text" 
                       id="name" 
                       name="name" 
                       value="<cfoutput>#url.name#</cfoutput>"
                       required 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                       placeholder="John Doe">
            </div>
            
            <div>
                <label for="role" class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                <select id="role" 
                        name="role" 
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="Administrator" <cfif url.role eq "Administrator">selected</cfif>>Administrator</option>
                    <option value="Editor" <cfif url.role eq "Editor">selected</cfif>>Editor</option>
                    <option value="Author" <cfif url.role eq "Author">selected</cfif>>Author</option>
                    <option value="Contributor" <cfif url.role eq "Contributor">selected</cfif>>Contributor</option>
                    <option value="Owner" <cfif url.role eq "Owner">selected</cfif>>Owner</option>
                </select>
            </div>
            
            <button type="submit" class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                Create Test User
            </button>
        </form>
        
        <div class="mt-6 pt-6 border-t border-gray-200">
            <h3 class="text-lg font-medium mb-3">Quick Setup Links</h3>
            <div class="space-y-2">
                <a href="?email=admin@cfghost.com&name=Admin User&role=Owner" 
                   class="block bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded text-sm">
                   Create Owner: admin@cfghost.com
                </a>
                <a href="?email=editor@cfghost.com&name=Editor User&role=Editor" 
                   class="block bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded text-sm">
                   Create Editor: editor@cfghost.com
                </a>
                <a href="?email=author@cfghost.com&name=Author User&role=Author" 
                   class="block bg-gray-100 hover:bg-gray-200 px-3 py-2 rounded text-sm">
                   Create Author: author@cfghost.com
                </a>
            </div>
        </div>
        
        <div class="mt-6 pt-6 border-t border-gray-200 text-center">
            <a href="/ghost/admin/login" class="text-blue-600 hover:text-blue-800">← Back to Login</a>
        </div>
    </div>
</body>
</html>