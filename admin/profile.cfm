<cfparam name="url.action" default="">
<cfset pageTitle = "My Profile">

<!--- Handle form submission --->
<cfset updateMessage = "">
<cfset updateType = "">

<cfif url.action eq "update" and structKeyExists(form, "userName")>
    <cftry>
        <!--- Get the submitted data --->
        <cfset newUserName = trim(form.userName)>
        <cfset newEmail = trim(form.email)>
        <cfset newRole = trim(form.role)>
        
        <!--- Basic validation --->
        <cfif len(newUserName) eq 0>
            <cfset updateMessage = "Name is required">
            <cfset updateType = "error">
        <cfelseif len(newEmail) eq 0>
            <cfset updateMessage = "Email is required">
            <cfset updateType = "error">
        <cfelse>
            <!--- Update session with new user name --->
            <cfif structKeyExists(session, "adminUser")>
                <cfset session.adminUser = newUserName>
            </cfif>
            <cfif structKeyExists(session, "userName")>
                <cfset session.userName = newUserName>
            </cfif>
            <cfif structKeyExists(session, "user")>
                <cfif isStruct(session.user)>
                    <cfset session.user.name = newUserName>
                    <cfset session.user.email = newEmail>
                    <cfset session.user.role = newRole>
                <cfelse>
                    <cfset session.user = {
                        name: newUserName,
                        email: newEmail,
                        role: newRole
                    }>
                </cfif>
            <cfelse>
                <!--- Create new user session if it doesn't exist --->
                <cfset session.user = {
                    name: newUserName,
                    email: newEmail,
                    role: newRole
                }>
            </cfif>
            
            <!--- TODO: In a real application, you would update the database here --->
            <!--- Example: Update user table with new information --->
            
            <cfset updateMessage = "Profile updated successfully!">
            <cfset updateType = "success">
        </cfif>
        
        <cfcatch any>
            <cfset updateMessage = "Error updating profile: " & cfcatch.message>
            <cfset updateType = "error">
        </cfcatch>
    </cftry>
</cfif>

<!--- Get current user data --->
<cfset currentUserName = "Admin User">
<cfset currentEmail = "admin@ghost.com">
<cfset currentRole = "Administrator">

<cfif structKeyExists(session, "user") and isStruct(session.user)>
    <cfif structKeyExists(session.user, "name")>
        <cfset currentUserName = session.user.name>
    </cfif>
    <cfif structKeyExists(session.user, "email")>
        <cfset currentEmail = session.user.email>
    </cfif>
    <cfif structKeyExists(session.user, "role")>
        <cfset currentRole = session.user.role>
    </cfif>
<cfelseif structKeyExists(session, "adminUser")>
    <cfset currentUserName = session.adminUser>
<cfelseif structKeyExists(session, "userName")>
    <cfset currentUserName = session.userName>
</cfif>

<cfinclude template="includes/header.cfm">

<div class="max-w-full">
    <div class="container full-container">
        
        <!-- Page Header -->
        <div class="flex items-center justify-between mb-6">
            <div>
                <h1 class="text-3xl font-bold text-dark dark:text-white">My Profile</h1>
                <p class="text-base text-gray-600 dark:text-gray-400 mt-1">Manage your account settings and preferences</p>
            </div>
        </div>

        <!-- Success/Error Messages -->
        <cfif len(updateMessage) gt 0>
            <div class="alert alert-<cfif updateType eq 'success'>success<cfelse>danger</cfif> mb-6">
                <cfoutput>#updateMessage#</cfoutput>
            </div>
        </cfif>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            
            <!-- Profile Information Card -->
            <div class="lg:col-span-2">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title mb-6">Profile Information</h5>
                        
                        <form method="post" action="/ghost/admin/profile?action=update">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                
                                <!-- Full Name -->
                                <div class="form-group">
                                    <label for="userName" class="form-label font-semibold">Full Name *</label>
                                    <input type="text" 
                                           id="userName" 
                                           name="userName" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(currentUserName)#</cfoutput>"
                                           required
                                           placeholder="Enter your full name">
                                    <small class="text-gray-500 dark:text-gray-400">This name will appear as the author when you create or duplicate posts.</small>
                                </div>
                                
                                <!-- Email -->
                                <div class="form-group">
                                    <label for="email" class="form-label font-semibold">Email Address *</label>
                                    <input type="email" 
                                           id="email" 
                                           name="email" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(currentEmail)#</cfoutput>"
                                           required
                                           placeholder="Enter your email">
                                </div>
                                
                                <!-- Role -->
                                <div class="form-group">
                                    <label for="role" class="form-label font-semibold">Role</label>
                                    <select id="role" name="role" class="form-control">
                                        <option value="Administrator" <cfif currentRole eq "Administrator">selected</cfif>>Administrator</option>
                                        <option value="Editor" <cfif currentRole eq "Editor">selected</cfif>>Editor</option>
                                        <option value="Author" <cfif currentRole eq "Author">selected</cfif>>Author</option>
                                        <option value="Contributor" <cfif currentRole eq "Contributor">selected</cfif>>Contributor</option>
                                    </select>
                                </div>
                                
                                <!-- Status -->
                                <div class="form-group">
                                    <label class="form-label font-semibold">Account Status</label>
                                    <div class="mt-2">
                                        <span class="badge bg-success">Active</span>
                                    </div>
                                </div>
                                
                            </div>
                            
                            <!-- Form Actions -->
                            <div class="flex items-center gap-4 mt-8 pt-6 border-t dark:border-darkborder">
                                <button type="submit" class="btn btn-primary">
                                    <i class="ti ti-device-floppy me-2"></i>
                                    Save Changes
                                </button>
                                <a href="/ghost/admin/index.cfm" class="btn btn-outline-secondary">
                                    Cancel
                                </a>
                            </div>
                            
                        </form>
                    </div>
                </div>
            </div>
            
            <!-- Profile Avatar Card -->
            <div class="lg:col-span-1">
                <div class="card">
                    <div class="card-body text-center">
                        <h5 class="card-title mb-6">Profile Avatar</h5>
                        
                        <!-- Current Avatar -->
                        <div class="mb-6">
                            <img src="https://ui-avatars.com/api/?name=<cfoutput>#urlEncodedFormat(currentUserName)#</cfoutput>&background=5D87FF&color=fff&size=120" 
                                 class="w-32 h-32 rounded-full mx-auto object-cover border-4 border-white dark:border-gray-700 shadow-lg" 
                                 alt="Profile Avatar">
                        </div>
                        
                        <!-- Avatar Info -->
                        <div class="text-center mb-6">
                            <h6 class="font-bold text-lg text-dark dark:text-white mb-1"><cfoutput>#htmlEditFormat(currentUserName)#</cfoutput></h6>
                            <p class="text-sm text-gray-600 dark:text-gray-400"><cfoutput>#htmlEditFormat(currentRole)#</cfoutput></p>
                            <p class="text-xs text-gray-500 dark:text-gray-500 mt-2"><cfoutput>#htmlEditFormat(currentEmail)#</cfoutput></p>
                        </div>
                        
                        <!-- Avatar Actions -->
                        <div class="space-y-3">
                            <button type="button" class="btn btn-outline-primary btn-sm w-full" onclick="generateNewAvatar()">
                                <i class="ti ti-refresh me-2"></i>
                                Generate New Avatar
                            </button>
                            <p class="text-xs text-gray-500 dark:text-gray-400">
                                Avatars are automatically generated based on your name
                            </p>
                        </div>
                        
                    </div>
                </div>
                
                <!-- Quick Stats Card -->
                <div class="card mt-6">
                    <div class="card-body">
                        <h5 class="card-title mb-4">Quick Stats</h5>
                        <div class="space-y-4">
                            <div class="flex items-center justify-between">
                                <span class="text-sm text-gray-600 dark:text-gray-400">Posts Created</span>
                                <span class="font-semibold text-dark dark:text-white">12</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-sm text-gray-600 dark:text-gray-400">Last Login</span>
                                <span class="font-semibold text-dark dark:text-white">Today</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-sm text-gray-600 dark:text-gray-400">Member Since</span>
                                <span class="font-semibold text-dark dark:text-white">Jan 2024</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</div>

<cfinclude template="includes/footer.cfm">

<script>
// Generate new avatar with different background color
function generateNewAvatar() {
    const colors = ['5D87FF', '49BEFF', 'FFAE1F', 'FA896B', '13DEB9', 'FB977D', 'FDBF00', '8E44AD'];
    const randomColor = colors[Math.floor(Math.random() * colors.length)];
    const userName = '<cfoutput>#javaScriptStringFormat(currentUserName)#</cfoutput>';
    const avatarImg = document.querySelector('img[alt="Profile Avatar"]');
    avatarImg.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(userName)}&background=${randomColor}&color=fff&size=120`;
}

// Show success message after form submission
<cfif updateType eq "success">
setTimeout(function() {
    const alert = document.querySelector('.alert-success');
    if (alert) {
        alert.style.transition = 'opacity 0.5s';
        alert.style.opacity = '0';
        setTimeout(() => alert.remove(), 500);
    }
}, 3000);
</cfif>
</script>