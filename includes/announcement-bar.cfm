<!--- Ghost Announcement Bar Component --->
<cftry>
    <cfparam name="request.dsn" default="blog">
    
    <!--- Get announcement settings (with cache bypass) --->
    <cfquery name="qAnnouncementSettings" datasource="#request.dsn#" cachedwithin="#createTimeSpan(0,0,0,0)#">
        SELECT `key`, `value` FROM settings 
        WHERE `key` IN ('announcement_content', 'announcement_background', 'announcement_visibility')
    </cfquery>
    
    <!--- Convert to struct --->
    <cfset announcementSettings = {}>
    <cfloop query="qAnnouncementSettings">
        <cfset announcementSettings[qAnnouncementSettings.key] = qAnnouncementSettings.value>
    </cfloop>
    
    <!--- Check if announcement should be displayed --->
    <cfset showAnnouncement = false>
    <cfset announcementContent = "">
    <cfset announcementBackground = "dark">
    <cfset announcementVisibility = ["visitors"]>
    
    <!--- Get announcement content --->
    <cfif structKeyExists(announcementSettings, "announcement_content") AND len(trim(announcementSettings.announcement_content))>
        <cfset announcementContent = announcementSettings.announcement_content>
    </cfif>
    
    <!--- Get announcement background --->
    <cfif structKeyExists(announcementSettings, "announcement_background") AND len(trim(announcementSettings.announcement_background))>
        <cfset announcementBackground = announcementSettings.announcement_background>
    </cfif>
    
    <!--- Get announcement visibility --->
    <cfif structKeyExists(announcementSettings, "announcement_visibility") AND len(trim(announcementSettings.announcement_visibility))>
        <cftry>
            <cfset announcementVisibility = deserializeJSON(announcementSettings.announcement_visibility)>
            <cfcatch>
                <!--- If JSON parsing fails, default to visitors --->
                <cfset announcementVisibility = ["visitors"]>
            </cfcatch>
        </cftry>
    </cfif>
    
    <!--- Only show if there's content --->
    <cfif len(trim(announcementContent))>
        <!--- Check visibility settings --->
        <cfset userStatus = "visitors"> <!--- Default to visitors --->
        
        <!--- Check if user is logged in --->
        <cfif structKeyExists(session, "MEMBERID") AND len(session.MEMBERID)>
            <!--- Check member status --->
            <cfquery name="qMemberStatus" datasource="#request.dsn#">
                SELECT status FROM members 
                WHERE id = <cfqueryparam value="#session.MEMBERID#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfif qMemberStatus.recordCount>
                <cfset userStatus = qMemberStatus.status EQ "free" ? "free_members" : "paid_members">
            </cfif>
        <cfelseif structKeyExists(session, "USERID") AND len(session.USERID)>
            <!--- Admin users should see everything --->
            <cfset userStatus = "visitors">
        </cfif>
        
        <!--- Check if current user type should see the announcement --->
        <cfloop array="#announcementVisibility#" index="visibleTo">
            <cfif visibleTo EQ userStatus>
                <cfset showAnnouncement = true>
                <cfbreak>
            </cfif>
        </cfloop>
    </cfif>
    
    <!--- Get accent color for accent background --->
    <cfset accentColor = "##15171A"> <!--- Default accent color --->
    <cfif announcementBackground EQ "accent">
        <cfquery name="qAccentColor" datasource="#request.dsn#">
            SELECT value FROM settings WHERE `key` = 'accent_color'
        </cfquery>
        <cfif qAccentColor.recordCount AND len(trim(qAccentColor.value))>
            <cfset accentColor = qAccentColor.value>
        </cfif>
    </cfif>
    
    <!--- Display announcement bar if conditions are met --->
    <cfif showAnnouncement>
        <cfoutput>
        <style>
        /* Ghost Announcement Bar Styles */
        .gh-announcement-bar,
        .gh-announcement-bar * {
            box-sizing: border-box !important;
        }

        .gh-announcement-bar {
            position: relative;
            z-index: 90;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 12px 48px;
            min-height: 48px;
            font-size: 15px;
            line-height: 23px;
            text-align: center;
        }

        .gh-announcement-bar.light {
            background-color: ##f0f0f0;
            color: ##15171a;
        }

        .gh-announcement-bar.accent {
            background-color: #accentColor#;
            color: ##fff;
        }

        .gh-announcement-bar.dark {
            background-color: ##15171a;
            color: ##fff;
        }

        .gh-announcement-bar *:not(path) {
            all: unset;
        }

        .gh-announcement-bar strong {
            font-weight: 700;
        }

        .gh-announcement-bar :is(i, em) {
            font-style: italic;
        }

        .gh-announcement-bar a {
            color: ##fff;
            font-weight: 700;
            text-decoration: underline;
            cursor: pointer;
        }

        .gh-announcement-bar.light a {
            color: #accentColor# !important;
        }

        .gh-announcement-bar button {
            position: absolute;
            top: 50%;
            right: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: -16px;
            width: 32px;
            height: 32px;
            padding: 0;
            background-color: transparent;
            border: 0;
            color: ##fff;
            cursor: pointer;
        }

        .gh-announcement-bar.light button {
            color: ##888;
        }

        .gh-announcement-bar svg {
            width: 10px;
            height: 10px;
            fill: currentColor;
        }
        
        /* Hide announcement bar if already dismissed */
        .gh-announcement-bar.hidden {
            display: none;
        }
        </style>
        </cfoutput>

        <div class="gh-announcement-bar <cfoutput>#announcementBackground#</cfoutput>" id="gh-announcement-bar">
            <div class="gh-announcement-bar-content">
                <cfoutput>#announcementContent#</cfoutput>
            </div>
            <button aria-label="close" onclick="closeAnnouncementBar()">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>
        </div>

        <script>
        // Announcement bar functionality
        const BAR_VISIBILITY_STORAGE_KEY = 'isAnnouncementBarVisible';
        const BAR_CONTENT_STORAGE_KEY = 'announcementBarContent';
        
        // Store bar as closed when X is clicked
        function closeAnnouncementBar() {
            const bar = document.getElementById('gh-announcement-bar');
            if (bar) {
                bar.classList.add('hidden');
                sessionStorage.setItem(BAR_VISIBILITY_STORAGE_KEY, 'false');
            }
        }
        
        // Check if content has changed
        function checkAnnouncementBar() {
            const currentContent = '<cfoutput>#jsStringFormat(announcementContent)#</cfoutput>';
            const storedContent = sessionStorage.getItem(BAR_CONTENT_STORAGE_KEY);
            const isVisible = sessionStorage.getItem(BAR_VISIBILITY_STORAGE_KEY);
            
            // If content changed, show the bar
            if (currentContent !== storedContent) {
                sessionStorage.setItem(BAR_CONTENT_STORAGE_KEY, currentContent);
                sessionStorage.setItem(BAR_VISIBILITY_STORAGE_KEY, 'true');
            } else if (isVisible === 'false') {
                // If previously closed and content hasn't changed, hide it
                const bar = document.getElementById('gh-announcement-bar');
                if (bar) {
                    bar.classList.add('hidden');
                }
            }
        }
        
        // Check on page load
        document.addEventListener('DOMContentLoaded', checkAnnouncementBar);
        </script>
    </cfif>
    
<cfcatch>
    <!--- Silently fail to prevent breaking the site --->
    <!--- Log error if needed --->
    <cflog file="announcement-bar" text="Error in announcement bar: #cfcatch.message#">
</cfcatch>
</cftry>