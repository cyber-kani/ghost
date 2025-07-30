<!--- Test General Settings Functionality --->
<cfparam name="request.dsn" default="blog">

<!DOCTYPE html>
<html>
<head>
    <title>Test General Settings</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test-section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; }
        .success { color: green; }
        .error { color: red; }
        pre { background: #f5f5f5; padding: 10px; overflow: auto; }
    </style>
</head>
<body>

<h1>General Settings Test</h1>

<!--- Test 1: Check if settings table exists --->
<div class="test-section">
    <h2>Test 1: Check Settings Table</h2>
    <cftry>
        <cfquery name="qTest" datasource="#request.dsn#">
            SELECT COUNT(*) as setting_count FROM settings
        </cfquery>
        <p class="success">✓ Settings table exists with <cfoutput>#qTest.setting_count#</cfoutput> settings</p>
    <cfcatch>
        <p class="error">✗ Settings table error: <cfoutput>#cfcatch.message#</cfoutput></p>
    </cfcatch>
    </cftry>
</div>

<!--- Test 2: Load existing settings --->
<div class="test-section">
    <h2>Test 2: Load Settings</h2>
    <cftry>
        <cfquery name="qSettings" datasource="#request.dsn#">
            SELECT `key`, value, type FROM settings
            ORDER BY `key`
        </cfquery>
        <p class="success">✓ Loaded <cfoutput>#qSettings.recordCount#</cfoutput> settings</p>
        <table border="1" cellpadding="5">
            <tr>
                <th>Key</th>
                <th>Value</th>
                <th>Type</th>
            </tr>
            <cfoutput query="qSettings">
            <tr>
                <td>#key#</td>
                <td>#HTMLEditFormat(left(value, 50))#<cfif len(value) GT 50>...</cfif></td>
                <td>#type#</td>
            </tr>
            </cfoutput>
        </table>
    <cfcatch>
        <p class="error">✗ Failed to load settings: <cfoutput>#cfcatch.message#</cfoutput></p>
    </cfcatch>
    </cftry>
</div>

<!--- Test 3: Test Save Settings AJAX --->
<div class="test-section">
    <h2>Test 3: Save Settings via AJAX</h2>
    <div id="saveTest"></div>
    <button onclick="testSaveSettings()">Test Save Settings</button>
</div>

<!--- Test 4: Test Image Upload --->
<div class="test-section">
    <h2>Test 4: Image Upload</h2>
    <form id="imageUploadForm" enctype="multipart/form-data">
        <input type="file" name="image" accept="image/*">
        <input type="hidden" name="type" value="logo">
        <button type="button" onclick="testImageUpload()">Test Upload</button>
    </form>
    <div id="uploadResult"></div>
</div>

<!--- Test 5: Check General Settings Page --->
<div class="test-section">
    <h2>Test 5: General Settings Page Access</h2>
    <p>Access the general settings page: <a href="/ghost/admin/settings/general" target="_blank">/ghost/admin/settings/general</a></p>
</div>

<script>
function testSaveSettings() {
    const formData = new FormData();
    formData.append('title', 'Test Blog Title');
    formData.append('description', 'Test blog description');
    formData.append('timezone', 'America/New_York');
    
    fetch('/ghost/admin/ajax/save-settings.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        const result = document.getElementById('saveTest');
        if (data.success) {
            result.innerHTML = '<p class="success">✓ ' + data.message + '</p><pre>' + JSON.stringify(data, null, 2) + '</pre>';
        } else {
            result.innerHTML = '<p class="error">✗ ' + data.message + '</p>';
        }
    })
    .catch(error => {
        document.getElementById('saveTest').innerHTML = '<p class="error">✗ Error: ' + error + '</p>';
    });
}

function testImageUpload() {
    const form = document.getElementById('imageUploadForm');
    const formData = new FormData(form);
    
    fetch('/ghost/admin/ajax/upload-settings-image.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        const result = document.getElementById('uploadResult');
        if (data.success) {
            result.innerHTML = '<p class="success">✓ Upload successful</p><pre>' + JSON.stringify(data, null, 2) + '</pre>';
        } else {
            result.innerHTML = '<p class="error">✗ ' + data.message + '</p>';
        }
    })
    .catch(error => {
        document.getElementById('uploadResult').innerHTML = '<p class="error">✗ Error: ' + error + '</p>';
    });
}
</script>

</body>
</html>