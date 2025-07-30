<cfparam name="request.dsn" default="blog">

<!--- Check if user is logged in --->
<cfif NOT structKeyExists(session, "ISLOGGEDIN") OR NOT session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login.cfm" addtoken="false">
</cfif>

<!--- Get filter parameters and clean them --->
<cfparam name="url.filter" default="all">
<cfparam name="url.role" default="">

<!--- Clean up duplicate parameters from nginx rewrite ----->
<cfif find(",", url.filter)>
    <cfset url.filter = listFirst(url.filter, ",")>
</cfif>

<!--- Build the WHERE clause based on filter --->
<cfset whereClause = "WHERE u.status = 'active'">

<cfif url.filter EQ "administrators">
    <cfset whereClause = whereClause & " AND (r.name = 'Administrator' OR r.name = 'Owner')">
<cfelseif url.filter EQ "editors">
    <cfset whereClause = whereClause & " AND r.name = 'Editor'">
<cfelseif url.filter EQ "authors">
    <cfset whereClause = whereClause & " AND r.name = 'Author'">
<cfelseif url.filter EQ "contributors">
    <cfset whereClause = whereClause & " AND r.name = 'Contributor'">
<cfelseif url.filter EQ "invited">
    <cfset whereClause = whereClause & " AND u.status = 'invited'">
</cfif>

<!--- Get all users with their roles --->
<cfquery name="qUsers" datasource="#request.dsn#">
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
    INNER JOIN roles_users ru ON u.id = ru.user_id
    INNER JOIN roles r ON ru.role_id = r.id
    #PreserveSingleQuotes(whereClause)#
    ORDER BY u.created_at DESC
</cfquery>

<!--- Get role counts --->
<cfquery name="qRoleCounts" datasource="#request.dsn#">
    SELECT 
        COUNT(CASE WHEN r.name IN ('Administrator', 'Owner') THEN 1 END) as admin_count,
        COUNT(CASE WHEN r.name = 'Editor' THEN 1 END) as editor_count,
        COUNT(CASE WHEN r.name = 'Author' THEN 1 END) as author_count,
        COUNT(CASE WHEN r.name = 'Contributor' THEN 1 END) as contributor_count,
        COUNT(CASE WHEN u.status = 'invited' THEN 1 END) as invited_count,
        COUNT(CASE WHEN u.status = 'active' THEN 1 END) as total_count
    FROM users u
    INNER JOIN roles_users ru ON u.id = ru.user_id
    INNER JOIN roles r ON ru.role_id = r.id
    WHERE u.status = 'active'
</cfquery>


<cfset pageTitle = "Staff">
<cfinclude template="includes/header.cfm">

<style>
/* Staff page styles */
.staff-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.staff-title {
    font-size: 2rem;
    font-weight: 700;
    color: #15171a;
    margin: 0;
}

.staff-actions {
    display: flex;
    gap: 1rem;
}

/* Filter tabs */
.filter-tabs {
    display: flex;
    gap: 2rem;
    border-bottom: 1px solid #e5e7eb;
    margin-bottom: 2rem;
}

.filter-tab {
    padding: 0.75rem 0;
    color: #738a94;
    text-decoration: none;
    font-size: 0.875rem;
    font-weight: 500;
    border-bottom: 2px solid transparent;
    transition: all 0.2s ease;
}

.filter-tab:hover {
    color: #15171a;
}

.filter-tab.active {
    color: #15171a;
    border-bottom-color: #15171a;
}

.filter-tab span {
    margin-left: 0.5rem;
    background: #f4f5f6;
    padding: 0.125rem 0.5rem;
    border-radius: 999px;
    font-size: 0.75rem;
}

/* User cards */
.user-grid {
    display: grid;
    gap: 1.5rem;
}

.user-card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 1.5rem;
    display: flex;
    align-items: center;
    gap: 1rem;
    transition: all 0.2s ease;
}

.user-card:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.user-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: #f4f5f6;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
    color: #738a94;
    flex-shrink: 0;
}

.user-avatar img {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    object-fit: cover;
}

.user-info {
    flex: 1;
}

.user-name {
    font-size: 1rem;
    font-weight: 600;
    color: #15171a;
    margin: 0 0 0.25rem 0;
}

.user-email {
    font-size: 0.875rem;
    color: #738a94;
    margin: 0;
}

.user-meta {
    display: flex;
    gap: 1.5rem;
    align-items: center;
    margin-left: auto;
    flex-shrink: 0;
}

.user-role {
    font-size: 0.875rem;
    color: #738a94;
}

.user-posts {
    font-size: 0.875rem;
    color: #738a94;
}

.user-status {
    padding: 0.25rem 0.75rem;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 500;
}

.user-status.invited {
    background: #fef3c7;
    color: #92400e;
}

.user-status.suspended {
    background: #fee2e2;
    color: #991b1b;
}

.user-last-seen {
    font-size: 0.875rem;
    color: #9ca3af;
}

/* Invite modal */
.invite-modal {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    display: none;
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.invite-modal.show {
    display: flex;
}

.invite-modal-content {
    background: white;
    border-radius: 8px;
    width: 90%;
    max-width: 500px;
    max-height: 90vh;
    overflow-y: auto;
}

.invite-modal-header {
    padding: 1.5rem;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.invite-modal-title {
    font-size: 1.25rem;
    font-weight: 700;
    color: #15171a;
    margin: 0;
}

.invite-modal-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    color: #738a94;
    cursor: pointer;
    padding: 0;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    transition: all 0.2s ease;
}

.invite-modal-close:hover {
    background: #f4f5f6;
}

.invite-modal-body {
    padding: 1.5rem;
}

.invite-form-group {
    margin-bottom: 1.5rem;
}

.invite-form-group label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
    margin-bottom: 0.5rem;
}

.invite-form-group input,
.invite-form-group select {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
}

.invite-modal-footer {
    padding: 1.5rem;
    border-top: 1px solid #e5e7eb;
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
}
</style>

<div class="container-fluid">
    <div class="staff-header">
        <h1 class="staff-title">Staff</h1>
        <div class="staff-actions">
            <button class="btn btn-primary" onclick="showInviteModal()">
                <i class="ti ti-user-plus mr-2"></i>Invite people
            </button>
        </div>
    </div>

    <div class="filter-tabs">
        <a href="/ghost/admin/staff?filter=all" class="filter-tab <cfif url.filter EQ 'all'>active</cfif>">
            All users <span><cfoutput>#qRoleCounts.total_count#</cfoutput></span>
        </a>
        <a href="/ghost/admin/staff?filter=administrators" class="filter-tab <cfif url.filter EQ 'administrators'>active</cfif>">
            Administrators <span><cfoutput>#qRoleCounts.admin_count#</cfoutput></span>
        </a>
        <a href="/ghost/admin/staff?filter=editors" class="filter-tab <cfif url.filter EQ 'editors'>active</cfif>">
            Editors <span><cfoutput>#qRoleCounts.editor_count#</cfoutput></span>
        </a>
        <a href="/ghost/admin/staff?filter=authors" class="filter-tab <cfif url.filter EQ 'authors'>active</cfif>">
            Authors <span><cfoutput>#qRoleCounts.author_count#</cfoutput></span>
        </a>
        <a href="/ghost/admin/staff?filter=contributors" class="filter-tab <cfif url.filter EQ 'contributors'>active</cfif>">
            Contributors <span><cfoutput>#qRoleCounts.contributor_count#</cfoutput></span>
        </a>
        <a href="/ghost/admin/staff?filter=invited" class="filter-tab <cfif url.filter EQ 'invited'>active</cfif>">
            Invited <span><cfoutput>#qRoleCounts.invited_count#</cfoutput></span>
        </a>
    </div>

    <div class="user-grid">
        <cfoutput query="qUsers">
        <div class="user-card" onclick="window.location.href='/ghost/admin/staff/edit/#id#';" style="cursor: pointer;">
            <div class="user-avatar">
                <cfif len(profile_image)>
                    <img src="#profile_image#" alt="#name#">
                <cfelse>
                    #left(name, 1)#
                </cfif>
            </div>
            <div class="user-info">
                <h3 class="user-name">#name#</h3>
                <p class="user-email">#email#</p>
            </div>
            <div class="user-meta">
                <cfif status EQ "invited">
                    <span class="user-status invited">Invited</span>
                <cfelseif status EQ "suspended">
                    <span class="user-status suspended">Suspended</span>
                </cfif>
                <span class="user-role">#role_name#</span>
                <span class="user-posts">#post_count# posts</span>
                <span class="user-last-seen">#last_seen_formatted#</span>
            </div>
        </div>
        </cfoutput>
        
        <cfif qUsers.recordCount EQ 0>
        <div class="empty-state">
            <p>No users found</p>
        </div>
        </cfif>
    </div>
</div>

<!-- Invite People Modal -->
<div class="invite-modal" id="inviteModal">
    <div class="invite-modal-content">
        <div class="invite-modal-header">
            <h2 class="invite-modal-title">Invite a new staff member</h2>
            <button class="invite-modal-close" onclick="hideInviteModal()">
                <i class="ti ti-x"></i>
            </button>
        </div>
        <form id="inviteForm">
            <div class="invite-modal-body">
                <div class="invite-form-group">
                    <label for="inviteEmail">Email address</label>
                    <input type="email" id="inviteEmail" name="email" required placeholder="jamie@example.com">
                </div>
                <div class="invite-form-group">
                    <label for="inviteRole">Role</label>
                    <select id="inviteRole" name="role_name" required>
                        <option value="">Select a role</option>
                        <option value="Contributor">Contributor</option>
                        <option value="Author">Author</option>
                        <option value="Editor">Editor</option>
                        <option value="Administrator">Administrator</option>
                    </select>
                </div>
                <div class="invite-form-group">
                    <label for="inviteMessage">Message (optional)</label>
                    <textarea id="inviteMessage" name="message" rows="3" placeholder="Add a personal message to the invitation email"></textarea>
                </div>
            </div>
            <div class="invite-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="hideInviteModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Send invitation</button>
            </div>
        </form>
    </div>
</div>

<script>
// Show/hide invite modal
function showInviteModal() {
    document.getElementById('inviteModal').classList.add('show');
}

function hideInviteModal() {
    document.getElementById('inviteModal').classList.remove('show');
    document.getElementById('inviteForm').reset();
}

// Handle invite form submission
document.getElementById('inviteForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    
    fetch('/ghost/admin/ajax/invite-user.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showMessage('Invitation sent successfully', 'success');
            hideInviteModal();
            setTimeout(() => location.reload(), 1500);
        } else {
            showMessage(data.message || 'Failed to send invitation', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showMessage('An error occurred', 'error');
    });
});

// Message display function
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
            </div>
        `;
    } else {
        toast.className += ' border-red-200';
        toast.innerHTML = `
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <i class="ti ti-alert-circle text-red-500 text-xl"></i>
                </div>
                <div class="ml-3">
                    <p class="text-sm text-gray-700">${message}</p>
                </div>
            </div>
        `;
    }
    
    // Add to container
    let container = document.getElementById('toastContainer');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        container.style.cssText = 'position: fixed; bottom: 1rem; right: 1rem; z-index: 9999;';
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
</script>

<cfinclude template="includes/footer.cfm">