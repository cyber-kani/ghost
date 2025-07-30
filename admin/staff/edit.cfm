<cfparam name="request.dsn" default="blog">
<cfparam name="url.id" default="">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Validate user ID --->
<cfif NOT len(trim(url.id))>
    <cflocation url="/ghost/admin/staff" addtoken="false">
</cfif>

<!--- Handle form submission --->
<cfif structKeyExists(form, "submitted")>
    <cftry>
        <!--- Update user details --->
        <cfquery datasource="#request.dsn#">
            UPDATE users
            SET 
                name = <cfqueryparam value="#form.name#" cfsqltype="cf_sql_varchar">,
                email = <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">,
                bio = <cfqueryparam value="#form.bio#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(form.bio))#">,
                website = <cfqueryparam value="#form.website#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(form.website))#">,
                location = <cfqueryparam value="#form.location#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(form.location))#">,
                facebook = <cfqueryparam value="#form.facebook#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(form.facebook))#">,
                twitter = <cfqueryparam value="#form.twitter#" cfsqltype="cf_sql_varchar" null="#NOT len(trim(form.twitter))#">,
                updated_at = NOW(),
                updated_by = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_varchar">
            WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
        </cfquery>
        
        <!--- Update user role if changed --->
        <cfif structKeyExists(form, "role_name") AND len(trim(form.role_name))>
            <!--- Get new role ID --->
            <cfquery name="getNewRole" datasource="#request.dsn#">
                SELECT id FROM roles 
                WHERE name = <cfqueryparam value="#form.role_name#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif getNewRole.recordCount>
                <!--- Delete existing role assignment --->
                <cfquery datasource="#request.dsn#">
                    DELETE FROM roles_users
                    WHERE user_id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
                </cfquery>
                
                <!--- Insert new role assignment --->
                <cfquery datasource="#request.dsn#">
                    INSERT INTO roles_users (id, role_id, user_id) VALUES (
                        <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#getNewRole.id#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
                    )
                </cfquery>
            </cfif>
        </cfif>
        
        <!--- Handle suspension/unsuspension --->
        <cfif structKeyExists(form, "status")>
            <cfquery datasource="#request.dsn#">
                UPDATE users
                SET status = <cfqueryparam value="#form.status#" cfsqltype="cf_sql_varchar">
                WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
            </cfquery>
        </cfif>
        
        <cfset successMessage = "User updated successfully">
        
    <cfcatch>
        <cfset errorMessage = "Error updating user: #cfcatch.message#">
    </cfcatch>
    </cftry>
</cfif>

<!--- Get user details --->
<cfquery name="qUser" datasource="#request.dsn#">
    SELECT u.*, 
           r.name as role_name,
           r.id as role_id,
           (SELECT COUNT(DISTINCT pa.post_id) FROM posts_authors pa WHERE pa.author_id = u.id) as post_count,
           CASE 
               WHEN u.last_seen IS NULL THEN 'Never'
               WHEN TIMESTAMPDIFF(MINUTE, u.last_seen, NOW()) < 60 THEN CONCAT(TIMESTAMPDIFF(MINUTE, u.last_seen, NOW()), ' minutes ago')
               WHEN TIMESTAMPDIFF(HOUR, u.last_seen, NOW()) < 24 THEN CONCAT(TIMESTAMPDIFF(HOUR, u.last_seen, NOW()), ' hours ago')
               WHEN TIMESTAMPDIFF(DAY, u.last_seen, NOW()) < 30 THEN CONCAT(TIMESTAMPDIFF(DAY, u.last_seen, NOW()), ' days ago')
               ELSE DATE_FORMAT(u.last_seen, '%b %d, %Y')
           END as last_seen_formatted
    FROM users u
    LEFT JOIN roles_users ru ON u.id = ru.user_id
    LEFT JOIN roles r ON ru.role_id = r.id
    WHERE u.id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfif qUser.recordCount EQ 0>
    <cflocation url="/ghost/admin/staff" addtoken="false">
</cfif>

<cfset pageTitle = "Edit Staff Member">
<cfinclude template="../includes/header.cfm">

<style>
/* Staff edit page styles */
.edit-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.edit-title {
    font-size: 2rem;
    font-weight: 700;
    color: #15171a;
    margin: 0;
}

.edit-actions {
    display: flex;
    gap: 1rem;
}

.user-header {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 2rem;
    margin-bottom: 2rem;
    display: flex;
    align-items: center;
    gap: 2rem;
}

.user-avatar-large {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: #f4f5f6;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    font-weight: 600;
    color: #738a94;
    flex-shrink: 0;
}

.user-avatar-large img {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
}

.user-header-info {
    flex: 1;
}

.user-header-name {
    font-size: 1.5rem;
    font-weight: 700;
    color: #15171a;
    margin: 0 0 0.5rem 0;
}

.user-header-meta {
    display: flex;
    gap: 2rem;
    color: #738a94;
    font-size: 0.875rem;
}

.edit-form {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 2rem;
}

.form-section {
    margin-bottom: 2rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid #e5e7eb;
}

.form-section:last-child {
    margin-bottom: 0;
    padding-bottom: 0;
    border-bottom: none;
}

.form-section-title {
    font-size: 1.125rem;
    font-weight: 600;
    color: #15171a;
    margin: 0 0 1.5rem 0;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-group:last-child {
    margin-bottom: 0;
}

.form-label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    margin-bottom: 0.5rem;
}

.form-input,
.form-textarea,
.form-select {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    transition: all 0.2s ease;
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
    outline: none;
    border-color: #14b8a6;
    box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.1);
}

.form-textarea {
    min-height: 100px;
    resize: vertical;
}

.form-hint {
    font-size: 0.75rem;
    color: #6b7280;
    margin-top: 0.25rem;
}

.danger-zone {
    background: #fef2f2;
    border: 1px solid #fecaca;
    border-radius: 8px;
    padding: 2rem;
    margin-top: 2rem;
}

.danger-zone-title {
    font-size: 1.125rem;
    font-weight: 600;
    color: #991b1b;
    margin: 0 0 1rem 0;
}

.danger-zone-text {
    color: #7f1d1d;
    margin: 0 0 1rem 0;
    font-size: 0.875rem;
}

.btn-danger {
    background: #dc2626;
    color: white;
    border: none;
    padding: 0.5rem 1rem;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
}

.btn-danger:hover {
    background: #b91c1c;
}

.form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 1px solid #e5e7eb;
}
</style>

<div class="container-fluid">
    <div class="edit-header">
        <h1 class="edit-title">Edit Staff Member</h1>
        <div class="edit-actions">
            <a href="/ghost/admin/staff" class="btn btn-secondary">
                <i class="ti ti-arrow-left mr-2"></i>Back to Staff
            </a>
        </div>
    </div>

    <!--- Display messages --->
    <cfif structKeyExists(variables, "successMessage")>
        <div class="alert alert-success mb-4"><cfoutput>#successMessage#</cfoutput></div>
    </cfif>
    <cfif structKeyExists(variables, "errorMessage")>
        <div class="alert alert-danger mb-4"><cfoutput>#errorMessage#</cfoutput></div>
    </cfif>

    <cfoutput query="qUser">
    <div class="user-header">
        <div class="user-avatar-large">
            <cfif len(profile_image)>
                <img src="#profile_image#" alt="#name#">
            <cfelse>
                #left(name, 1)#
            </cfif>
        </div>
        <div class="user-header-info">
            <h2 class="user-header-name">#name#</h2>
            <div class="user-header-meta">
                <span><i class="ti ti-mail mr-1"></i>#email#</span>
                <span><i class="ti ti-user mr-1"></i>#role_name#</span>
                <span><i class="ti ti-file-text mr-1"></i>#post_count# posts</span>
                <span><i class="ti ti-clock mr-1"></i>Last seen #last_seen_formatted#</span>
            </div>
        </div>
    </div>

    <form method="post" class="edit-form">
        <input type="hidden" name="submitted" value="true">
        
        <div class="form-section">
            <h3 class="form-section-title">Basic Info</h3>
            
            <div class="form-group">
                <label class="form-label" for="name">Full Name</label>
                <input type="text" id="name" name="name" class="form-input" value="#name#" required>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="email">Email</label>
                <input type="email" id="email" name="email" class="form-input" value="#email#" required>
                <div class="form-hint">Used for notifications</div>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="bio">Bio</label>
                <textarea id="bio" name="bio" class="form-textarea" placeholder="A short bio...">#bio#</textarea>
                <div class="form-hint">Recommended: 200 characters</div>
            </div>
        </div>
        
        <div class="form-section">
            <h3 class="form-section-title">Details</h3>
            
            <div class="form-group">
                <label class="form-label" for="location">Location</label>
                <input type="text" id="location" name="location" class="form-input" value="#location#" placeholder="Where in the world...">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="website">Website</label>
                <input type="url" id="website" name="website" class="form-input" value="#website#" placeholder="https://example.com">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="role_name">Role</label>
                <select id="role_name" name="role_name" class="form-select">
                    <option value="Contributor" <cfif role_name EQ "Contributor">selected</cfif>>Contributor</option>
                    <option value="Author" <cfif role_name EQ "Author">selected</cfif>>Author</option>
                    <option value="Editor" <cfif role_name EQ "Editor">selected</cfif>>Editor</option>
                    <option value="Administrator" <cfif role_name EQ "Administrator">selected</cfif>>Administrator</option>
                </select>
            </div>
        </div>
        
        <div class="form-section">
            <h3 class="form-section-title">Social Accounts</h3>
            
            <div class="form-group">
                <label class="form-label" for="facebook">Facebook Profile</label>
                <input type="text" id="facebook" name="facebook" class="form-input" value="#facebook#" placeholder="https://facebook.com/username">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="twitter">X (Twitter) Profile</label>
                <input type="text" id="twitter" name="twitter" class="form-input" value="#twitter#" placeholder="https://x.com/username">
            </div>
        </div>
        
        <div class="form-actions">
            <a href="/ghost/admin/staff" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">Save</button>
        </div>
    </form>
    
    <cfif status NEQ "suspended">
    <div class="danger-zone">
        <h3 class="danger-zone-title">Danger Zone</h3>
        <p class="danger-zone-text">Suspend this user to prevent them from logging in.</p>
        <form method="post" style="display: inline;">
            <input type="hidden" name="submitted" value="true">
            <input type="hidden" name="status" value="suspended">
            <button type="submit" class="btn-danger" onclick="return confirm('Are you sure you want to suspend this user?');">
                <i class="ti ti-user-x mr-2"></i>Suspend User
            </button>
        </form>
    </div>
    <cfelse>
    <div class="danger-zone" style="background: #f0fdf4; border-color: #86efac;">
        <h3 class="danger-zone-title" style="color: #166534;">User Suspended</h3>
        <p class="danger-zone-text" style="color: #14532d;">This user is currently suspended and cannot log in.</p>
        <form method="post" style="display: inline;">
            <input type="hidden" name="submitted" value="true">
            <input type="hidden" name="status" value="active">
            <button type="submit" class="btn btn-success">
                <i class="ti ti-user-check mr-2"></i>Unsuspend User
            </button>
        </form>
    </div>
    </cfif>
    </cfoutput>
</div>

<script>
// Auto-resize textarea
document.getElementById('bio').addEventListener('input', function() {
    this.style.height = 'auto';
    this.style.height = this.scrollHeight + 'px';
});

// Initialize textarea height
document.getElementById('bio').style.height = document.getElementById('bio').scrollHeight + 'px';
</script>

<cfinclude template="../includes/footer.cfm">