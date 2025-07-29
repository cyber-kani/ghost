<!--- Test Blog Theme Loading --->
<cfparam name="request.dsn" default="blog">

<!--- Get active theme --->
<cfquery name="qTheme" datasource="#request.dsn#">
    SELECT value FROM settings WHERE `key` = 'active_theme'
</cfquery>

<cfset activeTheme = qTheme.recordCount ? qTheme.value : "casper">

<cfoutput>
<!DOCTYPE html>
<html>
<head>
    <title>Test Theme Loading</title>
    <link rel="stylesheet" type="text/css" href="/ghost/themes/#activeTheme#/assets/built/screen.css" />
</head>
<body>
    <h1>Active Theme: #activeTheme#</h1>
    <p>CSS Path: /ghost/themes/#activeTheme#/assets/built/screen.css</p>
    
    <div class="gh-viewport">
        <header id="gh-head" class="gh-head outer">
            <div class="gh-head-inner inner">
                <div class="gh-head-brand">
                    <a class="gh-head-logo no-image" href="/ghost">
                        Ghost CFML
                    </a>
                </div>
            </div>
        </header>
        
        <main id="site-main" class="site-main outer">
            <div class="inner posts">
                <article class="post-card">
                    <div class="post-card-content">
                        <h2 class="post-card-title">Test Post</h2>
                        <p class="post-card-excerpt">This is a test post to verify theme styling.</p>
                    </div>
                </article>
            </div>
        </main>
    </div>
</body>
</html>
</cfoutput>