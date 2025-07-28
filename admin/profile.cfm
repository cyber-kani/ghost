<cfparam name="url.action" default="">
<cfset pageTitle = "My Profile">


<!--- Handle form submission --->
<cfset updateMessage = "">
<cfset updateType = "">

<!--- Get current user from database --->
<cfscript>
try {
    // Get current logged in user
    if (structKeyExists(session, "userId") and len(session.userId)) {
        userQuery = queryExecute("
            SELECT u.id, u.name, u.email, u.slug, u.profile_image, u.bio, 
                   u.website, u.location, u.status, u.created_at,
                   r.name as role_name
            FROM users u
            LEFT JOIN roles_users ru ON u.id = ru.user_id
            LEFT JOIN roles r ON ru.role_id = r.id
            WHERE u.id = :userId
            AND u.status = 'active'
            LIMIT 1
        ", {
            userId: {value: session.userId, cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"});
    } else {
        // No user in session, redirect to login
        location(url="/ghost/admin/login", addtoken=false);
    }
    
    if (userQuery.recordCount > 0) {
        currentUser = {
            id: userQuery.id[1],
            name: userQuery.name[1] ?: "Admin User",
            email: userQuery.email[1] ?: "admin@ghost.com",
            slug: userQuery.slug[1] ?: "admin-user",
            bio: userQuery.bio[1] ?: "",
            website: userQuery.website[1] ?: "",
            location: userQuery.location[1] ?: "",
            profile_image: userQuery.profile_image[1] ?: "",
            role: userQuery.role_name[1] ?: "Administrator",
            created_at: userQuery.created_at[1]
        };
    } else {
        // Default user if none found
        currentUser = {
            id: "1",
            name: "Admin User",
            email: "admin@ghost.com",
            slug: "admin-user",
            bio: "",
            website: "",
            location: "",
            profile_image: "",
            role: "Administrator",
            created_at: now()
        };
    }
} catch (any e) {
    // Default user on error
    currentUser = {
        id: "1",
        name: "Admin User",
        email: "admin@ghost.com",
        slug: "admin-user",
        bio: "",
        website: "",
        location: "",
        profile_image: "",
        role: "Administrator",
        created_at: now()
    };
}

// Get post statistics
try {
    postStats = queryExecute("
        SELECT 
            COUNT(*) as total_posts,
            SUM(CASE WHEN status = 'published' THEN 1 ELSE 0 END) as published_posts,
            SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft_posts
        FROM posts
        WHERE author_id = :authorId
    ", {
        authorId: {value: currentUser.id, cfsqltype: "cf_sql_varchar"}
    }, {datasource: "blog"});
    
    totalPosts = postStats.total_posts[1] ?: 0;
    publishedPosts = postStats.published_posts[1] ?: 0;
    draftPosts = postStats.draft_posts[1] ?: 0;
} catch (any e) {
    totalPosts = 0;
    publishedPosts = 0;
    draftPosts = 0;
}
</cfscript>

<cfif structKeyExists(form, "userName")>
    
    <cftry>
        <!--- Get the submitted data --->
        <cfset newUserName = trim(form.userName)>
        <cfset newEmail = trim(form.email)>
        <cfset newBio = structKeyExists(form, "bio") ? trim(form.bio) : "">
        <cfset newWebsite = structKeyExists(form, "website") ? trim(form.website) : "">
        <cfset newLocation = structKeyExists(form, "location") ? trim(form.location) : "">
        <cfset newSlug = structKeyExists(form, "slug") ? trim(form.slug) : "">
        
        <!--- Basic validation --->
        <cfif len(newUserName) eq 0>
            <cfset updateMessage = "Name is required">
            <cfset updateType = "error">
        <cfelseif len(newEmail) eq 0 or not isValid("email", newEmail)>
            <cfset updateMessage = "Valid email is required">
            <cfset updateType = "error">
        <cfelseif len(newSlug) eq 0>
            <cfset updateMessage = "Slug is required">
            <cfset updateType = "error">
        <cfelse>
            <!--- Debug: Show we're about to update --->
            <cfset updateMessage = "About to update database for user ID: " & currentUser.id>
            <cfset updateType = "info">
            
            <!--- Update database --->
            <cftry>
                <cfquery datasource="#request.dsn#" result="updateResult">
                    UPDATE users 
                    SET name = <cfqueryparam value="#newUserName#" cfsqltype="cf_sql_varchar">,
                        email = <cfqueryparam value="#newEmail#" cfsqltype="cf_sql_varchar">,
                        slug = <cfqueryparam value="#newSlug#" cfsqltype="cf_sql_varchar">,
                        bio = <cfqueryparam value="#newBio#" cfsqltype="cf_sql_longvarchar">,
                        website = <cfqueryparam value="#newWebsite#" cfsqltype="cf_sql_varchar">,
                        location = <cfqueryparam value="#newLocation#" cfsqltype="cf_sql_varchar">,
                        updated_at = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
                        updated_by = <cfqueryparam value="#currentUser.id#" cfsqltype="cf_sql_varchar">
                    WHERE id = <cfqueryparam value="#currentUser.id#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                
                <cfcatch type="any">
                    <cfset updateMessage = "Query error: " & cfcatch.message & " - " & cfcatch.detail>
                    <cfset updateType = "error">
                    <cfrethrow>
                </cfcatch>
            </cftry>
            
            <!--- Update session with new user data --->
            <cfif structKeyExists(session, "user")>
                <cfif isStruct(session.user)>
                    <cfset session.user.name = newUserName>
                    <cfset session.user.email = newEmail>
                </cfif>
            </cfif>
            
            <!--- Update current user struct --->
            <cfset currentUser.name = newUserName>
            <cfset currentUser.email = newEmail>
            <cfset currentUser.slug = newSlug>
            <cfset currentUser.bio = newBio>
            <cfset currentUser.website = newWebsite>
            <cfset currentUser.location = newLocation>
            
            <!--- Don't override the message if we already have one from the query --->
            <cfif updateType neq "success">
                <cfset updateMessage = "Profile updated successfully!">
                <cfset updateType = "success">
            </cfif>
        </cfif>
        
        <cfcatch type="any">
            <cfset updateMessage = "Error updating profile: " & cfcatch.message>
            <cfset updateType = "error">
        </cfcatch>
    </cftry>
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

        <!-- Success/Error Messages will be shown via JavaScript -->
        

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
            
            <!-- Profile Information Card -->
            <div class="lg:col-span-7">
                <div class="card h-full">
                    <div class="card-body">
                        <h5 class="card-title mb-6">Profile Information</h5>
                        
                        <form method="post" action="profile.cfm?action=update">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                
                                <!-- Full Name -->
                                <div class="form-group">
                                    <label for="userName" class="form-label font-semibold">Full Name *</label>
                                    <input type="text" 
                                           id="userName" 
                                           name="userName" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(currentUser.name)#</cfoutput>"
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
                                           value="<cfoutput>#htmlEditFormat(currentUser.email)#</cfoutput>"
                                           required
                                           placeholder="Enter your email">
                                </div>
                                
                                <!-- Location -->
                                <div class="form-group">
                                    <label for="location" class="form-label font-semibold">Location</label>
                                    <input type="text" 
                                           id="location" 
                                           name="location" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(currentUser.location)#</cfoutput>"
                                           placeholder="City, Country">
                                </div>
                                
                                <!-- Slug -->
                                <div class="form-group md:col-span-2">
                                    <label for="slug" class="form-label font-semibold">Slug</label>
                                    <div class="flex items-center gap-2">
                                        <span class="text-gray-500 dark:text-gray-400 text-sm">clitools.app/author/</span>
                                        <input type="text" 
                                               id="slug" 
                                               name="slug" 
                                               class="form-control flex-1" 
                                               value="<cfoutput>#htmlEditFormat(currentUser.slug)#</cfoutput>"
                                               required
                                               placeholder="your-url-slug">
                                    </div>
                                    <small class="text-gray-500 dark:text-gray-400 mt-1 block">
                                        <i class="ti ti-link text-xs"></i> 
                                        <a href="/author/<cfoutput>#currentUser.slug#</cfoutput>" target="_blank" class="hover:text-primary">
                                            https://clitools.app/author/<span id="slugPreview"><cfoutput>#currentUser.slug#</cfoutput></span>
                                        </a>
                                    </small>
                                </div>
                                
                                <!-- Website -->
                                <div class="form-group md:col-span-2">
                                    <label for="website" class="form-label font-semibold">Website</label>
                                    <input type="url" 
                                           id="website" 
                                           name="website" 
                                           class="form-control" 
                                           value="<cfoutput>#htmlEditFormat(currentUser.website)#</cfoutput>"
                                           placeholder="https://yourwebsite.com">
                                </div>
                                
                                <!-- Bio -->
                                <div class="form-group md:col-span-2">
                                    <label for="bio" class="form-label font-semibold">Bio</label>
                                    <textarea id="bio" 
                                              name="bio" 
                                              class="form-control" 
                                              rows="4"
                                              maxlength="250"
                                              placeholder="Tell us about yourself..."><cfoutput>#htmlEditFormat(currentUser.bio)#</cfoutput></textarea>
                                    <small class="text-gray-500 dark:text-gray-400">
                                        <span id="bioCount">0</span> / 250 characters
                                    </small>
                                </div>
                                
                                <!-- Role (Read-only) -->
                                <div class="form-group">
                                    <label class="form-label font-semibold text-gray-700 dark:text-gray-300">Role</label>
                                    <div class="mt-2">
                                        <span class="badge bg-primary text-white border-0"><cfoutput>#currentUser.role#</cfoutput></span>
                                    </div>
                                </div>
                                
                                <!-- Status -->
                                <div class="form-group">
                                    <label class="form-label font-semibold text-gray-700 dark:text-gray-300">Account Status</label>
                                    <div class="mt-2">
                                        <span class="badge bg-success text-white border-0">Active</span>
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
            
            <!-- Right Column - Avatar and Stats -->
            <div class="lg:col-span-5">
                <!-- Profile Avatar Card -->
                <div class="card">
                    <div class="card-body text-center">
                        <h5 class="card-title mb-6">Profile Avatar</h5>
                        
                        <!-- Current Avatar -->
                        <div class="mb-6 relative">
                            <cfif len(currentUser.profile_image) gt 0>
                                <img src="<cfoutput>#currentUser.profile_image#</cfoutput>" 
                                     class="w-32 h-32 rounded-full mx-auto object-cover border-4 border-white dark:border-gray-700 shadow-lg" 
                                     alt="Profile Avatar"
                                     id="profileImage">
                            <cfelse>
                                <img src="https://ui-avatars.com/api/?name=<cfoutput>#urlEncodedFormat(currentUser.name)#</cfoutput>&background=5D87FF&color=fff&size=120" 
                                     class="w-32 h-32 rounded-full mx-auto object-cover border-4 border-white dark:border-gray-700 shadow-lg" 
                                     alt="Profile Avatar"
                                     id="profileImage">
                            </cfif>
                            
                            <!-- Upload overlay -->
                            <div class="absolute inset-0 w-32 h-32 mx-auto rounded-full bg-black bg-opacity-50 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity cursor-pointer" onclick="document.getElementById('avatarUpload').click();">
                                <i class="ti ti-camera text-white text-2xl"></i>
                            </div>
                        </div>
                        
                        <!-- Hidden file input -->
                        <input type="file" id="avatarUpload" accept="image/*" style="display: none;" onchange="uploadAvatar(this)">
                        
                        <!-- Avatar Info -->
                        <div class="text-center mb-6">
                            <h6 class="font-bold text-lg text-dark dark:text-white mb-1"><cfoutput>#htmlEditFormat(currentUser.name)#</cfoutput></h6>
                            <p class="text-sm text-gray-600 dark:text-gray-400"><cfoutput>#htmlEditFormat(currentUser.role)#</cfoutput></p>
                            <p class="text-xs text-gray-500 dark:text-gray-500 mt-2"><cfoutput>#htmlEditFormat(currentUser.email)#</cfoutput></p>
                            <cfif len(currentUser.location) gt 0>
                                <p class="text-xs text-gray-500 dark:text-gray-500 mt-1">
                                    <i class="ti ti-map-pin"></i> <cfoutput>#htmlEditFormat(currentUser.location)#</cfoutput>
                                </p>
                            </cfif>
                        </div>
                        
                        <!-- Avatar Actions -->
                        <div class="space-y-3">
                            <button type="button" class="btn btn-outline-primary btn-sm w-full" onclick="document.getElementById('avatarUpload').click();">
                                <i class="ti ti-upload me-2"></i>
                                Upload New Avatar
                            </button>
                            <cfif len(currentUser.profile_image) gt 0>
                                <button type="button" class="btn btn-outline-danger btn-sm w-full" onclick="removeAvatar()">
                                    <i class="ti ti-trash me-2"></i>
                                    Remove Avatar
                                </button>
                            </cfif>
                            <p class="text-xs text-gray-500 dark:text-gray-400">
                                Upload a custom avatar or use your initials
                            </p>
                        </div>
                        
                    </div>
                </div>
                
                <!-- Quick Stats Card -->
                <div class="card mt-6">
                    <div class="card-body">
                        <h5 class="card-title mb-6">Quick Stats</h5>
                        
                        <!-- Stats Grid -->
                        <div class="grid grid-cols-2 gap-4 mb-6">
                            <!-- Total Posts -->
                            <div class="text-center p-4 rounded-lg bg-gray-50 dark:bg-gray-800">
                                <div class="flex justify-center mb-2">
                                    <div class="w-12 h-12 rounded-full bg-primary bg-opacity-10 flex items-center justify-center">
                                        <i class="ti ti-file-text text-primary text-xl"></i>
                                    </div>
                                </div>
                                <h3 class="text-2xl font-bold text-dark dark:text-white mb-1"><cfoutput>#totalPosts#</cfoutput></h3>
                                <p class="text-xs text-gray-600 dark:text-gray-400">Total Posts</p>
                            </div>
                            
                            <!-- Published -->
                            <div class="text-center p-4 rounded-lg bg-gray-50 dark:bg-gray-800">
                                <div class="flex justify-center mb-2">
                                    <div class="w-12 h-12 rounded-full bg-success bg-opacity-10 flex items-center justify-center">
                                        <i class="ti ti-circle-check text-success text-xl"></i>
                                    </div>
                                </div>
                                <h3 class="text-2xl font-bold text-dark dark:text-white mb-1"><cfoutput>#publishedPosts#</cfoutput></h3>
                                <p class="text-xs text-gray-600 dark:text-gray-400">Published</p>
                            </div>
                        </div>
                        
                        <!-- Additional Stats -->
                        <div class="space-y-3 pt-4 border-t dark:border-darkborder">
                            <div class="flex items-center justify-between py-2">
                                <div class="flex items-center gap-2">
                                    <i class="ti ti-edit text-gray-500 dark:text-gray-400 text-base"></i>
                                    <span class="text-sm text-gray-600 dark:text-gray-400">Drafts</span>
                                </div>
                                <span class="font-semibold text-dark dark:text-white"><cfoutput>#draftPosts#</cfoutput></span>
                            </div>
                            <div class="flex items-center justify-between py-2">
                                <div class="flex items-center gap-2">
                                    <i class="ti ti-login text-gray-500 dark:text-gray-400 text-base"></i>
                                    <span class="text-sm text-gray-600 dark:text-gray-400">Last Login</span>
                                </div>
                                <span class="font-semibold text-dark dark:text-white">Today</span>
                            </div>
                            <div class="flex items-center justify-between py-2">
                                <div class="flex items-center gap-2">
                                    <i class="ti ti-calendar text-gray-500 dark:text-gray-400 text-base"></i>
                                    <span class="text-sm text-gray-600 dark:text-gray-400">Member Since</span>
                                </div>
                                <span class="font-semibold text-dark dark:text-white">
                                    <cfoutput>#dateFormat(currentUser.created_at, "mmm yyyy")#</cfoutput>
                                </span>
                            </div>
                        </div>
                        
                        <!-- View All Posts Link -->
                        <div class="mt-6 pt-4 border-t dark:border-darkborder">
                            <a href="/ghost/admin/posts" class="flex items-center justify-center gap-2 text-primary hover:text-primaryhover font-medium text-sm">
                                <span>View All Posts</span>
                                <i class="ti ti-arrow-right text-base"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
        </div>
    </div>
</div>

<style>
/* Alert Message Animation */
@keyframes slideInRight {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

.alert-message {
    animation: slideInRight 0.3s ease-out;
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
</style>

<cfinclude template="includes/footer.cfm">

<script>
// Upload avatar
function uploadAvatar(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        
        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
            alert('File size must be less than 5MB');
            return;
        }
        
        // Validate file type
        if (!file.type.match('image.*')) {
            alert('Please select an image file');
            return;
        }
        
        // Create FormData
        const formData = new FormData();
        formData.append('file', file);
        formData.append('type', 'profile');
        
        // Show loading state
        const profileImg = document.getElementById('profileImage');
        const originalSrc = profileImg.src;
        profileImg.style.opacity = '0.5';
        
        // Upload via AJAX
        fetch('/ghost/admin/ajax/upload-image.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success || data.SUCCESS) {
                // Update image
                profileImg.src = data.url || data.URL;
                profileImg.style.opacity = '1';
                
                // Show success message
                showMessage('Profile image updated successfully', 'success');
                
                // Reload page after short delay to update UI
                setTimeout(() => location.reload(), 1000);
            } else {
                // Restore original image
                profileImg.src = originalSrc;
                profileImg.style.opacity = '1';
                alert(data.message || data.MESSAGE || 'Upload failed');
            }
        })
        .catch(error => {
            // Restore original image
            profileImg.src = originalSrc;
            profileImg.style.opacity = '1';
            alert('Upload failed: ' + error.message);
        });
    }
}

// Remove avatar
function removeAvatar() {
    if (confirm('Are you sure you want to remove your profile image?')) {
        // Update database to remove profile image
        const formData = new FormData();
        formData.append('action', 'removeAvatar');
        
        // Show loading state
        const profileImg = document.getElementById('profileImage');
        profileImg.style.opacity = '0.5';
        
        fetch('/ghost/admin/ajax/update-profile.cfm', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            console.log('Response status:', response.status);
            console.log('Response headers:', response.headers.get('content-type'));
            return response.text();
        })
        .then(text => {
            console.log('Raw response:', text);
            try {
                const data = JSON.parse(text);
                console.log('Parsed data:', data);
                if (data.success || data.SUCCESS) {
                    showMessage('Profile image removed successfully', 'success');
                    setTimeout(() => location.reload(), 1000);
                } else {
                    profileImg.style.opacity = '1';
                    showMessage(data.message || data.MESSAGE || 'Failed to remove avatar', 'error');
                }
            } catch (e) {
                console.error('JSON parse error:', e);
                profileImg.style.opacity = '1';
                showMessage('Invalid response from server', 'error');
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
            profileImg.style.opacity = '1';
            showMessage('Error: ' + error.message, 'error');
        });
    }
}

// Show message function (matching posts.cfm style)
function showMessage(message, type) {
    // Remove any existing messages
    const existingMessage = document.querySelector('.alert-message');
    if (existingMessage) {
        existingMessage.remove();
    }
    
    // Create message element
    const messageEl = document.createElement('div');
    messageEl.className = `alert-message fixed top-4 right-4 px-4 py-3 rounded-md shadow-lg z-50 max-w-md`;
    messageEl.style.animation = 'slideInRight 0.3s ease-out';
    
    if (type === 'success') {
        messageEl.className += ' bg-success text-white';
        messageEl.innerHTML = `<i class="ti ti-check-circle me-2"></i>${message}`;
    } else if (type === 'error') {
        messageEl.className += ' bg-error text-white';
        messageEl.innerHTML = `<i class="ti ti-alert-circle me-2"></i>${message}`;
    } else {
        messageEl.className += ' bg-primary text-white';
        messageEl.innerHTML = `<i class="ti ti-info-circle me-2"></i>${message}`;
    }
    
    // Add close button
    messageEl.innerHTML += `<button onclick="this.parentElement.remove()" class="ml-3 text-white hover:text-gray-200"><i class="ti ti-x"></i></button>`;
    
    document.body.appendChild(messageEl);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        messageEl.style.transition = 'opacity 0.3s ease-out';
        messageEl.style.opacity = '0';
        setTimeout(() => messageEl.remove(), 300);
    }, 5000);
}

// Bio character counter
document.addEventListener('DOMContentLoaded', function() {
    const bioField = document.getElementById('bio');
    const bioCount = document.getElementById('bioCount');
    
    if (bioField && bioCount) {
        function updateBioCount() {
            const count = bioField.value.length;
            bioCount.textContent = count;
            if (count > 200) {
                bioCount.parentElement.classList.add('text-red-500');
            } else {
                bioCount.parentElement.classList.remove('text-red-500');
            }
        }
        
        bioField.addEventListener('input', updateBioCount);
        updateBioCount(); // Initial count
    }
    
    // Auto-generate slug from name
    const nameField = document.getElementById('userName');
    const slugField = document.getElementById('slug');
    
    if (nameField && slugField) {
        let manuallyEdited = slugField.value !== '';
        
        slugField.addEventListener('input', () => {
            manuallyEdited = true;
            // Update slug preview
            const slugPreview = document.getElementById('slugPreview');
            if (slugPreview) {
                slugPreview.textContent = slugField.value || 'your-url-slug';
            }
        });
        
        nameField.addEventListener('input', function() {
            if (!manuallyEdited) {
                const slug = this.value
                    .toLowerCase()
                    .replace(/[^a-z0-9]+/g, '-')
                    .replace(/^-+|-+$/g, '');
                slugField.value = slug;
                // Update slug preview
                const slugPreview = document.getElementById('slugPreview');
                if (slugPreview) {
                    slugPreview.textContent = slug || 'your-url-slug';
                }
            }
        });
    }
});

// Show form submission message
<cfif len(updateMessage) gt 0>
    showMessage('<cfoutput>#jsStringFormat(updateMessage)#</cfoutput>', '<cfoutput>#updateType#</cfoutput>');
</cfif>
</script>