<!--- Test Image Upload --->
<cfoutput>
<h1>Test Upload</h1>

<form id="testUploadForm">
    <input type="file" id="testFile" accept="image/*">
    <button type="button" onclick="testUpload()">Upload Test</button>
</form>

<div id="result"></div>

<script>
function testUpload() {
    const fileInput = document.getElementById('testFile');
    const file = fileInput.files[0];
    
    if (!file) {
        alert('Please select a file');
        return;
    }
    
    const formData = new FormData();
    formData.append('image', file);
    
    fetch('/ghost/admin/ajax/upload-image.cfm', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        console.log('Response status:', response.status);
        console.log('Response headers:', response.headers);
        return response.text();
    })
    .then(text => {
        console.log('Raw response:', text);
        document.getElementById('result').innerHTML = '<pre>' + text + '</pre>';
        
        try {
            const data = JSON.parse(text);
            if (data.success) {
                document.getElementById('result').innerHTML += '<img src="' + data.url + '" style="max-width: 200px; margin-top: 10px;">';
            }
        } catch (e) {
            console.error('JSON parse error:', e);
        }
    })
    .catch(error => {
        console.error('Upload error:', error);
        document.getElementById('result').innerHTML = 'Error: ' + error.message;
    });
}
</script>
</cfoutput>