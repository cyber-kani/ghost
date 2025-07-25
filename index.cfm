<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><cfoutput>#application.siteName#</cfoutput></title>
    
    <!-- Fomantic-UI CSS -->
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.9.3/dist/semantic.min.css">
    
    <!-- Apple HIG + Material3 Design System -->
    <style>
        /* Apple Human Interface Guidelines Design Tokens */
        :root {
            /* Apple SF Typography Scale */
            --hig-font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Helvetica Neue", Helvetica, Arial, sans-serif;
            --hig-font-mono: "SF Mono", Menlo, Monaco, Consolas, monospace;
            
            /* Apple Color Palette */
            --hig-color-blue: #007AFF;
            --hig-color-green: #34C759;
            --hig-color-orange: #FF9500;
            --hig-color-red: #FF3B30;
            --hig-color-purple: #AF52DE;
            --hig-color-pink: #FF2D92;
            --hig-color-teal: #5AC8FA;
            --hig-color-indigo: #5856D6;
            
            /* Apple Semantic Colors */
            --hig-label-primary: #000000;
            --hig-label-secondary: #3C3C43;
            --hig-label-tertiary: #3C3C4399;
            --hig-separator: #3C3C431F;
            --hig-background-primary: #FFFFFF;
            --hig-background-secondary: #F2F2F7;
            --hig-background-tertiary: #FFFFFF;
            --hig-fill-primary: #78788033;
            --hig-fill-secondary: #78788028;
            --hig-fill-tertiary: #7676801E;
            
            /* Apple Spacing System (4pt grid) */
            --hig-spacing-xs: 4px;
            --hig-spacing-sm: 8px;
            --hig-spacing-md: 16px;
            --hig-spacing-lg: 24px;
            --hig-spacing-xl: 32px;
            --hig-spacing-xxl: 48px;
            
            /* Apple Typography Weights */
            --hig-weight-regular: 400;
            --hig-weight-medium: 500;
            --hig-weight-semibold: 600;
            --hig-weight-bold: 700;
            
            /* Apple Corner Radius */
            --hig-radius-sm: 8px;
            --hig-radius-md: 12px;
            --hig-radius-lg: 16px;
            --hig-radius-xl: 20px;
            
            /* Apple Shadow System */
            --hig-shadow-sm: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
            --hig-shadow-md: 0 3px 6px rgba(0,0,0,0.15), 0 2px 4px rgba(0,0,0,0.12);
            --hig-shadow-lg: 0 10px 20px rgba(0,0,0,0.15), 0 3px 6px rgba(0,0,0,0.10);
            --hig-shadow-xl: 0 15px 25px rgba(0,0,0,0.15), 0 5px 10px rgba(0,0,0,0.05);
        }

        /* Dark mode support following Apple HIG */
        @media (prefers-color-scheme: dark) {
            :root {
                --hig-label-primary: #FFFFFF;
                --hig-label-secondary: #EBEBF599;
                --hig-label-tertiary: #EBEBF54D;
                --hig-separator: #54545899;
                --hig-background-primary: #000000;
                --hig-background-secondary: #1C1C1E;
                --hig-background-tertiary: #2C2C2E;
                --hig-fill-primary: #7676804D;
                --hig-fill-secondary: #78788040;
                --hig-fill-tertiary: #7676803D;
            }
        }

        /* Apple HIG Body Styling */
        body {
            font-family: var(--hig-font-family);
            background: var(--hig-background-secondary);
            color: var(--hig-label-primary);
            min-height: 100vh;
            margin: 0;
            padding: var(--hig-spacing-lg);
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            text-rendering: optimizeLegibility;
        }

        /* Material 3 Design Tokens */
        :root {
            /* Material 3 Color System */
            --md-sys-color-primary: #6750A4;
            --md-sys-color-on-primary: #FFFFFF;
            --md-sys-color-primary-container: #EADDFF;
            --md-sys-color-on-primary-container: #21005D;
            --md-sys-color-secondary: #625B71;
            --md-sys-color-on-secondary: #FFFFFF;
            --md-sys-color-secondary-container: #E8DEF8;
            --md-sys-color-on-secondary-container: #1D192B;
            --md-sys-color-tertiary: #7D5260;
            --md-sys-color-on-tertiary: #FFFFFF;
            --md-sys-color-surface: #FFFBFE;
            --md-sys-color-on-surface: #1C1B1F;
            --md-sys-color-surface-variant: #E7E0EC;
            --md-sys-color-on-surface-variant: #49454F;
            --md-sys-color-surface-container: #F3EDF7;
            --md-sys-color-surface-container-high: #ECE6F0;
            --md-sys-color-outline: #79747E;
            --md-sys-color-outline-variant: #CAC4D0;
            --md-sys-color-success: #2E7D32;
            --md-sys-color-error: #B3261E;
            --md-sys-color-warning: #F57C00;
            
            /* Material 3 Typography Scale */
            --md-sys-typescale-display-large-font: var(--hig-font-family);
            --md-sys-typescale-display-large-size: 57px;
            --md-sys-typescale-display-large-weight: 400;
            --md-sys-typescale-headline-large-size: 32px;
            --md-sys-typescale-headline-large-weight: 400;
            --md-sys-typescale-headline-medium-size: 28px;
            --md-sys-typescale-headline-medium-weight: 400;
            --md-sys-typescale-title-large-size: 22px;
            --md-sys-typescale-title-large-weight: 400;
            --md-sys-typescale-body-large-size: 16px;
            --md-sys-typescale-body-large-weight: 400;
            --md-sys-typescale-label-large-size: 14px;
            --md-sys-typescale-label-large-weight: 500;
        }

        /* Material 3 Main Container - Following Apple HIG spacing */
        .main-container {
            background: var(--md-sys-color-surface);
            border-radius: var(--hig-radius-lg);
            box-shadow: var(--hig-shadow-lg);
            overflow: hidden;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Material 3 Header with Apple HIG proportions */
        .ghost-header {
            background: var(--md-sys-color-primary);
            color: var(--md-sys-color-on-primary);
            padding: var(--hig-spacing-xxl);
            text-align: center;
            position: relative;
        }

        .ghost-logo {
            font-size: var(--md-sys-typescale-display-large-size);
            font-weight: var(--md-sys-typescale-display-large-weight);
            margin-bottom: var(--hig-spacing-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--hig-spacing-md);
        }

        .ghost-icon {
            width: 48px;
            height: 48px;
            background: var(--md-sys-color-tertiary);
            border-radius: var(--hig-radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: var(--hig-weight-bold);
            color: var(--md-sys-color-on-tertiary);
        }

        /* Material 3 Status Section */
        .status-section {
            padding: var(--hig-spacing-xxl);
        }

        .status-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: var(--hig-spacing-lg);
            margin: var(--hig-spacing-xl) 0;
        }

        /* Material 3 Cards with Apple HIG principles */
        .ui.card.status-card {
            background: var(--md-sys-color-surface-container);
            border: 1px solid var(--md-sys-color-outline-variant);
            border-radius: var(--hig-radius-md);
            box-shadow: var(--hig-shadow-sm);
            transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
            padding: var(--hig-spacing-lg);
        }

        .ui.card.status-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--hig-shadow-md);
            background: var(--md-sys-color-surface-container-high);
        }

        .ui.card.status-card.success {
            border-left: 4px solid var(--md-sys-color-success);
        }

        .ui.card.status-card.error {
            border-left: 4px solid var(--md-sys-color-error);
        }

        .ui.card.status-card.warning {
            border-left: 4px solid var(--md-sys-color-warning);
        }

        .status-icon {
            font-size: var(--hig-spacing-xl);
            margin-bottom: var(--hig-spacing-sm);
        }

        /* Material 3 Action Buttons with Apple HIG touch targets */
        .action-buttons {
            text-align: center;
            padding: var(--hig-spacing-xl);
            border-top: 1px solid var(--md-sys-color-outline-variant);
            background: var(--md-sys-color-surface-variant);
        }

        .ui.button.ghost-button {
            background: var(--md-sys-color-primary);
            color: var(--md-sys-color-on-primary);
            border-radius: var(--hig-radius-xl);
            padding: var(--hig-spacing-md) var(--hig-spacing-lg);
            font-weight: var(--md-sys-typescale-label-large-weight);
            font-size: var(--md-sys-typescale-label-large-size);
            margin: var(--hig-spacing-sm);
            transition: all 0.2s cubic-bezier(0.4, 0.0, 0.2, 1);
            min-height: 44px; /* Apple HIG minimum touch target */
            min-width: 44px;
            border: none;
        }

        .ui.button.ghost-button:hover {
            background: var(--md-sys-color-primary-container);
            color: var(--md-sys-color-on-primary-container);
            transform: translateY(-1px);
            box-shadow: var(--hig-shadow-md);
        }

        .ui.button.ghost-secondary {
            background: var(--md-sys-color-secondary-container);
            color: var(--md-sys-color-on-secondary-container);
            border: 1px solid var(--md-sys-color-outline);
        }

        .ui.button.ghost-secondary:hover {
            background: var(--md-sys-color-secondary);
            color: var(--md-sys-color-on-secondary);
        }

        /* Material 3 Debug Section */
        .debug-section {
            background: var(--md-sys-color-surface-container);
            border: 1px solid var(--md-sys-color-outline-variant);
            border-radius: var(--hig-radius-md);
            padding: var(--hig-spacing-lg);
            margin: var(--hig-spacing-lg) var(--hig-spacing-xxl);
        }

        .ui.statistic .value {
            color: var(--md-sys-color-primary);
            font-family: var(--hig-font-family);
        }

        /* Material 3 Typography Classes */
        .md3-display-large {
            font-size: var(--md-sys-typescale-display-large-size);
            font-weight: var(--md-sys-typescale-display-large-weight);
            line-height: 1.2;
        }

        .md3-headline-large {
            font-size: var(--md-sys-typescale-headline-large-size);
            font-weight: var(--md-sys-typescale-headline-large-weight);
            line-height: 1.25;
        }

        .md3-title-large {
            font-size: var(--md-sys-typescale-title-large-size);
            font-weight: var(--md-sys-typescale-title-large-weight);
            line-height: 1.3;
        }

        .md3-body-large {
            font-size: var(--md-sys-typescale-body-large-size);
            font-weight: var(--md-sys-typescale-body-large-weight);
            line-height: 1.5;
        }

        /* Mobile responsive */
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }
            
            .ghost-header {
                padding: 24px;
            }
            
            .ghost-logo {
                font-size: 2rem;
            }
            
            .status-section,
            .action-buttons {
                padding: 24px;
            }
            
            .ui.button.ghost-button {
                display: block;
                width: 100%;
                margin: 8px 0;
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <!-- Ghost-inspired Header -->
        <div class="ghost-header">
            <div class="content">
                <div class="ghost-logo">
                    <div class="ghost-icon">G</div>
                    <cfoutput>#application.siteName#</cfoutput>
                </div>
                <div class="ui inverted header">
                    <div class="sub header">CFML-powered Ghost CMS Implementation</div>
                </div>
                <div class="ui inverted small statistics">
                    <div class="statistic">
                        <div class="value"><cfoutput>#application.version#</cfoutput></div>
                        <div class="label">Version</div>
                    </div>
                    <div class="statistic">
                        <div class="value"><cfoutput>#dateDiff('s', application.startTime, now())#</cfoutput>s</div>
                        <div class="label">Uptime</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Status Section -->
        <div class="status-section">
            <h2 class="ui header md3-headline-large">
                <i class="dashboard icon"></i>
                <div class="content">
                    System Status
                    <div class="sub header md3-body-large">Foundation components health check</div>
                </div>
            </h2>

            <div class="status-cards">
                <!-- Application Status -->
                <div class="ui card status-card success">
                    <div class="content">
                        <div class="header md3-title-large">
                            <div class="status-icon">🚀</div>
                            Application Status
                        </div>
                        <div class="meta md3-body-large">Core application health</div>
                        <div class="description">
                            <div class="ui relaxed list">
                                <div class="item">
                                    <i class="checkmark icon green"></i>
                                    <div class="content">
                                        <div class="header">Running</div>
                                        <div class="description">Started <cfoutput>#dateTimeFormat(application.startTime, 'HH:nn:ss')#</cfoutput></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Database Connection Test -->
                <!-- Database Connection Test with Enhanced Diagnostics -->
                <cfinclude template="config/database.cfm">
                
                <cfset dbTestResult = testDatabaseConnection()>
                <cfset dbStats = getDatabaseStats()>
                <cfset tableCheck = checkTableExistence()>

                <div class="ui card status-card <cfif dbTestResult.connected>success<cfelse>error</cfif>">
                    <div class="content">
                        <div class="header md3-title-large">
                            <div class="status-icon"><cfif dbTestResult.connected>💾<cfelse>⚠️</cfif></div>
                            Database Connection
                        </div>
                        <div class="meta md3-body-large">Blog datasource connectivity & Ghost tables</div>
                        <div class="description">
                            <div class="ui relaxed list">
                                <div class="item">
                                    <i class="<cfif dbTestResult.connected>checkmark green<cfelse>times red</cfif> icon"></i>
                                    <div class="content">
                                        <div class="header"><cfoutput>#dbTestResult.connected ? 'Connected' : 'Failed'#</cfoutput></div>
                                        <div class="description"><cfoutput>#dbTestResult.message#</cfoutput></div>
                                    </div>
                                </div>
                                <cfif dbTestResult.connected>
                                    <div class="item">
                                        <i class="table icon"></i>
                                        <div class="content">
                                            <div class="header">Ghost Tables</div>
                                            <div class="description">
                                                <cfoutput>#arrayLen(tableCheck.existingTables)# tables found</cfoutput>
                                                <cfif arrayLen(tableCheck.missingTables) gt 0>
                                                    <br><small style="color: #F57C00;">Missing: <cfoutput>#arrayLen(tableCheck.missingTables)# tables</cfoutput></small>
                                                </cfif>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="item">
                                        <i class="chart bar icon"></i>
                                        <div class="content">
                                            <div class="header">Data Summary</div>
                                            <div class="description">
                                                <cfif structKeyExists(dbStats.tables, "posts")>
                                                    Posts: <cfoutput>#dbStats.tables.posts#</cfoutput><br>
                                                </cfif>
                                                <cfif structKeyExists(dbStats.tables, "users")>
                                                    Users: <cfoutput>#dbStats.tables.users#</cfoutput><br>
                                                </cfif>
                                                <cfif structKeyExists(dbStats.tables, "tags")>
                                                    Tags: <cfoutput>#dbStats.tables.tags#</cfoutput>
                                                </cfif>
                                            </div>
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Project Structure -->
                <div class="ui card status-card success">
                    <div class="content">
                        <div class="header">
                            <div class="status-icon">📁</div>
                            Project Structure
                        </div>
                        <div class="meta">Directory organization</div>
                        <div class="description">
                            <div class="ui relaxed list">
                                <div class="item">
                                    <i class="folder icon"></i>
                                    <div class="content">Assets, Admin, Components</div>
                                </div>
                                <div class="item">
                                    <i class="folder icon"></i>
                                    <div class="content">Themes, Logs, Testing</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- CFML Environment -->
                <div class="ui card status-card success">
                    <div class="content">
                        <div class="header">
                            <div class="status-icon">⚙️</div>
                            CFML Environment
                        </div>
                        <div class="meta">Server information</div>
                        <div class="description">
                            <div class="ui relaxed list">
                                <div class="item">
                                    <i class="server icon"></i>
                                    <div class="content">
                                        <div class="header"><cfoutput>#server.coldfusion.productname#</cfoutput></div>
                                        <div class="description">Version <cfoutput>#server.coldfusion.productversion#</cfoutput></div>
                                    </div>
                                </div>
                                <div class="item">
                                    <i class="<cfif application.debugMode>bug<cfelse>shield</cfif> icon"></i>
                                    <div class="content">Debug: <cfoutput>#application.debugMode ? 'Enabled' : 'Disabled'#</cfoutput></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
            <a href="/ghost/admin/" class="ui button ghost-button">
                <i class="dashboard icon"></i>
                Admin Dashboard
            </a>
            <a href="/ghost/testing/" class="ui button ghost-button">
                <i class="flask icon"></i>
                Run Tests
            </a>
            <a href="?reinit=1" class="ui button ghost-secondary">
                <i class="refresh icon"></i>
                Reload Application
            </a>
        </div>

        <!-- Debug Information -->
        <cfif application.debugMode>
            <div class="debug-section">
                <h4 class="ui header">
                    <i class="bug icon"></i>
                    Debug Information
                </h4>
                <div class="ui relaxed divided list">
                    <div class="item">
                        <i class="id badge icon"></i>
                        <div class="content">
                            <div class="header">Request ID</div>
                            <div class="description"><cfoutput>#request.requestId#</cfoutput></div>
                        </div>
                    </div>
                    <div class="item">
                        <i class="user icon"></i>
                        <div class="content">
                            <div class="header">Session ID</div>
                            <div class="description"><cfoutput>#session.sessionId#</cfoutput></div>
                        </div>
                    </div>
                    <div class="item">
                        <i class="linkify icon"></i>
                        <div class="content">
                            <div class="header">Path Info</div>
                            <div class="description"><cfoutput>#request.pathInfo#</cfoutput></div>
                        </div>
                    </div>
                    <div class="item">
                        <i class="clock icon"></i>
                        <div class="content">
                            <div class="header">Processing Time</div>
                            <div class="description"><span id="processingTime">Calculating...</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </cfif>
    </div>

    <!-- Fomantic-UI JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.9.3/dist/semantic.min.js"></script>

    <cfif application.debugMode>
        <script>
            // Update processing time
            setTimeout(function() {
                const startTime = <cfoutput>#request.startTime#</cfoutput>;
                const currentTime = new Date().getTime();
                const processingTime = currentTime - startTime;
                document.getElementById('processingTime').textContent = processingTime + 'ms';
            }, 100);
        </script>
    </cfif>
</body>
</html>