<!DOCTYPE html>
<html>
<head>
    <title>Test Announcement Bar</title>
</head>
<body>
    <h1>Testing Announcement Bar</h1>
    
    <!--- Include the announcement bar --->
    <cfinclude template="/ghost/includes/announcement-bar.cfm">
    
    <p>If you can see this page but no announcement bar above, check the debug output in the page source.</p>
    
    <hr>
    
    <h2>Direct Settings Check:</h2>
    <cfquery name="qTestSettings" datasource="blog">
        SELECT * FROM settings 
        WHERE `key` LIKE 'announcement%'
    </cfquery>
    
    <cfdump var="#qTestSettings#" label="Announcement Settings in Database">
</body>
</html>