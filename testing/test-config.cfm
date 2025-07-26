<!--- Test Site Configuration --->
<h3>Testing Site Configuration</h3>

<cftry>
    <!--- Include the config --->
    <cfinclude template="../config/site.cfm">
    
    <cfoutput>
    <h4>Configuration Values:</h4>
    <ul>
        <li><strong>Ghost URL:</strong> #application.siteConfig.ghostUrl#</li>
        <li><strong>Content Path:</strong> #application.siteConfig.contentPath#</li>
        <li><strong>Images Path:</strong> #application.siteConfig.imagesPath#</li>
        <li><strong>Site Name:</strong> #application.siteConfig.siteName#</li>
    </ul>
    
    <h4>Testing Helper Functions:</h4>
    <cfset testUrl = "__GHOST_URL__/content/images/test.jpg">
    <p>Original: #testUrl#</p>
    <p>Replaced: #replaceGhostUrl(testUrl)#</p>
    
    <cfset testImage = "/content/images/2025/07/test.jpg">
    <p>Original: #testImage#</p>
    <p>Full URL: #getImageUrl(testImage)#</p>
    
    <cfset testImage2 = "__GHOST_URL__/content/images/2025/07/test2.jpg">
    <p>Original: #testImage2#</p>
    <p>Full URL: #getImageUrl(testImage2)#</p>
    </cfoutput>
    
    <cfcatch>
        <h3 style="color: red;">Error:</h3>
        <cfoutput>
            <p>Message: #cfcatch.message#</p>
            <p>Detail: #cfcatch.detail#</p>
        </cfoutput>
    </cfcatch>
</cftry>