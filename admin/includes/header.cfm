<!--- Check if user is logged in --->
<cfif not structKeyExists(session, "ISLOGGEDIN") or not session.ISLOGGEDIN>
    <cflocation url="/ghost/admin/login" addtoken="false">
</cfif>

<!--- Get current user information for header display --->
<cfset displayUserName = "Admin User">
<cfset displayUserRole = "Administrator">
<cfset displayUserEmail = "admin@ghost.com">
<cfset displayUserImage = "">

<!--- Get user from session or database (use uppercase session variables) --->
<cfif structKeyExists(session, "USERID") and len(session.USERID)>
    <cftry>
        <cfquery name="headerUserQuery" datasource="#request.dsn#">
            SELECT u.id, u.name, u.email, u.slug, u.profile_image,
                   r.name as role_name
            FROM users u
            LEFT JOIN roles_users ru ON u.id = ru.user_id
            LEFT JOIN roles r ON ru.role_id = r.id
            WHERE u.id = <cfqueryparam value="#session.USERID#" cfsqltype="cf_sql_varchar">
            AND u.status = 'active'
            LIMIT 1
        </cfquery>
        
        <cfif headerUserQuery.recordCount gt 0>
            <cfset displayUserName = headerUserQuery.name[1] ?: "Admin User">
            <cfset displayUserEmail = headerUserQuery.email[1] ?: "admin@ghost.com">
            <cfset displayUserRole = headerUserQuery.role_name[1] ?: "Administrator">
            <cfset displayUserImage = headerUserQuery.profile_image[1] ?: "">
            
            <!--- Update session with latest data --->
            <cfset session.userName = displayUserName>
            <cfset session.userEmail = displayUserEmail>
            <cfset session.userRole = displayUserRole>
        </cfif>
        
        <cfcatch>
            <!--- Use session data as fallback --->
            <cfif structKeyExists(session, "userName")>
                <cfset displayUserName = session.userName>
            </cfif>
            <cfif structKeyExists(session, "userEmail")>
                <cfset displayUserEmail = session.userEmail>
            </cfif>
            <cfif structKeyExists(session, "userRole")>
                <cfset displayUserRole = session.userRole>
            </cfif>
        </cfcatch>
    </cftry>
<cfelse>
    <!--- No user ID in session, redirect to login --->
    <cflocation url="/ghost/admin/login" addtoken="false">
</cfif>

<!--- Check session as fallback --->
<cfif structKeyExists(session, "user") and isStruct(session.user)>
    <cfif structKeyExists(session.user, "name") and len(trim(session.user.name))>
        <cfset displayUserName = session.user.name>
    </cfif>
    <cfif structKeyExists(session.user, "role") and len(trim(session.user.role))>
        <cfset displayUserRole = session.user.role>
    </cfif>
    <cfif structKeyExists(session.user, "email") and len(trim(session.user.email))>
        <cfset displayUserEmail = session.user.email>
    </cfif>
    <cfif structKeyExists(session.user, "profile_image") and len(trim(session.user.profile_image))>
        <cfset displayUserImage = session.user.profile_image>
    </cfif>
<cfelseif structKeyExists(session, "adminUser") and len(trim(session.adminUser))>
    <cfset displayUserName = session.adminUser>
<cfelseif structKeyExists(session, "userName") and len(trim(session.userName))>
    <cfset displayUserName = session.userName>
</cfif>

<!DOCTYPE html>
<html lang="en" dir="ltr" data-color-theme="Blue_Theme" class="light selected" data-layout="vertical" data-boxed-layout="boxed" data-card="shadow">
<head>
    <!-- Required meta tags -->
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- Page Title -->
    <title>Ghost Admin - <cfoutput>#pageTitle#</cfoutput></title>
    
    <!-- Favicon icon-->
    <link rel="icon" type="image/x-icon" href="/ghost/admin/assets/images/logos/favicon.ico">
    <link rel="icon" type="image/svg+xml" href="/ghost/admin/assets/images/logos/favicon.svg">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />
    
    <!-- Tabler Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
    
    <!-- Core Css -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/theme.css" />
    
    <!-- Ghost Publish Modal CSS -->
    <link rel="stylesheet" href="/ghost/admin/assets/css/ghost-publish-modal.css?v=<cfoutput>#dateFormat(now(), 'yyyymmdd')##timeFormat(now(), 'HHmmss')#</cfoutput>" />
    
    <!-- Iconify -->
    <script src="/ghost/admin/assets/libs/iconify-icon/dist/iconify-icon.min.js"></script>
    <!-- Fallback CDN -->
    <script>
        window.addEventListener('DOMContentLoaded', function() {
            if (typeof customElements.get('iconify-icon') === 'undefined') {
                var script = document.createElement('script');
                script.src = 'https://code.iconify.design/iconify-icon/1.0.7/iconify-icon.min.js';
                document.head.appendChild(script);
            }
        });
    </script>
    
    <!-- ApexCharts - Only load on dashboard pages -->
    <cfif structKeyExists(variables, "loadApexCharts") AND variables.loadApexCharts>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.css">
    </cfif>
    
    <!-- Fix for sidebar debug styling issues -->
    <style>
        /* Ensure sidebar maintains proper styling without debug colors */
        #application-sidebar-brand,
        .left-sidebar,
        aside[id*="sidebar"] {
            background-color: #ffffff !important;
            background: #ffffff !important;
            border: none !important;
            outline: none !important;
            box-shadow: 0 0 10px rgba(0,0,0,0.1) !important;
        }
        
        /* Dark mode support */
        .dark #application-sidebar-brand,
        .dark .left-sidebar,
        .dark aside[id*="sidebar"] {
            background-color: #1e1e1e !important;
            background: #1e1e1e !important;
            border: none !important;
            outline: none !important;
            box-shadow: 0 0 10px rgba(255,255,255,0.1) !important;
        }
        
        /* Remove any debug outlines from all elements */
        #application-sidebar-brand *,
        .left-sidebar *,
        aside[id*="sidebar"] * {
            outline: none !important;
            border-color: #e5e7eb !important;
        }
        
        /* Ensure navigation links don't have debug styling */
        #application-sidebar-brand .sidebar-link,
        .left-sidebar .sidebar-link,
        aside[id*="sidebar"] .sidebar-link {
            border: none !important;
            outline: none !important;
        }
    </style>
    
    <!-- Ghost Favicon -->
    <link rel="icon" type="image/svg+xml" href="/ghost/favicon.svg">
    <link rel="alternate icon" href="/ghost/favicon.ico">
</head>

<body class="DEFAULT_THEME bg-lightprimary dark:bg-darkbody">
    <main>
        <!--start the project-->
        <div id="main-wrapper" class="flex p-5">
            
            <aside id="application-sidebar-brand" class="hs-overlay hs-overlay-open:translate-x-0 -translate-x-full lg:translate-x-0 left-0 transform fixed top-0 with-vertical left-sidebar transition-all duration-300 h-screen z-[2] flex-shrink-0 w-[270px] border-border dark:border-darkborder bg-white dark:bg-dark lg:top-5 lg:start-5 shadow-md lg:rounded-md block">
                <!-- ---------------------------------- -->
                <!-- Start Vertical Layout Sidebar -->
                <!-- ---------------------------------- -->
                <div class="p-3.5">
                    <div class="brand-logo">
                        <a href="/ghost/admin/dashboard" class="text-nowrap logo-img flex items-center">
                            <i class="ti ti-ghost text-3xl text-primary dark:text-primary mr-2"></i>
                            <span class="text-xl font-bold text-dark dark:text-white">Ghost Admin</span>
                        </a>
                    </div>
                </div>
                
                <div class="scroll-sidebar" data-simplebar="">
                    <div class="px-4 mt-5 mini-layout" data-te-sidenav-menu-ref>
                        <nav class="hs-accordion-group w-full flex flex-col">
                            <ul data-te-sidenav-menu-ref id="sidebarnav">
                                
                                <!-----Dashboard------->
                                <div class="caption">
                                    <i class="ti ti-dots nav-small-cap-icon text-lg hidden text-center leading-[16px]"></i>
                                    <span class="hide-menu">HOME</span>
                                </div>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Dashboard'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightsuccess hover:text-success</cfif>" href="/ghost/admin/dashboard">
                                        <iconify-icon icon="solar:screencast-2-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Dashboard</span>
                                    </a>
                                </li>
                                
                                <!---Content---->
                                <div class="caption">
                                    <i class="ti ti-dots nav-small-cap-icon text-lg hidden text-center leading-[16px]"></i>
                                    <span class="hide-menu">CONTENT</span>
                                </div>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Posts'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightindigo hover:text-indigo dark:hover:text-indigo</cfif>" href="/ghost/admin/posts">
                                        <iconify-icon icon="solar:document-text-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Posts</span>
                                    </a>
                                </li>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Pages'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lighterror hover:text-error dark:hover:text-error</cfif>" href="/ghost/admin/pages">
                                        <iconify-icon icon="solar:file-text-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Pages</span>
                                    </a>
                                </li>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Tags'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightwarning hover:text-warning dark:hover:text-warning</cfif>" href="/ghost/admin/tags">
                                        <iconify-icon icon="solar:tag-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Tags</span>
                                    </a>
                                </li>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Drafts'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightsecondary hover:text-secondary dark:hover:text-secondary</cfif>" href="/ghost/admin/posts/drafts">
                                        <iconify-icon icon="solar:document-add-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Drafts</span>
                                    </a>
                                </li>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Scheduled'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightinfo hover:text-info dark:hover:text-info</cfif>" href="/ghost/admin/posts/scheduled">
                                        <iconify-icon icon="solar:calendar-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Scheduled</span>
                                    </a>
                                </li>
                                
                                <!---Members---->
                                <div class="caption">
                                    <i class="ti ti-dots nav-small-cap-icon text-lg hidden text-center leading-[16px]"></i>
                                    <span class="hide-menu">MEMBERS</span>
                                </div>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Members'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightsuccess hover:text-success dark:hover:text-success</cfif>" href="/ghost/admin/members">
                                        <iconify-icon icon="solar:users-group-two-rounded-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">All Members</span>
                                    </a>
                                </li>
                                
                                <!---Settings---->
                                <div class="caption">
                                    <i class="ti ti-dots nav-small-cap-icon text-lg hidden text-center leading-[16px]"></i>
                                    <span class="hide-menu">SETTINGS</span>
                                </div>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Settings'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightinfo hover:text-info dark:hover:text-info</cfif>" href="/ghost/admin/settings">
                                        <iconify-icon icon="solar:settings-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">General</span>
                                    </a>
                                </li>
                                
                                <li class="sidebar-item">
                                    <a class="sidebar-link <cfif pageTitle EQ 'Design'>before:bg-lightprimary hover:text-primary active before:bg-lightprimary text-primary dark:text-primary<cfelse>before:bg-lightindigo hover:text-indigo dark:hover:text-indigo</cfif>" href="/ghost/admin/design">
                                        <iconify-icon icon="solar:palette-line-duotone" class="text-xl p-2"></iconify-icon>
                                        <span class="hide-menu flex-shrink-0">Design</span>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
                
                <!-- End Sidebar navigation -->
            </aside>
            <!--  Sidebar End -->
            
            <div class="page-wrapper w-full" role="main">
                <!-- Main Content -->
                <main class="h-full">
                    <div class="container full-container py-5 xl:ps-6 ps-0 pt-0 pe-0 remove-ps">
                        <!--  Header Start -->
                        <header class="sticky top-0 inset-x-0 z-[1] flex flex-wrap md:justify-start md:flex-nowrap text-sm py-3 lg:py-0 mb-6 bg-white dark:bg-dark rounded-md shadow-md">
                            <div class="with-vertical w-full">
                                <div class="w-full mx-auto px-4 lg:px-6" aria-label="Global">
                                    <div class="relative md:flex md:items-center md:justify-between h-[70px]">
                                        <div class="hs-collapse grow md:block">
                                            <div class="flex justify-between items-center">
                                                <div class="flex items-center gap-2 lg:w-auto w-full justify-between">
                                                    <div class="relative">
                                                        <a class="lg:flex hidden text-xl icon-hover cursor-pointer text-link dark:text-darklink sidebartoggler h-10 w-10 hover:text-primary hover:bg-lightprimary dark:hover:bg-darkprimary justify-center items-center rounded-full" id="headerCollapse" href="javascript:void(0)">
                                                            <iconify-icon icon="solar:list-bold-duotone" class="text-2xl relative z-[1]"></iconify-icon>
                                                        </a>
                                                        <!--Mobile Sidebar Toggle -->
                                                        <div class="sticky top-0 inset-x-0 lg:hidden">
                                                            <div class="flex items-center">
                                                                <!-- Navigation Toggle -->
                                                                <a class="text-xl icon-hover cursor-pointer text-link dark:text-darklink sidebartoggler h-10 w-10 hover:text-primary hover:bg-lightprimary dark:hover:bg-darkprimary flex justify-center items-center rounded-full" data-hs-overlay="#application-sidebar-brand" aria-controls="application-sidebar-brand" aria-label="Toggle navigation">
                                                                    <iconify-icon icon="solar:list-bold-duotone" class="text-2xl relative z-[1]"></iconify-icon>
                                                                </a>
                                                                <!-- End Navigation Toggle -->
                                                            </div>
                                                        </div>
                                                        <!-- End Sidebar Toggle -->
                                                    </div>
                                                    
                                                    <div class="flex lg:hidden md:w-fit overflow-hidden">
                                                        <div class="brand-logo d-flex align-items-center justify-center">
                                                            <a href="/ghost/admin/dashboard" class="text-nowrap logo-img">
                                                                <i class="ti ti-ghost text-3xl text-primary dark:text-primary"></i>
                                                                <span class="ml-2 text-xl font-bold text-dark dark:text-white">Ghost Admin</span>
                                                            </a>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="lg:hidden">
                                                        <button type="button" class="p-2 hs-collapse-toggle inline-flex h-10 w-10 text-link dark:text-darklink hover:text-primary hover:bg-lightprimary dark:hover:bg-darkprimary justify-center items-center rounded-full" data-hs-collapse="#hs-basic-collapse-heading" aria-label="Toggle navigation">
                                                            <i class="ti ti-dots text-xl"></i>
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <!-- Right Side Items -->
                                        <div class="flex gap-2 items-center lg:ps-0 ps-5 justify-end">
                                            <div class="flex items-center">
                                                <!-- Search Bar -->
                                                <div class="relative hidden lg:block mr-3">
                                                    <input type="text" class="py-2 px-3 ps-10 block w-64 border border-gray-200 dark:border-gray-700 rounded-full text-sm focus:border-primary focus:ring-primary dark:bg-gray-800 dark:text-gray-400 bg-gray-50" placeholder="Search...">
                                                    <div class="absolute inset-y-0 start-0 flex items-center pointer-events-none ps-3">
                                                        <iconify-icon icon="solar:magnifer-linear" class="text-gray-400"></iconify-icon>
                                                    </div>
                                                </div>
                                                
                                                <!-- Mobile Search Toggle -->
                                                <div class="lg:hidden">
                                                    <button type="button" class="relative h-10 w-10 text-link dark:text-darklink cursor-pointer hover:bg-lightprimary hover:text-primary dark:hover:bg-darkprimary flex justify-center items-center rounded-full">
                                                        <iconify-icon icon="solar:magnifer-linear" class="text-2xl relative z-[1]"></iconify-icon>
                                                    </button>
                                                </div>
                                                
                                                <!-- Theme Toggle -->
                                                <button type="button" class="hs-dark-mode-active:hidden icon-hover block hs-dark-mode group items-center font-medium hover:text-primary text-link dark:text-darklink h-10 w-10 hover:bg-lightprimary dark:hover:bg-darkprimary justify-center rounded-full" data-hs-theme-click-value="dark" id="dark-layout">
                                                    <iconify-icon icon="solar:moon-line-duotone" class="text-2xl text-link dark:text-darklink relative hover:text-primary"></iconify-icon>
                                                </button>
                                                <button type="button" class="hs-dark-mode-active:block icon-hover hidden hs-dark-mode group items-center font-medium hover:text-primary text-link dark:text-darklink h-10 w-10 hover:bg-lightprimary dark:hover:bg-darkprimary justify-center rounded-full" data-hs-theme-click-value="light" id="light-layout">
                                                    <iconify-icon icon="solar:sun-2-line-duotone" class="text-2xl text-link dark:text-darklink relative hover:text-primary"></iconify-icon>
                                                </button>
                                                
                                                <!-- Messages -->
                                                <div class="hs-dropdown xl:[--strategy:absolute] [--adaptive:none] md:[--trigger:hover] sm:relative group/menu">
                                                    <a id="hs-dropdown-hover-event-messages" class="relative hs-dropdown-toggle h-10 w-10 text-link dark:text-darklink cursor-pointer hover:bg-lightprimary hover:text-primary dark:hover:bg-darkprimary flex justify-center items-center rounded-full group-hover/menu:bg-lightprimary group-hover/menu:text-primary">
                                                        <iconify-icon icon="solar:chat-dots-line-duotone" class="text-2xl relative z-[1]"></iconify-icon>
                                                        <span class="flex absolute top-2 end-[9px] -mt-0.5 -me-2">
                                                            <span class="animate-ping absolute inline-flex size-full rounded-full bg-yellow-400 opacity-75 dark:bg-yellow-600"></span>
                                                            <span class="relative inline-flex text-xs bg-yellow-500 text-white rounded-full py-0.5 px-1">
                                                                <div class="h-1 rounded-full bg-primary"></div>
                                                            </span>
                                                        </span>
                                                    </a>
                                                    <div class="card hs-dropdown-menu transition-[opacity,margin] duration hs-dropdown-open:opacity-100 opacity-0 right-0 rtl:right-auto rtl:left-0 mt-2 min-w-max top-auto w-full sm:w-[385px] hidden z-[2]" aria-labelledby="hs-dropdown-hover-event-messages">
                                                        <div class="flex items-center pt-6 px-7 gap-4">
                                                            <h3 class="mb-0 text-lg font-semibold text-dark dark:text-white">Messages</h3>
                                                            <span class="py-1 px-3 border-0 badge text-xs font-medium bg-info text-white">2 new</span>
                                                        </div>
                                                        <div class="message-body max-h-[320px] pt-4" data-simplebar="">
                                                            <a href="javascript:void(0)" class="dropdown-item px-7 py-3 flex justify-between items-center bg-hover">
                                                                <div class="flex items-center">
                                                                    <span class="flex-shrink-0">
                                                                        <img src="https://ui-avatars.com/api/?name=John+Doe&background=5D87FF&color=fff" alt="user" class="rounded-full w-12 h-12">
                                                                    </span>
                                                                    <div class="ps-4">
                                                                        <h5 class="mb-1 font-medium text-sm">John Doe</h5>
                                                                        <span class="text-xs block">New post published!</span>
                                                                    </div>
                                                                </div>
                                                                <span class="text-xs block self-start pt-1.5">2m ago</span>
                                                            </a>
                                                            <a href="javascript:void(0)" class="dropdown-item px-7 py-3 flex items-center justify-between bg-hover">
                                                                <div class="flex items-center">
                                                                    <span class="flex-shrink-0">
                                                                        <img src="https://ui-avatars.com/api/?name=Jane+Smith&background=49BEFF&color=fff" alt="user" class="rounded-full w-11">
                                                                    </span>
                                                                    <div class="ps-4">
                                                                        <h5 class="mb-1 font-medium text-sm">Jane Smith</h5>
                                                                        <span class="text-xs block">Comment on your post</span>
                                                                    </div>
                                                                </div>
                                                                <span class="text-xs block self-start pt-1.5">15m ago</span>
                                                            </a>
                                                        </div>
                                                        <div class="pt-3 pb-6 px-7">
                                                            <a href="#" class="btn w-full block">See All Messages</a>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Notifications -->
                                                <div class="hs-dropdown xl:[--strategy:absolute] [--adaptive:none] md:[--trigger:hover] sm:relative group/menu">
                                                    <a id="hs-dropdown-hover-event-notification" class="relative hs-dropdown-toggle h-10 w-10 text-link dark:text-darklink cursor-pointer hover:bg-lightprimary hover:text-primary dark:hover:bg-darkprimary flex justify-center items-center rounded-full group-hover/menu:bg-lightprimary group-hover/menu:text-primary">
                                                        <iconify-icon icon="solar:bell-bing-line-duotone" class="text-2xl relative z-[1]"></iconify-icon>
                                                        <span class="flex absolute top-2 end-3 -mt-0.5 -me-2">
                                                            <span class="animate-ping absolute inline-flex size-full rounded-full bg-teal-400 opacity-75 dark:bg-teal-600"></span>
                                                            <span class="relative inline-flex text-xs bg-teal-500 text-white rounded-full py-0.5 px-1">
                                                                <div class="h-1 rounded-full bg-primary"></div>
                                                            </span>
                                                        </span>
                                                    </a>
                                                    <div class="card hs-dropdown-menu transition-[opacity,margin] duration hs-dropdown-open:opacity-100 opacity-0 right-0 rtl:right-auto rtl:left-0 mt-2 min-w-max top-auto w-full sm:w-[360px] hidden z-[2]" aria-labelledby="hs-dropdown-hover-event-notification">
                                                        <div class="flex items-center pt-6 px-7 gap-4">
                                                            <h3 class="mb-0 text-lg font-semibold">Notifications</h3>
                                                            <span class="py-1 px-3 border-0 badge text-xs font-medium bg-warning text-white">3 new</span>
                                                        </div>
                                                        <div class="message-body max-h-[320px] pt-4" data-simplebar>
                                                            <a href="javascript:void(0)" class="dropdown-item px-7 py-3 flex items-center bg-hover">
                                                                <span class="flex-shrink-0 h-12 w-12 rounded-full bg-lightprimary dark:bg-darkprimary flex justify-center items-center">
                                                                    <iconify-icon icon="solar:document-text-line-duotone" class="text-primary text-xl"></iconify-icon>
                                                                </span>
                                                                <div class="ps-4">
                                                                    <h5 class="font-medium text-sm">New Post Published</h5>
                                                                    <span class="text-xs block my-0.5">"Getting Started with Ghost"</span>
                                                                    <p class="text-xs">Just now</p>
                                                                </div>
                                                            </a>
                                                            <a href="javascript:void(0)" class="dropdown-item px-7 py-3 flex items-center bg-hover">
                                                                <span class="flex-shrink-0 h-12 w-12 rounded-full bg-lightsuccess dark:bg-darksuccess flex justify-center items-center">
                                                                    <iconify-icon icon="solar:users-group-two-rounded-line-duotone" class="text-success text-xl"></iconify-icon>
                                                                </span>
                                                                <div class="ps-4">
                                                                    <h5 class="font-medium text-sm">New Member</h5>
                                                                    <span class="text-xs block my-0.5">Sarah Lee just joined</span>
                                                                    <p class="text-xs">5 min ago</p>
                                                                </div>
                                                            </a>
                                                            <a href="javascript:void(0)" class="dropdown-item px-7 py-3 flex items-center bg-hover">
                                                                <span class="flex-shrink-0 h-12 w-12 rounded-full bg-lighterror dark:bg-darkerror flex justify-center items-center">
                                                                    <iconify-icon icon="solar:chat-round-dots-line-duotone" class="text-error text-xl"></iconify-icon>
                                                                </span>
                                                                <div class="ps-4">
                                                                    <h5 class="font-medium text-sm">New Comment</h5>
                                                                    <span class="text-xs block my-0.5">On "SEO Best Practices"</span>
                                                                    <p class="text-xs">10 min ago</p>
                                                                </div>
                                                            </a>
                                                        </div>
                                                        <div class="pt-3 pb-6 px-7">
                                                            <a href="#" class="btn w-full block">See All Notifications</a>
                                                        </div>
                                                    </div>
                                                </div>
                                                
                                                <!-- Profile -->
                                                <div class="hs-dropdown xl:[--strategy:absolute] [--adaptive:none] md:[--trigger:hover] sm:relative ms-3">
                                                    <a id="hs-dropdown-hover-event-profile" class="relative hs-dropdown-toggle cursor-pointer align-middle rounded-full">
                                                        <div class="flex gap-3 items-center">
                                                            <div class="relative">
                                                                <cfif len(displayUserImage) gt 0>
                                                                    <img class="object-cover w-11 h-11 rounded-full" src="<cfoutput>#displayUserImage#</cfoutput>" alt="<cfoutput>#htmlEditFormat(displayUserName)#</cfoutput>" aria-hidden="true">
                                                                <cfelse>
                                                                    <img class="object-cover w-11 h-11 rounded-full" src="https://ui-avatars.com/api/?name=<cfoutput>#urlEncodedFormat(displayUserName)#</cfoutput>&background=5D87FF&color=fff" alt="<cfoutput>#htmlEditFormat(displayUserName)#</cfoutput>" aria-hidden="true">
                                                                </cfif>
                                                                <span class="h-3.5 w-3.5 rounded-full bg-success block absolute top-0 -end-1 border-2 border-white dark:border-dark"></span>
                                                            </div>
                                                            <div class="hidden sm:flex items-center">
                                                                <h6 class="font-bold text-dark dark:text-white text-base profile-name mb-0"><cfoutput>#htmlEditFormat(displayUserName)#</cfoutput></h6>
                                                            </div>
                                                        </div>
                                                    </a>
                                                    <div class="card hs-dropdown-menu transition-[opacity,margin] duration hs-dropdown-open:opacity-100 opacity-0 mt-2 min-w-max top-auto right-0 rtl:right-auto rtl:left-0 w-full sm:w-[385px] hidden z-[2] border-none" aria-labelledby="hs-dropdown-hover-event-profile">
                                                        <div class="card-body p-7">
                                                            <div class="flex items-center pb-5 justify-between">
                                                                <h3 class="mb-0 text-lg font-semibold text-dark dark:text-white">User Profile</h3>
                                                            </div>
                                                            <div class="message-body" data-simplebar>
                                                                <div class="">
                                                                    <div class="flex items-center gap-6 pb-5 border-b dark:border-darkborder">
                                                                        <cfif len(displayUserImage) gt 0>
                                                                            <img src="<cfoutput>#displayUserImage#</cfoutput>" class="h-[90px] w-[90px] rounded-full object-cover" alt="profile">
                                                                        <cfelse>
                                                                            <img src="https://ui-avatars.com/api/?name=<cfoutput>#urlEncodedFormat(displayUserName)#</cfoutput>&background=5D87FF&color=fff" class="h-[90px] w-[90px] rounded-full object-cover" alt="profile">
                                                                        </cfif>
                                                                        <div class="">
                                                                            <h5 class="card-title"><cfoutput>#htmlEditFormat(displayUserName)#</cfoutput></h5>
                                                                            <span class="card-subtitle"><cfoutput>#htmlEditFormat(lcase(displayUserRole))#</cfoutput></span>
                                                                            <p class="mb-0 mt-1 flex items-center">
                                                                                <iconify-icon icon="solar:mailbox-line-duotone" class="text-base me-1"></iconify-icon>
                                                                                <cfoutput>#htmlEditFormat(displayUserEmail)#</cfoutput>
                                                                            </p>
                                                                        </div>
                                                                    </div>
                                                                    
                                                                    <ul class="mt-3 flex flex-col gap-3.5">
                                                                        <li>
                                                                            <a href="/ghost/admin/profile" class="flex gap-5 items-center bg-hover relative group p-2 rounded-sm">
                                                                                <span class="bg-lightinfo dark:bg-darkinfo p-2 hover:bg-info group text-info hover:text-white rounded-sm flex justify-center items-center">
                                                                                    <iconify-icon icon="solar:wallet-2-line-duotone" class="text-2xl"></iconify-icon>
                                                                                </span>
                                                                                <div>
                                                                                    <h6 class="font-medium text-base leading-tight mb-1 group-hover:text-primary">My Profile</h6>
                                                                                    <p class="text-sm font-normal leading-tight">Account settings</p>
                                                                                </div>
                                                                            </a>
                                                                        </li>
                                                                        <li>
                                                                            <a href="/ghost/admin/posts" class="flex gap-5 items-center p-2 rounded-sm bg-hover relative group">
                                                                                <span class="bg-lightsuccess dark:bg-darksuccess p-2 hover:bg-success group text-success hover:text-white rounded-sm flex justify-center items-center">
                                                                                    <iconify-icon icon="solar:document-text-line-duotone" class="text-2xl"></iconify-icon>
                                                                                </span>
                                                                                <div>
                                                                                    <h6 class="font-medium text-base leading-tight mb-1 group-hover:text-primary">My Posts</h6>
                                                                                    <p class="text-sm font-normal leading-tight">Manage your content</p>
                                                                                </div>
                                                                            </a>
                                                                        </li>
                                                                        <li>
                                                                            <a href="/ghost/admin/settings" class="flex gap-5 items-center p-2 rounded-sm bg-hover relative group">
                                                                                <span class="bg-lighterror dark:bg-darkerror p-2 hover:bg-error group text-error hover:text-white rounded-sm flex justify-center items-center">
                                                                                    <iconify-icon icon="solar:settings-line-duotone" class="text-2xl"></iconify-icon>
                                                                                </span>
                                                                                <div>
                                                                                    <h6 class="font-medium text-base leading-tight mb-1 group-hover:text-primary">Settings</h6>
                                                                                    <p class="text-sm font-normal leading-tight">Blog configuration</p>
                                                                                </div>
                                                                            </a>
                                                                        </li>
                                                                    </ul>
                                                                </div>
                                                            </div>
                                                            <div class="mt-5">
                                                                <a href="/ghost/admin/logout" class="btn w-full block">
                                                                    Log Out
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </header>
                        <!--  Header End -->
                        
                        <!------Container------>
                        <div class="max-w-full">
                            <div class="container full-container">