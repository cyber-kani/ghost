<!--- Theme Style Loader --->
<cffunction name="getThemeStyles" access="public" returntype="string">
    <cfargument name="themeName" type="string" required="true">
    
    <cfset var styles = "">
    
    <cfswitch expression="#arguments.themeName#">
        <cfcase value="casper">
            <cfset styles = '
                /* Casper Theme Styles */
                :root {
                    --ghost-accent-color: ##26a8ed;
                    --color-primary-text: ##131313;
                    --color-secondary-text: ##737373;
                    --color-border: ##e5e5e5;
                    --color-background: ##ffffff;
                    --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
                }
                
                body {
                    font-family: var(--font-sans);
                    background: var(--color-background);
                    color: var(--color-primary-text);
                }
                
                header {
                    background: transparent;
                    border-bottom: 1px solid var(--color-border);
                    box-shadow: none;
                    padding: 40px 0;
                }
                
                .site-title {
                    font-size: 3.2rem;
                    font-weight: 700;
                    letter-spacing: -0.02em;
                    color: var(--color-primary-text);
                }
                
                .site-description {
                    font-size: 1.6rem;
                    font-weight: 400;
                    color: var(--color-secondary-text);
                    margin-top: 8px;
                }
                
                nav a {
                    font-size: 1.4rem;
                    color: var(--color-secondary-text);
                    font-weight: 400;
                }
                
                nav a:hover {
                    color: var(--color-primary-text);
                }
                
                main {
                    background: transparent;
                    box-shadow: none;
                    padding: 0;
                    max-width: 1200px;
                    margin: 60px auto;
                }
                
                .post-card {
                    border-bottom: 1px solid var(--color-border);
                    padding: 40px 0;
                }
                
                .post-card h2 {
                    font-size: 2.8rem;
                    font-weight: 700;
                    letter-spacing: -0.02em;
                    margin-bottom: 16px;
                }
                
                .post-card h2 a {
                    color: var(--color-primary-text);
                }
                
                .post-card h2 a:hover {
                    color: var(--ghost-accent-color);
                }
                
                .post-meta {
                    font-size: 1.3rem;
                    color: var(--color-secondary-text);
                    margin-bottom: 12px;
                }
                
                .post-excerpt {
                    font-size: 1.6rem;
                    line-height: 1.6;
                    color: var(--color-secondary-text);
                }
                
                .post-tag {
                    background: transparent;
                    border: 1px solid var(--color-border);
                    color: var(--color-secondary-text);
                    font-size: 1.3rem;
                    padding: 4px 12px;
                }
                
                .post-tag:hover {
                    border-color: var(--ghost-accent-color);
                    color: var(--ghost-accent-color);
                }
                
                /* Casper theme - vertical card layout */
                .post-feed {
                    display: grid !important;
                    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)) !important;
                    gap: 40px !important;
                }
                .post-card {
                    display: flex !important;
                    flex-direction: column !important;
                    border: none !important;
                    border-radius: 12px;
                    overflow: hidden;
                    background: ##fff;
                    box-shadow: 0 1px 4px rgba(0,0,0,0.1);
                    transition: all 0.3s ease;
                    padding: 0 !important;
                }
                .post-card:hover {
                    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
                    transform: translateY(-4px);
                }
                .post-card-image-link {
                    width: 100% !important;
                    height: 200px !important;
                    overflow: hidden;
                    display: block !important;
                    flex-shrink: 0;
                }
                .post-card-image {
                    width: 100% !important;
                    height: 100% !important;
                    object-fit: cover !important;
                    transition: opacity 0.3s ease;
                }
                .post-card:hover .post-card-image {
                    opacity: 0.9;
                }
                .post-card-content {
                    padding: 30px !important;
                    flex: 1;
                    display: flex;
                    flex-direction: column;
                }
                .post-card h2 {
                    font-size: 2.2rem;
                    margin-bottom: 12px;
                }
                .post-excerpt {
                    flex: 1;
                }
                .post-tags {
                    margin-top: 20px;
                }
                @media (max-width: 768px) {
                    .post-feed {
                        grid-template-columns: 1fr;
                    }
                }
            '>
        </cfcase>
        
        <cfcase value="liebling">
            <cfset styles = '
                /* Liebling Theme Styles */
                :root {
                    --color-primary: ##FF572F;
                    --color-text: ##1a1a1a;
                    --color-text-secondary: ##626262;
                    --color-border: ##f0f0f0;
                    --color-background: ##fafafa;
                }
                
                body {
                    font-family: "Source Sans Pro", -apple-system, BlinkMacSystemFont, sans-serif;
                    background: var(--color-background);
                    color: var(--color-text);
                }
                
                header {
                    background: ##fff;
                    border-bottom: 1px solid var(--color-border);
                    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
                    padding: 20px 0;
                }
                
                .header-inner {
                    align-items: center;
                }
                
                .site-title {
                    font-size: 2.4rem;
                    font-weight: 700;
                    color: var(--color-text);
                    text-transform: uppercase;
                    letter-spacing: 1px;
                }
                
                .site-description {
                    display: none;
                }
                
                nav a {
                    font-size: 1.5rem;
                    color: var(--color-text);
                    font-weight: 600;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }
                
                nav a:hover {
                    color: var(--color-primary);
                }
                
                main {
                    background: ##fff;
                    box-shadow: 0 0 40px rgba(0,0,0,0.08);
                    border-radius: 8px;
                    padding: 60px;
                    margin-top: 40px;
                }
                
                .post-card {
                    border-bottom: 2px solid var(--color-border);
                    padding: 40px 0;
                    position: relative;
                }
                
                .post-card h2 {
                    font-size: 2.6rem;
                    font-weight: 700;
                    margin-bottom: 20px;
                }
                
                .post-card h2 a {
                    color: var(--color-text);
                    transition: color 0.2s;
                }
                
                .post-card h2 a:hover {
                    color: var(--color-primary);
                }
                
                .post-meta {
                    font-size: 1.4rem;
                    color: var(--color-text-secondary);
                    margin-bottom: 20px;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }
                
                .post-excerpt {
                    font-size: 1.7rem;
                    line-height: 1.7;
                    color: var(--color-text-secondary);
                }
                
                .post-tag {
                    background: var(--color-primary);
                    color: ##fff;
                    font-size: 1.2rem;
                    padding: 6px 16px;
                    border-radius: 20px;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                    font-weight: 600;
                }
                
                .post-tag:hover {
                    background: ##e54d2a;
                }
                
                /* Liebling theme - no images in list, clean layout */
                .post-card {
                    display: block;
                    padding: 40px 0;
                }
                .post-card-image-link {
                    display: none;
                }
                .post-card-content {
                    max-width: 720px;
                }
            '>
        </cfcase>
        
        <cfcase value="solo">
            <cfset styles = '
                /* Solo Theme Styles */
                :root {
                    --color-primary: ##6366f1;
                    --color-text: ##111827;
                    --color-text-secondary: ##6b7280;
                    --color-border: ##e5e7eb;
                    --color-background: ##f9fafb;
                }
                
                body {
                    font-family: "Inter", -apple-system, BlinkMacSystemFont, sans-serif;
                    background: var(--color-background);
                    color: var(--color-text);
                    font-size: 18px;
                }
                
                header {
                    background: ##fff;
                    border-bottom: 1px solid var(--color-border);
                    padding: 32px 0;
                    margin-bottom: 0;
                }
                
                .site-title {
                    font-size: 2rem;
                    font-weight: 800;
                    color: var(--color-text);
                }
                
                .site-description {
                    font-size: 1.125rem;
                    color: var(--color-text-secondary);
                    margin-top: 4px;
                    font-weight: 400;
                }
                
                nav a {
                    font-size: 1rem;
                    color: var(--color-text-secondary);
                    font-weight: 500;
                }
                
                nav a:hover {
                    color: var(--color-primary);
                }
                
                main {
                    background: ##fff;
                    box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
                    border-radius: 12px;
                    padding: 48px;
                    margin-top: 32px;
                    border: 1px solid var(--color-border);
                }
                
                .post-card {
                    border-bottom: 1px solid var(--color-border);
                    padding: 48px 0;
                }
                
                .post-card h2 {
                    font-size: 2rem;
                    font-weight: 700;
                    margin-bottom: 16px;
                    line-height: 1.3;
                }
                
                .post-card h2 a {
                    color: var(--color-text);
                    background-image: linear-gradient(to right, var(--color-primary), var(--color-primary));
                    background-repeat: no-repeat;
                    background-position: 0 100%;
                    background-size: 0 2px;
                    transition: background-size 0.3s;
                }
                
                .post-card h2 a:hover {
                    background-size: 100% 2px;
                }
                
                .post-meta {
                    font-size: 0.875rem;
                    color: var(--color-text-secondary);
                    margin-bottom: 16px;
                }
                
                .post-excerpt {
                    font-size: 1.125rem;
                    line-height: 1.75;
                    color: var(--color-text-secondary);
                }
                
                .post-tag {
                    background: ##eef2ff;
                    color: var(--color-primary);
                    font-size: 0.875rem;
                    padding: 4px 12px;
                    border-radius: 6px;
                    font-weight: 500;
                    border: 1px solid ##c7d2fe;
                }
                
                .post-tag:hover {
                    background: ##e0e7ff;
                    border-color: ##a5b4fc;
                }
                
                /* Solo theme - minimal with small thumbnails */
                .post-feed {
                    display: flex;
                    flex-direction: column;
                    gap: 0;
                }
                .post-card {
                    display: flex;
                    gap: 24px;
                    align-items: center;
                    padding: 32px 0;
                }
                .post-card-image-link {
                    width: 120px;
                    height: 80px;
                    flex-shrink: 0;
                    border-radius: 8px;
                    overflow: hidden;
                    border: 1px solid var(--color-border);
                }
                .post-card-content {
                    flex: 1;
                }
                .post-card h2 {
                    font-size: 1.5rem;
                    margin-bottom: 8px;
                }
                .post-meta {
                    font-size: 0.875rem;
                    margin-bottom: 8px;
                }
                .post-excerpt {
                    font-size: 1rem;
                    margin-bottom: 12px;
                }
                @media (max-width: 640px) {
                    .post-card {
                        flex-direction: column;
                        align-items: flex-start;
                    }
                    .post-card-image-link {
                        width: 100%;
                        height: 180px;
                    }
                }
            '>
        </cfcase>
        
        <cfdefaultcase>
            <!--- Default/Simple theme styles (keep existing) --->
            <cfset styles = "">
        </cfdefaultcase>
    </cfswitch>
    
    <cfreturn styles>
</cffunction>